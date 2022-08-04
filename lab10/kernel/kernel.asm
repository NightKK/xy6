
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	18010113          	addi	sp,sp,384 # 80009180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	16c78793          	addi	a5,a5,364 # 800061d0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffca7ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dbe78793          	addi	a5,a5,-578 # 80000e6c <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	7f0080e7          	jalr	2032(ra) # 8000290e <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	77a080e7          	jalr	1914(ra) # 800008a8 <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7159                	addi	sp,sp,-112
    80000158:	f486                	sd	ra,104(sp)
    8000015a:	f0a2                	sd	s0,96(sp)
    8000015c:	eca6                	sd	s1,88(sp)
    8000015e:	e8ca                	sd	s2,80(sp)
    80000160:	e4ce                	sd	s3,72(sp)
    80000162:	e0d2                	sd	s4,64(sp)
    80000164:	fc56                	sd	s5,56(sp)
    80000166:	f85a                	sd	s6,48(sp)
    80000168:	f45e                	sd	s7,40(sp)
    8000016a:	f062                	sd	s8,32(sp)
    8000016c:	ec66                	sd	s9,24(sp)
    8000016e:	e86a                	sd	s10,16(sp)
    80000170:	1880                	addi	s0,sp,112
    80000172:	8aaa                	mv	s5,a0
    80000174:	8a2e                	mv	s4,a1
    80000176:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000017c:	00011517          	auipc	a0,0x11
    80000180:	00450513          	addi	a0,a0,4 # 80011180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00011497          	auipc	s1,0x11
    80000190:	ff448493          	addi	s1,s1,-12 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00011917          	auipc	s2,0x11
    80000198:	08490913          	addi	s2,s2,132 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000019c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000019e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a0:	4ca9                	li	s9,10
  while(n > 0){
    800001a2:	07305863          	blez	s3,80000212 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71463          	bne	a4,a5,800001d6 <consoleread+0x80>
      if(myproc()->killed){
    800001b2:	00002097          	auipc	ra,0x2
    800001b6:	bf4080e7          	jalr	-1036(ra) # 80001da6 <myproc>
    800001ba:	591c                	lw	a5,48(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	49c080e7          	jalr	1180(ra) # 8000265e <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef700e3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d6:	0017871b          	addiw	a4,a5,1
    800001da:	08e4ac23          	sw	a4,152(s1)
    800001de:	07f7f713          	andi	a4,a5,127
    800001e2:	9726                	add	a4,a4,s1
    800001e4:	01874703          	lbu	a4,24(a4)
    800001e8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001ec:	077d0563          	beq	s10,s7,80000256 <consoleread+0x100>
    cbuf = c;
    800001f0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f4:	4685                	li	a3,1
    800001f6:	f9f40613          	addi	a2,s0,-97
    800001fa:	85d2                	mv	a1,s4
    800001fc:	8556                	mv	a0,s5
    800001fe:	00002097          	auipc	ra,0x2
    80000202:	6ba080e7          	jalr	1722(ra) # 800028b8 <either_copyout>
    80000206:	01850663          	beq	a0,s8,80000212 <consoleread+0xbc>
    dst++;
    8000020a:	0a05                	addi	s4,s4,1
    --n;
    8000020c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000020e:	f99d1ae3          	bne	s10,s9,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000212:	00011517          	auipc	a0,0x11
    80000216:	f6e50513          	addi	a0,a0,-146 # 80011180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	f5850513          	addi	a0,a0,-168 # 80011180 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a46080e7          	jalr	-1466(ra) # 80000c76 <release>
        return -1;
    80000238:	557d                	li	a0,-1
}
    8000023a:	70a6                	ld	ra,104(sp)
    8000023c:	7406                	ld	s0,96(sp)
    8000023e:	64e6                	ld	s1,88(sp)
    80000240:	6946                	ld	s2,80(sp)
    80000242:	69a6                	ld	s3,72(sp)
    80000244:	6a06                	ld	s4,64(sp)
    80000246:	7ae2                	ld	s5,56(sp)
    80000248:	7b42                	ld	s6,48(sp)
    8000024a:	7ba2                	ld	s7,40(sp)
    8000024c:	7c02                	ld	s8,32(sp)
    8000024e:	6ce2                	ld	s9,24(sp)
    80000250:	6d42                	ld	s10,16(sp)
    80000252:	6165                	addi	sp,sp,112
    80000254:	8082                	ret
      if(n < target){
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	fb677ce3          	bgeu	a4,s6,80000212 <consoleread+0xbc>
        cons.r--;
    8000025e:	00011717          	auipc	a4,0x11
    80000262:	faf72d23          	sw	a5,-70(a4) # 80011218 <cons+0x98>
    80000266:	b775                	j	80000212 <consoleread+0xbc>

0000000080000268 <consputc>:
{
    80000268:	1141                	addi	sp,sp,-16
    8000026a:	e406                	sd	ra,8(sp)
    8000026c:	e022                	sd	s0,0(sp)
    8000026e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000270:	10000793          	li	a5,256
    80000274:	00f50a63          	beq	a0,a5,80000288 <consputc+0x20>
    uartputc_sync(c);
    80000278:	00000097          	auipc	ra,0x0
    8000027c:	55e080e7          	jalr	1374(ra) # 800007d6 <uartputc_sync>
}
    80000280:	60a2                	ld	ra,8(sp)
    80000282:	6402                	ld	s0,0(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000288:	4521                	li	a0,8
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	54c080e7          	jalr	1356(ra) # 800007d6 <uartputc_sync>
    80000292:	02000513          	li	a0,32
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	540080e7          	jalr	1344(ra) # 800007d6 <uartputc_sync>
    8000029e:	4521                	li	a0,8
    800002a0:	00000097          	auipc	ra,0x0
    800002a4:	536080e7          	jalr	1334(ra) # 800007d6 <uartputc_sync>
    800002a8:	bfe1                	j	80000280 <consputc+0x18>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	e04a                	sd	s2,0(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00011517          	auipc	a0,0x11
    800002bc:	ec850513          	addi	a0,a0,-312 # 80011180 <cons>
    800002c0:	00001097          	auipc	ra,0x1
    800002c4:	902080e7          	jalr	-1790(ra) # 80000bc2 <acquire>

  switch(c){
    800002c8:	47d5                	li	a5,21
    800002ca:	0af48663          	beq	s1,a5,80000376 <consoleintr+0xcc>
    800002ce:	0297ca63          	blt	a5,s1,80000302 <consoleintr+0x58>
    800002d2:	47a1                	li	a5,8
    800002d4:	0ef48763          	beq	s1,a5,800003c2 <consoleintr+0x118>
    800002d8:	47c1                	li	a5,16
    800002da:	10f49a63          	bne	s1,a5,800003ee <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002de:	00002097          	auipc	ra,0x2
    800002e2:	686080e7          	jalr	1670(ra) # 80002964 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00011517          	auipc	a0,0x11
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80011180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
}
    800002f6:	60e2                	ld	ra,24(sp)
    800002f8:	6442                	ld	s0,16(sp)
    800002fa:	64a2                	ld	s1,8(sp)
    800002fc:	6902                	ld	s2,0(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch(c){
    80000302:	07f00793          	li	a5,127
    80000306:	0af48e63          	beq	s1,a5,800003c2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000030a:	00011717          	auipc	a4,0x11
    8000030e:	e7670713          	addi	a4,a4,-394 # 80011180 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf763e3          	bltu	a4,a5,800002e6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x14a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	00000097          	auipc	ra,0x0
    80000330:	f3c080e7          	jalr	-196(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000334:	00011797          	auipc	a5,0x11
    80000338:	e4c78793          	addi	a5,a5,-436 # 80011180 <cons>
    8000033c:	0a07a703          	lw	a4,160(a5)
    80000340:	0017069b          	addiw	a3,a4,1
    80000344:	0006861b          	sext.w	a2,a3
    80000348:	0ad7a023          	sw	a3,160(a5)
    8000034c:	07f77713          	andi	a4,a4,127
    80000350:	97ba                	add	a5,a5,a4
    80000352:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000356:	47a9                	li	a5,10
    80000358:	0cf48563          	beq	s1,a5,80000422 <consoleintr+0x178>
    8000035c:	4791                	li	a5,4
    8000035e:	0cf48263          	beq	s1,a5,80000422 <consoleintr+0x178>
    80000362:	00011797          	auipc	a5,0x11
    80000366:	eb67a783          	lw	a5,-330(a5) # 80011218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00011717          	auipc	a4,0x11
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80011180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00011497          	auipc	s1,0x11
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80011180 <cons>
    while(cons.e != cons.w &&
    8000038e:	4929                	li	s2,10
    80000390:	f4f70be3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	37fd                	addiw	a5,a5,-1
    80000396:	07f7f713          	andi	a4,a5,127
    8000039a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000039c:	01874703          	lbu	a4,24(a4)
    800003a0:	f52703e3          	beq	a4,s2,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003a4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a8:	10000513          	li	a0,256
    800003ac:	00000097          	auipc	ra,0x0
    800003b0:	ebc080e7          	jalr	-324(ra) # 80000268 <consputc>
    while(cons.e != cons.w &&
    800003b4:	0a04a783          	lw	a5,160(s1)
    800003b8:	09c4a703          	lw	a4,156(s1)
    800003bc:	fcf71ce3          	bne	a4,a5,80000394 <consoleintr+0xea>
    800003c0:	b71d                	j	800002e6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c2:	00011717          	auipc	a4,0x11
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80011180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00011717          	auipc	a4,0x11
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e0:	10000513          	li	a0,256
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	e84080e7          	jalr	-380(ra) # 80000268 <consputc>
    800003ec:	bded                	j	800002e6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003ee:	ee048ce3          	beqz	s1,800002e6 <consoleintr+0x3c>
    800003f2:	bf21                	j	8000030a <consoleintr+0x60>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e72080e7          	jalr	-398(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003fe:	00011797          	auipc	a5,0x11
    80000402:	d8278793          	addi	a5,a5,-638 # 80011180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00011797          	auipc	a5,0x11
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00011517          	auipc	a0,0x11
    8000042e:	dee50513          	addi	a0,a0,-530 # 80011218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	3ac080e7          	jalr	940(ra) # 800027de <wakeup>
    8000043a:	b575                	j	800002e6 <consoleintr+0x3c>

000000008000043c <consoleinit>:

void
consoleinit(void)
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e406                	sd	ra,8(sp)
    80000440:	e022                	sd	s0,0(sp)
    80000442:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000444:	00008597          	auipc	a1,0x8
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80008010 <etext+0x10>
    8000044c:	00011517          	auipc	a0,0x11
    80000450:	d3450513          	addi	a0,a0,-716 # 80011180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	0002f797          	auipc	a5,0x2f
    80000468:	e9c78793          	addi	a5,a5,-356 # 8002f300 <devsw>
    8000046c:	00000717          	auipc	a4,0x0
    80000470:	cea70713          	addi	a4,a4,-790 # 80000156 <consoleread>
    80000474:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000476:	00000717          	auipc	a4,0x0
    8000047a:	c7e70713          	addi	a4,a4,-898 # 800000f4 <consolewrite>
    8000047e:	ef98                	sd	a4,24(a5)
}
    80000480:	60a2                	ld	ra,8(sp)
    80000482:	6402                	ld	s0,0(sp)
    80000484:	0141                	addi	sp,sp,16
    80000486:	8082                	ret

0000000080000488 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000488:	7179                	addi	sp,sp,-48
    8000048a:	f406                	sd	ra,40(sp)
    8000048c:	f022                	sd	s0,32(sp)
    8000048e:	ec26                	sd	s1,24(sp)
    80000490:	e84a                	sd	s2,16(sp)
    80000492:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000494:	c219                	beqz	a2,8000049a <printint+0x12>
    80000496:	08054663          	bltz	a0,80000522 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000049a:	2501                	sext.w	a0,a0
    8000049c:	4881                	li	a7,0
    8000049e:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004a4:	2581                	sext.w	a1,a1
    800004a6:	00008617          	auipc	a2,0x8
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80008040 <digits>
    800004ae:	883a                	mv	a6,a4
    800004b0:	2705                	addiw	a4,a4,1
    800004b2:	02b577bb          	remuw	a5,a0,a1
    800004b6:	1782                	slli	a5,a5,0x20
    800004b8:	9381                	srli	a5,a5,0x20
    800004ba:	97b2                	add	a5,a5,a2
    800004bc:	0007c783          	lbu	a5,0(a5)
    800004c0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004c4:	0005079b          	sext.w	a5,a0
    800004c8:	02b5553b          	divuw	a0,a0,a1
    800004cc:	0685                	addi	a3,a3,1
    800004ce:	feb7f0e3          	bgeu	a5,a1,800004ae <printint+0x26>

  if(sign)
    800004d2:	00088b63          	beqz	a7,800004e8 <printint+0x60>
    buf[i++] = '-';
    800004d6:	fe040793          	addi	a5,s0,-32
    800004da:	973e                	add	a4,a4,a5
    800004dc:	02d00793          	li	a5,45
    800004e0:	fef70823          	sb	a5,-16(a4)
    800004e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004e8:	02e05763          	blez	a4,80000516 <printint+0x8e>
    800004ec:	fd040793          	addi	a5,s0,-48
    800004f0:	00e784b3          	add	s1,a5,a4
    800004f4:	fff78913          	addi	s2,a5,-1
    800004f8:	993a                	add	s2,s2,a4
    800004fa:	377d                	addiw	a4,a4,-1
    800004fc:	1702                	slli	a4,a4,0x20
    800004fe:	9301                	srli	a4,a4,0x20
    80000500:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000504:	fff4c503          	lbu	a0,-1(s1)
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	d60080e7          	jalr	-672(ra) # 80000268 <consputc>
  while(--i >= 0)
    80000510:	14fd                	addi	s1,s1,-1
    80000512:	ff2499e3          	bne	s1,s2,80000504 <printint+0x7c>
}
    80000516:	70a2                	ld	ra,40(sp)
    80000518:	7402                	ld	s0,32(sp)
    8000051a:	64e2                	ld	s1,24(sp)
    8000051c:	6942                	ld	s2,16(sp)
    8000051e:	6145                	addi	sp,sp,48
    80000520:	8082                	ret
    x = -xx;
    80000522:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000526:	4885                	li	a7,1
    x = -xx;
    80000528:	bf9d                	j	8000049e <printint+0x16>

000000008000052a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000052a:	1101                	addi	sp,sp,-32
    8000052c:	ec06                	sd	ra,24(sp)
    8000052e:	e822                	sd	s0,16(sp)
    80000530:	e426                	sd	s1,8(sp)
    80000532:	1000                	addi	s0,sp,32
    80000534:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000536:	00011797          	auipc	a5,0x11
    8000053a:	d007a523          	sw	zero,-758(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000053e:	00008517          	auipc	a0,0x8
    80000542:	ada50513          	addi	a0,a0,-1318 # 80008018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	b7050513          	addi	a0,a0,-1168 # 800080c8 <digits+0x88>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	00009717          	auipc	a4,0x9
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 80009000 <panicked>
  for(;;)
    80000572:	a001                	j	80000572 <panic+0x48>

0000000080000574 <printf>:
{
    80000574:	7131                	addi	sp,sp,-192
    80000576:	fc86                	sd	ra,120(sp)
    80000578:	f8a2                	sd	s0,112(sp)
    8000057a:	f4a6                	sd	s1,104(sp)
    8000057c:	f0ca                	sd	s2,96(sp)
    8000057e:	ecce                	sd	s3,88(sp)
    80000580:	e8d2                	sd	s4,80(sp)
    80000582:	e4d6                	sd	s5,72(sp)
    80000584:	e0da                	sd	s6,64(sp)
    80000586:	fc5e                	sd	s7,56(sp)
    80000588:	f862                	sd	s8,48(sp)
    8000058a:	f466                	sd	s9,40(sp)
    8000058c:	f06a                	sd	s10,32(sp)
    8000058e:	ec6e                	sd	s11,24(sp)
    80000590:	0100                	addi	s0,sp,128
    80000592:	8a2a                	mv	s4,a0
    80000594:	e40c                	sd	a1,8(s0)
    80000596:	e810                	sd	a2,16(s0)
    80000598:	ec14                	sd	a3,24(s0)
    8000059a:	f018                	sd	a4,32(s0)
    8000059c:	f41c                	sd	a5,40(s0)
    8000059e:	03043823          	sd	a6,48(s0)
    800005a2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005a6:	00011d97          	auipc	s11,0x11
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80011240 <pr+0x18>
  if(locking)
    800005ae:	020d9b63          	bnez	s11,800005e4 <printf+0x70>
  if (fmt == 0)
    800005b2:	040a0263          	beqz	s4,800005f6 <printf+0x82>
  va_start(ap, fmt);
    800005b6:	00840793          	addi	a5,s0,8
    800005ba:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005be:	000a4503          	lbu	a0,0(s4)
    800005c2:	14050f63          	beqz	a0,80000720 <printf+0x1ac>
    800005c6:	4981                	li	s3,0
    if(c != '%'){
    800005c8:	02500a93          	li	s5,37
    switch(c){
    800005cc:	07000b93          	li	s7,112
  consputc('x');
    800005d0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d2:	00008b17          	auipc	s6,0x8
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80008040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00011517          	auipc	a0,0x11
    800005e8:	c4450513          	addi	a0,a0,-956 # 80011228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00008517          	auipc	a0,0x8
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80008028 <etext+0x28>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	f2c080e7          	jalr	-212(ra) # 8000052a <panic>
      consputc(c);
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	c62080e7          	jalr	-926(ra) # 80000268 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060e:	2985                	addiw	s3,s3,1
    80000610:	013a07b3          	add	a5,s4,s3
    80000614:	0007c503          	lbu	a0,0(a5)
    80000618:	10050463          	beqz	a0,80000720 <printf+0x1ac>
    if(c != '%'){
    8000061c:	ff5515e3          	bne	a0,s5,80000606 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c783          	lbu	a5,0(a5)
    8000062a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000062e:	cbed                	beqz	a5,80000720 <printf+0x1ac>
    switch(c){
    80000630:	05778a63          	beq	a5,s7,80000684 <printf+0x110>
    80000634:	02fbf663          	bgeu	s7,a5,80000660 <printf+0xec>
    80000638:	09978863          	beq	a5,s9,800006c8 <printf+0x154>
    8000063c:	07800713          	li	a4,120
    80000640:	0ce79563          	bne	a5,a4,8000070a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	85ea                	mv	a1,s10
    80000654:	4388                	lw	a0,0(a5)
    80000656:	00000097          	auipc	ra,0x0
    8000065a:	e32080e7          	jalr	-462(ra) # 80000488 <printint>
      break;
    8000065e:	bf45                	j	8000060e <printf+0x9a>
    switch(c){
    80000660:	09578f63          	beq	a5,s5,800006fe <printf+0x18a>
    80000664:	0b879363          	bne	a5,s8,8000070a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	45a9                	li	a1,10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e0e080e7          	jalr	-498(ra) # 80000488 <printint>
      break;
    80000682:	b771                	j	8000060e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000694:	03000513          	li	a0,48
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	bd0080e7          	jalr	-1072(ra) # 80000268 <consputc>
  consputc('x');
    800006a0:	07800513          	li	a0,120
    800006a4:	00000097          	auipc	ra,0x0
    800006a8:	bc4080e7          	jalr	-1084(ra) # 80000268 <consputc>
    800006ac:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ae:	03c95793          	srli	a5,s2,0x3c
    800006b2:	97da                	add	a5,a5,s6
    800006b4:	0007c503          	lbu	a0,0(a5)
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bb0080e7          	jalr	-1104(ra) # 80000268 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c0:	0912                	slli	s2,s2,0x4
    800006c2:	34fd                	addiw	s1,s1,-1
    800006c4:	f4ed                	bnez	s1,800006ae <printf+0x13a>
    800006c6:	b7a1                	j	8000060e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	6384                	ld	s1,0(a5)
    800006d6:	cc89                	beqz	s1,800006f0 <printf+0x17c>
      for(; *s; s++)
    800006d8:	0004c503          	lbu	a0,0(s1)
    800006dc:	d90d                	beqz	a0,8000060e <printf+0x9a>
        consputc(*s);
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	b8a080e7          	jalr	-1142(ra) # 80000268 <consputc>
      for(; *s; s++)
    800006e6:	0485                	addi	s1,s1,1
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	f96d                	bnez	a0,800006de <printf+0x16a>
    800006ee:	b705                	j	8000060e <printf+0x9a>
        s = "(null)";
    800006f0:	00008497          	auipc	s1,0x8
    800006f4:	93048493          	addi	s1,s1,-1744 # 80008020 <etext+0x20>
      for(; *s; s++)
    800006f8:	02800513          	li	a0,40
    800006fc:	b7cd                	j	800006de <printf+0x16a>
      consputc('%');
    800006fe:	8556                	mv	a0,s5
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b68080e7          	jalr	-1176(ra) # 80000268 <consputc>
      break;
    80000708:	b719                	j	8000060e <printf+0x9a>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b5c080e7          	jalr	-1188(ra) # 80000268 <consputc>
      consputc(c);
    80000714:	8526                	mv	a0,s1
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b52080e7          	jalr	-1198(ra) # 80000268 <consputc>
      break;
    8000071e:	bdc5                	j	8000060e <printf+0x9a>
  if(locking)
    80000720:	020d9163          	bnez	s11,80000742 <printf+0x1ce>
}
    80000724:	70e6                	ld	ra,120(sp)
    80000726:	7446                	ld	s0,112(sp)
    80000728:	74a6                	ld	s1,104(sp)
    8000072a:	7906                	ld	s2,96(sp)
    8000072c:	69e6                	ld	s3,88(sp)
    8000072e:	6a46                	ld	s4,80(sp)
    80000730:	6aa6                	ld	s5,72(sp)
    80000732:	6b06                	ld	s6,64(sp)
    80000734:	7be2                	ld	s7,56(sp)
    80000736:	7c42                	ld	s8,48(sp)
    80000738:	7ca2                	ld	s9,40(sp)
    8000073a:	7d02                	ld	s10,32(sp)
    8000073c:	6de2                	ld	s11,24(sp)
    8000073e:	6129                	addi	sp,sp,192
    80000740:	8082                	ret
    release(&pr.lock);
    80000742:	00011517          	auipc	a0,0x11
    80000746:	ae650513          	addi	a0,a0,-1306 # 80011228 <pr>
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	52c080e7          	jalr	1324(ra) # 80000c76 <release>
}
    80000752:	bfc9                	j	80000724 <printf+0x1b0>

0000000080000754 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000754:	1101                	addi	sp,sp,-32
    80000756:	ec06                	sd	ra,24(sp)
    80000758:	e822                	sd	s0,16(sp)
    8000075a:	e426                	sd	s1,8(sp)
    8000075c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000075e:	00011497          	auipc	s1,0x11
    80000762:	aca48493          	addi	s1,s1,-1334 # 80011228 <pr>
    80000766:	00008597          	auipc	a1,0x8
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80008038 <etext+0x38>
    8000076e:	8526                	mv	a0,s1
    80000770:	00000097          	auipc	ra,0x0
    80000774:	3c2080e7          	jalr	962(ra) # 80000b32 <initlock>
  pr.locking = 1;
    80000778:	4785                	li	a5,1
    8000077a:	cc9c                	sw	a5,24(s1)
}
    8000077c:	60e2                	ld	ra,24(sp)
    8000077e:	6442                	ld	s0,16(sp)
    80000780:	64a2                	ld	s1,8(sp)
    80000782:	6105                	addi	sp,sp,32
    80000784:	8082                	ret

0000000080000786 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000786:	1141                	addi	sp,sp,-16
    80000788:	e406                	sd	ra,8(sp)
    8000078a:	e022                	sd	s0,0(sp)
    8000078c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000078e:	100007b7          	lui	a5,0x10000
    80000792:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000796:	f8000713          	li	a4,-128
    8000079a:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000079e:	470d                	li	a4,3
    800007a0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007a4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007a8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ac:	469d                	li	a3,7
    800007ae:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007b2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007b6:	00008597          	auipc	a1,0x8
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80008058 <digits+0x18>
    800007be:	00011517          	auipc	a0,0x11
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80011248 <uart_tx_lock>
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	36c080e7          	jalr	876(ra) # 80000b32 <initlock>
}
    800007ce:	60a2                	ld	ra,8(sp)
    800007d0:	6402                	ld	s0,0(sp)
    800007d2:	0141                	addi	sp,sp,16
    800007d4:	8082                	ret

00000000800007d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007d6:	1101                	addi	sp,sp,-32
    800007d8:	ec06                	sd	ra,24(sp)
    800007da:	e822                	sd	s0,16(sp)
    800007dc:	e426                	sd	s1,8(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  push_off();
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	394080e7          	jalr	916(ra) # 80000b76 <push_off>

  if(panicked){
    800007ea:	00009797          	auipc	a5,0x9
    800007ee:	8167a783          	lw	a5,-2026(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800007f6:	c391                	beqz	a5,800007fa <uartputc_sync+0x24>
    for(;;)
    800007f8:	a001                	j	800007f8 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fa:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007fe:	0207f793          	andi	a5,a5,32
    80000802:	dfe5                	beqz	a5,800007fa <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000804:	0ff4f513          	andi	a0,s1,255
    80000808:	100007b7          	lui	a5,0x10000
    8000080c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000810:	00000097          	auipc	ra,0x0
    80000814:	406080e7          	jalr	1030(ra) # 80000c16 <pop_off>
}
    80000818:	60e2                	ld	ra,24(sp)
    8000081a:	6442                	ld	s0,16(sp)
    8000081c:	64a2                	ld	s1,8(sp)
    8000081e:	6105                	addi	sp,sp,32
    80000820:	8082                	ret

0000000080000822 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000822:	00008797          	auipc	a5,0x8
    80000826:	7e67b783          	ld	a5,2022(a5) # 80009008 <uart_tx_r>
    8000082a:	00008717          	auipc	a4,0x8
    8000082e:	7e673703          	ld	a4,2022(a4) # 80009010 <uart_tx_w>
    80000832:	06f70a63          	beq	a4,a5,800008a6 <uartstart+0x84>
{
    80000836:	7139                	addi	sp,sp,-64
    80000838:	fc06                	sd	ra,56(sp)
    8000083a:	f822                	sd	s0,48(sp)
    8000083c:	f426                	sd	s1,40(sp)
    8000083e:	f04a                	sd	s2,32(sp)
    80000840:	ec4e                	sd	s3,24(sp)
    80000842:	e852                	sd	s4,16(sp)
    80000844:	e456                	sd	s5,8(sp)
    80000846:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000848:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000084c:	00011a17          	auipc	s4,0x11
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00008497          	auipc	s1,0x8
    80000858:	7b448493          	addi	s1,s1,1972 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00008997          	auipc	s3,0x8
    80000860:	7b498993          	addi	s3,s3,1972 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000868:	02077713          	andi	a4,a4,32
    8000086c:	c705                	beqz	a4,80000894 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086e:	01f7f713          	andi	a4,a5,31
    80000872:	9752                	add	a4,a4,s4
    80000874:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000878:	0785                	addi	a5,a5,1
    8000087a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000087c:	8526                	mv	a0,s1
    8000087e:	00002097          	auipc	ra,0x2
    80000882:	f60080e7          	jalr	-160(ra) # 800027de <wakeup>
    
    WriteReg(THR, c);
    80000886:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000088a:	609c                	ld	a5,0(s1)
    8000088c:	0009b703          	ld	a4,0(s3)
    80000890:	fcf71ae3          	bne	a4,a5,80000864 <uartstart+0x42>
  }
}
    80000894:	70e2                	ld	ra,56(sp)
    80000896:	7442                	ld	s0,48(sp)
    80000898:	74a2                	ld	s1,40(sp)
    8000089a:	7902                	ld	s2,32(sp)
    8000089c:	69e2                	ld	s3,24(sp)
    8000089e:	6a42                	ld	s4,16(sp)
    800008a0:	6aa2                	ld	s5,8(sp)
    800008a2:	6121                	addi	sp,sp,64
    800008a4:	8082                	ret
    800008a6:	8082                	ret

00000000800008a8 <uartputc>:
{
    800008a8:	7179                	addi	sp,sp,-48
    800008aa:	f406                	sd	ra,40(sp)
    800008ac:	f022                	sd	s0,32(sp)
    800008ae:	ec26                	sd	s1,24(sp)
    800008b0:	e84a                	sd	s2,16(sp)
    800008b2:	e44e                	sd	s3,8(sp)
    800008b4:	e052                	sd	s4,0(sp)
    800008b6:	1800                	addi	s0,sp,48
    800008b8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ba:	00011517          	auipc	a0,0x11
    800008be:	98e50513          	addi	a0,a0,-1650 # 80011248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	00008797          	auipc	a5,0x8
    800008ce:	7367a783          	lw	a5,1846(a5) # 80009000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00008717          	auipc	a4,0x8
    800008da:	73a73703          	ld	a4,1850(a4) # 80009010 <uart_tx_w>
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	72a7b783          	ld	a5,1834(a5) # 80009008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00011997          	auipc	s3,0x11
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80011248 <uart_tx_lock>
    800008f6:	00008497          	auipc	s1,0x8
    800008fa:	71248493          	addi	s1,s1,1810 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00008917          	auipc	s2,0x8
    80000902:	71290913          	addi	s2,s2,1810 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	d54080e7          	jalr	-684(ra) # 8000265e <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00011497          	auipc	s1,0x11
    80000924:	92848493          	addi	s1,s1,-1752 # 80011248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00008797          	auipc	a5,0x8
    80000938:	6ce7be23          	sd	a4,1756(a5) # 80009010 <uart_tx_w>
      uartstart();
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	ee6080e7          	jalr	-282(ra) # 80000822 <uartstart>
      release(&uart_tx_lock);
    80000944:	8526                	mv	a0,s1
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	330080e7          	jalr	816(ra) # 80000c76 <release>
}
    8000094e:	70a2                	ld	ra,40(sp)
    80000950:	7402                	ld	s0,32(sp)
    80000952:	64e2                	ld	s1,24(sp)
    80000954:	6942                	ld	s2,16(sp)
    80000956:	69a2                	ld	s3,8(sp)
    80000958:	6a02                	ld	s4,0(sp)
    8000095a:	6145                	addi	sp,sp,48
    8000095c:	8082                	ret

000000008000095e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000095e:	1141                	addi	sp,sp,-16
    80000960:	e422                	sd	s0,8(sp)
    80000962:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000964:	100007b7          	lui	a5,0x10000
    80000968:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000096c:	8b85                	andi	a5,a5,1
    8000096e:	cb91                	beqz	a5,80000982 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000970:	100007b7          	lui	a5,0x10000
    80000974:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000978:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000097c:	6422                	ld	s0,8(sp)
    8000097e:	0141                	addi	sp,sp,16
    80000980:	8082                	ret
    return -1;
    80000982:	557d                	li	a0,-1
    80000984:	bfe5                	j	8000097c <uartgetc+0x1e>

0000000080000986 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000986:	1101                	addi	sp,sp,-32
    80000988:	ec06                	sd	ra,24(sp)
    8000098a:	e822                	sd	s0,16(sp)
    8000098c:	e426                	sd	s1,8(sp)
    8000098e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000990:	54fd                	li	s1,-1
    80000992:	a029                	j	8000099c <uartintr+0x16>
      break;
    consoleintr(c);
    80000994:	00000097          	auipc	ra,0x0
    80000998:	916080e7          	jalr	-1770(ra) # 800002aa <consoleintr>
    int c = uartgetc();
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	fc2080e7          	jalr	-62(ra) # 8000095e <uartgetc>
    if(c == -1)
    800009a4:	fe9518e3          	bne	a0,s1,80000994 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009a8:	00011497          	auipc	s1,0x11
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80011248 <uart_tx_lock>
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	210080e7          	jalr	528(ra) # 80000bc2 <acquire>
  uartstart();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	e68080e7          	jalr	-408(ra) # 80000822 <uartstart>
  release(&uart_tx_lock);
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret

00000000800009d6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	e04a                	sd	s2,0(sp)
    800009e0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	ebb9                	bnez	a5,80000a3c <kfree+0x66>
    800009e8:	84aa                	mv	s1,a0
    800009ea:	00033797          	auipc	a5,0x33
    800009ee:	61678793          	addi	a5,a5,1558 # 80034000 <end>
    800009f2:	04f56563          	bltu	a0,a5,80000a3c <kfree+0x66>
    800009f6:	47c5                	li	a5,17
    800009f8:	07ee                	slli	a5,a5,0x1b
    800009fa:	04f57163          	bgeu	a0,a5,80000a3c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4585                	li	a1,1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	2bc080e7          	jalr	700(ra) # 80000cbe <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0a:	00011917          	auipc	s2,0x11
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80011280 <kmem>
    80000a12:	854a                	mv	a0,s2
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1ae080e7          	jalr	430(ra) # 80000bc2 <acquire>
  r->next = kmem.freelist;
    80000a1c:	01893783          	ld	a5,24(s2)
    80000a20:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a22:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	24e080e7          	jalr	590(ra) # 80000c76 <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree");
    80000a3c:	00007517          	auipc	a0,0x7
    80000a40:	62450513          	addi	a0,a0,1572 # 80008060 <digits+0x20>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	ae6080e7          	jalr	-1306(ra) # 8000052a <panic>

0000000080000a4c <freerange>:
{
    80000a4c:	7179                	addi	sp,sp,-48
    80000a4e:	f406                	sd	ra,40(sp)
    80000a50:	f022                	sd	s0,32(sp)
    80000a52:	ec26                	sd	s1,24(sp)
    80000a54:	e84a                	sd	s2,16(sp)
    80000a56:	e44e                	sd	s3,8(sp)
    80000a58:	e052                	sd	s4,0(sp)
    80000a5a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a5c:	6785                	lui	a5,0x1
    80000a5e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a62:	94aa                	add	s1,s1,a0
    80000a64:	757d                	lui	a0,0xfffff
    80000a66:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a68:	94be                	add	s1,s1,a5
    80000a6a:	0095ee63          	bltu	a1,s1,80000a86 <freerange+0x3a>
    80000a6e:	892e                	mv	s2,a1
    kfree(p);
    80000a70:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a72:	6985                	lui	s3,0x1
    kfree(p);
    80000a74:	01448533          	add	a0,s1,s4
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	f5e080e7          	jalr	-162(ra) # 800009d6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe9979e3          	bgeu	s2,s1,80000a74 <freerange+0x28>
}
    80000a86:	70a2                	ld	ra,40(sp)
    80000a88:	7402                	ld	s0,32(sp)
    80000a8a:	64e2                	ld	s1,24(sp)
    80000a8c:	6942                	ld	s2,16(sp)
    80000a8e:	69a2                	ld	s3,8(sp)
    80000a90:	6a02                	ld	s4,0(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00007597          	auipc	a1,0x7
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80008068 <digits+0x28>
    80000aa6:	00010517          	auipc	a0,0x10
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80011280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	00033517          	auipc	a0,0x33
    80000abe:	54650513          	addi	a0,a0,1350 # 80034000 <end>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f8a080e7          	jalr	-118(ra) # 80000a4c <freerange>
}
    80000aca:	60a2                	ld	ra,8(sp)
    80000acc:	6402                	ld	s0,0(sp)
    80000ace:	0141                	addi	sp,sp,16
    80000ad0:	8082                	ret

0000000080000ad2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000adc:	00010497          	auipc	s1,0x10
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80011280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00010517          	auipc	a0,0x10
    80000af8:	78c50513          	addi	a0,a0,1932 # 80011280 <kmem>
    80000afc:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	178080e7          	jalr	376(ra) # 80000c76 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b06:	6605                	lui	a2,0x1
    80000b08:	4595                	li	a1,5
    80000b0a:	8526                	mv	a0,s1
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	1b2080e7          	jalr	434(ra) # 80000cbe <memset>
  return (void*)r;
}
    80000b14:	8526                	mv	a0,s1
    80000b16:	60e2                	ld	ra,24(sp)
    80000b18:	6442                	ld	s0,16(sp)
    80000b1a:	64a2                	ld	s1,8(sp)
    80000b1c:	6105                	addi	sp,sp,32
    80000b1e:	8082                	ret
  release(&kmem.lock);
    80000b20:	00010517          	auipc	a0,0x10
    80000b24:	76050513          	addi	a0,a0,1888 # 80011280 <kmem>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
  if(r)
    80000b30:	b7d5                	j	80000b14 <kalloc+0x42>

0000000080000b32 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b32:	1141                	addi	sp,sp,-16
    80000b34:	e422                	sd	s0,8(sp)
    80000b36:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b38:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b3a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b3e:	00053823          	sd	zero,16(a0)
}
    80000b42:	6422                	ld	s0,8(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b48:	411c                	lw	a5,0(a0)
    80000b4a:	e399                	bnez	a5,80000b50 <holding+0x8>
    80000b4c:	4501                	li	a0,0
  return r;
}
    80000b4e:	8082                	ret
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b5a:	6904                	ld	s1,16(a0)
    80000b5c:	00001097          	auipc	ra,0x1
    80000b60:	22e080e7          	jalr	558(ra) # 80001d8a <mycpu>
    80000b64:	40a48533          	sub	a0,s1,a0
    80000b68:	00153513          	seqz	a0,a0
}
    80000b6c:	60e2                	ld	ra,24(sp)
    80000b6e:	6442                	ld	s0,16(sp)
    80000b70:	64a2                	ld	s1,8(sp)
    80000b72:	6105                	addi	sp,sp,32
    80000b74:	8082                	ret

0000000080000b76 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b80:	100024f3          	csrr	s1,sstatus
    80000b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b8a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b8e:	00001097          	auipc	ra,0x1
    80000b92:	1fc080e7          	jalr	508(ra) # 80001d8a <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	1f0080e7          	jalr	496(ra) # 80001d8a <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	2785                	addiw	a5,a5,1
    80000ba6:	dd3c                	sw	a5,120(a0)
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    mycpu()->intena = old;
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	1d8080e7          	jalr	472(ra) # 80001d8a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bba:	8085                	srli	s1,s1,0x1
    80000bbc:	8885                	andi	s1,s1,1
    80000bbe:	dd64                	sw	s1,124(a0)
    80000bc0:	bfe9                	j	80000b9a <push_off+0x24>

0000000080000bc2 <acquire>:
{
    80000bc2:	1101                	addi	sp,sp,-32
    80000bc4:	ec06                	sd	ra,24(sp)
    80000bc6:	e822                	sd	s0,16(sp)
    80000bc8:	e426                	sd	s1,8(sp)
    80000bca:	1000                	addi	s0,sp,32
    80000bcc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	fa8080e7          	jalr	-88(ra) # 80000b76 <push_off>
  if(holding(lk))
    80000bd6:	8526                	mv	a0,s1
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f70080e7          	jalr	-144(ra) # 80000b48 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be0:	4705                	li	a4,1
  if(holding(lk))
    80000be2:	e115                	bnez	a0,80000c06 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	87ba                	mv	a5,a4
    80000be6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bea:	2781                	sext.w	a5,a5
    80000bec:	ffe5                	bnez	a5,80000be4 <acquire+0x22>
  __sync_synchronize();
    80000bee:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	198080e7          	jalr	408(ra) # 80001d8a <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00007517          	auipc	a0,0x7
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80008070 <digits+0x30>
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	91c080e7          	jalr	-1764(ra) # 8000052a <panic>

0000000080000c16 <pop_off>:

void
pop_off(void)
{
    80000c16:	1141                	addi	sp,sp,-16
    80000c18:	e406                	sd	ra,8(sp)
    80000c1a:	e022                	sd	s0,0(sp)
    80000c1c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	16c080e7          	jalr	364(ra) # 80001d8a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c2a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c2c:	e78d                	bnez	a5,80000c56 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	02f05b63          	blez	a5,80000c66 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c34:	37fd                	addiw	a5,a5,-1
    80000c36:	0007871b          	sext.w	a4,a5
    80000c3a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c3c:	eb09                	bnez	a4,80000c4e <pop_off+0x38>
    80000c3e:	5d7c                	lw	a5,124(a0)
    80000c40:	c799                	beqz	a5,80000c4e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c46:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c4a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c4e:	60a2                	ld	ra,8(sp)
    80000c50:	6402                	ld	s0,0(sp)
    80000c52:	0141                	addi	sp,sp,16
    80000c54:	8082                	ret
    panic("pop_off - interruptible");
    80000c56:	00007517          	auipc	a0,0x7
    80000c5a:	42250513          	addi	a0,a0,1058 # 80008078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80008090 <digits+0x50>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8bc080e7          	jalr	-1860(ra) # 8000052a <panic>

0000000080000c76 <release>:
{
    80000c76:	1101                	addi	sp,sp,-32
    80000c78:	ec06                	sd	ra,24(sp)
    80000c7a:	e822                	sd	s0,16(sp)
    80000c7c:	e426                	sd	s1,8(sp)
    80000c7e:	1000                	addi	s0,sp,32
    80000c80:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	ec6080e7          	jalr	-314(ra) # 80000b48 <holding>
    80000c8a:	c115                	beqz	a0,80000cae <release+0x38>
  lk->cpu = 0;
    80000c8c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c90:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c94:	0f50000f          	fence	iorw,ow
    80000c98:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	f7a080e7          	jalr	-134(ra) # 80000c16 <pop_off>
}
    80000ca4:	60e2                	ld	ra,24(sp)
    80000ca6:	6442                	ld	s0,16(sp)
    80000ca8:	64a2                	ld	s1,8(sp)
    80000caa:	6105                	addi	sp,sp,32
    80000cac:	8082                	ret
    panic("release");
    80000cae:	00007517          	auipc	a0,0x7
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80008098 <digits+0x58>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>

0000000080000cbe <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cbe:	1141                	addi	sp,sp,-16
    80000cc0:	e422                	sd	s0,8(sp)
    80000cc2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cc4:	ca19                	beqz	a2,80000cda <memset+0x1c>
    80000cc6:	87aa                	mv	a5,a0
    80000cc8:	1602                	slli	a2,a2,0x20
    80000cca:	9201                	srli	a2,a2,0x20
    80000ccc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cd0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cd4:	0785                	addi	a5,a5,1
    80000cd6:	fee79de3          	bne	a5,a4,80000cd0 <memset+0x12>
  }
  return dst;
}
    80000cda:	6422                	ld	s0,8(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret

0000000080000ce0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ce6:	ca05                	beqz	a2,80000d16 <memcmp+0x36>
    80000ce8:	fff6069b          	addiw	a3,a2,-1
    80000cec:	1682                	slli	a3,a3,0x20
    80000cee:	9281                	srli	a3,a3,0x20
    80000cf0:	0685                	addi	a3,a3,1
    80000cf2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cf4:	00054783          	lbu	a5,0(a0)
    80000cf8:	0005c703          	lbu	a4,0(a1)
    80000cfc:	00e79863          	bne	a5,a4,80000d0c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d00:	0505                	addi	a0,a0,1
    80000d02:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d04:	fed518e3          	bne	a0,a3,80000cf4 <memcmp+0x14>
  }

  return 0;
    80000d08:	4501                	li	a0,0
    80000d0a:	a019                	j	80000d10 <memcmp+0x30>
      return *s1 - *s2;
    80000d0c:	40e7853b          	subw	a0,a5,a4
}
    80000d10:	6422                	ld	s0,8(sp)
    80000d12:	0141                	addi	sp,sp,16
    80000d14:	8082                	ret
  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	bfe5                	j	80000d10 <memcmp+0x30>

0000000080000d1a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d1a:	1141                	addi	sp,sp,-16
    80000d1c:	e422                	sd	s0,8(sp)
    80000d1e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d20:	02a5e563          	bltu	a1,a0,80000d4a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	ce11                	beqz	a2,80000d44 <memmove+0x2a>
    80000d2a:	1682                	slli	a3,a3,0x20
    80000d2c:	9281                	srli	a3,a3,0x20
    80000d2e:	0685                	addi	a3,a3,1
    80000d30:	96ae                	add	a3,a3,a1
    80000d32:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d34:	0585                	addi	a1,a1,1
    80000d36:	0785                	addi	a5,a5,1
    80000d38:	fff5c703          	lbu	a4,-1(a1)
    80000d3c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d40:	fed59ae3          	bne	a1,a3,80000d34 <memmove+0x1a>

  return dst;
}
    80000d44:	6422                	ld	s0,8(sp)
    80000d46:	0141                	addi	sp,sp,16
    80000d48:	8082                	ret
  if(s < d && s + n > d){
    80000d4a:	02061713          	slli	a4,a2,0x20
    80000d4e:	9301                	srli	a4,a4,0x20
    80000d50:	00e587b3          	add	a5,a1,a4
    80000d54:	fcf578e3          	bgeu	a0,a5,80000d24 <memmove+0xa>
    d += n;
    80000d58:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d5a:	fff6069b          	addiw	a3,a2,-1
    80000d5e:	d27d                	beqz	a2,80000d44 <memmove+0x2a>
    80000d60:	02069613          	slli	a2,a3,0x20
    80000d64:	9201                	srli	a2,a2,0x20
    80000d66:	fff64613          	not	a2,a2
    80000d6a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d6c:	17fd                	addi	a5,a5,-1
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	0007c683          	lbu	a3,0(a5)
    80000d74:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d78:	fef61ae3          	bne	a2,a5,80000d6c <memmove+0x52>
    80000d7c:	b7e1                	j	80000d44 <memmove+0x2a>

0000000080000d7e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d7e:	1141                	addi	sp,sp,-16
    80000d80:	e406                	sd	ra,8(sp)
    80000d82:	e022                	sd	s0,0(sp)
    80000d84:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f94080e7          	jalr	-108(ra) # 80000d1a <memmove>
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9c:	ce11                	beqz	a2,80000db8 <strncmp+0x22>
    80000d9e:	00054783          	lbu	a5,0(a0)
    80000da2:	cf89                	beqz	a5,80000dbc <strncmp+0x26>
    80000da4:	0005c703          	lbu	a4,0(a1)
    80000da8:	00f71a63          	bne	a4,a5,80000dbc <strncmp+0x26>
    n--, p++, q++;
    80000dac:	367d                	addiw	a2,a2,-1
    80000dae:	0505                	addi	a0,a0,1
    80000db0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db2:	f675                	bnez	a2,80000d9e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db4:	4501                	li	a0,0
    80000db6:	a809                	j	80000dc8 <strncmp+0x32>
    80000db8:	4501                	li	a0,0
    80000dba:	a039                	j	80000dc8 <strncmp+0x32>
  if(n == 0)
    80000dbc:	ca09                	beqz	a2,80000dce <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dbe:	00054503          	lbu	a0,0(a0)
    80000dc2:	0005c783          	lbu	a5,0(a1)
    80000dc6:	9d1d                	subw	a0,a0,a5
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	bfe5                	j	80000dc8 <strncmp+0x32>

0000000080000dd2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd8:	872a                	mv	a4,a0
    80000dda:	8832                	mv	a6,a2
    80000ddc:	367d                	addiw	a2,a2,-1
    80000dde:	01005963          	blez	a6,80000df0 <strncpy+0x1e>
    80000de2:	0705                	addi	a4,a4,1
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	fef70fa3          	sb	a5,-1(a4)
    80000dec:	0585                	addi	a1,a1,1
    80000dee:	f7f5                	bnez	a5,80000dda <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df0:	86ba                	mv	a3,a4
    80000df2:	00c05c63          	blez	a2,80000e0a <strncpy+0x38>
    *s++ = 0;
    80000df6:	0685                	addi	a3,a3,1
    80000df8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000dfc:	fff6c793          	not	a5,a3
    80000e00:	9fb9                	addw	a5,a5,a4
    80000e02:	010787bb          	addw	a5,a5,a6
    80000e06:	fef048e3          	bgtz	a5,80000df6 <strncpy+0x24>
  return os;
}
    80000e0a:	6422                	ld	s0,8(sp)
    80000e0c:	0141                	addi	sp,sp,16
    80000e0e:	8082                	ret

0000000080000e10 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e10:	1141                	addi	sp,sp,-16
    80000e12:	e422                	sd	s0,8(sp)
    80000e14:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e16:	02c05363          	blez	a2,80000e3c <safestrcpy+0x2c>
    80000e1a:	fff6069b          	addiw	a3,a2,-1
    80000e1e:	1682                	slli	a3,a3,0x20
    80000e20:	9281                	srli	a3,a3,0x20
    80000e22:	96ae                	add	a3,a3,a1
    80000e24:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e26:	00d58963          	beq	a1,a3,80000e38 <safestrcpy+0x28>
    80000e2a:	0585                	addi	a1,a1,1
    80000e2c:	0785                	addi	a5,a5,1
    80000e2e:	fff5c703          	lbu	a4,-1(a1)
    80000e32:	fee78fa3          	sb	a4,-1(a5)
    80000e36:	fb65                	bnez	a4,80000e26 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e38:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e3c:	6422                	ld	s0,8(sp)
    80000e3e:	0141                	addi	sp,sp,16
    80000e40:	8082                	ret

0000000080000e42 <strlen>:

int
strlen(const char *s)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e422                	sd	s0,8(sp)
    80000e46:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	cf91                	beqz	a5,80000e68 <strlen+0x26>
    80000e4e:	0505                	addi	a0,a0,1
    80000e50:	87aa                	mv	a5,a0
    80000e52:	4685                	li	a3,1
    80000e54:	9e89                	subw	a3,a3,a0
    80000e56:	00f6853b          	addw	a0,a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	fb7d                	bnez	a4,80000e56 <strlen+0x14>
    ;
  return n;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e68:	4501                	li	a0,0
    80000e6a:	bfe5                	j	80000e62 <strlen+0x20>

0000000080000e6c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e406                	sd	ra,8(sp)
    80000e70:	e022                	sd	s0,0(sp)
    80000e72:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e74:	00001097          	auipc	ra,0x1
    80000e78:	f06080e7          	jalr	-250(ra) # 80001d7a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00008717          	auipc	a4,0x8
    80000e80:	19c70713          	addi	a4,a4,412 # 80009018 <started>
  if(cpuid() == 0){
    80000e84:	c139                	beqz	a0,80000eca <main+0x5e>
    while(started == 0)
    80000e86:	431c                	lw	a5,0(a4)
    80000e88:	2781                	sext.w	a5,a5
    80000e8a:	dff5                	beqz	a5,80000e86 <main+0x1a>
      ;
    __sync_synchronize();
    80000e8c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	eea080e7          	jalr	-278(ra) # 80001d7a <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00007517          	auipc	a0,0x7
    80000e9e:	21e50513          	addi	a0,a0,542 # 800080b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0d8080e7          	jalr	216(ra) # 80000f82 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	bf2080e7          	jalr	-1038(ra) # 80002aa4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	356080e7          	jalr	854(ra) # 80006210 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	494080e7          	jalr	1172(ra) # 80002356 <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00007517          	auipc	a0,0x7
    80000ede:	1ee50513          	addi	a0,a0,494 # 800080c8 <digits+0x88>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1b650513          	addi	a0,a0,438 # 800080a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	1ce50513          	addi	a0,a0,462 # 800080c8 <digits+0x88>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	334080e7          	jalr	820(ra) # 80001246 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	dc0080e7          	jalr	-576(ra) # 80001ce2 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	b52080e7          	jalr	-1198(ra) # 80002a7c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	b72080e7          	jalr	-1166(ra) # 80002aa4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	2c0080e7          	jalr	704(ra) # 800061fa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	2ce080e7          	jalr	718(ra) # 80006210 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	2f4080e7          	jalr	756(ra) # 8000323e <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	984080e7          	jalr	-1660(ra) # 800038d6 <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	936080e7          	jalr	-1738(ra) # 80004890 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	3d0080e7          	jalr	976(ra) # 80006332 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	106080e7          	jalr	262(ra) # 80002070 <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00008717          	auipc	a4,0x8
    80000f7c:	0af72023          	sw	a5,160(a4) # 80009018 <started>
    80000f80:	b789                	j	80000ec2 <main+0x56>

0000000080000f82 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f88:	00008797          	auipc	a5,0x8
    80000f8c:	0987b783          	ld	a5,152(a5) # 80009020 <kernel_pagetable>
    80000f90:	83b1                	srli	a5,a5,0xc
    80000f92:	577d                	li	a4,-1
    80000f94:	177e                	slli	a4,a4,0x3f
    80000f96:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f98:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa0:	6422                	ld	s0,8(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret

0000000080000fa6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fa6:	7139                	addi	sp,sp,-64
    80000fa8:	fc06                	sd	ra,56(sp)
    80000faa:	f822                	sd	s0,48(sp)
    80000fac:	f426                	sd	s1,40(sp)
    80000fae:	f04a                	sd	s2,32(sp)
    80000fb0:	ec4e                	sd	s3,24(sp)
    80000fb2:	e852                	sd	s4,16(sp)
    80000fb4:	e456                	sd	s5,8(sp)
    80000fb6:	e05a                	sd	s6,0(sp)
    80000fb8:	0080                	addi	s0,sp,64
    80000fba:	84aa                	mv	s1,a0
    80000fbc:	89ae                	mv	s3,a1
    80000fbe:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fc6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fc8:	04b7f263          	bgeu	a5,a1,8000100c <walk+0x66>
    panic("walk");
    80000fcc:	00007517          	auipc	a0,0x7
    80000fd0:	10450513          	addi	a0,a0,260 # 800080d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fdc:	060a8663          	beqz	s5,80001048 <walk+0xa2>
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	af2080e7          	jalr	-1294(ra) # 80000ad2 <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	c529                	beqz	a0,80001034 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	cce080e7          	jalr	-818(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ff8:	00c4d793          	srli	a5,s1,0xc
    80000ffc:	07aa                	slli	a5,a5,0xa
    80000ffe:	0017e793          	ori	a5,a5,1
    80001002:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	036a0063          	beq	s4,s6,80001028 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100c:	0149d933          	srl	s2,s3,s4
    80001010:	1ff97913          	andi	s2,s2,511
    80001014:	090e                	slli	s2,s2,0x3
    80001016:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001018:	00093483          	ld	s1,0(s2)
    8000101c:	0014f793          	andi	a5,s1,1
    80001020:	dfd5                	beqz	a5,80000fdc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001022:	80a9                	srli	s1,s1,0xa
    80001024:	04b2                	slli	s1,s1,0xc
    80001026:	b7c5                	j	80001006 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001028:	00c9d513          	srli	a0,s3,0xc
    8000102c:	1ff57513          	andi	a0,a0,511
    80001030:	050e                	slli	a0,a0,0x3
    80001032:	9526                	add	a0,a0,s1
}
    80001034:	70e2                	ld	ra,56(sp)
    80001036:	7442                	ld	s0,48(sp)
    80001038:	74a2                	ld	s1,40(sp)
    8000103a:	7902                	ld	s2,32(sp)
    8000103c:	69e2                	ld	s3,24(sp)
    8000103e:	6a42                	ld	s4,16(sp)
    80001040:	6aa2                	ld	s5,8(sp)
    80001042:	6b02                	ld	s6,0(sp)
    80001044:	6121                	addi	sp,sp,64
    80001046:	8082                	ret
        return 0;
    80001048:	4501                	li	a0,0
    8000104a:	b7ed                	j	80001034 <walk+0x8e>

000000008000104c <vm_exists>:

// Whether the virtual address is mapped.
int
vm_exists(pagetable_t pagetable, uint64 va)
{
    8000104c:	1141                	addi	sp,sp,-16
    8000104e:	e406                	sd	ra,8(sp)
    80001050:	e022                	sd	s0,0(sp)
    80001052:	0800                	addi	s0,sp,16
  pte_t *pte;
  return (pte = walk(pagetable, va, 0)) != 0 && (*pte & PTE_V) != 0;
    80001054:	4601                	li	a2,0
    80001056:	00000097          	auipc	ra,0x0
    8000105a:	f50080e7          	jalr	-176(ra) # 80000fa6 <walk>
    8000105e:	c519                	beqz	a0,8000106c <vm_exists+0x20>
    80001060:	6108                	ld	a0,0(a0)
    80001062:	8905                	andi	a0,a0,1
}
    80001064:	60a2                	ld	ra,8(sp)
    80001066:	6402                	ld	s0,0(sp)
    80001068:	0141                	addi	sp,sp,16
    8000106a:	8082                	ret
  return (pte = walk(pagetable, va, 0)) != 0 && (*pte & PTE_V) != 0;
    8000106c:	4501                	li	a0,0
    8000106e:	bfdd                	j	80001064 <vm_exists+0x18>

0000000080001070 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001070:	57fd                	li	a5,-1
    80001072:	83e9                	srli	a5,a5,0x1a
    80001074:	00b7f463          	bgeu	a5,a1,8000107c <walkaddr+0xc>
    return 0;
    80001078:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000107a:	8082                	ret
{
    8000107c:	1141                	addi	sp,sp,-16
    8000107e:	e406                	sd	ra,8(sp)
    80001080:	e022                	sd	s0,0(sp)
    80001082:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001084:	4601                	li	a2,0
    80001086:	00000097          	auipc	ra,0x0
    8000108a:	f20080e7          	jalr	-224(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000108e:	c105                	beqz	a0,800010ae <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001090:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001092:	0117f693          	andi	a3,a5,17
    80001096:	4745                	li	a4,17
    return 0;
    80001098:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000109a:	00e68663          	beq	a3,a4,800010a6 <walkaddr+0x36>
}
    8000109e:	60a2                	ld	ra,8(sp)
    800010a0:	6402                	ld	s0,0(sp)
    800010a2:	0141                	addi	sp,sp,16
    800010a4:	8082                	ret
  pa = PTE2PA(*pte);
    800010a6:	00a7d513          	srli	a0,a5,0xa
    800010aa:	0532                	slli	a0,a0,0xc
  return pa;
    800010ac:	bfcd                	j	8000109e <walkaddr+0x2e>
    return 0;
    800010ae:	4501                	li	a0,0
    800010b0:	b7fd                	j	8000109e <walkaddr+0x2e>

00000000800010b2 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010b2:	715d                	addi	sp,sp,-80
    800010b4:	e486                	sd	ra,72(sp)
    800010b6:	e0a2                	sd	s0,64(sp)
    800010b8:	fc26                	sd	s1,56(sp)
    800010ba:	f84a                	sd	s2,48(sp)
    800010bc:	f44e                	sd	s3,40(sp)
    800010be:	f052                	sd	s4,32(sp)
    800010c0:	ec56                	sd	s5,24(sp)
    800010c2:	e85a                	sd	s6,16(sp)
    800010c4:	e45e                	sd	s7,8(sp)
    800010c6:	0880                	addi	s0,sp,80
    800010c8:	8aaa                	mv	s5,a0
    800010ca:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010cc:	777d                	lui	a4,0xfffff
    800010ce:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010d2:	167d                	addi	a2,a2,-1
    800010d4:	00b609b3          	add	s3,a2,a1
    800010d8:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010dc:	893e                	mv	s2,a5
    800010de:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e2:	6b85                	lui	s7,0x1
    800010e4:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010e8:	4605                	li	a2,1
    800010ea:	85ca                	mv	a1,s2
    800010ec:	8556                	mv	a0,s5
    800010ee:	00000097          	auipc	ra,0x0
    800010f2:	eb8080e7          	jalr	-328(ra) # 80000fa6 <walk>
    800010f6:	c51d                	beqz	a0,80001124 <mappages+0x72>
    if(*pte & PTE_V)
    800010f8:	611c                	ld	a5,0(a0)
    800010fa:	8b85                	andi	a5,a5,1
    800010fc:	ef81                	bnez	a5,80001114 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010fe:	80b1                	srli	s1,s1,0xc
    80001100:	04aa                	slli	s1,s1,0xa
    80001102:	0164e4b3          	or	s1,s1,s6
    80001106:	0014e493          	ori	s1,s1,1
    8000110a:	e104                	sd	s1,0(a0)
    if(a == last)
    8000110c:	03390863          	beq	s2,s3,8000113c <mappages+0x8a>
    a += PGSIZE;
    80001110:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001112:	bfc9                	j	800010e4 <mappages+0x32>
      panic("remap");
    80001114:	00007517          	auipc	a0,0x7
    80001118:	fc450513          	addi	a0,a0,-60 # 800080d8 <digits+0x98>
    8000111c:	fffff097          	auipc	ra,0xfffff
    80001120:	40e080e7          	jalr	1038(ra) # 8000052a <panic>
      return -1;
    80001124:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001126:	60a6                	ld	ra,72(sp)
    80001128:	6406                	ld	s0,64(sp)
    8000112a:	74e2                	ld	s1,56(sp)
    8000112c:	7942                	ld	s2,48(sp)
    8000112e:	79a2                	ld	s3,40(sp)
    80001130:	7a02                	ld	s4,32(sp)
    80001132:	6ae2                	ld	s5,24(sp)
    80001134:	6b42                	ld	s6,16(sp)
    80001136:	6ba2                	ld	s7,8(sp)
    80001138:	6161                	addi	sp,sp,80
    8000113a:	8082                	ret
  return 0;
    8000113c:	4501                	li	a0,0
    8000113e:	b7e5                	j	80001126 <mappages+0x74>

0000000080001140 <kvmmap>:
{
    80001140:	1141                	addi	sp,sp,-16
    80001142:	e406                	sd	ra,8(sp)
    80001144:	e022                	sd	s0,0(sp)
    80001146:	0800                	addi	s0,sp,16
    80001148:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000114a:	86b2                	mv	a3,a2
    8000114c:	863e                	mv	a2,a5
    8000114e:	00000097          	auipc	ra,0x0
    80001152:	f64080e7          	jalr	-156(ra) # 800010b2 <mappages>
    80001156:	e509                	bnez	a0,80001160 <kvmmap+0x20>
}
    80001158:	60a2                	ld	ra,8(sp)
    8000115a:	6402                	ld	s0,0(sp)
    8000115c:	0141                	addi	sp,sp,16
    8000115e:	8082                	ret
    panic("kvmmap");
    80001160:	00007517          	auipc	a0,0x7
    80001164:	f8050513          	addi	a0,a0,-128 # 800080e0 <digits+0xa0>
    80001168:	fffff097          	auipc	ra,0xfffff
    8000116c:	3c2080e7          	jalr	962(ra) # 8000052a <panic>

0000000080001170 <kvmmake>:
{
    80001170:	1101                	addi	sp,sp,-32
    80001172:	ec06                	sd	ra,24(sp)
    80001174:	e822                	sd	s0,16(sp)
    80001176:	e426                	sd	s1,8(sp)
    80001178:	e04a                	sd	s2,0(sp)
    8000117a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	956080e7          	jalr	-1706(ra) # 80000ad2 <kalloc>
    80001184:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001186:	6605                	lui	a2,0x1
    80001188:	4581                	li	a1,0
    8000118a:	00000097          	auipc	ra,0x0
    8000118e:	b34080e7          	jalr	-1228(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001192:	4719                	li	a4,6
    80001194:	6685                	lui	a3,0x1
    80001196:	10000637          	lui	a2,0x10000
    8000119a:	100005b7          	lui	a1,0x10000
    8000119e:	8526                	mv	a0,s1
    800011a0:	00000097          	auipc	ra,0x0
    800011a4:	fa0080e7          	jalr	-96(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a8:	4719                	li	a4,6
    800011aa:	6685                	lui	a3,0x1
    800011ac:	10001637          	lui	a2,0x10001
    800011b0:	100015b7          	lui	a1,0x10001
    800011b4:	8526                	mv	a0,s1
    800011b6:	00000097          	auipc	ra,0x0
    800011ba:	f8a080e7          	jalr	-118(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011be:	4719                	li	a4,6
    800011c0:	004006b7          	lui	a3,0x400
    800011c4:	0c000637          	lui	a2,0xc000
    800011c8:	0c0005b7          	lui	a1,0xc000
    800011cc:	8526                	mv	a0,s1
    800011ce:	00000097          	auipc	ra,0x0
    800011d2:	f72080e7          	jalr	-142(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d6:	00007917          	auipc	s2,0x7
    800011da:	e2a90913          	addi	s2,s2,-470 # 80008000 <etext>
    800011de:	4729                	li	a4,10
    800011e0:	80007697          	auipc	a3,0x80007
    800011e4:	e2068693          	addi	a3,a3,-480 # 8000 <_entry-0x7fff8000>
    800011e8:	4605                	li	a2,1
    800011ea:	067e                	slli	a2,a2,0x1f
    800011ec:	85b2                	mv	a1,a2
    800011ee:	8526                	mv	a0,s1
    800011f0:	00000097          	auipc	ra,0x0
    800011f4:	f50080e7          	jalr	-176(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f8:	4719                	li	a4,6
    800011fa:	46c5                	li	a3,17
    800011fc:	06ee                	slli	a3,a3,0x1b
    800011fe:	412686b3          	sub	a3,a3,s2
    80001202:	864a                	mv	a2,s2
    80001204:	85ca                	mv	a1,s2
    80001206:	8526                	mv	a0,s1
    80001208:	00000097          	auipc	ra,0x0
    8000120c:	f38080e7          	jalr	-200(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001210:	4729                	li	a4,10
    80001212:	6685                	lui	a3,0x1
    80001214:	00006617          	auipc	a2,0x6
    80001218:	dec60613          	addi	a2,a2,-532 # 80007000 <_trampoline>
    8000121c:	040005b7          	lui	a1,0x4000
    80001220:	15fd                	addi	a1,a1,-1
    80001222:	05b2                	slli	a1,a1,0xc
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f1a080e7          	jalr	-230(ra) # 80001140 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122e:	8526                	mv	a0,s1
    80001230:	00001097          	auipc	ra,0x1
    80001234:	a1c080e7          	jalr	-1508(ra) # 80001c4c <proc_mapstacks>
}
    80001238:	8526                	mv	a0,s1
    8000123a:	60e2                	ld	ra,24(sp)
    8000123c:	6442                	ld	s0,16(sp)
    8000123e:	64a2                	ld	s1,8(sp)
    80001240:	6902                	ld	s2,0(sp)
    80001242:	6105                	addi	sp,sp,32
    80001244:	8082                	ret

0000000080001246 <kvminit>:
{
    80001246:	1141                	addi	sp,sp,-16
    80001248:	e406                	sd	ra,8(sp)
    8000124a:	e022                	sd	s0,0(sp)
    8000124c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124e:	00000097          	auipc	ra,0x0
    80001252:	f22080e7          	jalr	-222(ra) # 80001170 <kvmmake>
    80001256:	00008797          	auipc	a5,0x8
    8000125a:	dca7b523          	sd	a0,-566(a5) # 80009020 <kernel_pagetable>
}
    8000125e:	60a2                	ld	ra,8(sp)
    80001260:	6402                	ld	s0,0(sp)
    80001262:	0141                	addi	sp,sp,16
    80001264:	8082                	ret

0000000080001266 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001266:	715d                	addi	sp,sp,-80
    80001268:	e486                	sd	ra,72(sp)
    8000126a:	e0a2                	sd	s0,64(sp)
    8000126c:	fc26                	sd	s1,56(sp)
    8000126e:	f84a                	sd	s2,48(sp)
    80001270:	f44e                	sd	s3,40(sp)
    80001272:	f052                	sd	s4,32(sp)
    80001274:	ec56                	sd	s5,24(sp)
    80001276:	e85a                	sd	s6,16(sp)
    80001278:	e45e                	sd	s7,8(sp)
    8000127a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127c:	03459793          	slli	a5,a1,0x34
    80001280:	e795                	bnez	a5,800012ac <uvmunmap+0x46>
    80001282:	8a2a                	mv	s4,a0
    80001284:	892e                	mv	s2,a1
    80001286:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	0632                	slli	a2,a2,0xc
    8000128a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001290:	6b05                	lui	s6,0x1
    80001292:	0735e263          	bltu	a1,s3,800012f6 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001296:	60a6                	ld	ra,72(sp)
    80001298:	6406                	ld	s0,64(sp)
    8000129a:	74e2                	ld	s1,56(sp)
    8000129c:	7942                	ld	s2,48(sp)
    8000129e:	79a2                	ld	s3,40(sp)
    800012a0:	7a02                	ld	s4,32(sp)
    800012a2:	6ae2                	ld	s5,24(sp)
    800012a4:	6b42                	ld	s6,16(sp)
    800012a6:	6ba2                	ld	s7,8(sp)
    800012a8:	6161                	addi	sp,sp,80
    800012aa:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ac:	00007517          	auipc	a0,0x7
    800012b0:	e3c50513          	addi	a0,a0,-452 # 800080e8 <digits+0xa8>
    800012b4:	fffff097          	auipc	ra,0xfffff
    800012b8:	276080e7          	jalr	630(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    800012bc:	00007517          	auipc	a0,0x7
    800012c0:	e4450513          	addi	a0,a0,-444 # 80008100 <digits+0xc0>
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	266080e7          	jalr	614(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012cc:	00007517          	auipc	a0,0x7
    800012d0:	e4450513          	addi	a0,a0,-444 # 80008110 <digits+0xd0>
    800012d4:	fffff097          	auipc	ra,0xfffff
    800012d8:	256080e7          	jalr	598(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012dc:	00007517          	auipc	a0,0x7
    800012e0:	e4c50513          	addi	a0,a0,-436 # 80008128 <digits+0xe8>
    800012e4:	fffff097          	auipc	ra,0xfffff
    800012e8:	246080e7          	jalr	582(ra) # 8000052a <panic>
    *pte = 0;
    800012ec:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f0:	995a                	add	s2,s2,s6
    800012f2:	fb3972e3          	bgeu	s2,s3,80001296 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f6:	4601                	li	a2,0
    800012f8:	85ca                	mv	a1,s2
    800012fa:	8552                	mv	a0,s4
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	caa080e7          	jalr	-854(ra) # 80000fa6 <walk>
    80001304:	84aa                	mv	s1,a0
    80001306:	d95d                	beqz	a0,800012bc <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001308:	6108                	ld	a0,0(a0)
    8000130a:	00157793          	andi	a5,a0,1
    8000130e:	dfdd                	beqz	a5,800012cc <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001310:	3ff57793          	andi	a5,a0,1023
    80001314:	fd7784e3          	beq	a5,s7,800012dc <uvmunmap+0x76>
    if(do_free){
    80001318:	fc0a8ae3          	beqz	s5,800012ec <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131e:	0532                	slli	a0,a0,0xc
    80001320:	fffff097          	auipc	ra,0xfffff
    80001324:	6b6080e7          	jalr	1718(ra) # 800009d6 <kfree>
    80001328:	b7d1                	j	800012ec <uvmunmap+0x86>

000000008000132a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000132a:	1101                	addi	sp,sp,-32
    8000132c:	ec06                	sd	ra,24(sp)
    8000132e:	e822                	sd	s0,16(sp)
    80001330:	e426                	sd	s1,8(sp)
    80001332:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001334:	fffff097          	auipc	ra,0xfffff
    80001338:	79e080e7          	jalr	1950(ra) # 80000ad2 <kalloc>
    8000133c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133e:	c519                	beqz	a0,8000134c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001340:	6605                	lui	a2,0x1
    80001342:	4581                	li	a1,0
    80001344:	00000097          	auipc	ra,0x0
    80001348:	97a080e7          	jalr	-1670(ra) # 80000cbe <memset>
  return pagetable;
}
    8000134c:	8526                	mv	a0,s1
    8000134e:	60e2                	ld	ra,24(sp)
    80001350:	6442                	ld	s0,16(sp)
    80001352:	64a2                	ld	s1,8(sp)
    80001354:	6105                	addi	sp,sp,32
    80001356:	8082                	ret

0000000080001358 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001358:	7179                	addi	sp,sp,-48
    8000135a:	f406                	sd	ra,40(sp)
    8000135c:	f022                	sd	s0,32(sp)
    8000135e:	ec26                	sd	s1,24(sp)
    80001360:	e84a                	sd	s2,16(sp)
    80001362:	e44e                	sd	s3,8(sp)
    80001364:	e052                	sd	s4,0(sp)
    80001366:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001368:	6785                	lui	a5,0x1
    8000136a:	04f67863          	bgeu	a2,a5,800013ba <uvminit+0x62>
    8000136e:	8a2a                	mv	s4,a0
    80001370:	89ae                	mv	s3,a1
    80001372:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001374:	fffff097          	auipc	ra,0xfffff
    80001378:	75e080e7          	jalr	1886(ra) # 80000ad2 <kalloc>
    8000137c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137e:	6605                	lui	a2,0x1
    80001380:	4581                	li	a1,0
    80001382:	00000097          	auipc	ra,0x0
    80001386:	93c080e7          	jalr	-1732(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000138a:	4779                	li	a4,30
    8000138c:	86ca                	mv	a3,s2
    8000138e:	6605                	lui	a2,0x1
    80001390:	4581                	li	a1,0
    80001392:	8552                	mv	a0,s4
    80001394:	00000097          	auipc	ra,0x0
    80001398:	d1e080e7          	jalr	-738(ra) # 800010b2 <mappages>
  memmove(mem, src, sz);
    8000139c:	8626                	mv	a2,s1
    8000139e:	85ce                	mv	a1,s3
    800013a0:	854a                	mv	a0,s2
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	978080e7          	jalr	-1672(ra) # 80000d1a <memmove>
}
    800013aa:	70a2                	ld	ra,40(sp)
    800013ac:	7402                	ld	s0,32(sp)
    800013ae:	64e2                	ld	s1,24(sp)
    800013b0:	6942                	ld	s2,16(sp)
    800013b2:	69a2                	ld	s3,8(sp)
    800013b4:	6a02                	ld	s4,0(sp)
    800013b6:	6145                	addi	sp,sp,48
    800013b8:	8082                	ret
    panic("inituvm: more than a page");
    800013ba:	00007517          	auipc	a0,0x7
    800013be:	d8650513          	addi	a0,a0,-634 # 80008140 <digits+0x100>
    800013c2:	fffff097          	auipc	ra,0xfffff
    800013c6:	168080e7          	jalr	360(ra) # 8000052a <panic>

00000000800013ca <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013ca:	1101                	addi	sp,sp,-32
    800013cc:	ec06                	sd	ra,24(sp)
    800013ce:	e822                	sd	s0,16(sp)
    800013d0:	e426                	sd	s1,8(sp)
    800013d2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d6:	00b67d63          	bgeu	a2,a1,800013f0 <uvmdealloc+0x26>
    800013da:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013dc:	6785                	lui	a5,0x1
    800013de:	17fd                	addi	a5,a5,-1
    800013e0:	00f60733          	add	a4,a2,a5
    800013e4:	767d                	lui	a2,0xfffff
    800013e6:	8f71                	and	a4,a4,a2
    800013e8:	97ae                	add	a5,a5,a1
    800013ea:	8ff1                	and	a5,a5,a2
    800013ec:	00f76863          	bltu	a4,a5,800013fc <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013f0:	8526                	mv	a0,s1
    800013f2:	60e2                	ld	ra,24(sp)
    800013f4:	6442                	ld	s0,16(sp)
    800013f6:	64a2                	ld	s1,8(sp)
    800013f8:	6105                	addi	sp,sp,32
    800013fa:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fc:	8f99                	sub	a5,a5,a4
    800013fe:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001400:	4685                	li	a3,1
    80001402:	0007861b          	sext.w	a2,a5
    80001406:	85ba                	mv	a1,a4
    80001408:	00000097          	auipc	ra,0x0
    8000140c:	e5e080e7          	jalr	-418(ra) # 80001266 <uvmunmap>
    80001410:	b7c5                	j	800013f0 <uvmdealloc+0x26>

0000000080001412 <uvmalloc>:
  if(newsz < oldsz)
    80001412:	0ab66163          	bltu	a2,a1,800014b4 <uvmalloc+0xa2>
{
    80001416:	7139                	addi	sp,sp,-64
    80001418:	fc06                	sd	ra,56(sp)
    8000141a:	f822                	sd	s0,48(sp)
    8000141c:	f426                	sd	s1,40(sp)
    8000141e:	f04a                	sd	s2,32(sp)
    80001420:	ec4e                	sd	s3,24(sp)
    80001422:	e852                	sd	s4,16(sp)
    80001424:	e456                	sd	s5,8(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f063          	bgeu	s3,a2,800014b8 <uvmalloc+0xa6>
    8000143c:	894e                	mv	s2,s3
    mem = kalloc();
    8000143e:	fffff097          	auipc	ra,0xfffff
    80001442:	694080e7          	jalr	1684(ra) # 80000ad2 <kalloc>
    80001446:	84aa                	mv	s1,a0
    if(mem == 0){
    80001448:	c51d                	beqz	a0,80001476 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000144a:	6605                	lui	a2,0x1
    8000144c:	4581                	li	a1,0
    8000144e:	00000097          	auipc	ra,0x0
    80001452:	870080e7          	jalr	-1936(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001456:	4779                	li	a4,30
    80001458:	86a6                	mv	a3,s1
    8000145a:	6605                	lui	a2,0x1
    8000145c:	85ca                	mv	a1,s2
    8000145e:	8556                	mv	a0,s5
    80001460:	00000097          	auipc	ra,0x0
    80001464:	c52080e7          	jalr	-942(ra) # 800010b2 <mappages>
    80001468:	e905                	bnez	a0,80001498 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146a:	6785                	lui	a5,0x1
    8000146c:	993e                	add	s2,s2,a5
    8000146e:	fd4968e3          	bltu	s2,s4,8000143e <uvmalloc+0x2c>
  return newsz;
    80001472:	8552                	mv	a0,s4
    80001474:	a809                	j	80001486 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001476:	864e                	mv	a2,s3
    80001478:	85ca                	mv	a1,s2
    8000147a:	8556                	mv	a0,s5
    8000147c:	00000097          	auipc	ra,0x0
    80001480:	f4e080e7          	jalr	-178(ra) # 800013ca <uvmdealloc>
      return 0;
    80001484:	4501                	li	a0,0
}
    80001486:	70e2                	ld	ra,56(sp)
    80001488:	7442                	ld	s0,48(sp)
    8000148a:	74a2                	ld	s1,40(sp)
    8000148c:	7902                	ld	s2,32(sp)
    8000148e:	69e2                	ld	s3,24(sp)
    80001490:	6a42                	ld	s4,16(sp)
    80001492:	6aa2                	ld	s5,8(sp)
    80001494:	6121                	addi	sp,sp,64
    80001496:	8082                	ret
      kfree(mem);
    80001498:	8526                	mv	a0,s1
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	53c080e7          	jalr	1340(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a2:	864e                	mv	a2,s3
    800014a4:	85ca                	mv	a1,s2
    800014a6:	8556                	mv	a0,s5
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	f22080e7          	jalr	-222(ra) # 800013ca <uvmdealloc>
      return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	bfd1                	j	80001486 <uvmalloc+0x74>
    return oldsz;
    800014b4:	852e                	mv	a0,a1
}
    800014b6:	8082                	ret
  return newsz;
    800014b8:	8532                	mv	a0,a2
    800014ba:	b7f1                	j	80001486 <uvmalloc+0x74>

00000000800014bc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014bc:	7179                	addi	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	addi	s0,sp,48
    800014cc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ce:	84aa                	mv	s1,a0
    800014d0:	6905                	lui	s2,0x1
    800014d2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	4985                	li	s3,1
    800014d6:	a821                	j	800014ee <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014da:	0532                	slli	a0,a0,0xc
    800014dc:	00000097          	auipc	ra,0x0
    800014e0:	fe0080e7          	jalr	-32(ra) # 800014bc <freewalk>
      pagetable[i] = 0;
    800014e4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014e8:	04a1                	addi	s1,s1,8
    800014ea:	03248163          	beq	s1,s2,8000150c <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014ee:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f0:	00f57793          	andi	a5,a0,15
    800014f4:	ff3782e3          	beq	a5,s3,800014d8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014f8:	8905                	andi	a0,a0,1
    800014fa:	d57d                	beqz	a0,800014e8 <freewalk+0x2c>
      panic("freewalk: leaf");
    800014fc:	00007517          	auipc	a0,0x7
    80001500:	c6450513          	addi	a0,a0,-924 # 80008160 <digits+0x120>
    80001504:	fffff097          	auipc	ra,0xfffff
    80001508:	026080e7          	jalr	38(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    8000150c:	8552                	mv	a0,s4
    8000150e:	fffff097          	auipc	ra,0xfffff
    80001512:	4c8080e7          	jalr	1224(ra) # 800009d6 <kfree>
}
    80001516:	70a2                	ld	ra,40(sp)
    80001518:	7402                	ld	s0,32(sp)
    8000151a:	64e2                	ld	s1,24(sp)
    8000151c:	6942                	ld	s2,16(sp)
    8000151e:	69a2                	ld	s3,8(sp)
    80001520:	6a02                	ld	s4,0(sp)
    80001522:	6145                	addi	sp,sp,48
    80001524:	8082                	ret

0000000080001526 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001526:	1101                	addi	sp,sp,-32
    80001528:	ec06                	sd	ra,24(sp)
    8000152a:	e822                	sd	s0,16(sp)
    8000152c:	e426                	sd	s1,8(sp)
    8000152e:	1000                	addi	s0,sp,32
    80001530:	84aa                	mv	s1,a0
  if(sz > 0)
    80001532:	e999                	bnez	a1,80001548 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001534:	8526                	mv	a0,s1
    80001536:	00000097          	auipc	ra,0x0
    8000153a:	f86080e7          	jalr	-122(ra) # 800014bc <freewalk>
}
    8000153e:	60e2                	ld	ra,24(sp)
    80001540:	6442                	ld	s0,16(sp)
    80001542:	64a2                	ld	s1,8(sp)
    80001544:	6105                	addi	sp,sp,32
    80001546:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001548:	6605                	lui	a2,0x1
    8000154a:	167d                	addi	a2,a2,-1
    8000154c:	962e                	add	a2,a2,a1
    8000154e:	4685                	li	a3,1
    80001550:	8231                	srli	a2,a2,0xc
    80001552:	4581                	li	a1,0
    80001554:	00000097          	auipc	ra,0x0
    80001558:	d12080e7          	jalr	-750(ra) # 80001266 <uvmunmap>
    8000155c:	bfe1                	j	80001534 <uvmfree+0xe>

000000008000155e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000155e:	c679                	beqz	a2,8000162c <uvmcopy+0xce>
{
    80001560:	715d                	addi	sp,sp,-80
    80001562:	e486                	sd	ra,72(sp)
    80001564:	e0a2                	sd	s0,64(sp)
    80001566:	fc26                	sd	s1,56(sp)
    80001568:	f84a                	sd	s2,48(sp)
    8000156a:	f44e                	sd	s3,40(sp)
    8000156c:	f052                	sd	s4,32(sp)
    8000156e:	ec56                	sd	s5,24(sp)
    80001570:	e85a                	sd	s6,16(sp)
    80001572:	e45e                	sd	s7,8(sp)
    80001574:	0880                	addi	s0,sp,80
    80001576:	8b2a                	mv	s6,a0
    80001578:	8aae                	mv	s5,a1
    8000157a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000157c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000157e:	4601                	li	a2,0
    80001580:	85ce                	mv	a1,s3
    80001582:	855a                	mv	a0,s6
    80001584:	00000097          	auipc	ra,0x0
    80001588:	a22080e7          	jalr	-1502(ra) # 80000fa6 <walk>
    8000158c:	c531                	beqz	a0,800015d8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000158e:	6118                	ld	a4,0(a0)
    80001590:	00177793          	andi	a5,a4,1
    80001594:	cbb1                	beqz	a5,800015e8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001596:	00a75593          	srli	a1,a4,0xa
    8000159a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000159e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a2:	fffff097          	auipc	ra,0xfffff
    800015a6:	530080e7          	jalr	1328(ra) # 80000ad2 <kalloc>
    800015aa:	892a                	mv	s2,a0
    800015ac:	c939                	beqz	a0,80001602 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	85de                	mv	a1,s7
    800015b2:	fffff097          	auipc	ra,0xfffff
    800015b6:	768080e7          	jalr	1896(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ba:	8726                	mv	a4,s1
    800015bc:	86ca                	mv	a3,s2
    800015be:	6605                	lui	a2,0x1
    800015c0:	85ce                	mv	a1,s3
    800015c2:	8556                	mv	a0,s5
    800015c4:	00000097          	auipc	ra,0x0
    800015c8:	aee080e7          	jalr	-1298(ra) # 800010b2 <mappages>
    800015cc:	e515                	bnez	a0,800015f8 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015ce:	6785                	lui	a5,0x1
    800015d0:	99be                	add	s3,s3,a5
    800015d2:	fb49e6e3          	bltu	s3,s4,8000157e <uvmcopy+0x20>
    800015d6:	a081                	j	80001616 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015d8:	00007517          	auipc	a0,0x7
    800015dc:	b9850513          	addi	a0,a0,-1128 # 80008170 <digits+0x130>
    800015e0:	fffff097          	auipc	ra,0xfffff
    800015e4:	f4a080e7          	jalr	-182(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    800015e8:	00007517          	auipc	a0,0x7
    800015ec:	ba850513          	addi	a0,a0,-1112 # 80008190 <digits+0x150>
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	f3a080e7          	jalr	-198(ra) # 8000052a <panic>
      kfree(mem);
    800015f8:	854a                	mv	a0,s2
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	3dc080e7          	jalr	988(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001602:	4685                	li	a3,1
    80001604:	00c9d613          	srli	a2,s3,0xc
    80001608:	4581                	li	a1,0
    8000160a:	8556                	mv	a0,s5
    8000160c:	00000097          	auipc	ra,0x0
    80001610:	c5a080e7          	jalr	-934(ra) # 80001266 <uvmunmap>
  return -1;
    80001614:	557d                	li	a0,-1
}
    80001616:	60a6                	ld	ra,72(sp)
    80001618:	6406                	ld	s0,64(sp)
    8000161a:	74e2                	ld	s1,56(sp)
    8000161c:	7942                	ld	s2,48(sp)
    8000161e:	79a2                	ld	s3,40(sp)
    80001620:	7a02                	ld	s4,32(sp)
    80001622:	6ae2                	ld	s5,24(sp)
    80001624:	6b42                	ld	s6,16(sp)
    80001626:	6ba2                	ld	s7,8(sp)
    80001628:	6161                	addi	sp,sp,80
    8000162a:	8082                	ret
  return 0;
    8000162c:	4501                	li	a0,0
}
    8000162e:	8082                	ret

0000000080001630 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001630:	1141                	addi	sp,sp,-16
    80001632:	e406                	sd	ra,8(sp)
    80001634:	e022                	sd	s0,0(sp)
    80001636:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001638:	4601                	li	a2,0
    8000163a:	00000097          	auipc	ra,0x0
    8000163e:	96c080e7          	jalr	-1684(ra) # 80000fa6 <walk>
  if(pte == 0)
    80001642:	c901                	beqz	a0,80001652 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001644:	611c                	ld	a5,0(a0)
    80001646:	9bbd                	andi	a5,a5,-17
    80001648:	e11c                	sd	a5,0(a0)
}
    8000164a:	60a2                	ld	ra,8(sp)
    8000164c:	6402                	ld	s0,0(sp)
    8000164e:	0141                	addi	sp,sp,16
    80001650:	8082                	ret
    panic("uvmclear");
    80001652:	00007517          	auipc	a0,0x7
    80001656:	b5e50513          	addi	a0,a0,-1186 # 800081b0 <digits+0x170>
    8000165a:	fffff097          	auipc	ra,0xfffff
    8000165e:	ed0080e7          	jalr	-304(ra) # 8000052a <panic>

0000000080001662 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001662:	c6bd                	beqz	a3,800016d0 <copyout+0x6e>
{
    80001664:	715d                	addi	sp,sp,-80
    80001666:	e486                	sd	ra,72(sp)
    80001668:	e0a2                	sd	s0,64(sp)
    8000166a:	fc26                	sd	s1,56(sp)
    8000166c:	f84a                	sd	s2,48(sp)
    8000166e:	f44e                	sd	s3,40(sp)
    80001670:	f052                	sd	s4,32(sp)
    80001672:	ec56                	sd	s5,24(sp)
    80001674:	e85a                	sd	s6,16(sp)
    80001676:	e45e                	sd	s7,8(sp)
    80001678:	e062                	sd	s8,0(sp)
    8000167a:	0880                	addi	s0,sp,80
    8000167c:	8b2a                	mv	s6,a0
    8000167e:	8c2e                	mv	s8,a1
    80001680:	8a32                	mv	s4,a2
    80001682:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001684:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001686:	6a85                	lui	s5,0x1
    80001688:	a015                	j	800016ac <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168a:	9562                	add	a0,a0,s8
    8000168c:	0004861b          	sext.w	a2,s1
    80001690:	85d2                	mv	a1,s4
    80001692:	41250533          	sub	a0,a0,s2
    80001696:	fffff097          	auipc	ra,0xfffff
    8000169a:	684080e7          	jalr	1668(ra) # 80000d1a <memmove>

    len -= n;
    8000169e:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016a8:	02098263          	beqz	s3,800016cc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ac:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b0:	85ca                	mv	a1,s2
    800016b2:	855a                	mv	a0,s6
    800016b4:	00000097          	auipc	ra,0x0
    800016b8:	9bc080e7          	jalr	-1604(ra) # 80001070 <walkaddr>
    if(pa0 == 0)
    800016bc:	cd01                	beqz	a0,800016d4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016be:	418904b3          	sub	s1,s2,s8
    800016c2:	94d6                	add	s1,s1,s5
    if(n > len)
    800016c4:	fc99f3e3          	bgeu	s3,s1,8000168a <copyout+0x28>
    800016c8:	84ce                	mv	s1,s3
    800016ca:	b7c1                	j	8000168a <copyout+0x28>
  }
  return 0;
    800016cc:	4501                	li	a0,0
    800016ce:	a021                	j	800016d6 <copyout+0x74>
    800016d0:	4501                	li	a0,0
}
    800016d2:	8082                	ret
      return -1;
    800016d4:	557d                	li	a0,-1
}
    800016d6:	60a6                	ld	ra,72(sp)
    800016d8:	6406                	ld	s0,64(sp)
    800016da:	74e2                	ld	s1,56(sp)
    800016dc:	7942                	ld	s2,48(sp)
    800016de:	79a2                	ld	s3,40(sp)
    800016e0:	7a02                	ld	s4,32(sp)
    800016e2:	6ae2                	ld	s5,24(sp)
    800016e4:	6b42                	ld	s6,16(sp)
    800016e6:	6ba2                	ld	s7,8(sp)
    800016e8:	6c02                	ld	s8,0(sp)
    800016ea:	6161                	addi	sp,sp,80
    800016ec:	8082                	ret

00000000800016ee <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ee:	caa5                	beqz	a3,8000175e <copyin+0x70>
{
    800016f0:	715d                	addi	sp,sp,-80
    800016f2:	e486                	sd	ra,72(sp)
    800016f4:	e0a2                	sd	s0,64(sp)
    800016f6:	fc26                	sd	s1,56(sp)
    800016f8:	f84a                	sd	s2,48(sp)
    800016fa:	f44e                	sd	s3,40(sp)
    800016fc:	f052                	sd	s4,32(sp)
    800016fe:	ec56                	sd	s5,24(sp)
    80001700:	e85a                	sd	s6,16(sp)
    80001702:	e45e                	sd	s7,8(sp)
    80001704:	e062                	sd	s8,0(sp)
    80001706:	0880                	addi	s0,sp,80
    80001708:	8b2a                	mv	s6,a0
    8000170a:	8a2e                	mv	s4,a1
    8000170c:	8c32                	mv	s8,a2
    8000170e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001710:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001712:	6a85                	lui	s5,0x1
    80001714:	a01d                	j	8000173a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001716:	018505b3          	add	a1,a0,s8
    8000171a:	0004861b          	sext.w	a2,s1
    8000171e:	412585b3          	sub	a1,a1,s2
    80001722:	8552                	mv	a0,s4
    80001724:	fffff097          	auipc	ra,0xfffff
    80001728:	5f6080e7          	jalr	1526(ra) # 80000d1a <memmove>

    len -= n;
    8000172c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001730:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001732:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001736:	02098263          	beqz	s3,8000175a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000173e:	85ca                	mv	a1,s2
    80001740:	855a                	mv	a0,s6
    80001742:	00000097          	auipc	ra,0x0
    80001746:	92e080e7          	jalr	-1746(ra) # 80001070 <walkaddr>
    if(pa0 == 0)
    8000174a:	cd01                	beqz	a0,80001762 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000174c:	418904b3          	sub	s1,s2,s8
    80001750:	94d6                	add	s1,s1,s5
    if(n > len)
    80001752:	fc99f2e3          	bgeu	s3,s1,80001716 <copyin+0x28>
    80001756:	84ce                	mv	s1,s3
    80001758:	bf7d                	j	80001716 <copyin+0x28>
  }
  return 0;
    8000175a:	4501                	li	a0,0
    8000175c:	a021                	j	80001764 <copyin+0x76>
    8000175e:	4501                	li	a0,0
}
    80001760:	8082                	ret
      return -1;
    80001762:	557d                	li	a0,-1
}
    80001764:	60a6                	ld	ra,72(sp)
    80001766:	6406                	ld	s0,64(sp)
    80001768:	74e2                	ld	s1,56(sp)
    8000176a:	7942                	ld	s2,48(sp)
    8000176c:	79a2                	ld	s3,40(sp)
    8000176e:	7a02                	ld	s4,32(sp)
    80001770:	6ae2                	ld	s5,24(sp)
    80001772:	6b42                	ld	s6,16(sp)
    80001774:	6ba2                	ld	s7,8(sp)
    80001776:	6c02                	ld	s8,0(sp)
    80001778:	6161                	addi	sp,sp,80
    8000177a:	8082                	ret

000000008000177c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000177c:	c6c5                	beqz	a3,80001824 <copyinstr+0xa8>
{
    8000177e:	715d                	addi	sp,sp,-80
    80001780:	e486                	sd	ra,72(sp)
    80001782:	e0a2                	sd	s0,64(sp)
    80001784:	fc26                	sd	s1,56(sp)
    80001786:	f84a                	sd	s2,48(sp)
    80001788:	f44e                	sd	s3,40(sp)
    8000178a:	f052                	sd	s4,32(sp)
    8000178c:	ec56                	sd	s5,24(sp)
    8000178e:	e85a                	sd	s6,16(sp)
    80001790:	e45e                	sd	s7,8(sp)
    80001792:	0880                	addi	s0,sp,80
    80001794:	8a2a                	mv	s4,a0
    80001796:	8b2e                	mv	s6,a1
    80001798:	8bb2                	mv	s7,a2
    8000179a:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000179c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000179e:	6985                	lui	s3,0x1
    800017a0:	a035                	j	800017cc <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017a6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017a8:	0017b793          	seqz	a5,a5
    800017ac:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b0:	60a6                	ld	ra,72(sp)
    800017b2:	6406                	ld	s0,64(sp)
    800017b4:	74e2                	ld	s1,56(sp)
    800017b6:	7942                	ld	s2,48(sp)
    800017b8:	79a2                	ld	s3,40(sp)
    800017ba:	7a02                	ld	s4,32(sp)
    800017bc:	6ae2                	ld	s5,24(sp)
    800017be:	6b42                	ld	s6,16(sp)
    800017c0:	6ba2                	ld	s7,8(sp)
    800017c2:	6161                	addi	sp,sp,80
    800017c4:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017ca:	c8a9                	beqz	s1,8000181c <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017cc:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d0:	85ca                	mv	a1,s2
    800017d2:	8552                	mv	a0,s4
    800017d4:	00000097          	auipc	ra,0x0
    800017d8:	89c080e7          	jalr	-1892(ra) # 80001070 <walkaddr>
    if(pa0 == 0)
    800017dc:	c131                	beqz	a0,80001820 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017de:	41790833          	sub	a6,s2,s7
    800017e2:	984e                	add	a6,a6,s3
    if(n > max)
    800017e4:	0104f363          	bgeu	s1,a6,800017ea <copyinstr+0x6e>
    800017e8:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ea:	955e                	add	a0,a0,s7
    800017ec:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f0:	fc080be3          	beqz	a6,800017c6 <copyinstr+0x4a>
    800017f4:	985a                	add	a6,a6,s6
    800017f6:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017f8:	41650633          	sub	a2,a0,s6
    800017fc:	14fd                	addi	s1,s1,-1
    800017fe:	9b26                	add	s6,s6,s1
    80001800:	00f60733          	add	a4,a2,a5
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffcb000>
    80001808:	df49                	beqz	a4,800017a2 <copyinstr+0x26>
        *dst = *p;
    8000180a:	00e78023          	sb	a4,0(a5)
      --max;
    8000180e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001812:	0785                	addi	a5,a5,1
    while(n > 0){
    80001814:	ff0796e3          	bne	a5,a6,80001800 <copyinstr+0x84>
      dst++;
    80001818:	8b42                	mv	s6,a6
    8000181a:	b775                	j	800017c6 <copyinstr+0x4a>
    8000181c:	4781                	li	a5,0
    8000181e:	b769                	j	800017a8 <copyinstr+0x2c>
      return -1;
    80001820:	557d                	li	a0,-1
    80001822:	b779                	j	800017b0 <copyinstr+0x34>
  int got_null = 0;
    80001824:	4781                	li	a5,0
  if(got_null){
    80001826:	0017b793          	seqz	a5,a5
    8000182a:	40f00533          	neg	a0,a5
}
    8000182e:	8082                	ret

0000000080001830 <mmap_pgfault>:

// Mmap pages does not exist, page fault will occur.
// Alloc a physical page and read the file to it.
int 
mmap_pgfault(uint64 stval, struct proc *p)
{
    80001830:	7139                	addi	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	addi	s0,sp,64
    80001844:	8a2e                	mv	s4,a1
  stval = PGROUNDDOWN(stval);
    80001846:	77fd                	lui	a5,0xfffff
    80001848:	00f57933          	and	s2,a0,a5

  struct vma *a = 0;
  // Which vma?
  for(int i = 0; i < NVMA; i++){
    8000184c:	16858793          	addi	a5,a1,360 # 4000168 <_entry-0x7bfffe98>
    80001850:	4481                	li	s1,0
    80001852:	4641                	li	a2,16
    80001854:	a031                	j	80001860 <mmap_pgfault+0x30>
    80001856:	2485                	addiw	s1,s1,1
    80001858:	03878793          	addi	a5,a5,56 # fffffffffffff038 <end+0xffffffff7ffcb038>
    8000185c:	0cc48a63          	beq	s1,a2,80001930 <mmap_pgfault+0x100>
    if(p->vmas[i].used && stval >= p->vmas[i].start && stval < p->vmas[i].end){
    80001860:	4398                	lw	a4,0(a5)
    80001862:	db75                	beqz	a4,80001856 <mmap_pgfault+0x26>
    80001864:	7798                	ld	a4,40(a5)
    80001866:	fee968e3          	bltu	s2,a4,80001856 <mmap_pgfault+0x26>
    8000186a:	7b98                	ld	a4,48(a5)
    8000186c:	fee975e3          	bgeu	s2,a4,80001856 <mmap_pgfault+0x26>
    }
  }

  if(a == 0) return -1;

  char *pa = kalloc();
    80001870:	fffff097          	auipc	ra,0xfffff
    80001874:	262080e7          	jalr	610(ra) # 80000ad2 <kalloc>
    80001878:	8aaa                	mv	s5,a0
  if(pa == 0) return -1;
    8000187a:	c571                	beqz	a0,80001946 <mmap_pgfault+0x116>
  memset(pa, 0, PGSIZE);
    8000187c:	6605                	lui	a2,0x1
    8000187e:	4581                	li	a1,0
    80001880:	fffff097          	auipc	ra,0xfffff
    80001884:	43e080e7          	jalr	1086(ra) # 80000cbe <memset>

  int perm = PTE_U;
  if(a->permissions & PROT_READ)
    80001888:	00349793          	slli	a5,s1,0x3
    8000188c:	8f85                	sub	a5,a5,s1
    8000188e:	078e                	slli	a5,a5,0x3
    80001890:	97d2                	add	a5,a5,s4
    80001892:	17c7a783          	lw	a5,380(a5)
    80001896:	0017f693          	andi	a3,a5,1
  int perm = PTE_U;
    8000189a:	4741                	li	a4,16
  if(a->permissions & PROT_READ)
    8000189c:	c291                	beqz	a3,800018a0 <mmap_pgfault+0x70>
    perm |= PTE_R;
    8000189e:	4749                	li	a4,18
  if(a->permissions & PROT_WRITE)
    800018a0:	8b89                	andi	a5,a5,2
    800018a2:	c399                	beqz	a5,800018a8 <mmap_pgfault+0x78>
    perm |= PTE_W;
    800018a4:	00476713          	ori	a4,a4,4
  if(mappages(p->pagetable, PGROUNDDOWN(stval), PGSIZE, (uint64)pa, perm) != 0)
    800018a8:	86d6                	mv	a3,s5
    800018aa:	6605                	lui	a2,0x1
    800018ac:	85ca                	mv	a1,s2
    800018ae:	050a3503          	ld	a0,80(s4) # fffffffffffff050 <end+0xffffffff7ffcb050>
    800018b2:	00000097          	auipc	ra,0x0
    800018b6:	800080e7          	jalr	-2048(ra) # 800010b2 <mappages>
    800018ba:	8b2a                	mv	s6,a0
    800018bc:	e559                	bnez	a0,8000194a <mmap_pgfault+0x11a>
    return -1;
  
  uint64 off = stval - a->start + a->offset;
    800018be:	00349993          	slli	s3,s1,0x3
    800018c2:	409989b3          	sub	s3,s3,s1
    800018c6:	098e                	slli	s3,s3,0x3
    800018c8:	99d2                	add	s3,s3,s4
    800018ca:	1849a503          	lw	a0,388(s3) # 1184 <_entry-0x7fffee7c>
    800018ce:	1909b783          	ld	a5,400(s3)
    800018d2:	8d1d                	sub	a0,a0,a5
    800018d4:	992a                	add	s2,s2,a0
  ilock(a->f->ip);
    800018d6:	1889b783          	ld	a5,392(s3)
    800018da:	6f88                	ld	a0,24(a5)
    800018dc:	00002097          	auipc	ra,0x2
    800018e0:	1f2080e7          	jalr	498(ra) # 80003ace <ilock>
  if(readi(a->f->ip, 0, (uint64)pa, off, PGSIZE) <= 0){
    800018e4:	1889b783          	ld	a5,392(s3)
    800018e8:	6705                	lui	a4,0x1
    800018ea:	0009069b          	sext.w	a3,s2
    800018ee:	8656                	mv	a2,s5
    800018f0:	4581                	li	a1,0
    800018f2:	6f88                	ld	a0,24(a5)
    800018f4:	00002097          	auipc	ra,0x2
    800018f8:	48e080e7          	jalr	1166(ra) # 80003d82 <readi>
    800018fc:	02a05c63          	blez	a0,80001934 <mmap_pgfault+0x104>
    iunlock(a->f->ip);
    return -1;
  }
  iunlock(a->f->ip);
    80001900:	00349793          	slli	a5,s1,0x3
    80001904:	409784b3          	sub	s1,a5,s1
    80001908:	048e                	slli	s1,s1,0x3
    8000190a:	9a26                	add	s4,s4,s1
    8000190c:	188a3783          	ld	a5,392(s4)
    80001910:	6f88                	ld	a0,24(a5)
    80001912:	00002097          	auipc	ra,0x2
    80001916:	27e080e7          	jalr	638(ra) # 80003b90 <iunlock>

  return 0;
}
    8000191a:	855a                	mv	a0,s6
    8000191c:	70e2                	ld	ra,56(sp)
    8000191e:	7442                	ld	s0,48(sp)
    80001920:	74a2                	ld	s1,40(sp)
    80001922:	7902                	ld	s2,32(sp)
    80001924:	69e2                	ld	s3,24(sp)
    80001926:	6a42                	ld	s4,16(sp)
    80001928:	6aa2                	ld	s5,8(sp)
    8000192a:	6b02                	ld	s6,0(sp)
    8000192c:	6121                	addi	sp,sp,64
    8000192e:	8082                	ret
  if(a == 0) return -1;
    80001930:	5b7d                	li	s6,-1
    80001932:	b7e5                	j	8000191a <mmap_pgfault+0xea>
    iunlock(a->f->ip);
    80001934:	1889b783          	ld	a5,392(s3)
    80001938:	6f88                	ld	a0,24(a5)
    8000193a:	00002097          	auipc	ra,0x2
    8000193e:	256080e7          	jalr	598(ra) # 80003b90 <iunlock>
    return -1;
    80001942:	5b7d                	li	s6,-1
    80001944:	bfd9                	j	8000191a <mmap_pgfault+0xea>
  if(pa == 0) return -1;
    80001946:	5b7d                	li	s6,-1
    80001948:	bfc9                	j	8000191a <mmap_pgfault+0xea>
    return -1;
    8000194a:	5b7d                	li	s6,-1
    8000194c:	b7f9                	j	8000191a <mmap_pgfault+0xea>

000000008000194e <munmap_writeback>:

// If an unmapped page has been modified and the file is mapped MAP_SHARED, 
// write the page back to the file. 
int
munmap_writeback(uint64 unstart, uint64 unlen, uint64 start, uint64 offset, struct vma *a)
{
    8000194e:	7159                	addi	sp,sp,-112
    80001950:	f486                	sd	ra,104(sp)
    80001952:	f0a2                	sd	s0,96(sp)
    80001954:	eca6                	sd	s1,88(sp)
    80001956:	e8ca                	sd	s2,80(sp)
    80001958:	e4ce                	sd	s3,72(sp)
    8000195a:	e0d2                	sd	s4,64(sp)
    8000195c:	fc56                	sd	s5,56(sp)
    8000195e:	f85a                	sd	s6,48(sp)
    80001960:	f45e                	sd	s7,40(sp)
    80001962:	f062                	sd	s8,32(sp)
    80001964:	ec66                	sd	s9,24(sp)
    80001966:	e86a                	sd	s10,16(sp)
    80001968:	e46e                	sd	s11,8(sp)
    8000196a:	1880                	addi	s0,sp,112
    8000196c:	8aaa                	mv	s5,a0
    8000196e:	89ae                	mv	s3,a1
  struct file *f = a->f;
    80001970:	02073903          	ld	s2,32(a4) # 1020 <_entry-0x7fffefe0>
  uint off = unstart - start + offset;
    80001974:	40c5063b          	subw	a2,a0,a2
    80001978:	00d604bb          	addw	s1,a2,a3
    8000197c:	00048c1b          	sext.w	s8,s1
  uint size;

  ilock(f->ip);
    80001980:	01893503          	ld	a0,24(s2) # 1018 <_entry-0x7fffefe8>
    80001984:	00002097          	auipc	ra,0x2
    80001988:	14a080e7          	jalr	330(ra) # 80003ace <ilock>
  size = f->ip->size;
    8000198c:	01893503          	ld	a0,24(s2)
    80001990:	04c52b83          	lw	s7,76(a0)
  iunlock(f->ip);
    80001994:	00002097          	auipc	ra,0x2
    80001998:	1fc080e7          	jalr	508(ra) # 80003b90 <iunlock>

  if(off >= size) return -1;
    8000199c:	0b7c7e63          	bgeu	s8,s7,80001a58 <munmap_writeback+0x10a>

  uint n = unlen < size - off ? unlen : size - off;
    800019a0:	409b8bbb          	subw	s7,s7,s1
    800019a4:	1b82                	slli	s7,s7,0x20
    800019a6:	020bdb93          	srli	s7,s7,0x20
    800019aa:	0179f363          	bgeu	s3,s7,800019b0 <munmap_writeback+0x62>
    800019ae:	8bce                	mv	s7,s3
    800019b0:	000b8a1b          	sext.w	s4,s7

  int r, ret = 0;
  int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
  int i = 0;
  while(i < n){
    800019b4:	060a0e63          	beqz	s4,80001a30 <munmap_writeback+0xe2>
  int i = 0;
    800019b8:	4981                	li	s3,0
  while(i < n){
    800019ba:	4481                	li	s1,0
    800019bc:	6b05                	lui	s6,0x1
    800019be:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800019c2:	6c85                	lui	s9,0x1
    800019c4:	c00c8c9b          	addiw	s9,s9,-1024
    800019c8:	a8a1                	j	80001a20 <munmap_writeback+0xd2>
    800019ca:	000d8d1b          	sext.w	s10,s11
    int n1 = n - i;
    if(n1 > max)
      n1 = max;

    begin_op();
    800019ce:	00003097          	auipc	ra,0x3
    800019d2:	ad2080e7          	jalr	-1326(ra) # 800044a0 <begin_op>
    ilock(f->ip);
    800019d6:	01893503          	ld	a0,24(s2)
    800019da:	00002097          	auipc	ra,0x2
    800019de:	0f4080e7          	jalr	244(ra) # 80003ace <ilock>
    r = writei(f->ip, 1, unstart, off + i, n1);
    800019e2:	876a                	mv	a4,s10
    800019e4:	009c06bb          	addw	a3,s8,s1
    800019e8:	8656                	mv	a2,s5
    800019ea:	4585                	li	a1,1
    800019ec:	01893503          	ld	a0,24(s2)
    800019f0:	00002097          	auipc	ra,0x2
    800019f4:	48a080e7          	jalr	1162(ra) # 80003e7a <writei>
    800019f8:	84aa                	mv	s1,a0
    iunlock(f->ip);
    800019fa:	01893503          	ld	a0,24(s2)
    800019fe:	00002097          	auipc	ra,0x2
    80001a02:	192080e7          	jalr	402(ra) # 80003b90 <iunlock>
    end_op();
    80001a06:	00003097          	auipc	ra,0x3
    80001a0a:	b1a080e7          	jalr	-1254(ra) # 80004520 <end_op>

    if(r != n1){
    80001a0e:	029d1263          	bne	s10,s1,80001a32 <munmap_writeback+0xe4>
      // error from writei
      break;
    }
    i += r;
    80001a12:	013484bb          	addw	s1,s1,s3
    80001a16:	0004899b          	sext.w	s3,s1
  while(i < n){
    80001a1a:	84ce                	mv	s1,s3
    80001a1c:	0149fb63          	bgeu	s3,s4,80001a32 <munmap_writeback+0xe4>
    int n1 = n - i;
    80001a20:	409a07bb          	subw	a5,s4,s1
    if(n1 > max)
    80001a24:	8dbe                	mv	s11,a5
    80001a26:	2781                	sext.w	a5,a5
    80001a28:	fafb51e3          	bge	s6,a5,800019ca <munmap_writeback+0x7c>
    80001a2c:	8de6                	mv	s11,s9
    80001a2e:	bf71                	j	800019ca <munmap_writeback+0x7c>
  int i = 0;
    80001a30:	4981                	li	s3,0
  }
  ret = (i == n ? n : -1);
    80001a32:	2b81                	sext.w	s7,s7
    80001a34:	033b9463          	bne	s7,s3,80001a5c <munmap_writeback+0x10e>

  return ret;
}
    80001a38:	854e                	mv	a0,s3
    80001a3a:	70a6                	ld	ra,104(sp)
    80001a3c:	7406                	ld	s0,96(sp)
    80001a3e:	64e6                	ld	s1,88(sp)
    80001a40:	6946                	ld	s2,80(sp)
    80001a42:	69a6                	ld	s3,72(sp)
    80001a44:	6a06                	ld	s4,64(sp)
    80001a46:	7ae2                	ld	s5,56(sp)
    80001a48:	7b42                	ld	s6,48(sp)
    80001a4a:	7ba2                	ld	s7,40(sp)
    80001a4c:	7c02                	ld	s8,32(sp)
    80001a4e:	6ce2                	ld	s9,24(sp)
    80001a50:	6d42                	ld	s10,16(sp)
    80001a52:	6da2                	ld	s11,8(sp)
    80001a54:	6165                	addi	sp,sp,112
    80001a56:	8082                	ret
  if(off >= size) return -1;
    80001a58:	59fd                	li	s3,-1
    80001a5a:	bff9                	j	80001a38 <munmap_writeback+0xea>
  ret = (i == n ? n : -1);
    80001a5c:	59fd                	li	s3,-1
    80001a5e:	bfe9                	j	80001a38 <munmap_writeback+0xea>

0000000080001a60 <munmap>:

//Find the VMA for the address range and unmap the specified pages.
int
munmap(uint64 addr, int length)
{
    80001a60:	7159                	addi	sp,sp,-112
    80001a62:	f486                	sd	ra,104(sp)
    80001a64:	f0a2                	sd	s0,96(sp)
    80001a66:	eca6                	sd	s1,88(sp)
    80001a68:	e8ca                	sd	s2,80(sp)
    80001a6a:	e4ce                	sd	s3,72(sp)
    80001a6c:	e0d2                	sd	s4,64(sp)
    80001a6e:	fc56                	sd	s5,56(sp)
    80001a70:	f85a                	sd	s6,48(sp)
    80001a72:	f45e                	sd	s7,40(sp)
    80001a74:	f062                	sd	s8,32(sp)
    80001a76:	ec66                	sd	s9,24(sp)
    80001a78:	e86a                	sd	s10,16(sp)
    80001a7a:	e46e                	sd	s11,8(sp)
    80001a7c:	1880                	addi	s0,sp,112
    80001a7e:	892a                	mv	s2,a0
    80001a80:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80001a82:	00000097          	auipc	ra,0x0
    80001a86:	324080e7          	jalr	804(ra) # 80001da6 <myproc>
    80001a8a:	8a2a                	mv	s4,a0
  struct vma *a = 0;
  addr = PGROUNDDOWN(addr);
    80001a8c:	757d                	lui	a0,0xfffff
    80001a8e:	00a97933          	and	s2,s2,a0

  for(int i = 0; i < NVMA; i++){
    80001a92:	168a0793          	addi	a5,s4,360
    80001a96:	4481                	li	s1,0
    80001a98:	4641                	li	a2,16
    80001a9a:	a031                	j	80001aa6 <munmap+0x46>
    80001a9c:	2485                	addiw	s1,s1,1
    80001a9e:	03878793          	addi	a5,a5,56
    80001aa2:	06c48663          	beq	s1,a2,80001b0e <munmap+0xae>
    if(p->vmas[i].used && addr >= p->vmas[i].start && addr < p->vmas[i].end){
    80001aa6:	4398                	lw	a4,0(a5)
    80001aa8:	db75                	beqz	a4,80001a9c <munmap+0x3c>
    80001aaa:	7798                	ld	a4,40(a5)
    80001aac:	fee968e3          	bltu	s2,a4,80001a9c <munmap+0x3c>
    80001ab0:	7b98                	ld	a4,48(a5)
    80001ab2:	fee975e3          	bgeu	s2,a4,80001a9c <munmap+0x3c>
      a = &p->vmas[i];
    80001ab6:	00349793          	slli	a5,s1,0x3
    80001aba:	40978bb3          	sub	s7,a5,s1
    80001abe:	0b8e                	slli	s7,s7,0x3
    80001ac0:	168b8b93          	addi	s7,s7,360 # fffffffffffff168 <end+0xffffffff7ffcb168>
    80001ac4:	9bd2                	add	s7,s7,s4
  }

  if (a == 0) return -1;

  uint64 unstart, unlen;
  uint64 start = a->start, offset = a->offset, orilen = a->length;
    80001ac6:	8f85                	sub	a5,a5,s1
    80001ac8:	078e                	slli	a5,a5,0x3
    80001aca:	97d2                	add	a5,a5,s4
    80001acc:	1907bc83          	ld	s9,400(a5)
    80001ad0:	1847ad03          	lw	s10,388(a5)
    80001ad4:	1787a703          	lw	a4,376(a5)
    80001ad8:	8dba                	mv	s11,a4

  if(addr == a->start){
    80001ada:	03990c63          	beq	s2,s9,80001b12 <munmap+0xb2>
    unlen = PGROUNDUP(length) < a->length ? PGROUNDUP(length) : a->length;

    a->start = unstart + unlen; 
    a->length = a->end - a->start;
    a->offset = a->offset + unlen;
  } else if(addr + length >= a->end){
    80001ade:	00349793          	slli	a5,s1,0x3
    80001ae2:	8f85                	sub	a5,a5,s1
    80001ae4:	078e                	slli	a5,a5,0x3
    80001ae6:	97d2                	add	a5,a5,s4
    80001ae8:	1987bc03          	ld	s8,408(a5)
    80001aec:	99ca                	add	s3,s3,s2
    80001aee:	0789ef63          	bltu	s3,s8,80001b6c <munmap+0x10c>
    // Unmap at the end
    unstart = addr;
    unlen = a->end - unstart;
    80001af2:	412c0c33          	sub	s8,s8,s2

    a->end = unstart;
    80001af6:	00349793          	slli	a5,s1,0x3
    80001afa:	8f85                	sub	a5,a5,s1
    80001afc:	078e                	slli	a5,a5,0x3
    80001afe:	97d2                	add	a5,a5,s4
    80001b00:	1927bc23          	sd	s2,408(a5)
    a->length = a->end - a->start;
    80001b04:	4199073b          	subw	a4,s2,s9
    80001b08:	16e7ac23          	sw	a4,376(a5)
    80001b0c:	a099                	j	80001b52 <munmap+0xf2>
  if (a == 0) return -1;
    80001b0e:	557d                	li	a0,-1
    80001b10:	a84d                	j	80001bc2 <munmap+0x162>
    unlen = PGROUNDUP(length) < a->length ? PGROUNDUP(length) : a->length;
    80001b12:	6785                	lui	a5,0x1
    80001b14:	37fd                	addiw	a5,a5,-1
    80001b16:	00f989bb          	addw	s3,s3,a5
    80001b1a:	77fd                	lui	a5,0xfffff
    80001b1c:	00f9f9b3          	and	s3,s3,a5
    80001b20:	86ce                	mv	a3,s3
    80001b22:	2981                	sext.w	s3,s3
    80001b24:	01375363          	bge	a4,s3,80001b2a <munmap+0xca>
    80001b28:	86ba                	mv	a3,a4
    80001b2a:	00068c1b          	sext.w	s8,a3
    a->start = unstart + unlen; 
    80001b2e:	01890633          	add	a2,s2,s8
    80001b32:	00349793          	slli	a5,s1,0x3
    80001b36:	8f85                	sub	a5,a5,s1
    80001b38:	078e                	slli	a5,a5,0x3
    80001b3a:	97d2                	add	a5,a5,s4
    80001b3c:	18c7b823          	sd	a2,400(a5) # fffffffffffff190 <end+0xffffffff7ffcb190>
    a->length = a->end - a->start;
    80001b40:	1987b703          	ld	a4,408(a5)
    80001b44:	9f11                	subw	a4,a4,a2
    80001b46:	16e7ac23          	sw	a4,376(a5)
    a->offset = a->offset + unlen;
    80001b4a:	00dd06bb          	addw	a3,s10,a3
    80001b4e:	18d7a223          	sw	a3,388(a5)
    // Unmap the whole region
    unstart = a->start;
    unlen = a->end - a->start;
  }
  
  for(int i = 0; i < unlen / PGSIZE; i++){
    80001b52:	00cc5b13          	srli	s6,s8,0xc
    80001b56:	6785                	lui	a5,0x1
    80001b58:	06fc6263          	bltu	s8,a5,80001bbc <munmap+0x15c>
    80001b5c:	4981                	li	s3,0
    uint64 va = unstart + i * PGSIZE;
    // May not be alloced due to lazy alloc through page fault.
    if(vm_exists(p->pagetable, va)){
      if(a->flags & MAP_SHARED){
    80001b5e:	00349a93          	slli	s5,s1,0x3
    80001b62:	409a8ab3          	sub	s5,s5,s1
    80001b66:	0a8e                	slli	s5,s5,0x3
    80001b68:	9ad2                	add	s5,s5,s4
    80001b6a:	a01d                	j	80001b90 <munmap+0x130>
    unlen = a->end - a->start;
    80001b6c:	419c0c33          	sub	s8,s8,s9
    unstart = a->start;
    80001b70:	8966                	mv	s2,s9
    80001b72:	b7c5                	j	80001b52 <munmap+0xf2>
        munmap_writeback(va, PGSIZE, start, offset, a);
      }

      uvmunmap(p->pagetable, va, 1, 1);
    80001b74:	4685                	li	a3,1
    80001b76:	4605                	li	a2,1
    80001b78:	85ca                	mv	a1,s2
    80001b7a:	050a3503          	ld	a0,80(s4)
    80001b7e:	fffff097          	auipc	ra,0xfffff
    80001b82:	6e8080e7          	jalr	1768(ra) # 80001266 <uvmunmap>
  for(int i = 0; i < unlen / PGSIZE; i++){
    80001b86:	0985                	addi	s3,s3,1
    80001b88:	6785                	lui	a5,0x1
    80001b8a:	993e                	add	s2,s2,a5
    80001b8c:	0369f863          	bgeu	s3,s6,80001bbc <munmap+0x15c>
    if(vm_exists(p->pagetable, va)){
    80001b90:	85ca                	mv	a1,s2
    80001b92:	050a3503          	ld	a0,80(s4)
    80001b96:	fffff097          	auipc	ra,0xfffff
    80001b9a:	4b6080e7          	jalr	1206(ra) # 8000104c <vm_exists>
    80001b9e:	d565                	beqz	a0,80001b86 <munmap+0x126>
      if(a->flags & MAP_SHARED){
    80001ba0:	180aa783          	lw	a5,384(s5) # fffffffffffff180 <end+0xffffffff7ffcb180>
    80001ba4:	8b85                	andi	a5,a5,1
    80001ba6:	d7f9                	beqz	a5,80001b74 <munmap+0x114>
        munmap_writeback(va, PGSIZE, start, offset, a);
    80001ba8:	875e                	mv	a4,s7
    80001baa:	86ea                	mv	a3,s10
    80001bac:	8666                	mv	a2,s9
    80001bae:	6585                	lui	a1,0x1
    80001bb0:	854a                	mv	a0,s2
    80001bb2:	00000097          	auipc	ra,0x0
    80001bb6:	d9c080e7          	jalr	-612(ra) # 8000194e <munmap_writeback>
    80001bba:	bf6d                	j	80001b74 <munmap+0x114>
  if(unlen == orilen){
    fileclose(a->f);
    a->used = 0;
  }
  
  return 0;
    80001bbc:	4501                	li	a0,0
  if(unlen == orilen){
    80001bbe:	03bc0163          	beq	s8,s11,80001be0 <munmap+0x180>
    80001bc2:	70a6                	ld	ra,104(sp)
    80001bc4:	7406                	ld	s0,96(sp)
    80001bc6:	64e6                	ld	s1,88(sp)
    80001bc8:	6946                	ld	s2,80(sp)
    80001bca:	69a6                	ld	s3,72(sp)
    80001bcc:	6a06                	ld	s4,64(sp)
    80001bce:	7ae2                	ld	s5,56(sp)
    80001bd0:	7b42                	ld	s6,48(sp)
    80001bd2:	7ba2                	ld	s7,40(sp)
    80001bd4:	7c02                	ld	s8,32(sp)
    80001bd6:	6ce2                	ld	s9,24(sp)
    80001bd8:	6d42                	ld	s10,16(sp)
    80001bda:	6da2                	ld	s11,8(sp)
    80001bdc:	6165                	addi	sp,sp,112
    80001bde:	8082                	ret
    fileclose(a->f);
    80001be0:	00349913          	slli	s2,s1,0x3
    80001be4:	409907b3          	sub	a5,s2,s1
    80001be8:	078e                	slli	a5,a5,0x3
    80001bea:	97d2                	add	a5,a5,s4
    80001bec:	1887b503          	ld	a0,392(a5) # 1188 <_entry-0x7fffee78>
    80001bf0:	00003097          	auipc	ra,0x3
    80001bf4:	d84080e7          	jalr	-636(ra) # 80004974 <fileclose>
    a->used = 0;
    80001bf8:	409907b3          	sub	a5,s2,s1
    80001bfc:	078e                	slli	a5,a5,0x3
    80001bfe:	9a3e                	add	s4,s4,a5
    80001c00:	160a2423          	sw	zero,360(s4)
  return 0;
    80001c04:	4501                	li	a0,0
    80001c06:	bf75                	j	80001bc2 <munmap+0x162>

0000000080001c08 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001c08:	1101                	addi	sp,sp,-32
    80001c0a:	ec06                	sd	ra,24(sp)
    80001c0c:	e822                	sd	s0,16(sp)
    80001c0e:	e426                	sd	s1,8(sp)
    80001c10:	1000                	addi	s0,sp,32
    80001c12:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001c14:	fffff097          	auipc	ra,0xfffff
    80001c18:	f34080e7          	jalr	-204(ra) # 80000b48 <holding>
    80001c1c:	c909                	beqz	a0,80001c2e <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001c1e:	749c                	ld	a5,40(s1)
    80001c20:	00978f63          	beq	a5,s1,80001c3e <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001c24:	60e2                	ld	ra,24(sp)
    80001c26:	6442                	ld	s0,16(sp)
    80001c28:	64a2                	ld	s1,8(sp)
    80001c2a:	6105                	addi	sp,sp,32
    80001c2c:	8082                	ret
    panic("wakeup1");
    80001c2e:	00006517          	auipc	a0,0x6
    80001c32:	59250513          	addi	a0,a0,1426 # 800081c0 <digits+0x180>
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	8f4080e7          	jalr	-1804(ra) # 8000052a <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001c3e:	4c98                	lw	a4,24(s1)
    80001c40:	4785                	li	a5,1
    80001c42:	fef711e3          	bne	a4,a5,80001c24 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001c46:	4789                	li	a5,2
    80001c48:	cc9c                	sw	a5,24(s1)
}
    80001c4a:	bfe9                	j	80001c24 <wakeup1+0x1c>

0000000080001c4c <proc_mapstacks>:
proc_mapstacks(pagetable_t kpgtbl) {
    80001c4c:	7139                	addi	sp,sp,-64
    80001c4e:	fc06                	sd	ra,56(sp)
    80001c50:	f822                	sd	s0,48(sp)
    80001c52:	f426                	sd	s1,40(sp)
    80001c54:	f04a                	sd	s2,32(sp)
    80001c56:	ec4e                	sd	s3,24(sp)
    80001c58:	e852                	sd	s4,16(sp)
    80001c5a:	e456                	sd	s5,8(sp)
    80001c5c:	e05a                	sd	s6,0(sp)
    80001c5e:	0080                	addi	s0,sp,64
    80001c60:	89aa                	mv	s3,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c62:	00010497          	auipc	s1,0x10
    80001c66:	a5648493          	addi	s1,s1,-1450 # 800116b8 <proc>
    uint64 va = KSTACK((int) (p - proc));
    80001c6a:	8b26                	mv	s6,s1
    80001c6c:	00006a97          	auipc	s5,0x6
    80001c70:	394a8a93          	addi	s5,s5,916 # 80008000 <etext>
    80001c74:	04000937          	lui	s2,0x4000
    80001c78:	197d                	addi	s2,s2,-1
    80001c7a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c7c:	00023a17          	auipc	s4,0x23
    80001c80:	43ca0a13          	addi	s4,s4,1084 # 800250b8 <tickslock>
    char *pa = kalloc();
    80001c84:	fffff097          	auipc	ra,0xfffff
    80001c88:	e4e080e7          	jalr	-434(ra) # 80000ad2 <kalloc>
    80001c8c:	862a                	mv	a2,a0
    if(pa == 0)
    80001c8e:	c131                	beqz	a0,80001cd2 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001c90:	416485b3          	sub	a1,s1,s6
    80001c94:	858d                	srai	a1,a1,0x3
    80001c96:	000ab783          	ld	a5,0(s5)
    80001c9a:	02f585b3          	mul	a1,a1,a5
    80001c9e:	2585                	addiw	a1,a1,1
    80001ca0:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001ca4:	4719                	li	a4,6
    80001ca6:	6685                	lui	a3,0x1
    80001ca8:	40b905b3          	sub	a1,s2,a1
    80001cac:	854e                	mv	a0,s3
    80001cae:	fffff097          	auipc	ra,0xfffff
    80001cb2:	492080e7          	jalr	1170(ra) # 80001140 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cb6:	4e848493          	addi	s1,s1,1256
    80001cba:	fd4495e3          	bne	s1,s4,80001c84 <proc_mapstacks+0x38>
}
    80001cbe:	70e2                	ld	ra,56(sp)
    80001cc0:	7442                	ld	s0,48(sp)
    80001cc2:	74a2                	ld	s1,40(sp)
    80001cc4:	7902                	ld	s2,32(sp)
    80001cc6:	69e2                	ld	s3,24(sp)
    80001cc8:	6a42                	ld	s4,16(sp)
    80001cca:	6aa2                	ld	s5,8(sp)
    80001ccc:	6b02                	ld	s6,0(sp)
    80001cce:	6121                	addi	sp,sp,64
    80001cd0:	8082                	ret
      panic("kalloc");
    80001cd2:	00006517          	auipc	a0,0x6
    80001cd6:	4f650513          	addi	a0,a0,1270 # 800081c8 <digits+0x188>
    80001cda:	fffff097          	auipc	ra,0xfffff
    80001cde:	850080e7          	jalr	-1968(ra) # 8000052a <panic>

0000000080001ce2 <procinit>:
{
    80001ce2:	7139                	addi	sp,sp,-64
    80001ce4:	fc06                	sd	ra,56(sp)
    80001ce6:	f822                	sd	s0,48(sp)
    80001ce8:	f426                	sd	s1,40(sp)
    80001cea:	f04a                	sd	s2,32(sp)
    80001cec:	ec4e                	sd	s3,24(sp)
    80001cee:	e852                	sd	s4,16(sp)
    80001cf0:	e456                	sd	s5,8(sp)
    80001cf2:	e05a                	sd	s6,0(sp)
    80001cf4:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    80001cf6:	00006597          	auipc	a1,0x6
    80001cfa:	4da58593          	addi	a1,a1,1242 # 800081d0 <digits+0x190>
    80001cfe:	0000f517          	auipc	a0,0xf
    80001d02:	5a250513          	addi	a0,a0,1442 # 800112a0 <pid_lock>
    80001d06:	fffff097          	auipc	ra,0xfffff
    80001d0a:	e2c080e7          	jalr	-468(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d0e:	00010497          	auipc	s1,0x10
    80001d12:	9aa48493          	addi	s1,s1,-1622 # 800116b8 <proc>
      initlock(&p->lock, "proc");
    80001d16:	00006b17          	auipc	s6,0x6
    80001d1a:	4c2b0b13          	addi	s6,s6,1218 # 800081d8 <digits+0x198>
      p->kstack = KSTACK((int) (p - proc));
    80001d1e:	8aa6                	mv	s5,s1
    80001d20:	00006a17          	auipc	s4,0x6
    80001d24:	2e0a0a13          	addi	s4,s4,736 # 80008000 <etext>
    80001d28:	04000937          	lui	s2,0x4000
    80001d2c:	197d                	addi	s2,s2,-1
    80001d2e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d30:	00023997          	auipc	s3,0x23
    80001d34:	38898993          	addi	s3,s3,904 # 800250b8 <tickslock>
      initlock(&p->lock, "proc");
    80001d38:	85da                	mv	a1,s6
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	df6080e7          	jalr	-522(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001d44:	415487b3          	sub	a5,s1,s5
    80001d48:	878d                	srai	a5,a5,0x3
    80001d4a:	000a3703          	ld	a4,0(s4)
    80001d4e:	02e787b3          	mul	a5,a5,a4
    80001d52:	2785                	addiw	a5,a5,1
    80001d54:	00d7979b          	slliw	a5,a5,0xd
    80001d58:	40f907b3          	sub	a5,s2,a5
    80001d5c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d5e:	4e848493          	addi	s1,s1,1256
    80001d62:	fd349be3          	bne	s1,s3,80001d38 <procinit+0x56>
}
    80001d66:	70e2                	ld	ra,56(sp)
    80001d68:	7442                	ld	s0,48(sp)
    80001d6a:	74a2                	ld	s1,40(sp)
    80001d6c:	7902                	ld	s2,32(sp)
    80001d6e:	69e2                	ld	s3,24(sp)
    80001d70:	6a42                	ld	s4,16(sp)
    80001d72:	6aa2                	ld	s5,8(sp)
    80001d74:	6b02                	ld	s6,0(sp)
    80001d76:	6121                	addi	sp,sp,64
    80001d78:	8082                	ret

0000000080001d7a <cpuid>:
{
    80001d7a:	1141                	addi	sp,sp,-16
    80001d7c:	e422                	sd	s0,8(sp)
    80001d7e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d80:	8512                	mv	a0,tp
}
    80001d82:	2501                	sext.w	a0,a0
    80001d84:	6422                	ld	s0,8(sp)
    80001d86:	0141                	addi	sp,sp,16
    80001d88:	8082                	ret

0000000080001d8a <mycpu>:
mycpu(void) {
    80001d8a:	1141                	addi	sp,sp,-16
    80001d8c:	e422                	sd	s0,8(sp)
    80001d8e:	0800                	addi	s0,sp,16
    80001d90:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001d92:	2781                	sext.w	a5,a5
    80001d94:	079e                	slli	a5,a5,0x7
}
    80001d96:	0000f517          	auipc	a0,0xf
    80001d9a:	52250513          	addi	a0,a0,1314 # 800112b8 <cpus>
    80001d9e:	953e                	add	a0,a0,a5
    80001da0:	6422                	ld	s0,8(sp)
    80001da2:	0141                	addi	sp,sp,16
    80001da4:	8082                	ret

0000000080001da6 <myproc>:
myproc(void) {
    80001da6:	1101                	addi	sp,sp,-32
    80001da8:	ec06                	sd	ra,24(sp)
    80001daa:	e822                	sd	s0,16(sp)
    80001dac:	e426                	sd	s1,8(sp)
    80001dae:	1000                	addi	s0,sp,32
  push_off();
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	dc6080e7          	jalr	-570(ra) # 80000b76 <push_off>
    80001db8:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001dba:	2781                	sext.w	a5,a5
    80001dbc:	079e                	slli	a5,a5,0x7
    80001dbe:	0000f717          	auipc	a4,0xf
    80001dc2:	4e270713          	addi	a4,a4,1250 # 800112a0 <pid_lock>
    80001dc6:	97ba                	add	a5,a5,a4
    80001dc8:	6f84                	ld	s1,24(a5)
  pop_off();
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	e4c080e7          	jalr	-436(ra) # 80000c16 <pop_off>
}
    80001dd2:	8526                	mv	a0,s1
    80001dd4:	60e2                	ld	ra,24(sp)
    80001dd6:	6442                	ld	s0,16(sp)
    80001dd8:	64a2                	ld	s1,8(sp)
    80001dda:	6105                	addi	sp,sp,32
    80001ddc:	8082                	ret

0000000080001dde <forkret>:
{
    80001dde:	1141                	addi	sp,sp,-16
    80001de0:	e406                	sd	ra,8(sp)
    80001de2:	e022                	sd	s0,0(sp)
    80001de4:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001de6:	00000097          	auipc	ra,0x0
    80001dea:	fc0080e7          	jalr	-64(ra) # 80001da6 <myproc>
    80001dee:	fffff097          	auipc	ra,0xfffff
    80001df2:	e88080e7          	jalr	-376(ra) # 80000c76 <release>
  if (first) {
    80001df6:	00007797          	auipc	a5,0x7
    80001dfa:	a0a7a783          	lw	a5,-1526(a5) # 80008800 <first.1>
    80001dfe:	eb89                	bnez	a5,80001e10 <forkret+0x32>
  usertrapret();
    80001e00:	00001097          	auipc	ra,0x1
    80001e04:	cbc080e7          	jalr	-836(ra) # 80002abc <usertrapret>
}
    80001e08:	60a2                	ld	ra,8(sp)
    80001e0a:	6402                	ld	s0,0(sp)
    80001e0c:	0141                	addi	sp,sp,16
    80001e0e:	8082                	ret
    first = 0;
    80001e10:	00007797          	auipc	a5,0x7
    80001e14:	9e07a823          	sw	zero,-1552(a5) # 80008800 <first.1>
    fsinit(ROOTDEV);
    80001e18:	4505                	li	a0,1
    80001e1a:	00002097          	auipc	ra,0x2
    80001e1e:	a3c080e7          	jalr	-1476(ra) # 80003856 <fsinit>
    80001e22:	bff9                	j	80001e00 <forkret+0x22>

0000000080001e24 <allocpid>:
allocpid() {
    80001e24:	1101                	addi	sp,sp,-32
    80001e26:	ec06                	sd	ra,24(sp)
    80001e28:	e822                	sd	s0,16(sp)
    80001e2a:	e426                	sd	s1,8(sp)
    80001e2c:	e04a                	sd	s2,0(sp)
    80001e2e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001e30:	0000f917          	auipc	s2,0xf
    80001e34:	47090913          	addi	s2,s2,1136 # 800112a0 <pid_lock>
    80001e38:	854a                	mv	a0,s2
    80001e3a:	fffff097          	auipc	ra,0xfffff
    80001e3e:	d88080e7          	jalr	-632(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001e42:	00007797          	auipc	a5,0x7
    80001e46:	9c278793          	addi	a5,a5,-1598 # 80008804 <nextpid>
    80001e4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001e4c:	0014871b          	addiw	a4,s1,1
    80001e50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001e52:	854a                	mv	a0,s2
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	e22080e7          	jalr	-478(ra) # 80000c76 <release>
}
    80001e5c:	8526                	mv	a0,s1
    80001e5e:	60e2                	ld	ra,24(sp)
    80001e60:	6442                	ld	s0,16(sp)
    80001e62:	64a2                	ld	s1,8(sp)
    80001e64:	6902                	ld	s2,0(sp)
    80001e66:	6105                	addi	sp,sp,32
    80001e68:	8082                	ret

0000000080001e6a <proc_pagetable>:
{
    80001e6a:	1101                	addi	sp,sp,-32
    80001e6c:	ec06                	sd	ra,24(sp)
    80001e6e:	e822                	sd	s0,16(sp)
    80001e70:	e426                	sd	s1,8(sp)
    80001e72:	e04a                	sd	s2,0(sp)
    80001e74:	1000                	addi	s0,sp,32
    80001e76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	4b2080e7          	jalr	1202(ra) # 8000132a <uvmcreate>
    80001e80:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001e82:	c121                	beqz	a0,80001ec2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e84:	4729                	li	a4,10
    80001e86:	00005697          	auipc	a3,0x5
    80001e8a:	17a68693          	addi	a3,a3,378 # 80007000 <_trampoline>
    80001e8e:	6605                	lui	a2,0x1
    80001e90:	040005b7          	lui	a1,0x4000
    80001e94:	15fd                	addi	a1,a1,-1
    80001e96:	05b2                	slli	a1,a1,0xc
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	21a080e7          	jalr	538(ra) # 800010b2 <mappages>
    80001ea0:	02054863          	bltz	a0,80001ed0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ea4:	4719                	li	a4,6
    80001ea6:	05893683          	ld	a3,88(s2)
    80001eaa:	6605                	lui	a2,0x1
    80001eac:	020005b7          	lui	a1,0x2000
    80001eb0:	15fd                	addi	a1,a1,-1
    80001eb2:	05b6                	slli	a1,a1,0xd
    80001eb4:	8526                	mv	a0,s1
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	1fc080e7          	jalr	508(ra) # 800010b2 <mappages>
    80001ebe:	02054163          	bltz	a0,80001ee0 <proc_pagetable+0x76>
}
    80001ec2:	8526                	mv	a0,s1
    80001ec4:	60e2                	ld	ra,24(sp)
    80001ec6:	6442                	ld	s0,16(sp)
    80001ec8:	64a2                	ld	s1,8(sp)
    80001eca:	6902                	ld	s2,0(sp)
    80001ecc:	6105                	addi	sp,sp,32
    80001ece:	8082                	ret
    uvmfree(pagetable, 0);
    80001ed0:	4581                	li	a1,0
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	fffff097          	auipc	ra,0xfffff
    80001ed8:	652080e7          	jalr	1618(ra) # 80001526 <uvmfree>
    return 0;
    80001edc:	4481                	li	s1,0
    80001ede:	b7d5                	j	80001ec2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ee0:	4681                	li	a3,0
    80001ee2:	4605                	li	a2,1
    80001ee4:	040005b7          	lui	a1,0x4000
    80001ee8:	15fd                	addi	a1,a1,-1
    80001eea:	05b2                	slli	a1,a1,0xc
    80001eec:	8526                	mv	a0,s1
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	378080e7          	jalr	888(ra) # 80001266 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ef6:	4581                	li	a1,0
    80001ef8:	8526                	mv	a0,s1
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	62c080e7          	jalr	1580(ra) # 80001526 <uvmfree>
    return 0;
    80001f02:	4481                	li	s1,0
    80001f04:	bf7d                	j	80001ec2 <proc_pagetable+0x58>

0000000080001f06 <proc_freepagetable>:
{
    80001f06:	1101                	addi	sp,sp,-32
    80001f08:	ec06                	sd	ra,24(sp)
    80001f0a:	e822                	sd	s0,16(sp)
    80001f0c:	e426                	sd	s1,8(sp)
    80001f0e:	e04a                	sd	s2,0(sp)
    80001f10:	1000                	addi	s0,sp,32
    80001f12:	84aa                	mv	s1,a0
    80001f14:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f16:	4681                	li	a3,0
    80001f18:	4605                	li	a2,1
    80001f1a:	040005b7          	lui	a1,0x4000
    80001f1e:	15fd                	addi	a1,a1,-1
    80001f20:	05b2                	slli	a1,a1,0xc
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	344080e7          	jalr	836(ra) # 80001266 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f2a:	4681                	li	a3,0
    80001f2c:	4605                	li	a2,1
    80001f2e:	020005b7          	lui	a1,0x2000
    80001f32:	15fd                	addi	a1,a1,-1
    80001f34:	05b6                	slli	a1,a1,0xd
    80001f36:	8526                	mv	a0,s1
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	32e080e7          	jalr	814(ra) # 80001266 <uvmunmap>
  uvmfree(pagetable, sz);
    80001f40:	85ca                	mv	a1,s2
    80001f42:	8526                	mv	a0,s1
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	5e2080e7          	jalr	1506(ra) # 80001526 <uvmfree>
}
    80001f4c:	60e2                	ld	ra,24(sp)
    80001f4e:	6442                	ld	s0,16(sp)
    80001f50:	64a2                	ld	s1,8(sp)
    80001f52:	6902                	ld	s2,0(sp)
    80001f54:	6105                	addi	sp,sp,32
    80001f56:	8082                	ret

0000000080001f58 <freeproc>:
{
    80001f58:	1101                	addi	sp,sp,-32
    80001f5a:	ec06                	sd	ra,24(sp)
    80001f5c:	e822                	sd	s0,16(sp)
    80001f5e:	e426                	sd	s1,8(sp)
    80001f60:	1000                	addi	s0,sp,32
    80001f62:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001f64:	6d28                	ld	a0,88(a0)
    80001f66:	c509                	beqz	a0,80001f70 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001f68:	fffff097          	auipc	ra,0xfffff
    80001f6c:	a6e080e7          	jalr	-1426(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001f70:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001f74:	68a8                	ld	a0,80(s1)
    80001f76:	c511                	beqz	a0,80001f82 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001f78:	64ac                	ld	a1,72(s1)
    80001f7a:	00000097          	auipc	ra,0x0
    80001f7e:	f8c080e7          	jalr	-116(ra) # 80001f06 <proc_freepagetable>
  p->pagetable = 0;
    80001f82:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001f86:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001f8a:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001f8e:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001f92:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001f96:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001f9a:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001f9e:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001fa2:	0004ac23          	sw	zero,24(s1)
}
    80001fa6:	60e2                	ld	ra,24(sp)
    80001fa8:	6442                	ld	s0,16(sp)
    80001faa:	64a2                	ld	s1,8(sp)
    80001fac:	6105                	addi	sp,sp,32
    80001fae:	8082                	ret

0000000080001fb0 <allocproc>:
{
    80001fb0:	1101                	addi	sp,sp,-32
    80001fb2:	ec06                	sd	ra,24(sp)
    80001fb4:	e822                	sd	s0,16(sp)
    80001fb6:	e426                	sd	s1,8(sp)
    80001fb8:	e04a                	sd	s2,0(sp)
    80001fba:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fbc:	0000f497          	auipc	s1,0xf
    80001fc0:	6fc48493          	addi	s1,s1,1788 # 800116b8 <proc>
    80001fc4:	00023917          	auipc	s2,0x23
    80001fc8:	0f490913          	addi	s2,s2,244 # 800250b8 <tickslock>
    acquire(&p->lock);
    80001fcc:	8526                	mv	a0,s1
    80001fce:	fffff097          	auipc	ra,0xfffff
    80001fd2:	bf4080e7          	jalr	-1036(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80001fd6:	4c9c                	lw	a5,24(s1)
    80001fd8:	cf81                	beqz	a5,80001ff0 <allocproc+0x40>
      release(&p->lock);
    80001fda:	8526                	mv	a0,s1
    80001fdc:	fffff097          	auipc	ra,0xfffff
    80001fe0:	c9a080e7          	jalr	-870(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fe4:	4e848493          	addi	s1,s1,1256
    80001fe8:	ff2492e3          	bne	s1,s2,80001fcc <allocproc+0x1c>
  return 0;
    80001fec:	4481                	li	s1,0
    80001fee:	a0b9                	j	8000203c <allocproc+0x8c>
  p->pid = allocpid();
    80001ff0:	00000097          	auipc	ra,0x0
    80001ff4:	e34080e7          	jalr	-460(ra) # 80001e24 <allocpid>
    80001ff8:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ffa:	fffff097          	auipc	ra,0xfffff
    80001ffe:	ad8080e7          	jalr	-1320(ra) # 80000ad2 <kalloc>
    80002002:	892a                	mv	s2,a0
    80002004:	eca8                	sd	a0,88(s1)
    80002006:	c131                	beqz	a0,8000204a <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80002008:	8526                	mv	a0,s1
    8000200a:	00000097          	auipc	ra,0x0
    8000200e:	e60080e7          	jalr	-416(ra) # 80001e6a <proc_pagetable>
    80002012:	892a                	mv	s2,a0
    80002014:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002016:	c129                	beqz	a0,80002058 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80002018:	07000613          	li	a2,112
    8000201c:	4581                	li	a1,0
    8000201e:	06048513          	addi	a0,s1,96
    80002022:	fffff097          	auipc	ra,0xfffff
    80002026:	c9c080e7          	jalr	-868(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    8000202a:	00000797          	auipc	a5,0x0
    8000202e:	db478793          	addi	a5,a5,-588 # 80001dde <forkret>
    80002032:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002034:	60bc                	ld	a5,64(s1)
    80002036:	6705                	lui	a4,0x1
    80002038:	97ba                	add	a5,a5,a4
    8000203a:	f4bc                	sd	a5,104(s1)
}
    8000203c:	8526                	mv	a0,s1
    8000203e:	60e2                	ld	ra,24(sp)
    80002040:	6442                	ld	s0,16(sp)
    80002042:	64a2                	ld	s1,8(sp)
    80002044:	6902                	ld	s2,0(sp)
    80002046:	6105                	addi	sp,sp,32
    80002048:	8082                	ret
    release(&p->lock);
    8000204a:	8526                	mv	a0,s1
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	c2a080e7          	jalr	-982(ra) # 80000c76 <release>
    return 0;
    80002054:	84ca                	mv	s1,s2
    80002056:	b7dd                	j	8000203c <allocproc+0x8c>
    freeproc(p);
    80002058:	8526                	mv	a0,s1
    8000205a:	00000097          	auipc	ra,0x0
    8000205e:	efe080e7          	jalr	-258(ra) # 80001f58 <freeproc>
    release(&p->lock);
    80002062:	8526                	mv	a0,s1
    80002064:	fffff097          	auipc	ra,0xfffff
    80002068:	c12080e7          	jalr	-1006(ra) # 80000c76 <release>
    return 0;
    8000206c:	84ca                	mv	s1,s2
    8000206e:	b7f9                	j	8000203c <allocproc+0x8c>

0000000080002070 <userinit>:
{
    80002070:	1101                	addi	sp,sp,-32
    80002072:	ec06                	sd	ra,24(sp)
    80002074:	e822                	sd	s0,16(sp)
    80002076:	e426                	sd	s1,8(sp)
    80002078:	1000                	addi	s0,sp,32
  p = allocproc();
    8000207a:	00000097          	auipc	ra,0x0
    8000207e:	f36080e7          	jalr	-202(ra) # 80001fb0 <allocproc>
    80002082:	84aa                	mv	s1,a0
  initproc = p;
    80002084:	00007797          	auipc	a5,0x7
    80002088:	faa7b223          	sd	a0,-92(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    8000208c:	03400613          	li	a2,52
    80002090:	00006597          	auipc	a1,0x6
    80002094:	78058593          	addi	a1,a1,1920 # 80008810 <initcode>
    80002098:	6928                	ld	a0,80(a0)
    8000209a:	fffff097          	auipc	ra,0xfffff
    8000209e:	2be080e7          	jalr	702(ra) # 80001358 <uvminit>
  p->sz = PGSIZE;
    800020a2:	6785                	lui	a5,0x1
    800020a4:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800020a6:	6cb8                	ld	a4,88(s1)
    800020a8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800020ac:	6cb8                	ld	a4,88(s1)
    800020ae:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800020b0:	4641                	li	a2,16
    800020b2:	00006597          	auipc	a1,0x6
    800020b6:	12e58593          	addi	a1,a1,302 # 800081e0 <digits+0x1a0>
    800020ba:	15848513          	addi	a0,s1,344
    800020be:	fffff097          	auipc	ra,0xfffff
    800020c2:	d52080e7          	jalr	-686(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    800020c6:	00006517          	auipc	a0,0x6
    800020ca:	12a50513          	addi	a0,a0,298 # 800081f0 <digits+0x1b0>
    800020ce:	00002097          	auipc	ra,0x2
    800020d2:	1b6080e7          	jalr	438(ra) # 80004284 <namei>
    800020d6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800020da:	4789                	li	a5,2
    800020dc:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800020de:	8526                	mv	a0,s1
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	b96080e7          	jalr	-1130(ra) # 80000c76 <release>
}
    800020e8:	60e2                	ld	ra,24(sp)
    800020ea:	6442                	ld	s0,16(sp)
    800020ec:	64a2                	ld	s1,8(sp)
    800020ee:	6105                	addi	sp,sp,32
    800020f0:	8082                	ret

00000000800020f2 <growproc>:
{
    800020f2:	1101                	addi	sp,sp,-32
    800020f4:	ec06                	sd	ra,24(sp)
    800020f6:	e822                	sd	s0,16(sp)
    800020f8:	e426                	sd	s1,8(sp)
    800020fa:	e04a                	sd	s2,0(sp)
    800020fc:	1000                	addi	s0,sp,32
    800020fe:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002100:	00000097          	auipc	ra,0x0
    80002104:	ca6080e7          	jalr	-858(ra) # 80001da6 <myproc>
    80002108:	892a                	mv	s2,a0
  sz = p->sz;
    8000210a:	652c                	ld	a1,72(a0)
    8000210c:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80002110:	00904f63          	bgtz	s1,8000212e <growproc+0x3c>
  } else if(n < 0){
    80002114:	0204cc63          	bltz	s1,8000214c <growproc+0x5a>
  p->sz = sz;
    80002118:	1602                	slli	a2,a2,0x20
    8000211a:	9201                	srli	a2,a2,0x20
    8000211c:	04c93423          	sd	a2,72(s2)
  return 0;
    80002120:	4501                	li	a0,0
}
    80002122:	60e2                	ld	ra,24(sp)
    80002124:	6442                	ld	s0,16(sp)
    80002126:	64a2                	ld	s1,8(sp)
    80002128:	6902                	ld	s2,0(sp)
    8000212a:	6105                	addi	sp,sp,32
    8000212c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    8000212e:	9e25                	addw	a2,a2,s1
    80002130:	1602                	slli	a2,a2,0x20
    80002132:	9201                	srli	a2,a2,0x20
    80002134:	1582                	slli	a1,a1,0x20
    80002136:	9181                	srli	a1,a1,0x20
    80002138:	6928                	ld	a0,80(a0)
    8000213a:	fffff097          	auipc	ra,0xfffff
    8000213e:	2d8080e7          	jalr	728(ra) # 80001412 <uvmalloc>
    80002142:	0005061b          	sext.w	a2,a0
    80002146:	fa69                	bnez	a2,80002118 <growproc+0x26>
      return -1;
    80002148:	557d                	li	a0,-1
    8000214a:	bfe1                	j	80002122 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000214c:	9e25                	addw	a2,a2,s1
    8000214e:	1602                	slli	a2,a2,0x20
    80002150:	9201                	srli	a2,a2,0x20
    80002152:	1582                	slli	a1,a1,0x20
    80002154:	9181                	srli	a1,a1,0x20
    80002156:	6928                	ld	a0,80(a0)
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	272080e7          	jalr	626(ra) # 800013ca <uvmdealloc>
    80002160:	0005061b          	sext.w	a2,a0
    80002164:	bf55                	j	80002118 <growproc+0x26>

0000000080002166 <fork_mmap>:
{
    80002166:	7179                	addi	sp,sp,-48
    80002168:	f406                	sd	ra,40(sp)
    8000216a:	f022                	sd	s0,32(sp)
    8000216c:	ec26                	sd	s1,24(sp)
    8000216e:	e84a                	sd	s2,16(sp)
    80002170:	e44e                	sd	s3,8(sp)
    80002172:	1800                	addi	s0,sp,48
  for(int i = 0; i < NVMA; i++){
    80002174:	16858493          	addi	s1,a1,360
    80002178:	16850913          	addi	s2,a0,360
    8000217c:	4e850993          	addi	s3,a0,1256
    80002180:	a039                	j	8000218e <fork_mmap+0x28>
    80002182:	03848493          	addi	s1,s1,56
    80002186:	03890913          	addi	s2,s2,56
    8000218a:	03390f63          	beq	s2,s3,800021c8 <fork_mmap+0x62>
    if(p->vmas[i].used){
    8000218e:	409c                	lw	a5,0(s1)
    80002190:	dbed                	beqz	a5,80002182 <fork_mmap+0x1c>
      np->vmas[i] = p->vmas[i];
    80002192:	0004b803          	ld	a6,0(s1)
    80002196:	648c                	ld	a1,8(s1)
    80002198:	6890                	ld	a2,16(s1)
    8000219a:	6c94                	ld	a3,24(s1)
    8000219c:	7088                	ld	a0,32(s1)
    8000219e:	7498                	ld	a4,40(s1)
    800021a0:	789c                	ld	a5,48(s1)
    800021a2:	01093023          	sd	a6,0(s2)
    800021a6:	00b93423          	sd	a1,8(s2)
    800021aa:	00c93823          	sd	a2,16(s2)
    800021ae:	00d93c23          	sd	a3,24(s2)
    800021b2:	02a93023          	sd	a0,32(s2)
    800021b6:	02e93423          	sd	a4,40(s2)
    800021ba:	02f93823          	sd	a5,48(s2)
      filedup(np->vmas[i].f);
    800021be:	00002097          	auipc	ra,0x2
    800021c2:	764080e7          	jalr	1892(ra) # 80004922 <filedup>
    800021c6:	bf75                	j	80002182 <fork_mmap+0x1c>
}
    800021c8:	70a2                	ld	ra,40(sp)
    800021ca:	7402                	ld	s0,32(sp)
    800021cc:	64e2                	ld	s1,24(sp)
    800021ce:	6942                	ld	s2,16(sp)
    800021d0:	69a2                	ld	s3,8(sp)
    800021d2:	6145                	addi	sp,sp,48
    800021d4:	8082                	ret

00000000800021d6 <fork>:
{
    800021d6:	7139                	addi	sp,sp,-64
    800021d8:	fc06                	sd	ra,56(sp)
    800021da:	f822                	sd	s0,48(sp)
    800021dc:	f426                	sd	s1,40(sp)
    800021de:	f04a                	sd	s2,32(sp)
    800021e0:	ec4e                	sd	s3,24(sp)
    800021e2:	e852                	sd	s4,16(sp)
    800021e4:	e456                	sd	s5,8(sp)
    800021e6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800021e8:	00000097          	auipc	ra,0x0
    800021ec:	bbe080e7          	jalr	-1090(ra) # 80001da6 <myproc>
    800021f0:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800021f2:	00000097          	auipc	ra,0x0
    800021f6:	dbe080e7          	jalr	-578(ra) # 80001fb0 <allocproc>
    800021fa:	c96d                	beqz	a0,800022ec <fork+0x116>
    800021fc:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800021fe:	048ab603          	ld	a2,72(s5)
    80002202:	692c                	ld	a1,80(a0)
    80002204:	050ab503          	ld	a0,80(s5)
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	356080e7          	jalr	854(ra) # 8000155e <uvmcopy>
    80002210:	04054a63          	bltz	a0,80002264 <fork+0x8e>
  np->sz = p->sz;
    80002214:	048ab783          	ld	a5,72(s5)
    80002218:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    8000221c:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80002220:	058ab683          	ld	a3,88(s5)
    80002224:	87b6                	mv	a5,a3
    80002226:	058a3703          	ld	a4,88(s4)
    8000222a:	12068693          	addi	a3,a3,288
    8000222e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002232:	6788                	ld	a0,8(a5)
    80002234:	6b8c                	ld	a1,16(a5)
    80002236:	6f90                	ld	a2,24(a5)
    80002238:	01073023          	sd	a6,0(a4)
    8000223c:	e708                	sd	a0,8(a4)
    8000223e:	eb0c                	sd	a1,16(a4)
    80002240:	ef10                	sd	a2,24(a4)
    80002242:	02078793          	addi	a5,a5,32
    80002246:	02070713          	addi	a4,a4,32
    8000224a:	fed792e3          	bne	a5,a3,8000222e <fork+0x58>
  np->trapframe->a0 = 0;
    8000224e:	058a3783          	ld	a5,88(s4)
    80002252:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002256:	0d0a8493          	addi	s1,s5,208
    8000225a:	0d0a0913          	addi	s2,s4,208
    8000225e:	150a8993          	addi	s3,s5,336
    80002262:	a00d                	j	80002284 <fork+0xae>
    freeproc(np);
    80002264:	8552                	mv	a0,s4
    80002266:	00000097          	auipc	ra,0x0
    8000226a:	cf2080e7          	jalr	-782(ra) # 80001f58 <freeproc>
    release(&np->lock);
    8000226e:	8552                	mv	a0,s4
    80002270:	fffff097          	auipc	ra,0xfffff
    80002274:	a06080e7          	jalr	-1530(ra) # 80000c76 <release>
    return -1;
    80002278:	54fd                	li	s1,-1
    8000227a:	a8b9                	j	800022d8 <fork+0x102>
  for(i = 0; i < NOFILE; i++)
    8000227c:	04a1                	addi	s1,s1,8
    8000227e:	0921                	addi	s2,s2,8
    80002280:	01348b63          	beq	s1,s3,80002296 <fork+0xc0>
    if(p->ofile[i])
    80002284:	6088                	ld	a0,0(s1)
    80002286:	d97d                	beqz	a0,8000227c <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80002288:	00002097          	auipc	ra,0x2
    8000228c:	69a080e7          	jalr	1690(ra) # 80004922 <filedup>
    80002290:	00a93023          	sd	a0,0(s2)
    80002294:	b7e5                	j	8000227c <fork+0xa6>
  np->cwd = idup(p->cwd);
    80002296:	150ab503          	ld	a0,336(s5)
    8000229a:	00001097          	auipc	ra,0x1
    8000229e:	7f6080e7          	jalr	2038(ra) # 80003a90 <idup>
    800022a2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800022a6:	4641                	li	a2,16
    800022a8:	158a8593          	addi	a1,s5,344
    800022ac:	158a0513          	addi	a0,s4,344
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	b60080e7          	jalr	-1184(ra) # 80000e10 <safestrcpy>
  fork_mmap(np, p);
    800022b8:	85d6                	mv	a1,s5
    800022ba:	8552                	mv	a0,s4
    800022bc:	00000097          	auipc	ra,0x0
    800022c0:	eaa080e7          	jalr	-342(ra) # 80002166 <fork_mmap>
  pid = np->pid;
    800022c4:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    800022c8:	4789                	li	a5,2
    800022ca:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800022ce:	8552                	mv	a0,s4
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	9a6080e7          	jalr	-1626(ra) # 80000c76 <release>
}
    800022d8:	8526                	mv	a0,s1
    800022da:	70e2                	ld	ra,56(sp)
    800022dc:	7442                	ld	s0,48(sp)
    800022de:	74a2                	ld	s1,40(sp)
    800022e0:	7902                	ld	s2,32(sp)
    800022e2:	69e2                	ld	s3,24(sp)
    800022e4:	6a42                	ld	s4,16(sp)
    800022e6:	6aa2                	ld	s5,8(sp)
    800022e8:	6121                	addi	sp,sp,64
    800022ea:	8082                	ret
    return -1;
    800022ec:	54fd                	li	s1,-1
    800022ee:	b7ed                	j	800022d8 <fork+0x102>

00000000800022f0 <reparent>:
{
    800022f0:	7179                	addi	sp,sp,-48
    800022f2:	f406                	sd	ra,40(sp)
    800022f4:	f022                	sd	s0,32(sp)
    800022f6:	ec26                	sd	s1,24(sp)
    800022f8:	e84a                	sd	s2,16(sp)
    800022fa:	e44e                	sd	s3,8(sp)
    800022fc:	e052                	sd	s4,0(sp)
    800022fe:	1800                	addi	s0,sp,48
    80002300:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002302:	0000f497          	auipc	s1,0xf
    80002306:	3b648493          	addi	s1,s1,950 # 800116b8 <proc>
      pp->parent = initproc;
    8000230a:	00007a17          	auipc	s4,0x7
    8000230e:	d1ea0a13          	addi	s4,s4,-738 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002312:	00023997          	auipc	s3,0x23
    80002316:	da698993          	addi	s3,s3,-602 # 800250b8 <tickslock>
    8000231a:	a029                	j	80002324 <reparent+0x34>
    8000231c:	4e848493          	addi	s1,s1,1256
    80002320:	03348363          	beq	s1,s3,80002346 <reparent+0x56>
    if(pp->parent == p){
    80002324:	709c                	ld	a5,32(s1)
    80002326:	ff279be3          	bne	a5,s2,8000231c <reparent+0x2c>
      acquire(&pp->lock);
    8000232a:	8526                	mv	a0,s1
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	896080e7          	jalr	-1898(ra) # 80000bc2 <acquire>
      pp->parent = initproc;
    80002334:	000a3783          	ld	a5,0(s4)
    80002338:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    8000233a:	8526                	mv	a0,s1
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	93a080e7          	jalr	-1734(ra) # 80000c76 <release>
    80002344:	bfe1                	j	8000231c <reparent+0x2c>
}
    80002346:	70a2                	ld	ra,40(sp)
    80002348:	7402                	ld	s0,32(sp)
    8000234a:	64e2                	ld	s1,24(sp)
    8000234c:	6942                	ld	s2,16(sp)
    8000234e:	69a2                	ld	s3,8(sp)
    80002350:	6a02                	ld	s4,0(sp)
    80002352:	6145                	addi	sp,sp,48
    80002354:	8082                	ret

0000000080002356 <scheduler>:
{
    80002356:	711d                	addi	sp,sp,-96
    80002358:	ec86                	sd	ra,88(sp)
    8000235a:	e8a2                	sd	s0,80(sp)
    8000235c:	e4a6                	sd	s1,72(sp)
    8000235e:	e0ca                	sd	s2,64(sp)
    80002360:	fc4e                	sd	s3,56(sp)
    80002362:	f852                	sd	s4,48(sp)
    80002364:	f456                	sd	s5,40(sp)
    80002366:	f05a                	sd	s6,32(sp)
    80002368:	ec5e                	sd	s7,24(sp)
    8000236a:	e862                	sd	s8,16(sp)
    8000236c:	e466                	sd	s9,8(sp)
    8000236e:	1080                	addi	s0,sp,96
    80002370:	8792                	mv	a5,tp
  int id = r_tp();
    80002372:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002374:	00779c13          	slli	s8,a5,0x7
    80002378:	0000f717          	auipc	a4,0xf
    8000237c:	f2870713          	addi	a4,a4,-216 # 800112a0 <pid_lock>
    80002380:	9762                	add	a4,a4,s8
    80002382:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80002386:	0000f717          	auipc	a4,0xf
    8000238a:	f3a70713          	addi	a4,a4,-198 # 800112c0 <cpus+0x8>
    8000238e:	9c3a                	add	s8,s8,a4
    int nproc = 0;
    80002390:	4c81                	li	s9,0
      if(p->state == RUNNABLE) {
    80002392:	4a89                	li	s5,2
        c->proc = p;
    80002394:	079e                	slli	a5,a5,0x7
    80002396:	0000fb17          	auipc	s6,0xf
    8000239a:	f0ab0b13          	addi	s6,s6,-246 # 800112a0 <pid_lock>
    8000239e:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800023a0:	00023a17          	auipc	s4,0x23
    800023a4:	d18a0a13          	addi	s4,s4,-744 # 800250b8 <tickslock>
    800023a8:	a8a1                	j	80002400 <scheduler+0xaa>
      release(&p->lock);
    800023aa:	8526                	mv	a0,s1
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	8ca080e7          	jalr	-1846(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800023b4:	4e848493          	addi	s1,s1,1256
    800023b8:	03448a63          	beq	s1,s4,800023ec <scheduler+0x96>
      acquire(&p->lock);
    800023bc:	8526                	mv	a0,s1
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	804080e7          	jalr	-2044(ra) # 80000bc2 <acquire>
      if(p->state != UNUSED) {
    800023c6:	4c9c                	lw	a5,24(s1)
    800023c8:	d3ed                	beqz	a5,800023aa <scheduler+0x54>
        nproc++;
    800023ca:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    800023cc:	fd579fe3          	bne	a5,s5,800023aa <scheduler+0x54>
        p->state = RUNNING;
    800023d0:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    800023d4:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    800023d8:	06048593          	addi	a1,s1,96
    800023dc:	8562                	mv	a0,s8
    800023de:	00000097          	auipc	ra,0x0
    800023e2:	634080e7          	jalr	1588(ra) # 80002a12 <swtch>
        c->proc = 0;
    800023e6:	000b3c23          	sd	zero,24(s6)
    800023ea:	b7c1                	j	800023aa <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    800023ec:	013aca63          	blt	s5,s3,80002400 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023f0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800023f4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023f8:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800023fc:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002400:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002404:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002408:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    8000240c:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    8000240e:	0000f497          	auipc	s1,0xf
    80002412:	2aa48493          	addi	s1,s1,682 # 800116b8 <proc>
        p->state = RUNNING;
    80002416:	4b8d                	li	s7,3
    80002418:	b755                	j	800023bc <scheduler+0x66>

000000008000241a <sched>:
{
    8000241a:	7179                	addi	sp,sp,-48
    8000241c:	f406                	sd	ra,40(sp)
    8000241e:	f022                	sd	s0,32(sp)
    80002420:	ec26                	sd	s1,24(sp)
    80002422:	e84a                	sd	s2,16(sp)
    80002424:	e44e                	sd	s3,8(sp)
    80002426:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002428:	00000097          	auipc	ra,0x0
    8000242c:	97e080e7          	jalr	-1666(ra) # 80001da6 <myproc>
    80002430:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002432:	ffffe097          	auipc	ra,0xffffe
    80002436:	716080e7          	jalr	1814(ra) # 80000b48 <holding>
    8000243a:	c93d                	beqz	a0,800024b0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000243c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000243e:	2781                	sext.w	a5,a5
    80002440:	079e                	slli	a5,a5,0x7
    80002442:	0000f717          	auipc	a4,0xf
    80002446:	e5e70713          	addi	a4,a4,-418 # 800112a0 <pid_lock>
    8000244a:	97ba                	add	a5,a5,a4
    8000244c:	0907a703          	lw	a4,144(a5)
    80002450:	4785                	li	a5,1
    80002452:	06f71763          	bne	a4,a5,800024c0 <sched+0xa6>
  if(p->state == RUNNING)
    80002456:	4c98                	lw	a4,24(s1)
    80002458:	478d                	li	a5,3
    8000245a:	06f70b63          	beq	a4,a5,800024d0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000245e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002462:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002464:	efb5                	bnez	a5,800024e0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002466:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002468:	0000f917          	auipc	s2,0xf
    8000246c:	e3890913          	addi	s2,s2,-456 # 800112a0 <pid_lock>
    80002470:	2781                	sext.w	a5,a5
    80002472:	079e                	slli	a5,a5,0x7
    80002474:	97ca                	add	a5,a5,s2
    80002476:	0947a983          	lw	s3,148(a5)
    8000247a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000247c:	2781                	sext.w	a5,a5
    8000247e:	079e                	slli	a5,a5,0x7
    80002480:	0000f597          	auipc	a1,0xf
    80002484:	e4058593          	addi	a1,a1,-448 # 800112c0 <cpus+0x8>
    80002488:	95be                	add	a1,a1,a5
    8000248a:	06048513          	addi	a0,s1,96
    8000248e:	00000097          	auipc	ra,0x0
    80002492:	584080e7          	jalr	1412(ra) # 80002a12 <swtch>
    80002496:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002498:	2781                	sext.w	a5,a5
    8000249a:	079e                	slli	a5,a5,0x7
    8000249c:	97ca                	add	a5,a5,s2
    8000249e:	0937aa23          	sw	s3,148(a5)
}
    800024a2:	70a2                	ld	ra,40(sp)
    800024a4:	7402                	ld	s0,32(sp)
    800024a6:	64e2                	ld	s1,24(sp)
    800024a8:	6942                	ld	s2,16(sp)
    800024aa:	69a2                	ld	s3,8(sp)
    800024ac:	6145                	addi	sp,sp,48
    800024ae:	8082                	ret
    panic("sched p->lock");
    800024b0:	00006517          	auipc	a0,0x6
    800024b4:	d4850513          	addi	a0,a0,-696 # 800081f8 <digits+0x1b8>
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	072080e7          	jalr	114(ra) # 8000052a <panic>
    panic("sched locks");
    800024c0:	00006517          	auipc	a0,0x6
    800024c4:	d4850513          	addi	a0,a0,-696 # 80008208 <digits+0x1c8>
    800024c8:	ffffe097          	auipc	ra,0xffffe
    800024cc:	062080e7          	jalr	98(ra) # 8000052a <panic>
    panic("sched running");
    800024d0:	00006517          	auipc	a0,0x6
    800024d4:	d4850513          	addi	a0,a0,-696 # 80008218 <digits+0x1d8>
    800024d8:	ffffe097          	auipc	ra,0xffffe
    800024dc:	052080e7          	jalr	82(ra) # 8000052a <panic>
    panic("sched interruptible");
    800024e0:	00006517          	auipc	a0,0x6
    800024e4:	d4850513          	addi	a0,a0,-696 # 80008228 <digits+0x1e8>
    800024e8:	ffffe097          	auipc	ra,0xffffe
    800024ec:	042080e7          	jalr	66(ra) # 8000052a <panic>

00000000800024f0 <exit>:
{
    800024f0:	7179                	addi	sp,sp,-48
    800024f2:	f406                	sd	ra,40(sp)
    800024f4:	f022                	sd	s0,32(sp)
    800024f6:	ec26                	sd	s1,24(sp)
    800024f8:	e84a                	sd	s2,16(sp)
    800024fa:	e44e                	sd	s3,8(sp)
    800024fc:	e052                	sd	s4,0(sp)
    800024fe:	1800                	addi	s0,sp,48
    80002500:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002502:	00000097          	auipc	ra,0x0
    80002506:	8a4080e7          	jalr	-1884(ra) # 80001da6 <myproc>
    8000250a:	892a                	mv	s2,a0
  if(p == initproc)
    8000250c:	00007797          	auipc	a5,0x7
    80002510:	b1c7b783          	ld	a5,-1252(a5) # 80009028 <initproc>
    80002514:	0d050493          	addi	s1,a0,208
    80002518:	15050993          	addi	s3,a0,336
    8000251c:	02a79363          	bne	a5,a0,80002542 <exit+0x52>
    panic("init exiting");
    80002520:	00006517          	auipc	a0,0x6
    80002524:	d2050513          	addi	a0,a0,-736 # 80008240 <digits+0x200>
    80002528:	ffffe097          	auipc	ra,0xffffe
    8000252c:	002080e7          	jalr	2(ra) # 8000052a <panic>
      fileclose(f);
    80002530:	00002097          	auipc	ra,0x2
    80002534:	444080e7          	jalr	1092(ra) # 80004974 <fileclose>
      p->ofile[fd] = 0;
    80002538:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000253c:	04a1                	addi	s1,s1,8
    8000253e:	01348563          	beq	s1,s3,80002548 <exit+0x58>
    if(p->ofile[fd]){
    80002542:	6088                	ld	a0,0(s1)
    80002544:	f575                	bnez	a0,80002530 <exit+0x40>
    80002546:	bfdd                	j	8000253c <exit+0x4c>
    80002548:	16890493          	addi	s1,s2,360
    8000254c:	4e890993          	addi	s3,s2,1256
    80002550:	a029                	j	8000255a <exit+0x6a>
  for(int i = 0; i < NVMA; i++){
    80002552:	03848493          	addi	s1,s1,56
    80002556:	01348d63          	beq	s1,s3,80002570 <exit+0x80>
    if(p->vmas[i].used){
    8000255a:	409c                	lw	a5,0(s1)
    8000255c:	dbfd                	beqz	a5,80002552 <exit+0x62>
      munmap(p->vmas[i].start, p->vmas[i].length);
    8000255e:	488c                	lw	a1,16(s1)
    80002560:	7488                	ld	a0,40(s1)
    80002562:	fffff097          	auipc	ra,0xfffff
    80002566:	4fe080e7          	jalr	1278(ra) # 80001a60 <munmap>
      p->vmas[i].used = 0;
    8000256a:	0004a023          	sw	zero,0(s1)
    8000256e:	b7d5                	j	80002552 <exit+0x62>
  begin_op();
    80002570:	00002097          	auipc	ra,0x2
    80002574:	f30080e7          	jalr	-208(ra) # 800044a0 <begin_op>
  iput(p->cwd);
    80002578:	15093503          	ld	a0,336(s2)
    8000257c:	00001097          	auipc	ra,0x1
    80002580:	70c080e7          	jalr	1804(ra) # 80003c88 <iput>
  end_op();
    80002584:	00002097          	auipc	ra,0x2
    80002588:	f9c080e7          	jalr	-100(ra) # 80004520 <end_op>
  p->cwd = 0;
    8000258c:	14093823          	sd	zero,336(s2)
  acquire(&initproc->lock);
    80002590:	00007497          	auipc	s1,0x7
    80002594:	a9848493          	addi	s1,s1,-1384 # 80009028 <initproc>
    80002598:	6088                	ld	a0,0(s1)
    8000259a:	ffffe097          	auipc	ra,0xffffe
    8000259e:	628080e7          	jalr	1576(ra) # 80000bc2 <acquire>
  wakeup1(initproc);
    800025a2:	6088                	ld	a0,0(s1)
    800025a4:	fffff097          	auipc	ra,0xfffff
    800025a8:	664080e7          	jalr	1636(ra) # 80001c08 <wakeup1>
  release(&initproc->lock);
    800025ac:	6088                	ld	a0,0(s1)
    800025ae:	ffffe097          	auipc	ra,0xffffe
    800025b2:	6c8080e7          	jalr	1736(ra) # 80000c76 <release>
  acquire(&p->lock);
    800025b6:	854a                	mv	a0,s2
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	60a080e7          	jalr	1546(ra) # 80000bc2 <acquire>
  struct proc *original_parent = p->parent;
    800025c0:	02093483          	ld	s1,32(s2)
  release(&p->lock);
    800025c4:	854a                	mv	a0,s2
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	6b0080e7          	jalr	1712(ra) # 80000c76 <release>
  acquire(&original_parent->lock);
    800025ce:	8526                	mv	a0,s1
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	5f2080e7          	jalr	1522(ra) # 80000bc2 <acquire>
  acquire(&p->lock);
    800025d8:	854a                	mv	a0,s2
    800025da:	ffffe097          	auipc	ra,0xffffe
    800025de:	5e8080e7          	jalr	1512(ra) # 80000bc2 <acquire>
  reparent(p);
    800025e2:	854a                	mv	a0,s2
    800025e4:	00000097          	auipc	ra,0x0
    800025e8:	d0c080e7          	jalr	-756(ra) # 800022f0 <reparent>
  wakeup1(original_parent);
    800025ec:	8526                	mv	a0,s1
    800025ee:	fffff097          	auipc	ra,0xfffff
    800025f2:	61a080e7          	jalr	1562(ra) # 80001c08 <wakeup1>
  p->xstate = status;
    800025f6:	03492a23          	sw	s4,52(s2)
  p->state = ZOMBIE;
    800025fa:	4791                	li	a5,4
    800025fc:	00f92c23          	sw	a5,24(s2)
  release(&original_parent->lock);
    80002600:	8526                	mv	a0,s1
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	674080e7          	jalr	1652(ra) # 80000c76 <release>
  sched();
    8000260a:	00000097          	auipc	ra,0x0
    8000260e:	e10080e7          	jalr	-496(ra) # 8000241a <sched>
  panic("zombie exit");
    80002612:	00006517          	auipc	a0,0x6
    80002616:	c3e50513          	addi	a0,a0,-962 # 80008250 <digits+0x210>
    8000261a:	ffffe097          	auipc	ra,0xffffe
    8000261e:	f10080e7          	jalr	-240(ra) # 8000052a <panic>

0000000080002622 <yield>:
{
    80002622:	1101                	addi	sp,sp,-32
    80002624:	ec06                	sd	ra,24(sp)
    80002626:	e822                	sd	s0,16(sp)
    80002628:	e426                	sd	s1,8(sp)
    8000262a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000262c:	fffff097          	auipc	ra,0xfffff
    80002630:	77a080e7          	jalr	1914(ra) # 80001da6 <myproc>
    80002634:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002636:	ffffe097          	auipc	ra,0xffffe
    8000263a:	58c080e7          	jalr	1420(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    8000263e:	4789                	li	a5,2
    80002640:	cc9c                	sw	a5,24(s1)
  sched();
    80002642:	00000097          	auipc	ra,0x0
    80002646:	dd8080e7          	jalr	-552(ra) # 8000241a <sched>
  release(&p->lock);
    8000264a:	8526                	mv	a0,s1
    8000264c:	ffffe097          	auipc	ra,0xffffe
    80002650:	62a080e7          	jalr	1578(ra) # 80000c76 <release>
}
    80002654:	60e2                	ld	ra,24(sp)
    80002656:	6442                	ld	s0,16(sp)
    80002658:	64a2                	ld	s1,8(sp)
    8000265a:	6105                	addi	sp,sp,32
    8000265c:	8082                	ret

000000008000265e <sleep>:
{
    8000265e:	7179                	addi	sp,sp,-48
    80002660:	f406                	sd	ra,40(sp)
    80002662:	f022                	sd	s0,32(sp)
    80002664:	ec26                	sd	s1,24(sp)
    80002666:	e84a                	sd	s2,16(sp)
    80002668:	e44e                	sd	s3,8(sp)
    8000266a:	1800                	addi	s0,sp,48
    8000266c:	89aa                	mv	s3,a0
    8000266e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002670:	fffff097          	auipc	ra,0xfffff
    80002674:	736080e7          	jalr	1846(ra) # 80001da6 <myproc>
    80002678:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000267a:	05250663          	beq	a0,s2,800026c6 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	544080e7          	jalr	1348(ra) # 80000bc2 <acquire>
    release(lk);
    80002686:	854a                	mv	a0,s2
    80002688:	ffffe097          	auipc	ra,0xffffe
    8000268c:	5ee080e7          	jalr	1518(ra) # 80000c76 <release>
  p->chan = chan;
    80002690:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002694:	4785                	li	a5,1
    80002696:	cc9c                	sw	a5,24(s1)
  sched();
    80002698:	00000097          	auipc	ra,0x0
    8000269c:	d82080e7          	jalr	-638(ra) # 8000241a <sched>
  p->chan = 0;
    800026a0:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800026a4:	8526                	mv	a0,s1
    800026a6:	ffffe097          	auipc	ra,0xffffe
    800026aa:	5d0080e7          	jalr	1488(ra) # 80000c76 <release>
    acquire(lk);
    800026ae:	854a                	mv	a0,s2
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	512080e7          	jalr	1298(ra) # 80000bc2 <acquire>
}
    800026b8:	70a2                	ld	ra,40(sp)
    800026ba:	7402                	ld	s0,32(sp)
    800026bc:	64e2                	ld	s1,24(sp)
    800026be:	6942                	ld	s2,16(sp)
    800026c0:	69a2                	ld	s3,8(sp)
    800026c2:	6145                	addi	sp,sp,48
    800026c4:	8082                	ret
  p->chan = chan;
    800026c6:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800026ca:	4785                	li	a5,1
    800026cc:	cd1c                	sw	a5,24(a0)
  sched();
    800026ce:	00000097          	auipc	ra,0x0
    800026d2:	d4c080e7          	jalr	-692(ra) # 8000241a <sched>
  p->chan = 0;
    800026d6:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800026da:	bff9                	j	800026b8 <sleep+0x5a>

00000000800026dc <wait>:
{
    800026dc:	715d                	addi	sp,sp,-80
    800026de:	e486                	sd	ra,72(sp)
    800026e0:	e0a2                	sd	s0,64(sp)
    800026e2:	fc26                	sd	s1,56(sp)
    800026e4:	f84a                	sd	s2,48(sp)
    800026e6:	f44e                	sd	s3,40(sp)
    800026e8:	f052                	sd	s4,32(sp)
    800026ea:	ec56                	sd	s5,24(sp)
    800026ec:	e85a                	sd	s6,16(sp)
    800026ee:	e45e                	sd	s7,8(sp)
    800026f0:	0880                	addi	s0,sp,80
    800026f2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800026f4:	fffff097          	auipc	ra,0xfffff
    800026f8:	6b2080e7          	jalr	1714(ra) # 80001da6 <myproc>
    800026fc:	892a                	mv	s2,a0
  acquire(&p->lock);
    800026fe:	ffffe097          	auipc	ra,0xffffe
    80002702:	4c4080e7          	jalr	1220(ra) # 80000bc2 <acquire>
    havekids = 0;
    80002706:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002708:	4a11                	li	s4,4
        havekids = 1;
    8000270a:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000270c:	00023997          	auipc	s3,0x23
    80002710:	9ac98993          	addi	s3,s3,-1620 # 800250b8 <tickslock>
    havekids = 0;
    80002714:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002716:	0000f497          	auipc	s1,0xf
    8000271a:	fa248493          	addi	s1,s1,-94 # 800116b8 <proc>
    8000271e:	a08d                	j	80002780 <wait+0xa4>
          pid = np->pid;
    80002720:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002724:	000b0e63          	beqz	s6,80002740 <wait+0x64>
    80002728:	4691                	li	a3,4
    8000272a:	03448613          	addi	a2,s1,52
    8000272e:	85da                	mv	a1,s6
    80002730:	05093503          	ld	a0,80(s2)
    80002734:	fffff097          	auipc	ra,0xfffff
    80002738:	f2e080e7          	jalr	-210(ra) # 80001662 <copyout>
    8000273c:	02054263          	bltz	a0,80002760 <wait+0x84>
          freeproc(np);
    80002740:	8526                	mv	a0,s1
    80002742:	00000097          	auipc	ra,0x0
    80002746:	816080e7          	jalr	-2026(ra) # 80001f58 <freeproc>
          release(&np->lock);
    8000274a:	8526                	mv	a0,s1
    8000274c:	ffffe097          	auipc	ra,0xffffe
    80002750:	52a080e7          	jalr	1322(ra) # 80000c76 <release>
          release(&p->lock);
    80002754:	854a                	mv	a0,s2
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	520080e7          	jalr	1312(ra) # 80000c76 <release>
          return pid;
    8000275e:	a8a9                	j	800027b8 <wait+0xdc>
            release(&np->lock);
    80002760:	8526                	mv	a0,s1
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	514080e7          	jalr	1300(ra) # 80000c76 <release>
            release(&p->lock);
    8000276a:	854a                	mv	a0,s2
    8000276c:	ffffe097          	auipc	ra,0xffffe
    80002770:	50a080e7          	jalr	1290(ra) # 80000c76 <release>
            return -1;
    80002774:	59fd                	li	s3,-1
    80002776:	a089                	j	800027b8 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002778:	4e848493          	addi	s1,s1,1256
    8000277c:	03348463          	beq	s1,s3,800027a4 <wait+0xc8>
      if(np->parent == p){
    80002780:	709c                	ld	a5,32(s1)
    80002782:	ff279be3          	bne	a5,s2,80002778 <wait+0x9c>
        acquire(&np->lock);
    80002786:	8526                	mv	a0,s1
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	43a080e7          	jalr	1082(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    80002790:	4c9c                	lw	a5,24(s1)
    80002792:	f94787e3          	beq	a5,s4,80002720 <wait+0x44>
        release(&np->lock);
    80002796:	8526                	mv	a0,s1
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	4de080e7          	jalr	1246(ra) # 80000c76 <release>
        havekids = 1;
    800027a0:	8756                	mv	a4,s5
    800027a2:	bfd9                	j	80002778 <wait+0x9c>
    if(!havekids || p->killed){
    800027a4:	c701                	beqz	a4,800027ac <wait+0xd0>
    800027a6:	03092783          	lw	a5,48(s2)
    800027aa:	c39d                	beqz	a5,800027d0 <wait+0xf4>
      release(&p->lock);
    800027ac:	854a                	mv	a0,s2
    800027ae:	ffffe097          	auipc	ra,0xffffe
    800027b2:	4c8080e7          	jalr	1224(ra) # 80000c76 <release>
      return -1;
    800027b6:	59fd                	li	s3,-1
}
    800027b8:	854e                	mv	a0,s3
    800027ba:	60a6                	ld	ra,72(sp)
    800027bc:	6406                	ld	s0,64(sp)
    800027be:	74e2                	ld	s1,56(sp)
    800027c0:	7942                	ld	s2,48(sp)
    800027c2:	79a2                	ld	s3,40(sp)
    800027c4:	7a02                	ld	s4,32(sp)
    800027c6:	6ae2                	ld	s5,24(sp)
    800027c8:	6b42                	ld	s6,16(sp)
    800027ca:	6ba2                	ld	s7,8(sp)
    800027cc:	6161                	addi	sp,sp,80
    800027ce:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800027d0:	85ca                	mv	a1,s2
    800027d2:	854a                	mv	a0,s2
    800027d4:	00000097          	auipc	ra,0x0
    800027d8:	e8a080e7          	jalr	-374(ra) # 8000265e <sleep>
    havekids = 0;
    800027dc:	bf25                	j	80002714 <wait+0x38>

00000000800027de <wakeup>:
{
    800027de:	7139                	addi	sp,sp,-64
    800027e0:	fc06                	sd	ra,56(sp)
    800027e2:	f822                	sd	s0,48(sp)
    800027e4:	f426                	sd	s1,40(sp)
    800027e6:	f04a                	sd	s2,32(sp)
    800027e8:	ec4e                	sd	s3,24(sp)
    800027ea:	e852                	sd	s4,16(sp)
    800027ec:	e456                	sd	s5,8(sp)
    800027ee:	0080                	addi	s0,sp,64
    800027f0:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800027f2:	0000f497          	auipc	s1,0xf
    800027f6:	ec648493          	addi	s1,s1,-314 # 800116b8 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800027fa:	4985                	li	s3,1
      p->state = RUNNABLE;
    800027fc:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800027fe:	00023917          	auipc	s2,0x23
    80002802:	8ba90913          	addi	s2,s2,-1862 # 800250b8 <tickslock>
    80002806:	a811                	j	8000281a <wakeup+0x3c>
    release(&p->lock);
    80002808:	8526                	mv	a0,s1
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	46c080e7          	jalr	1132(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002812:	4e848493          	addi	s1,s1,1256
    80002816:	03248063          	beq	s1,s2,80002836 <wakeup+0x58>
    acquire(&p->lock);
    8000281a:	8526                	mv	a0,s1
    8000281c:	ffffe097          	auipc	ra,0xffffe
    80002820:	3a6080e7          	jalr	934(ra) # 80000bc2 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002824:	4c9c                	lw	a5,24(s1)
    80002826:	ff3791e3          	bne	a5,s3,80002808 <wakeup+0x2a>
    8000282a:	749c                	ld	a5,40(s1)
    8000282c:	fd479ee3          	bne	a5,s4,80002808 <wakeup+0x2a>
      p->state = RUNNABLE;
    80002830:	0154ac23          	sw	s5,24(s1)
    80002834:	bfd1                	j	80002808 <wakeup+0x2a>
}
    80002836:	70e2                	ld	ra,56(sp)
    80002838:	7442                	ld	s0,48(sp)
    8000283a:	74a2                	ld	s1,40(sp)
    8000283c:	7902                	ld	s2,32(sp)
    8000283e:	69e2                	ld	s3,24(sp)
    80002840:	6a42                	ld	s4,16(sp)
    80002842:	6aa2                	ld	s5,8(sp)
    80002844:	6121                	addi	sp,sp,64
    80002846:	8082                	ret

0000000080002848 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002848:	7179                	addi	sp,sp,-48
    8000284a:	f406                	sd	ra,40(sp)
    8000284c:	f022                	sd	s0,32(sp)
    8000284e:	ec26                	sd	s1,24(sp)
    80002850:	e84a                	sd	s2,16(sp)
    80002852:	e44e                	sd	s3,8(sp)
    80002854:	1800                	addi	s0,sp,48
    80002856:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002858:	0000f497          	auipc	s1,0xf
    8000285c:	e6048493          	addi	s1,s1,-416 # 800116b8 <proc>
    80002860:	00023997          	auipc	s3,0x23
    80002864:	85898993          	addi	s3,s3,-1960 # 800250b8 <tickslock>
    acquire(&p->lock);
    80002868:	8526                	mv	a0,s1
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	358080e7          	jalr	856(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002872:	5c9c                	lw	a5,56(s1)
    80002874:	01278d63          	beq	a5,s2,8000288e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002878:	8526                	mv	a0,s1
    8000287a:	ffffe097          	auipc	ra,0xffffe
    8000287e:	3fc080e7          	jalr	1020(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002882:	4e848493          	addi	s1,s1,1256
    80002886:	ff3491e3          	bne	s1,s3,80002868 <kill+0x20>
  }
  return -1;
    8000288a:	557d                	li	a0,-1
    8000288c:	a821                	j	800028a4 <kill+0x5c>
      p->killed = 1;
    8000288e:	4785                	li	a5,1
    80002890:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002892:	4c98                	lw	a4,24(s1)
    80002894:	00f70f63          	beq	a4,a5,800028b2 <kill+0x6a>
      release(&p->lock);
    80002898:	8526                	mv	a0,s1
    8000289a:	ffffe097          	auipc	ra,0xffffe
    8000289e:	3dc080e7          	jalr	988(ra) # 80000c76 <release>
      return 0;
    800028a2:	4501                	li	a0,0
}
    800028a4:	70a2                	ld	ra,40(sp)
    800028a6:	7402                	ld	s0,32(sp)
    800028a8:	64e2                	ld	s1,24(sp)
    800028aa:	6942                	ld	s2,16(sp)
    800028ac:	69a2                	ld	s3,8(sp)
    800028ae:	6145                	addi	sp,sp,48
    800028b0:	8082                	ret
        p->state = RUNNABLE;
    800028b2:	4789                	li	a5,2
    800028b4:	cc9c                	sw	a5,24(s1)
    800028b6:	b7cd                	j	80002898 <kill+0x50>

00000000800028b8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800028b8:	7179                	addi	sp,sp,-48
    800028ba:	f406                	sd	ra,40(sp)
    800028bc:	f022                	sd	s0,32(sp)
    800028be:	ec26                	sd	s1,24(sp)
    800028c0:	e84a                	sd	s2,16(sp)
    800028c2:	e44e                	sd	s3,8(sp)
    800028c4:	e052                	sd	s4,0(sp)
    800028c6:	1800                	addi	s0,sp,48
    800028c8:	84aa                	mv	s1,a0
    800028ca:	892e                	mv	s2,a1
    800028cc:	89b2                	mv	s3,a2
    800028ce:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028d0:	fffff097          	auipc	ra,0xfffff
    800028d4:	4d6080e7          	jalr	1238(ra) # 80001da6 <myproc>
  if(user_dst){
    800028d8:	c08d                	beqz	s1,800028fa <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800028da:	86d2                	mv	a3,s4
    800028dc:	864e                	mv	a2,s3
    800028de:	85ca                	mv	a1,s2
    800028e0:	6928                	ld	a0,80(a0)
    800028e2:	fffff097          	auipc	ra,0xfffff
    800028e6:	d80080e7          	jalr	-640(ra) # 80001662 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028ea:	70a2                	ld	ra,40(sp)
    800028ec:	7402                	ld	s0,32(sp)
    800028ee:	64e2                	ld	s1,24(sp)
    800028f0:	6942                	ld	s2,16(sp)
    800028f2:	69a2                	ld	s3,8(sp)
    800028f4:	6a02                	ld	s4,0(sp)
    800028f6:	6145                	addi	sp,sp,48
    800028f8:	8082                	ret
    memmove((char *)dst, src, len);
    800028fa:	000a061b          	sext.w	a2,s4
    800028fe:	85ce                	mv	a1,s3
    80002900:	854a                	mv	a0,s2
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	418080e7          	jalr	1048(ra) # 80000d1a <memmove>
    return 0;
    8000290a:	8526                	mv	a0,s1
    8000290c:	bff9                	j	800028ea <either_copyout+0x32>

000000008000290e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000290e:	7179                	addi	sp,sp,-48
    80002910:	f406                	sd	ra,40(sp)
    80002912:	f022                	sd	s0,32(sp)
    80002914:	ec26                	sd	s1,24(sp)
    80002916:	e84a                	sd	s2,16(sp)
    80002918:	e44e                	sd	s3,8(sp)
    8000291a:	e052                	sd	s4,0(sp)
    8000291c:	1800                	addi	s0,sp,48
    8000291e:	892a                	mv	s2,a0
    80002920:	84ae                	mv	s1,a1
    80002922:	89b2                	mv	s3,a2
    80002924:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002926:	fffff097          	auipc	ra,0xfffff
    8000292a:	480080e7          	jalr	1152(ra) # 80001da6 <myproc>
  if(user_src){
    8000292e:	c08d                	beqz	s1,80002950 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002930:	86d2                	mv	a3,s4
    80002932:	864e                	mv	a2,s3
    80002934:	85ca                	mv	a1,s2
    80002936:	6928                	ld	a0,80(a0)
    80002938:	fffff097          	auipc	ra,0xfffff
    8000293c:	db6080e7          	jalr	-586(ra) # 800016ee <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002940:	70a2                	ld	ra,40(sp)
    80002942:	7402                	ld	s0,32(sp)
    80002944:	64e2                	ld	s1,24(sp)
    80002946:	6942                	ld	s2,16(sp)
    80002948:	69a2                	ld	s3,8(sp)
    8000294a:	6a02                	ld	s4,0(sp)
    8000294c:	6145                	addi	sp,sp,48
    8000294e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002950:	000a061b          	sext.w	a2,s4
    80002954:	85ce                	mv	a1,s3
    80002956:	854a                	mv	a0,s2
    80002958:	ffffe097          	auipc	ra,0xffffe
    8000295c:	3c2080e7          	jalr	962(ra) # 80000d1a <memmove>
    return 0;
    80002960:	8526                	mv	a0,s1
    80002962:	bff9                	j	80002940 <either_copyin+0x32>

0000000080002964 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002964:	715d                	addi	sp,sp,-80
    80002966:	e486                	sd	ra,72(sp)
    80002968:	e0a2                	sd	s0,64(sp)
    8000296a:	fc26                	sd	s1,56(sp)
    8000296c:	f84a                	sd	s2,48(sp)
    8000296e:	f44e                	sd	s3,40(sp)
    80002970:	f052                	sd	s4,32(sp)
    80002972:	ec56                	sd	s5,24(sp)
    80002974:	e85a                	sd	s6,16(sp)
    80002976:	e45e                	sd	s7,8(sp)
    80002978:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000297a:	00005517          	auipc	a0,0x5
    8000297e:	74e50513          	addi	a0,a0,1870 # 800080c8 <digits+0x88>
    80002982:	ffffe097          	auipc	ra,0xffffe
    80002986:	bf2080e7          	jalr	-1038(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000298a:	0000f497          	auipc	s1,0xf
    8000298e:	e8648493          	addi	s1,s1,-378 # 80011810 <proc+0x158>
    80002992:	00023917          	auipc	s2,0x23
    80002996:	87e90913          	addi	s2,s2,-1922 # 80025210 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000299a:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000299c:	00006997          	auipc	s3,0x6
    800029a0:	8c498993          	addi	s3,s3,-1852 # 80008260 <digits+0x220>
    printf("%d %s %s", p->pid, state, p->name);
    800029a4:	00006a97          	auipc	s5,0x6
    800029a8:	8c4a8a93          	addi	s5,s5,-1852 # 80008268 <digits+0x228>
    printf("\n");
    800029ac:	00005a17          	auipc	s4,0x5
    800029b0:	71ca0a13          	addi	s4,s4,1820 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029b4:	00006b97          	auipc	s7,0x6
    800029b8:	8ecb8b93          	addi	s7,s7,-1812 # 800082a0 <states.0>
    800029bc:	a00d                	j	800029de <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800029be:	ee06a583          	lw	a1,-288(a3)
    800029c2:	8556                	mv	a0,s5
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	bb0080e7          	jalr	-1104(ra) # 80000574 <printf>
    printf("\n");
    800029cc:	8552                	mv	a0,s4
    800029ce:	ffffe097          	auipc	ra,0xffffe
    800029d2:	ba6080e7          	jalr	-1114(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800029d6:	4e848493          	addi	s1,s1,1256
    800029da:	03248163          	beq	s1,s2,800029fc <procdump+0x98>
    if(p->state == UNUSED)
    800029de:	86a6                	mv	a3,s1
    800029e0:	ec04a783          	lw	a5,-320(s1)
    800029e4:	dbed                	beqz	a5,800029d6 <procdump+0x72>
      state = "???";
    800029e6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029e8:	fcfb6be3          	bltu	s6,a5,800029be <procdump+0x5a>
    800029ec:	1782                	slli	a5,a5,0x20
    800029ee:	9381                	srli	a5,a5,0x20
    800029f0:	078e                	slli	a5,a5,0x3
    800029f2:	97de                	add	a5,a5,s7
    800029f4:	6390                	ld	a2,0(a5)
    800029f6:	f661                	bnez	a2,800029be <procdump+0x5a>
      state = "???";
    800029f8:	864e                	mv	a2,s3
    800029fa:	b7d1                	j	800029be <procdump+0x5a>
  }
}
    800029fc:	60a6                	ld	ra,72(sp)
    800029fe:	6406                	ld	s0,64(sp)
    80002a00:	74e2                	ld	s1,56(sp)
    80002a02:	7942                	ld	s2,48(sp)
    80002a04:	79a2                	ld	s3,40(sp)
    80002a06:	7a02                	ld	s4,32(sp)
    80002a08:	6ae2                	ld	s5,24(sp)
    80002a0a:	6b42                	ld	s6,16(sp)
    80002a0c:	6ba2                	ld	s7,8(sp)
    80002a0e:	6161                	addi	sp,sp,80
    80002a10:	8082                	ret

0000000080002a12 <swtch>:
    80002a12:	00153023          	sd	ra,0(a0)
    80002a16:	00253423          	sd	sp,8(a0)
    80002a1a:	e900                	sd	s0,16(a0)
    80002a1c:	ed04                	sd	s1,24(a0)
    80002a1e:	03253023          	sd	s2,32(a0)
    80002a22:	03353423          	sd	s3,40(a0)
    80002a26:	03453823          	sd	s4,48(a0)
    80002a2a:	03553c23          	sd	s5,56(a0)
    80002a2e:	05653023          	sd	s6,64(a0)
    80002a32:	05753423          	sd	s7,72(a0)
    80002a36:	05853823          	sd	s8,80(a0)
    80002a3a:	05953c23          	sd	s9,88(a0)
    80002a3e:	07a53023          	sd	s10,96(a0)
    80002a42:	07b53423          	sd	s11,104(a0)
    80002a46:	0005b083          	ld	ra,0(a1)
    80002a4a:	0085b103          	ld	sp,8(a1)
    80002a4e:	6980                	ld	s0,16(a1)
    80002a50:	6d84                	ld	s1,24(a1)
    80002a52:	0205b903          	ld	s2,32(a1)
    80002a56:	0285b983          	ld	s3,40(a1)
    80002a5a:	0305ba03          	ld	s4,48(a1)
    80002a5e:	0385ba83          	ld	s5,56(a1)
    80002a62:	0405bb03          	ld	s6,64(a1)
    80002a66:	0485bb83          	ld	s7,72(a1)
    80002a6a:	0505bc03          	ld	s8,80(a1)
    80002a6e:	0585bc83          	ld	s9,88(a1)
    80002a72:	0605bd03          	ld	s10,96(a1)
    80002a76:	0685bd83          	ld	s11,104(a1)
    80002a7a:	8082                	ret

0000000080002a7c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a7c:	1141                	addi	sp,sp,-16
    80002a7e:	e406                	sd	ra,8(sp)
    80002a80:	e022                	sd	s0,0(sp)
    80002a82:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a84:	00006597          	auipc	a1,0x6
    80002a88:	84458593          	addi	a1,a1,-1980 # 800082c8 <states.0+0x28>
    80002a8c:	00022517          	auipc	a0,0x22
    80002a90:	62c50513          	addi	a0,a0,1580 # 800250b8 <tickslock>
    80002a94:	ffffe097          	auipc	ra,0xffffe
    80002a98:	09e080e7          	jalr	158(ra) # 80000b32 <initlock>
}
    80002a9c:	60a2                	ld	ra,8(sp)
    80002a9e:	6402                	ld	s0,0(sp)
    80002aa0:	0141                	addi	sp,sp,16
    80002aa2:	8082                	ret

0000000080002aa4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002aa4:	1141                	addi	sp,sp,-16
    80002aa6:	e422                	sd	s0,8(sp)
    80002aa8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002aaa:	00003797          	auipc	a5,0x3
    80002aae:	69678793          	addi	a5,a5,1686 # 80006140 <kernelvec>
    80002ab2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ab6:	6422                	ld	s0,8(sp)
    80002ab8:	0141                	addi	sp,sp,16
    80002aba:	8082                	ret

0000000080002abc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002abc:	1141                	addi	sp,sp,-16
    80002abe:	e406                	sd	ra,8(sp)
    80002ac0:	e022                	sd	s0,0(sp)
    80002ac2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	2e2080e7          	jalr	738(ra) # 80001da6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002acc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ad0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ad2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002ad6:	00004617          	auipc	a2,0x4
    80002ada:	52a60613          	addi	a2,a2,1322 # 80007000 <_trampoline>
    80002ade:	00004697          	auipc	a3,0x4
    80002ae2:	52268693          	addi	a3,a3,1314 # 80007000 <_trampoline>
    80002ae6:	8e91                	sub	a3,a3,a2
    80002ae8:	040007b7          	lui	a5,0x4000
    80002aec:	17fd                	addi	a5,a5,-1
    80002aee:	07b2                	slli	a5,a5,0xc
    80002af0:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002af2:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002af6:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002af8:	180026f3          	csrr	a3,satp
    80002afc:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002afe:	6d38                	ld	a4,88(a0)
    80002b00:	6134                	ld	a3,64(a0)
    80002b02:	6585                	lui	a1,0x1
    80002b04:	96ae                	add	a3,a3,a1
    80002b06:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b08:	6d38                	ld	a4,88(a0)
    80002b0a:	00000697          	auipc	a3,0x0
    80002b0e:	13868693          	addi	a3,a3,312 # 80002c42 <usertrap>
    80002b12:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b14:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b16:	8692                	mv	a3,tp
    80002b18:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b1a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b1e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b22:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b26:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b2a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b2c:	6f18                	ld	a4,24(a4)
    80002b2e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b32:	692c                	ld	a1,80(a0)
    80002b34:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002b36:	00004717          	auipc	a4,0x4
    80002b3a:	55a70713          	addi	a4,a4,1370 # 80007090 <userret>
    80002b3e:	8f11                	sub	a4,a4,a2
    80002b40:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002b42:	577d                	li	a4,-1
    80002b44:	177e                	slli	a4,a4,0x3f
    80002b46:	8dd9                	or	a1,a1,a4
    80002b48:	02000537          	lui	a0,0x2000
    80002b4c:	157d                	addi	a0,a0,-1
    80002b4e:	0536                	slli	a0,a0,0xd
    80002b50:	9782                	jalr	a5
}
    80002b52:	60a2                	ld	ra,8(sp)
    80002b54:	6402                	ld	s0,0(sp)
    80002b56:	0141                	addi	sp,sp,16
    80002b58:	8082                	ret

0000000080002b5a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b5a:	1101                	addi	sp,sp,-32
    80002b5c:	ec06                	sd	ra,24(sp)
    80002b5e:	e822                	sd	s0,16(sp)
    80002b60:	e426                	sd	s1,8(sp)
    80002b62:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b64:	00022497          	auipc	s1,0x22
    80002b68:	55448493          	addi	s1,s1,1364 # 800250b8 <tickslock>
    80002b6c:	8526                	mv	a0,s1
    80002b6e:	ffffe097          	auipc	ra,0xffffe
    80002b72:	054080e7          	jalr	84(ra) # 80000bc2 <acquire>
  ticks++;
    80002b76:	00006517          	auipc	a0,0x6
    80002b7a:	4ba50513          	addi	a0,a0,1210 # 80009030 <ticks>
    80002b7e:	411c                	lw	a5,0(a0)
    80002b80:	2785                	addiw	a5,a5,1
    80002b82:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002b84:	00000097          	auipc	ra,0x0
    80002b88:	c5a080e7          	jalr	-934(ra) # 800027de <wakeup>
  release(&tickslock);
    80002b8c:	8526                	mv	a0,s1
    80002b8e:	ffffe097          	auipc	ra,0xffffe
    80002b92:	0e8080e7          	jalr	232(ra) # 80000c76 <release>
}
    80002b96:	60e2                	ld	ra,24(sp)
    80002b98:	6442                	ld	s0,16(sp)
    80002b9a:	64a2                	ld	s1,8(sp)
    80002b9c:	6105                	addi	sp,sp,32
    80002b9e:	8082                	ret

0000000080002ba0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002ba0:	1101                	addi	sp,sp,-32
    80002ba2:	ec06                	sd	ra,24(sp)
    80002ba4:	e822                	sd	s0,16(sp)
    80002ba6:	e426                	sd	s1,8(sp)
    80002ba8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002baa:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002bae:	00074d63          	bltz	a4,80002bc8 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002bb2:	57fd                	li	a5,-1
    80002bb4:	17fe                	slli	a5,a5,0x3f
    80002bb6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002bb8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002bba:	06f70363          	beq	a4,a5,80002c20 <devintr+0x80>
  }
}
    80002bbe:	60e2                	ld	ra,24(sp)
    80002bc0:	6442                	ld	s0,16(sp)
    80002bc2:	64a2                	ld	s1,8(sp)
    80002bc4:	6105                	addi	sp,sp,32
    80002bc6:	8082                	ret
     (scause & 0xff) == 9){
    80002bc8:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002bcc:	46a5                	li	a3,9
    80002bce:	fed792e3          	bne	a5,a3,80002bb2 <devintr+0x12>
    int irq = plic_claim();
    80002bd2:	00003097          	auipc	ra,0x3
    80002bd6:	676080e7          	jalr	1654(ra) # 80006248 <plic_claim>
    80002bda:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002bdc:	47a9                	li	a5,10
    80002bde:	02f50763          	beq	a0,a5,80002c0c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002be2:	4785                	li	a5,1
    80002be4:	02f50963          	beq	a0,a5,80002c16 <devintr+0x76>
    return 1;
    80002be8:	4505                	li	a0,1
    } else if(irq){
    80002bea:	d8f1                	beqz	s1,80002bbe <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002bec:	85a6                	mv	a1,s1
    80002bee:	00005517          	auipc	a0,0x5
    80002bf2:	6e250513          	addi	a0,a0,1762 # 800082d0 <states.0+0x30>
    80002bf6:	ffffe097          	auipc	ra,0xffffe
    80002bfa:	97e080e7          	jalr	-1666(ra) # 80000574 <printf>
      plic_complete(irq);
    80002bfe:	8526                	mv	a0,s1
    80002c00:	00003097          	auipc	ra,0x3
    80002c04:	66c080e7          	jalr	1644(ra) # 8000626c <plic_complete>
    return 1;
    80002c08:	4505                	li	a0,1
    80002c0a:	bf55                	j	80002bbe <devintr+0x1e>
      uartintr();
    80002c0c:	ffffe097          	auipc	ra,0xffffe
    80002c10:	d7a080e7          	jalr	-646(ra) # 80000986 <uartintr>
    80002c14:	b7ed                	j	80002bfe <devintr+0x5e>
      virtio_disk_intr();
    80002c16:	00004097          	auipc	ra,0x4
    80002c1a:	ae8080e7          	jalr	-1304(ra) # 800066fe <virtio_disk_intr>
    80002c1e:	b7c5                	j	80002bfe <devintr+0x5e>
    if(cpuid() == 0){
    80002c20:	fffff097          	auipc	ra,0xfffff
    80002c24:	15a080e7          	jalr	346(ra) # 80001d7a <cpuid>
    80002c28:	c901                	beqz	a0,80002c38 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c2a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c2e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c30:	14479073          	csrw	sip,a5
    return 2;
    80002c34:	4509                	li	a0,2
    80002c36:	b761                	j	80002bbe <devintr+0x1e>
      clockintr();
    80002c38:	00000097          	auipc	ra,0x0
    80002c3c:	f22080e7          	jalr	-222(ra) # 80002b5a <clockintr>
    80002c40:	b7ed                	j	80002c2a <devintr+0x8a>

0000000080002c42 <usertrap>:
{
    80002c42:	1101                	addi	sp,sp,-32
    80002c44:	ec06                	sd	ra,24(sp)
    80002c46:	e822                	sd	s0,16(sp)
    80002c48:	e426                	sd	s1,8(sp)
    80002c4a:	e04a                	sd	s2,0(sp)
    80002c4c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c4e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c52:	1007f793          	andi	a5,a5,256
    80002c56:	efd1                	bnez	a5,80002cf2 <usertrap+0xb0>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c58:	00003797          	auipc	a5,0x3
    80002c5c:	4e878793          	addi	a5,a5,1256 # 80006140 <kernelvec>
    80002c60:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c64:	fffff097          	auipc	ra,0xfffff
    80002c68:	142080e7          	jalr	322(ra) # 80001da6 <myproc>
    80002c6c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c6e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c70:	14102773          	csrr	a4,sepc
    80002c74:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c76:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c7a:	47a1                	li	a5,8
    80002c7c:	08f70363          	beq	a4,a5,80002d02 <usertrap+0xc0>
    80002c80:	14202773          	csrr	a4,scause
  } else if (r_scause() == 13 || r_scause() == 15) {
    80002c84:	47b5                	li	a5,13
    80002c86:	00f70763          	beq	a4,a5,80002c94 <usertrap+0x52>
    80002c8a:	14202773          	csrr	a4,scause
    80002c8e:	47bd                	li	a5,15
    80002c90:	0af71b63          	bne	a4,a5,80002d46 <usertrap+0x104>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c94:	14302573          	csrr	a0,stval
    if(mmap_pgfault(stval, p) != 0){
    80002c98:	85a6                	mv	a1,s1
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	b96080e7          	jalr	-1130(ra) # 80001830 <mmap_pgfault>
    80002ca2:	c141                	beqz	a0,80002d22 <usertrap+0xe0>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ca4:	142025f3          	csrr	a1,scause
      printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ca8:	5c90                	lw	a2,56(s1)
    80002caa:	00005517          	auipc	a0,0x5
    80002cae:	66650513          	addi	a0,a0,1638 # 80008310 <states.0+0x70>
    80002cb2:	ffffe097          	auipc	ra,0xffffe
    80002cb6:	8c2080e7          	jalr	-1854(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cba:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cbe:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cc2:	00005517          	auipc	a0,0x5
    80002cc6:	67e50513          	addi	a0,a0,1662 # 80008340 <states.0+0xa0>
    80002cca:	ffffe097          	auipc	ra,0xffffe
    80002cce:	8aa080e7          	jalr	-1878(ra) # 80000574 <printf>
      p->killed = 1;
    80002cd2:	4785                	li	a5,1
    80002cd4:	d89c                	sw	a5,48(s1)
{
    80002cd6:	4901                	li	s2,0
    exit(-1);
    80002cd8:	557d                	li	a0,-1
    80002cda:	00000097          	auipc	ra,0x0
    80002cde:	816080e7          	jalr	-2026(ra) # 800024f0 <exit>
  if(which_dev == 2)
    80002ce2:	4789                	li	a5,2
    80002ce4:	04f91163          	bne	s2,a5,80002d26 <usertrap+0xe4>
    yield();
    80002ce8:	00000097          	auipc	ra,0x0
    80002cec:	93a080e7          	jalr	-1734(ra) # 80002622 <yield>
    80002cf0:	a81d                	j	80002d26 <usertrap+0xe4>
    panic("usertrap: not from user mode");
    80002cf2:	00005517          	auipc	a0,0x5
    80002cf6:	5fe50513          	addi	a0,a0,1534 # 800082f0 <states.0+0x50>
    80002cfa:	ffffe097          	auipc	ra,0xffffe
    80002cfe:	830080e7          	jalr	-2000(ra) # 8000052a <panic>
    if(p->killed)
    80002d02:	591c                	lw	a5,48(a0)
    80002d04:	eb9d                	bnez	a5,80002d3a <usertrap+0xf8>
    p->trapframe->epc += 4;
    80002d06:	6cb8                	ld	a4,88(s1)
    80002d08:	6f1c                	ld	a5,24(a4)
    80002d0a:	0791                	addi	a5,a5,4
    80002d0c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d0e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d12:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d16:	10079073          	csrw	sstatus,a5
    syscall();
    80002d1a:	00000097          	auipc	ra,0x0
    80002d1e:	2b8080e7          	jalr	696(ra) # 80002fd2 <syscall>
  if(p->killed)
    80002d22:	589c                	lw	a5,48(s1)
    80002d24:	e7a5                	bnez	a5,80002d8c <usertrap+0x14a>
  usertrapret();
    80002d26:	00000097          	auipc	ra,0x0
    80002d2a:	d96080e7          	jalr	-618(ra) # 80002abc <usertrapret>
}
    80002d2e:	60e2                	ld	ra,24(sp)
    80002d30:	6442                	ld	s0,16(sp)
    80002d32:	64a2                	ld	s1,8(sp)
    80002d34:	6902                	ld	s2,0(sp)
    80002d36:	6105                	addi	sp,sp,32
    80002d38:	8082                	ret
      exit(-1);
    80002d3a:	557d                	li	a0,-1
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	7b4080e7          	jalr	1972(ra) # 800024f0 <exit>
    80002d44:	b7c9                	j	80002d06 <usertrap+0xc4>
  } else if((which_dev = devintr()) != 0){
    80002d46:	00000097          	auipc	ra,0x0
    80002d4a:	e5a080e7          	jalr	-422(ra) # 80002ba0 <devintr>
    80002d4e:	892a                	mv	s2,a0
    80002d50:	c501                	beqz	a0,80002d58 <usertrap+0x116>
  if(p->killed)
    80002d52:	589c                	lw	a5,48(s1)
    80002d54:	d7d9                	beqz	a5,80002ce2 <usertrap+0xa0>
    80002d56:	b749                	j	80002cd8 <usertrap+0x96>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d58:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d5c:	5c90                	lw	a2,56(s1)
    80002d5e:	00005517          	auipc	a0,0x5
    80002d62:	5b250513          	addi	a0,a0,1458 # 80008310 <states.0+0x70>
    80002d66:	ffffe097          	auipc	ra,0xffffe
    80002d6a:	80e080e7          	jalr	-2034(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d6e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d72:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d76:	00005517          	auipc	a0,0x5
    80002d7a:	5ca50513          	addi	a0,a0,1482 # 80008340 <states.0+0xa0>
    80002d7e:	ffffd097          	auipc	ra,0xffffd
    80002d82:	7f6080e7          	jalr	2038(ra) # 80000574 <printf>
    p->killed = 1;
    80002d86:	4785                	li	a5,1
    80002d88:	d89c                	sw	a5,48(s1)
    80002d8a:	b7b1                	j	80002cd6 <usertrap+0x94>
  if(p->killed)
    80002d8c:	4901                	li	s2,0
    80002d8e:	b7a9                	j	80002cd8 <usertrap+0x96>

0000000080002d90 <kerneltrap>:
{
    80002d90:	7179                	addi	sp,sp,-48
    80002d92:	f406                	sd	ra,40(sp)
    80002d94:	f022                	sd	s0,32(sp)
    80002d96:	ec26                	sd	s1,24(sp)
    80002d98:	e84a                	sd	s2,16(sp)
    80002d9a:	e44e                	sd	s3,8(sp)
    80002d9c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d9e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002da2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002da6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002daa:	1004f793          	andi	a5,s1,256
    80002dae:	cb85                	beqz	a5,80002dde <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002db0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002db4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002db6:	ef85                	bnez	a5,80002dee <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002db8:	00000097          	auipc	ra,0x0
    80002dbc:	de8080e7          	jalr	-536(ra) # 80002ba0 <devintr>
    80002dc0:	cd1d                	beqz	a0,80002dfe <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dc2:	4789                	li	a5,2
    80002dc4:	06f50a63          	beq	a0,a5,80002e38 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002dc8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dcc:	10049073          	csrw	sstatus,s1
}
    80002dd0:	70a2                	ld	ra,40(sp)
    80002dd2:	7402                	ld	s0,32(sp)
    80002dd4:	64e2                	ld	s1,24(sp)
    80002dd6:	6942                	ld	s2,16(sp)
    80002dd8:	69a2                	ld	s3,8(sp)
    80002dda:	6145                	addi	sp,sp,48
    80002ddc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002dde:	00005517          	auipc	a0,0x5
    80002de2:	58250513          	addi	a0,a0,1410 # 80008360 <states.0+0xc0>
    80002de6:	ffffd097          	auipc	ra,0xffffd
    80002dea:	744080e7          	jalr	1860(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002dee:	00005517          	auipc	a0,0x5
    80002df2:	59a50513          	addi	a0,a0,1434 # 80008388 <states.0+0xe8>
    80002df6:	ffffd097          	auipc	ra,0xffffd
    80002dfa:	734080e7          	jalr	1844(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002dfe:	85ce                	mv	a1,s3
    80002e00:	00005517          	auipc	a0,0x5
    80002e04:	5a850513          	addi	a0,a0,1448 # 800083a8 <states.0+0x108>
    80002e08:	ffffd097          	auipc	ra,0xffffd
    80002e0c:	76c080e7          	jalr	1900(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e10:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e14:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e18:	00005517          	auipc	a0,0x5
    80002e1c:	5a050513          	addi	a0,a0,1440 # 800083b8 <states.0+0x118>
    80002e20:	ffffd097          	auipc	ra,0xffffd
    80002e24:	754080e7          	jalr	1876(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002e28:	00005517          	auipc	a0,0x5
    80002e2c:	5a850513          	addi	a0,a0,1448 # 800083d0 <states.0+0x130>
    80002e30:	ffffd097          	auipc	ra,0xffffd
    80002e34:	6fa080e7          	jalr	1786(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e38:	fffff097          	auipc	ra,0xfffff
    80002e3c:	f6e080e7          	jalr	-146(ra) # 80001da6 <myproc>
    80002e40:	d541                	beqz	a0,80002dc8 <kerneltrap+0x38>
    80002e42:	fffff097          	auipc	ra,0xfffff
    80002e46:	f64080e7          	jalr	-156(ra) # 80001da6 <myproc>
    80002e4a:	4d18                	lw	a4,24(a0)
    80002e4c:	478d                	li	a5,3
    80002e4e:	f6f71de3          	bne	a4,a5,80002dc8 <kerneltrap+0x38>
    yield();
    80002e52:	fffff097          	auipc	ra,0xfffff
    80002e56:	7d0080e7          	jalr	2000(ra) # 80002622 <yield>
    80002e5a:	b7bd                	j	80002dc8 <kerneltrap+0x38>

0000000080002e5c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e5c:	1101                	addi	sp,sp,-32
    80002e5e:	ec06                	sd	ra,24(sp)
    80002e60:	e822                	sd	s0,16(sp)
    80002e62:	e426                	sd	s1,8(sp)
    80002e64:	1000                	addi	s0,sp,32
    80002e66:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e68:	fffff097          	auipc	ra,0xfffff
    80002e6c:	f3e080e7          	jalr	-194(ra) # 80001da6 <myproc>
  switch (n) {
    80002e70:	4795                	li	a5,5
    80002e72:	0497e163          	bltu	a5,s1,80002eb4 <argraw+0x58>
    80002e76:	048a                	slli	s1,s1,0x2
    80002e78:	00005717          	auipc	a4,0x5
    80002e7c:	59070713          	addi	a4,a4,1424 # 80008408 <states.0+0x168>
    80002e80:	94ba                	add	s1,s1,a4
    80002e82:	409c                	lw	a5,0(s1)
    80002e84:	97ba                	add	a5,a5,a4
    80002e86:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e88:	6d3c                	ld	a5,88(a0)
    80002e8a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e8c:	60e2                	ld	ra,24(sp)
    80002e8e:	6442                	ld	s0,16(sp)
    80002e90:	64a2                	ld	s1,8(sp)
    80002e92:	6105                	addi	sp,sp,32
    80002e94:	8082                	ret
    return p->trapframe->a1;
    80002e96:	6d3c                	ld	a5,88(a0)
    80002e98:	7fa8                	ld	a0,120(a5)
    80002e9a:	bfcd                	j	80002e8c <argraw+0x30>
    return p->trapframe->a2;
    80002e9c:	6d3c                	ld	a5,88(a0)
    80002e9e:	63c8                	ld	a0,128(a5)
    80002ea0:	b7f5                	j	80002e8c <argraw+0x30>
    return p->trapframe->a3;
    80002ea2:	6d3c                	ld	a5,88(a0)
    80002ea4:	67c8                	ld	a0,136(a5)
    80002ea6:	b7dd                	j	80002e8c <argraw+0x30>
    return p->trapframe->a4;
    80002ea8:	6d3c                	ld	a5,88(a0)
    80002eaa:	6bc8                	ld	a0,144(a5)
    80002eac:	b7c5                	j	80002e8c <argraw+0x30>
    return p->trapframe->a5;
    80002eae:	6d3c                	ld	a5,88(a0)
    80002eb0:	6fc8                	ld	a0,152(a5)
    80002eb2:	bfe9                	j	80002e8c <argraw+0x30>
  panic("argraw");
    80002eb4:	00005517          	auipc	a0,0x5
    80002eb8:	52c50513          	addi	a0,a0,1324 # 800083e0 <states.0+0x140>
    80002ebc:	ffffd097          	auipc	ra,0xffffd
    80002ec0:	66e080e7          	jalr	1646(ra) # 8000052a <panic>

0000000080002ec4 <fetchaddr>:
{
    80002ec4:	1101                	addi	sp,sp,-32
    80002ec6:	ec06                	sd	ra,24(sp)
    80002ec8:	e822                	sd	s0,16(sp)
    80002eca:	e426                	sd	s1,8(sp)
    80002ecc:	e04a                	sd	s2,0(sp)
    80002ece:	1000                	addi	s0,sp,32
    80002ed0:	84aa                	mv	s1,a0
    80002ed2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ed4:	fffff097          	auipc	ra,0xfffff
    80002ed8:	ed2080e7          	jalr	-302(ra) # 80001da6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002edc:	653c                	ld	a5,72(a0)
    80002ede:	02f4f863          	bgeu	s1,a5,80002f0e <fetchaddr+0x4a>
    80002ee2:	00848713          	addi	a4,s1,8
    80002ee6:	02e7e663          	bltu	a5,a4,80002f12 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002eea:	46a1                	li	a3,8
    80002eec:	8626                	mv	a2,s1
    80002eee:	85ca                	mv	a1,s2
    80002ef0:	6928                	ld	a0,80(a0)
    80002ef2:	ffffe097          	auipc	ra,0xffffe
    80002ef6:	7fc080e7          	jalr	2044(ra) # 800016ee <copyin>
    80002efa:	00a03533          	snez	a0,a0
    80002efe:	40a00533          	neg	a0,a0
}
    80002f02:	60e2                	ld	ra,24(sp)
    80002f04:	6442                	ld	s0,16(sp)
    80002f06:	64a2                	ld	s1,8(sp)
    80002f08:	6902                	ld	s2,0(sp)
    80002f0a:	6105                	addi	sp,sp,32
    80002f0c:	8082                	ret
    return -1;
    80002f0e:	557d                	li	a0,-1
    80002f10:	bfcd                	j	80002f02 <fetchaddr+0x3e>
    80002f12:	557d                	li	a0,-1
    80002f14:	b7fd                	j	80002f02 <fetchaddr+0x3e>

0000000080002f16 <fetchstr>:
{
    80002f16:	7179                	addi	sp,sp,-48
    80002f18:	f406                	sd	ra,40(sp)
    80002f1a:	f022                	sd	s0,32(sp)
    80002f1c:	ec26                	sd	s1,24(sp)
    80002f1e:	e84a                	sd	s2,16(sp)
    80002f20:	e44e                	sd	s3,8(sp)
    80002f22:	1800                	addi	s0,sp,48
    80002f24:	892a                	mv	s2,a0
    80002f26:	84ae                	mv	s1,a1
    80002f28:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f2a:	fffff097          	auipc	ra,0xfffff
    80002f2e:	e7c080e7          	jalr	-388(ra) # 80001da6 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002f32:	86ce                	mv	a3,s3
    80002f34:	864a                	mv	a2,s2
    80002f36:	85a6                	mv	a1,s1
    80002f38:	6928                	ld	a0,80(a0)
    80002f3a:	fffff097          	auipc	ra,0xfffff
    80002f3e:	842080e7          	jalr	-1982(ra) # 8000177c <copyinstr>
  if(err < 0)
    80002f42:	00054763          	bltz	a0,80002f50 <fetchstr+0x3a>
  return strlen(buf);
    80002f46:	8526                	mv	a0,s1
    80002f48:	ffffe097          	auipc	ra,0xffffe
    80002f4c:	efa080e7          	jalr	-262(ra) # 80000e42 <strlen>
}
    80002f50:	70a2                	ld	ra,40(sp)
    80002f52:	7402                	ld	s0,32(sp)
    80002f54:	64e2                	ld	s1,24(sp)
    80002f56:	6942                	ld	s2,16(sp)
    80002f58:	69a2                	ld	s3,8(sp)
    80002f5a:	6145                	addi	sp,sp,48
    80002f5c:	8082                	ret

0000000080002f5e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002f5e:	1101                	addi	sp,sp,-32
    80002f60:	ec06                	sd	ra,24(sp)
    80002f62:	e822                	sd	s0,16(sp)
    80002f64:	e426                	sd	s1,8(sp)
    80002f66:	1000                	addi	s0,sp,32
    80002f68:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f6a:	00000097          	auipc	ra,0x0
    80002f6e:	ef2080e7          	jalr	-270(ra) # 80002e5c <argraw>
    80002f72:	c088                	sw	a0,0(s1)
  return 0;
}
    80002f74:	4501                	li	a0,0
    80002f76:	60e2                	ld	ra,24(sp)
    80002f78:	6442                	ld	s0,16(sp)
    80002f7a:	64a2                	ld	s1,8(sp)
    80002f7c:	6105                	addi	sp,sp,32
    80002f7e:	8082                	ret

0000000080002f80 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002f80:	1101                	addi	sp,sp,-32
    80002f82:	ec06                	sd	ra,24(sp)
    80002f84:	e822                	sd	s0,16(sp)
    80002f86:	e426                	sd	s1,8(sp)
    80002f88:	1000                	addi	s0,sp,32
    80002f8a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f8c:	00000097          	auipc	ra,0x0
    80002f90:	ed0080e7          	jalr	-304(ra) # 80002e5c <argraw>
    80002f94:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f96:	4501                	li	a0,0
    80002f98:	60e2                	ld	ra,24(sp)
    80002f9a:	6442                	ld	s0,16(sp)
    80002f9c:	64a2                	ld	s1,8(sp)
    80002f9e:	6105                	addi	sp,sp,32
    80002fa0:	8082                	ret

0000000080002fa2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002fa2:	1101                	addi	sp,sp,-32
    80002fa4:	ec06                	sd	ra,24(sp)
    80002fa6:	e822                	sd	s0,16(sp)
    80002fa8:	e426                	sd	s1,8(sp)
    80002faa:	e04a                	sd	s2,0(sp)
    80002fac:	1000                	addi	s0,sp,32
    80002fae:	84ae                	mv	s1,a1
    80002fb0:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002fb2:	00000097          	auipc	ra,0x0
    80002fb6:	eaa080e7          	jalr	-342(ra) # 80002e5c <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002fba:	864a                	mv	a2,s2
    80002fbc:	85a6                	mv	a1,s1
    80002fbe:	00000097          	auipc	ra,0x0
    80002fc2:	f58080e7          	jalr	-168(ra) # 80002f16 <fetchstr>
}
    80002fc6:	60e2                	ld	ra,24(sp)
    80002fc8:	6442                	ld	s0,16(sp)
    80002fca:	64a2                	ld	s1,8(sp)
    80002fcc:	6902                	ld	s2,0(sp)
    80002fce:	6105                	addi	sp,sp,32
    80002fd0:	8082                	ret

0000000080002fd2 <syscall>:
[SYS_munmap]  sys_munmap,
};

void
syscall(void)
{
    80002fd2:	1101                	addi	sp,sp,-32
    80002fd4:	ec06                	sd	ra,24(sp)
    80002fd6:	e822                	sd	s0,16(sp)
    80002fd8:	e426                	sd	s1,8(sp)
    80002fda:	e04a                	sd	s2,0(sp)
    80002fdc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002fde:	fffff097          	auipc	ra,0xfffff
    80002fe2:	dc8080e7          	jalr	-568(ra) # 80001da6 <myproc>
    80002fe6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002fe8:	05853903          	ld	s2,88(a0)
    80002fec:	0a893783          	ld	a5,168(s2)
    80002ff0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ff4:	37fd                	addiw	a5,a5,-1
    80002ff6:	4759                	li	a4,22
    80002ff8:	00f76f63          	bltu	a4,a5,80003016 <syscall+0x44>
    80002ffc:	00369713          	slli	a4,a3,0x3
    80003000:	00005797          	auipc	a5,0x5
    80003004:	42078793          	addi	a5,a5,1056 # 80008420 <syscalls>
    80003008:	97ba                	add	a5,a5,a4
    8000300a:	639c                	ld	a5,0(a5)
    8000300c:	c789                	beqz	a5,80003016 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    8000300e:	9782                	jalr	a5
    80003010:	06a93823          	sd	a0,112(s2)
    80003014:	a839                	j	80003032 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003016:	15848613          	addi	a2,s1,344
    8000301a:	5c8c                	lw	a1,56(s1)
    8000301c:	00005517          	auipc	a0,0x5
    80003020:	3cc50513          	addi	a0,a0,972 # 800083e8 <states.0+0x148>
    80003024:	ffffd097          	auipc	ra,0xffffd
    80003028:	550080e7          	jalr	1360(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000302c:	6cbc                	ld	a5,88(s1)
    8000302e:	577d                	li	a4,-1
    80003030:	fbb8                	sd	a4,112(a5)
  }
}
    80003032:	60e2                	ld	ra,24(sp)
    80003034:	6442                	ld	s0,16(sp)
    80003036:	64a2                	ld	s1,8(sp)
    80003038:	6902                	ld	s2,0(sp)
    8000303a:	6105                	addi	sp,sp,32
    8000303c:	8082                	ret

000000008000303e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000303e:	1101                	addi	sp,sp,-32
    80003040:	ec06                	sd	ra,24(sp)
    80003042:	e822                	sd	s0,16(sp)
    80003044:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003046:	fec40593          	addi	a1,s0,-20
    8000304a:	4501                	li	a0,0
    8000304c:	00000097          	auipc	ra,0x0
    80003050:	f12080e7          	jalr	-238(ra) # 80002f5e <argint>
    return -1;
    80003054:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003056:	00054963          	bltz	a0,80003068 <sys_exit+0x2a>
  exit(n);
    8000305a:	fec42503          	lw	a0,-20(s0)
    8000305e:	fffff097          	auipc	ra,0xfffff
    80003062:	492080e7          	jalr	1170(ra) # 800024f0 <exit>
  return 0;  // not reached
    80003066:	4781                	li	a5,0
}
    80003068:	853e                	mv	a0,a5
    8000306a:	60e2                	ld	ra,24(sp)
    8000306c:	6442                	ld	s0,16(sp)
    8000306e:	6105                	addi	sp,sp,32
    80003070:	8082                	ret

0000000080003072 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003072:	1141                	addi	sp,sp,-16
    80003074:	e406                	sd	ra,8(sp)
    80003076:	e022                	sd	s0,0(sp)
    80003078:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000307a:	fffff097          	auipc	ra,0xfffff
    8000307e:	d2c080e7          	jalr	-724(ra) # 80001da6 <myproc>
}
    80003082:	5d08                	lw	a0,56(a0)
    80003084:	60a2                	ld	ra,8(sp)
    80003086:	6402                	ld	s0,0(sp)
    80003088:	0141                	addi	sp,sp,16
    8000308a:	8082                	ret

000000008000308c <sys_fork>:

uint64
sys_fork(void)
{
    8000308c:	1141                	addi	sp,sp,-16
    8000308e:	e406                	sd	ra,8(sp)
    80003090:	e022                	sd	s0,0(sp)
    80003092:	0800                	addi	s0,sp,16
  return fork();
    80003094:	fffff097          	auipc	ra,0xfffff
    80003098:	142080e7          	jalr	322(ra) # 800021d6 <fork>
}
    8000309c:	60a2                	ld	ra,8(sp)
    8000309e:	6402                	ld	s0,0(sp)
    800030a0:	0141                	addi	sp,sp,16
    800030a2:	8082                	ret

00000000800030a4 <sys_wait>:

uint64
sys_wait(void)
{
    800030a4:	1101                	addi	sp,sp,-32
    800030a6:	ec06                	sd	ra,24(sp)
    800030a8:	e822                	sd	s0,16(sp)
    800030aa:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800030ac:	fe840593          	addi	a1,s0,-24
    800030b0:	4501                	li	a0,0
    800030b2:	00000097          	auipc	ra,0x0
    800030b6:	ece080e7          	jalr	-306(ra) # 80002f80 <argaddr>
    800030ba:	87aa                	mv	a5,a0
    return -1;
    800030bc:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800030be:	0007c863          	bltz	a5,800030ce <sys_wait+0x2a>
  return wait(p);
    800030c2:	fe843503          	ld	a0,-24(s0)
    800030c6:	fffff097          	auipc	ra,0xfffff
    800030ca:	616080e7          	jalr	1558(ra) # 800026dc <wait>
}
    800030ce:	60e2                	ld	ra,24(sp)
    800030d0:	6442                	ld	s0,16(sp)
    800030d2:	6105                	addi	sp,sp,32
    800030d4:	8082                	ret

00000000800030d6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800030d6:	7179                	addi	sp,sp,-48
    800030d8:	f406                	sd	ra,40(sp)
    800030da:	f022                	sd	s0,32(sp)
    800030dc:	ec26                	sd	s1,24(sp)
    800030de:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800030e0:	fdc40593          	addi	a1,s0,-36
    800030e4:	4501                	li	a0,0
    800030e6:	00000097          	auipc	ra,0x0
    800030ea:	e78080e7          	jalr	-392(ra) # 80002f5e <argint>
    return -1;
    800030ee:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800030f0:	00054f63          	bltz	a0,8000310e <sys_sbrk+0x38>
  addr = myproc()->sz;
    800030f4:	fffff097          	auipc	ra,0xfffff
    800030f8:	cb2080e7          	jalr	-846(ra) # 80001da6 <myproc>
    800030fc:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800030fe:	fdc42503          	lw	a0,-36(s0)
    80003102:	fffff097          	auipc	ra,0xfffff
    80003106:	ff0080e7          	jalr	-16(ra) # 800020f2 <growproc>
    8000310a:	00054863          	bltz	a0,8000311a <sys_sbrk+0x44>
    return -1;
  return addr;
}
    8000310e:	8526                	mv	a0,s1
    80003110:	70a2                	ld	ra,40(sp)
    80003112:	7402                	ld	s0,32(sp)
    80003114:	64e2                	ld	s1,24(sp)
    80003116:	6145                	addi	sp,sp,48
    80003118:	8082                	ret
    return -1;
    8000311a:	54fd                	li	s1,-1
    8000311c:	bfcd                	j	8000310e <sys_sbrk+0x38>

000000008000311e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000311e:	7139                	addi	sp,sp,-64
    80003120:	fc06                	sd	ra,56(sp)
    80003122:	f822                	sd	s0,48(sp)
    80003124:	f426                	sd	s1,40(sp)
    80003126:	f04a                	sd	s2,32(sp)
    80003128:	ec4e                	sd	s3,24(sp)
    8000312a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000312c:	fcc40593          	addi	a1,s0,-52
    80003130:	4501                	li	a0,0
    80003132:	00000097          	auipc	ra,0x0
    80003136:	e2c080e7          	jalr	-468(ra) # 80002f5e <argint>
    return -1;
    8000313a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000313c:	06054563          	bltz	a0,800031a6 <sys_sleep+0x88>
  acquire(&tickslock);
    80003140:	00022517          	auipc	a0,0x22
    80003144:	f7850513          	addi	a0,a0,-136 # 800250b8 <tickslock>
    80003148:	ffffe097          	auipc	ra,0xffffe
    8000314c:	a7a080e7          	jalr	-1414(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003150:	00006917          	auipc	s2,0x6
    80003154:	ee092903          	lw	s2,-288(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003158:	fcc42783          	lw	a5,-52(s0)
    8000315c:	cf85                	beqz	a5,80003194 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000315e:	00022997          	auipc	s3,0x22
    80003162:	f5a98993          	addi	s3,s3,-166 # 800250b8 <tickslock>
    80003166:	00006497          	auipc	s1,0x6
    8000316a:	eca48493          	addi	s1,s1,-310 # 80009030 <ticks>
    if(myproc()->killed){
    8000316e:	fffff097          	auipc	ra,0xfffff
    80003172:	c38080e7          	jalr	-968(ra) # 80001da6 <myproc>
    80003176:	591c                	lw	a5,48(a0)
    80003178:	ef9d                	bnez	a5,800031b6 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000317a:	85ce                	mv	a1,s3
    8000317c:	8526                	mv	a0,s1
    8000317e:	fffff097          	auipc	ra,0xfffff
    80003182:	4e0080e7          	jalr	1248(ra) # 8000265e <sleep>
  while(ticks - ticks0 < n){
    80003186:	409c                	lw	a5,0(s1)
    80003188:	412787bb          	subw	a5,a5,s2
    8000318c:	fcc42703          	lw	a4,-52(s0)
    80003190:	fce7efe3          	bltu	a5,a4,8000316e <sys_sleep+0x50>
  }
  release(&tickslock);
    80003194:	00022517          	auipc	a0,0x22
    80003198:	f2450513          	addi	a0,a0,-220 # 800250b8 <tickslock>
    8000319c:	ffffe097          	auipc	ra,0xffffe
    800031a0:	ada080e7          	jalr	-1318(ra) # 80000c76 <release>
  return 0;
    800031a4:	4781                	li	a5,0
}
    800031a6:	853e                	mv	a0,a5
    800031a8:	70e2                	ld	ra,56(sp)
    800031aa:	7442                	ld	s0,48(sp)
    800031ac:	74a2                	ld	s1,40(sp)
    800031ae:	7902                	ld	s2,32(sp)
    800031b0:	69e2                	ld	s3,24(sp)
    800031b2:	6121                	addi	sp,sp,64
    800031b4:	8082                	ret
      release(&tickslock);
    800031b6:	00022517          	auipc	a0,0x22
    800031ba:	f0250513          	addi	a0,a0,-254 # 800250b8 <tickslock>
    800031be:	ffffe097          	auipc	ra,0xffffe
    800031c2:	ab8080e7          	jalr	-1352(ra) # 80000c76 <release>
      return -1;
    800031c6:	57fd                	li	a5,-1
    800031c8:	bff9                	j	800031a6 <sys_sleep+0x88>

00000000800031ca <sys_kill>:

uint64
sys_kill(void)
{
    800031ca:	1101                	addi	sp,sp,-32
    800031cc:	ec06                	sd	ra,24(sp)
    800031ce:	e822                	sd	s0,16(sp)
    800031d0:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800031d2:	fec40593          	addi	a1,s0,-20
    800031d6:	4501                	li	a0,0
    800031d8:	00000097          	auipc	ra,0x0
    800031dc:	d86080e7          	jalr	-634(ra) # 80002f5e <argint>
    800031e0:	87aa                	mv	a5,a0
    return -1;
    800031e2:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800031e4:	0007c863          	bltz	a5,800031f4 <sys_kill+0x2a>
  return kill(pid);
    800031e8:	fec42503          	lw	a0,-20(s0)
    800031ec:	fffff097          	auipc	ra,0xfffff
    800031f0:	65c080e7          	jalr	1628(ra) # 80002848 <kill>
}
    800031f4:	60e2                	ld	ra,24(sp)
    800031f6:	6442                	ld	s0,16(sp)
    800031f8:	6105                	addi	sp,sp,32
    800031fa:	8082                	ret

00000000800031fc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800031fc:	1101                	addi	sp,sp,-32
    800031fe:	ec06                	sd	ra,24(sp)
    80003200:	e822                	sd	s0,16(sp)
    80003202:	e426                	sd	s1,8(sp)
    80003204:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003206:	00022517          	auipc	a0,0x22
    8000320a:	eb250513          	addi	a0,a0,-334 # 800250b8 <tickslock>
    8000320e:	ffffe097          	auipc	ra,0xffffe
    80003212:	9b4080e7          	jalr	-1612(ra) # 80000bc2 <acquire>
  xticks = ticks;
    80003216:	00006497          	auipc	s1,0x6
    8000321a:	e1a4a483          	lw	s1,-486(s1) # 80009030 <ticks>
  release(&tickslock);
    8000321e:	00022517          	auipc	a0,0x22
    80003222:	e9a50513          	addi	a0,a0,-358 # 800250b8 <tickslock>
    80003226:	ffffe097          	auipc	ra,0xffffe
    8000322a:	a50080e7          	jalr	-1456(ra) # 80000c76 <release>
  return xticks;
}
    8000322e:	02049513          	slli	a0,s1,0x20
    80003232:	9101                	srli	a0,a0,0x20
    80003234:	60e2                	ld	ra,24(sp)
    80003236:	6442                	ld	s0,16(sp)
    80003238:	64a2                	ld	s1,8(sp)
    8000323a:	6105                	addi	sp,sp,32
    8000323c:	8082                	ret

000000008000323e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000323e:	7179                	addi	sp,sp,-48
    80003240:	f406                	sd	ra,40(sp)
    80003242:	f022                	sd	s0,32(sp)
    80003244:	ec26                	sd	s1,24(sp)
    80003246:	e84a                	sd	s2,16(sp)
    80003248:	e44e                	sd	s3,8(sp)
    8000324a:	e052                	sd	s4,0(sp)
    8000324c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000324e:	00005597          	auipc	a1,0x5
    80003252:	29258593          	addi	a1,a1,658 # 800084e0 <syscalls+0xc0>
    80003256:	00022517          	auipc	a0,0x22
    8000325a:	e7a50513          	addi	a0,a0,-390 # 800250d0 <bcache>
    8000325e:	ffffe097          	auipc	ra,0xffffe
    80003262:	8d4080e7          	jalr	-1836(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003266:	0002a797          	auipc	a5,0x2a
    8000326a:	e6a78793          	addi	a5,a5,-406 # 8002d0d0 <bcache+0x8000>
    8000326e:	0002a717          	auipc	a4,0x2a
    80003272:	0ca70713          	addi	a4,a4,202 # 8002d338 <bcache+0x8268>
    80003276:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000327a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000327e:	00022497          	auipc	s1,0x22
    80003282:	e6a48493          	addi	s1,s1,-406 # 800250e8 <bcache+0x18>
    b->next = bcache.head.next;
    80003286:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003288:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000328a:	00005a17          	auipc	s4,0x5
    8000328e:	25ea0a13          	addi	s4,s4,606 # 800084e8 <syscalls+0xc8>
    b->next = bcache.head.next;
    80003292:	2b893783          	ld	a5,696(s2)
    80003296:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003298:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000329c:	85d2                	mv	a1,s4
    8000329e:	01048513          	addi	a0,s1,16
    800032a2:	00001097          	auipc	ra,0x1
    800032a6:	4c4080e7          	jalr	1220(ra) # 80004766 <initsleeplock>
    bcache.head.next->prev = b;
    800032aa:	2b893783          	ld	a5,696(s2)
    800032ae:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800032b0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032b4:	45848493          	addi	s1,s1,1112
    800032b8:	fd349de3          	bne	s1,s3,80003292 <binit+0x54>
  }
}
    800032bc:	70a2                	ld	ra,40(sp)
    800032be:	7402                	ld	s0,32(sp)
    800032c0:	64e2                	ld	s1,24(sp)
    800032c2:	6942                	ld	s2,16(sp)
    800032c4:	69a2                	ld	s3,8(sp)
    800032c6:	6a02                	ld	s4,0(sp)
    800032c8:	6145                	addi	sp,sp,48
    800032ca:	8082                	ret

00000000800032cc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800032cc:	7179                	addi	sp,sp,-48
    800032ce:	f406                	sd	ra,40(sp)
    800032d0:	f022                	sd	s0,32(sp)
    800032d2:	ec26                	sd	s1,24(sp)
    800032d4:	e84a                	sd	s2,16(sp)
    800032d6:	e44e                	sd	s3,8(sp)
    800032d8:	1800                	addi	s0,sp,48
    800032da:	892a                	mv	s2,a0
    800032dc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800032de:	00022517          	auipc	a0,0x22
    800032e2:	df250513          	addi	a0,a0,-526 # 800250d0 <bcache>
    800032e6:	ffffe097          	auipc	ra,0xffffe
    800032ea:	8dc080e7          	jalr	-1828(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800032ee:	0002a497          	auipc	s1,0x2a
    800032f2:	09a4b483          	ld	s1,154(s1) # 8002d388 <bcache+0x82b8>
    800032f6:	0002a797          	auipc	a5,0x2a
    800032fa:	04278793          	addi	a5,a5,66 # 8002d338 <bcache+0x8268>
    800032fe:	02f48f63          	beq	s1,a5,8000333c <bread+0x70>
    80003302:	873e                	mv	a4,a5
    80003304:	a021                	j	8000330c <bread+0x40>
    80003306:	68a4                	ld	s1,80(s1)
    80003308:	02e48a63          	beq	s1,a4,8000333c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000330c:	449c                	lw	a5,8(s1)
    8000330e:	ff279ce3          	bne	a5,s2,80003306 <bread+0x3a>
    80003312:	44dc                	lw	a5,12(s1)
    80003314:	ff3799e3          	bne	a5,s3,80003306 <bread+0x3a>
      b->refcnt++;
    80003318:	40bc                	lw	a5,64(s1)
    8000331a:	2785                	addiw	a5,a5,1
    8000331c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000331e:	00022517          	auipc	a0,0x22
    80003322:	db250513          	addi	a0,a0,-590 # 800250d0 <bcache>
    80003326:	ffffe097          	auipc	ra,0xffffe
    8000332a:	950080e7          	jalr	-1712(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    8000332e:	01048513          	addi	a0,s1,16
    80003332:	00001097          	auipc	ra,0x1
    80003336:	46e080e7          	jalr	1134(ra) # 800047a0 <acquiresleep>
      return b;
    8000333a:	a8b9                	j	80003398 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000333c:	0002a497          	auipc	s1,0x2a
    80003340:	0444b483          	ld	s1,68(s1) # 8002d380 <bcache+0x82b0>
    80003344:	0002a797          	auipc	a5,0x2a
    80003348:	ff478793          	addi	a5,a5,-12 # 8002d338 <bcache+0x8268>
    8000334c:	00f48863          	beq	s1,a5,8000335c <bread+0x90>
    80003350:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003352:	40bc                	lw	a5,64(s1)
    80003354:	cf81                	beqz	a5,8000336c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003356:	64a4                	ld	s1,72(s1)
    80003358:	fee49de3          	bne	s1,a4,80003352 <bread+0x86>
  panic("bget: no buffers");
    8000335c:	00005517          	auipc	a0,0x5
    80003360:	19450513          	addi	a0,a0,404 # 800084f0 <syscalls+0xd0>
    80003364:	ffffd097          	auipc	ra,0xffffd
    80003368:	1c6080e7          	jalr	454(ra) # 8000052a <panic>
      b->dev = dev;
    8000336c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003370:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003374:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003378:	4785                	li	a5,1
    8000337a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000337c:	00022517          	auipc	a0,0x22
    80003380:	d5450513          	addi	a0,a0,-684 # 800250d0 <bcache>
    80003384:	ffffe097          	auipc	ra,0xffffe
    80003388:	8f2080e7          	jalr	-1806(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    8000338c:	01048513          	addi	a0,s1,16
    80003390:	00001097          	auipc	ra,0x1
    80003394:	410080e7          	jalr	1040(ra) # 800047a0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003398:	409c                	lw	a5,0(s1)
    8000339a:	cb89                	beqz	a5,800033ac <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000339c:	8526                	mv	a0,s1
    8000339e:	70a2                	ld	ra,40(sp)
    800033a0:	7402                	ld	s0,32(sp)
    800033a2:	64e2                	ld	s1,24(sp)
    800033a4:	6942                	ld	s2,16(sp)
    800033a6:	69a2                	ld	s3,8(sp)
    800033a8:	6145                	addi	sp,sp,48
    800033aa:	8082                	ret
    virtio_disk_rw(b, 0);
    800033ac:	4581                	li	a1,0
    800033ae:	8526                	mv	a0,s1
    800033b0:	00003097          	auipc	ra,0x3
    800033b4:	0c6080e7          	jalr	198(ra) # 80006476 <virtio_disk_rw>
    b->valid = 1;
    800033b8:	4785                	li	a5,1
    800033ba:	c09c                	sw	a5,0(s1)
  return b;
    800033bc:	b7c5                	j	8000339c <bread+0xd0>

00000000800033be <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800033be:	1101                	addi	sp,sp,-32
    800033c0:	ec06                	sd	ra,24(sp)
    800033c2:	e822                	sd	s0,16(sp)
    800033c4:	e426                	sd	s1,8(sp)
    800033c6:	1000                	addi	s0,sp,32
    800033c8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033ca:	0541                	addi	a0,a0,16
    800033cc:	00001097          	auipc	ra,0x1
    800033d0:	46e080e7          	jalr	1134(ra) # 8000483a <holdingsleep>
    800033d4:	cd01                	beqz	a0,800033ec <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033d6:	4585                	li	a1,1
    800033d8:	8526                	mv	a0,s1
    800033da:	00003097          	auipc	ra,0x3
    800033de:	09c080e7          	jalr	156(ra) # 80006476 <virtio_disk_rw>
}
    800033e2:	60e2                	ld	ra,24(sp)
    800033e4:	6442                	ld	s0,16(sp)
    800033e6:	64a2                	ld	s1,8(sp)
    800033e8:	6105                	addi	sp,sp,32
    800033ea:	8082                	ret
    panic("bwrite");
    800033ec:	00005517          	auipc	a0,0x5
    800033f0:	11c50513          	addi	a0,a0,284 # 80008508 <syscalls+0xe8>
    800033f4:	ffffd097          	auipc	ra,0xffffd
    800033f8:	136080e7          	jalr	310(ra) # 8000052a <panic>

00000000800033fc <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800033fc:	1101                	addi	sp,sp,-32
    800033fe:	ec06                	sd	ra,24(sp)
    80003400:	e822                	sd	s0,16(sp)
    80003402:	e426                	sd	s1,8(sp)
    80003404:	e04a                	sd	s2,0(sp)
    80003406:	1000                	addi	s0,sp,32
    80003408:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000340a:	01050913          	addi	s2,a0,16
    8000340e:	854a                	mv	a0,s2
    80003410:	00001097          	auipc	ra,0x1
    80003414:	42a080e7          	jalr	1066(ra) # 8000483a <holdingsleep>
    80003418:	c92d                	beqz	a0,8000348a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000341a:	854a                	mv	a0,s2
    8000341c:	00001097          	auipc	ra,0x1
    80003420:	3da080e7          	jalr	986(ra) # 800047f6 <releasesleep>

  acquire(&bcache.lock);
    80003424:	00022517          	auipc	a0,0x22
    80003428:	cac50513          	addi	a0,a0,-852 # 800250d0 <bcache>
    8000342c:	ffffd097          	auipc	ra,0xffffd
    80003430:	796080e7          	jalr	1942(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003434:	40bc                	lw	a5,64(s1)
    80003436:	37fd                	addiw	a5,a5,-1
    80003438:	0007871b          	sext.w	a4,a5
    8000343c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000343e:	eb05                	bnez	a4,8000346e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003440:	68bc                	ld	a5,80(s1)
    80003442:	64b8                	ld	a4,72(s1)
    80003444:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003446:	64bc                	ld	a5,72(s1)
    80003448:	68b8                	ld	a4,80(s1)
    8000344a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000344c:	0002a797          	auipc	a5,0x2a
    80003450:	c8478793          	addi	a5,a5,-892 # 8002d0d0 <bcache+0x8000>
    80003454:	2b87b703          	ld	a4,696(a5)
    80003458:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000345a:	0002a717          	auipc	a4,0x2a
    8000345e:	ede70713          	addi	a4,a4,-290 # 8002d338 <bcache+0x8268>
    80003462:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003464:	2b87b703          	ld	a4,696(a5)
    80003468:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000346a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000346e:	00022517          	auipc	a0,0x22
    80003472:	c6250513          	addi	a0,a0,-926 # 800250d0 <bcache>
    80003476:	ffffe097          	auipc	ra,0xffffe
    8000347a:	800080e7          	jalr	-2048(ra) # 80000c76 <release>
}
    8000347e:	60e2                	ld	ra,24(sp)
    80003480:	6442                	ld	s0,16(sp)
    80003482:	64a2                	ld	s1,8(sp)
    80003484:	6902                	ld	s2,0(sp)
    80003486:	6105                	addi	sp,sp,32
    80003488:	8082                	ret
    panic("brelse");
    8000348a:	00005517          	auipc	a0,0x5
    8000348e:	08650513          	addi	a0,a0,134 # 80008510 <syscalls+0xf0>
    80003492:	ffffd097          	auipc	ra,0xffffd
    80003496:	098080e7          	jalr	152(ra) # 8000052a <panic>

000000008000349a <bpin>:

void
bpin(struct buf *b) {
    8000349a:	1101                	addi	sp,sp,-32
    8000349c:	ec06                	sd	ra,24(sp)
    8000349e:	e822                	sd	s0,16(sp)
    800034a0:	e426                	sd	s1,8(sp)
    800034a2:	1000                	addi	s0,sp,32
    800034a4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034a6:	00022517          	auipc	a0,0x22
    800034aa:	c2a50513          	addi	a0,a0,-982 # 800250d0 <bcache>
    800034ae:	ffffd097          	auipc	ra,0xffffd
    800034b2:	714080e7          	jalr	1812(ra) # 80000bc2 <acquire>
  b->refcnt++;
    800034b6:	40bc                	lw	a5,64(s1)
    800034b8:	2785                	addiw	a5,a5,1
    800034ba:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034bc:	00022517          	auipc	a0,0x22
    800034c0:	c1450513          	addi	a0,a0,-1004 # 800250d0 <bcache>
    800034c4:	ffffd097          	auipc	ra,0xffffd
    800034c8:	7b2080e7          	jalr	1970(ra) # 80000c76 <release>
}
    800034cc:	60e2                	ld	ra,24(sp)
    800034ce:	6442                	ld	s0,16(sp)
    800034d0:	64a2                	ld	s1,8(sp)
    800034d2:	6105                	addi	sp,sp,32
    800034d4:	8082                	ret

00000000800034d6 <bunpin>:

void
bunpin(struct buf *b) {
    800034d6:	1101                	addi	sp,sp,-32
    800034d8:	ec06                	sd	ra,24(sp)
    800034da:	e822                	sd	s0,16(sp)
    800034dc:	e426                	sd	s1,8(sp)
    800034de:	1000                	addi	s0,sp,32
    800034e0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034e2:	00022517          	auipc	a0,0x22
    800034e6:	bee50513          	addi	a0,a0,-1042 # 800250d0 <bcache>
    800034ea:	ffffd097          	auipc	ra,0xffffd
    800034ee:	6d8080e7          	jalr	1752(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800034f2:	40bc                	lw	a5,64(s1)
    800034f4:	37fd                	addiw	a5,a5,-1
    800034f6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034f8:	00022517          	auipc	a0,0x22
    800034fc:	bd850513          	addi	a0,a0,-1064 # 800250d0 <bcache>
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	776080e7          	jalr	1910(ra) # 80000c76 <release>
}
    80003508:	60e2                	ld	ra,24(sp)
    8000350a:	6442                	ld	s0,16(sp)
    8000350c:	64a2                	ld	s1,8(sp)
    8000350e:	6105                	addi	sp,sp,32
    80003510:	8082                	ret

0000000080003512 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003512:	1101                	addi	sp,sp,-32
    80003514:	ec06                	sd	ra,24(sp)
    80003516:	e822                	sd	s0,16(sp)
    80003518:	e426                	sd	s1,8(sp)
    8000351a:	e04a                	sd	s2,0(sp)
    8000351c:	1000                	addi	s0,sp,32
    8000351e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003520:	00d5d59b          	srliw	a1,a1,0xd
    80003524:	0002a797          	auipc	a5,0x2a
    80003528:	2887a783          	lw	a5,648(a5) # 8002d7ac <sb+0x1c>
    8000352c:	9dbd                	addw	a1,a1,a5
    8000352e:	00000097          	auipc	ra,0x0
    80003532:	d9e080e7          	jalr	-610(ra) # 800032cc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003536:	0074f713          	andi	a4,s1,7
    8000353a:	4785                	li	a5,1
    8000353c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003540:	14ce                	slli	s1,s1,0x33
    80003542:	90d9                	srli	s1,s1,0x36
    80003544:	00950733          	add	a4,a0,s1
    80003548:	05874703          	lbu	a4,88(a4)
    8000354c:	00e7f6b3          	and	a3,a5,a4
    80003550:	c69d                	beqz	a3,8000357e <bfree+0x6c>
    80003552:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003554:	94aa                	add	s1,s1,a0
    80003556:	fff7c793          	not	a5,a5
    8000355a:	8ff9                	and	a5,a5,a4
    8000355c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003560:	00001097          	auipc	ra,0x1
    80003564:	118080e7          	jalr	280(ra) # 80004678 <log_write>
  brelse(bp);
    80003568:	854a                	mv	a0,s2
    8000356a:	00000097          	auipc	ra,0x0
    8000356e:	e92080e7          	jalr	-366(ra) # 800033fc <brelse>
}
    80003572:	60e2                	ld	ra,24(sp)
    80003574:	6442                	ld	s0,16(sp)
    80003576:	64a2                	ld	s1,8(sp)
    80003578:	6902                	ld	s2,0(sp)
    8000357a:	6105                	addi	sp,sp,32
    8000357c:	8082                	ret
    panic("freeing free block");
    8000357e:	00005517          	auipc	a0,0x5
    80003582:	f9a50513          	addi	a0,a0,-102 # 80008518 <syscalls+0xf8>
    80003586:	ffffd097          	auipc	ra,0xffffd
    8000358a:	fa4080e7          	jalr	-92(ra) # 8000052a <panic>

000000008000358e <balloc>:
{
    8000358e:	711d                	addi	sp,sp,-96
    80003590:	ec86                	sd	ra,88(sp)
    80003592:	e8a2                	sd	s0,80(sp)
    80003594:	e4a6                	sd	s1,72(sp)
    80003596:	e0ca                	sd	s2,64(sp)
    80003598:	fc4e                	sd	s3,56(sp)
    8000359a:	f852                	sd	s4,48(sp)
    8000359c:	f456                	sd	s5,40(sp)
    8000359e:	f05a                	sd	s6,32(sp)
    800035a0:	ec5e                	sd	s7,24(sp)
    800035a2:	e862                	sd	s8,16(sp)
    800035a4:	e466                	sd	s9,8(sp)
    800035a6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800035a8:	0002a797          	auipc	a5,0x2a
    800035ac:	1ec7a783          	lw	a5,492(a5) # 8002d794 <sb+0x4>
    800035b0:	cbd1                	beqz	a5,80003644 <balloc+0xb6>
    800035b2:	8baa                	mv	s7,a0
    800035b4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800035b6:	0002ab17          	auipc	s6,0x2a
    800035ba:	1dab0b13          	addi	s6,s6,474 # 8002d790 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035be:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800035c0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035c2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800035c4:	6c89                	lui	s9,0x2
    800035c6:	a831                	j	800035e2 <balloc+0x54>
    brelse(bp);
    800035c8:	854a                	mv	a0,s2
    800035ca:	00000097          	auipc	ra,0x0
    800035ce:	e32080e7          	jalr	-462(ra) # 800033fc <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800035d2:	015c87bb          	addw	a5,s9,s5
    800035d6:	00078a9b          	sext.w	s5,a5
    800035da:	004b2703          	lw	a4,4(s6)
    800035de:	06eaf363          	bgeu	s5,a4,80003644 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800035e2:	41fad79b          	sraiw	a5,s5,0x1f
    800035e6:	0137d79b          	srliw	a5,a5,0x13
    800035ea:	015787bb          	addw	a5,a5,s5
    800035ee:	40d7d79b          	sraiw	a5,a5,0xd
    800035f2:	01cb2583          	lw	a1,28(s6)
    800035f6:	9dbd                	addw	a1,a1,a5
    800035f8:	855e                	mv	a0,s7
    800035fa:	00000097          	auipc	ra,0x0
    800035fe:	cd2080e7          	jalr	-814(ra) # 800032cc <bread>
    80003602:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003604:	004b2503          	lw	a0,4(s6)
    80003608:	000a849b          	sext.w	s1,s5
    8000360c:	8662                	mv	a2,s8
    8000360e:	faa4fde3          	bgeu	s1,a0,800035c8 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003612:	41f6579b          	sraiw	a5,a2,0x1f
    80003616:	01d7d69b          	srliw	a3,a5,0x1d
    8000361a:	00c6873b          	addw	a4,a3,a2
    8000361e:	00777793          	andi	a5,a4,7
    80003622:	9f95                	subw	a5,a5,a3
    80003624:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003628:	4037571b          	sraiw	a4,a4,0x3
    8000362c:	00e906b3          	add	a3,s2,a4
    80003630:	0586c683          	lbu	a3,88(a3)
    80003634:	00d7f5b3          	and	a1,a5,a3
    80003638:	cd91                	beqz	a1,80003654 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000363a:	2605                	addiw	a2,a2,1
    8000363c:	2485                	addiw	s1,s1,1
    8000363e:	fd4618e3          	bne	a2,s4,8000360e <balloc+0x80>
    80003642:	b759                	j	800035c8 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003644:	00005517          	auipc	a0,0x5
    80003648:	eec50513          	addi	a0,a0,-276 # 80008530 <syscalls+0x110>
    8000364c:	ffffd097          	auipc	ra,0xffffd
    80003650:	ede080e7          	jalr	-290(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003654:	974a                	add	a4,a4,s2
    80003656:	8fd5                	or	a5,a5,a3
    80003658:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000365c:	854a                	mv	a0,s2
    8000365e:	00001097          	auipc	ra,0x1
    80003662:	01a080e7          	jalr	26(ra) # 80004678 <log_write>
        brelse(bp);
    80003666:	854a                	mv	a0,s2
    80003668:	00000097          	auipc	ra,0x0
    8000366c:	d94080e7          	jalr	-620(ra) # 800033fc <brelse>
  bp = bread(dev, bno);
    80003670:	85a6                	mv	a1,s1
    80003672:	855e                	mv	a0,s7
    80003674:	00000097          	auipc	ra,0x0
    80003678:	c58080e7          	jalr	-936(ra) # 800032cc <bread>
    8000367c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000367e:	40000613          	li	a2,1024
    80003682:	4581                	li	a1,0
    80003684:	05850513          	addi	a0,a0,88
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	636080e7          	jalr	1590(ra) # 80000cbe <memset>
  log_write(bp);
    80003690:	854a                	mv	a0,s2
    80003692:	00001097          	auipc	ra,0x1
    80003696:	fe6080e7          	jalr	-26(ra) # 80004678 <log_write>
  brelse(bp);
    8000369a:	854a                	mv	a0,s2
    8000369c:	00000097          	auipc	ra,0x0
    800036a0:	d60080e7          	jalr	-672(ra) # 800033fc <brelse>
}
    800036a4:	8526                	mv	a0,s1
    800036a6:	60e6                	ld	ra,88(sp)
    800036a8:	6446                	ld	s0,80(sp)
    800036aa:	64a6                	ld	s1,72(sp)
    800036ac:	6906                	ld	s2,64(sp)
    800036ae:	79e2                	ld	s3,56(sp)
    800036b0:	7a42                	ld	s4,48(sp)
    800036b2:	7aa2                	ld	s5,40(sp)
    800036b4:	7b02                	ld	s6,32(sp)
    800036b6:	6be2                	ld	s7,24(sp)
    800036b8:	6c42                	ld	s8,16(sp)
    800036ba:	6ca2                	ld	s9,8(sp)
    800036bc:	6125                	addi	sp,sp,96
    800036be:	8082                	ret

00000000800036c0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800036c0:	7179                	addi	sp,sp,-48
    800036c2:	f406                	sd	ra,40(sp)
    800036c4:	f022                	sd	s0,32(sp)
    800036c6:	ec26                	sd	s1,24(sp)
    800036c8:	e84a                	sd	s2,16(sp)
    800036ca:	e44e                	sd	s3,8(sp)
    800036cc:	e052                	sd	s4,0(sp)
    800036ce:	1800                	addi	s0,sp,48
    800036d0:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036d2:	47ad                	li	a5,11
    800036d4:	04b7fe63          	bgeu	a5,a1,80003730 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800036d8:	ff45849b          	addiw	s1,a1,-12
    800036dc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800036e0:	0ff00793          	li	a5,255
    800036e4:	0ae7e363          	bltu	a5,a4,8000378a <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800036e8:	08052583          	lw	a1,128(a0)
    800036ec:	c5ad                	beqz	a1,80003756 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800036ee:	00092503          	lw	a0,0(s2)
    800036f2:	00000097          	auipc	ra,0x0
    800036f6:	bda080e7          	jalr	-1062(ra) # 800032cc <bread>
    800036fa:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800036fc:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003700:	02049593          	slli	a1,s1,0x20
    80003704:	9181                	srli	a1,a1,0x20
    80003706:	058a                	slli	a1,a1,0x2
    80003708:	00b784b3          	add	s1,a5,a1
    8000370c:	0004a983          	lw	s3,0(s1)
    80003710:	04098d63          	beqz	s3,8000376a <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003714:	8552                	mv	a0,s4
    80003716:	00000097          	auipc	ra,0x0
    8000371a:	ce6080e7          	jalr	-794(ra) # 800033fc <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000371e:	854e                	mv	a0,s3
    80003720:	70a2                	ld	ra,40(sp)
    80003722:	7402                	ld	s0,32(sp)
    80003724:	64e2                	ld	s1,24(sp)
    80003726:	6942                	ld	s2,16(sp)
    80003728:	69a2                	ld	s3,8(sp)
    8000372a:	6a02                	ld	s4,0(sp)
    8000372c:	6145                	addi	sp,sp,48
    8000372e:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003730:	02059493          	slli	s1,a1,0x20
    80003734:	9081                	srli	s1,s1,0x20
    80003736:	048a                	slli	s1,s1,0x2
    80003738:	94aa                	add	s1,s1,a0
    8000373a:	0504a983          	lw	s3,80(s1)
    8000373e:	fe0990e3          	bnez	s3,8000371e <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003742:	4108                	lw	a0,0(a0)
    80003744:	00000097          	auipc	ra,0x0
    80003748:	e4a080e7          	jalr	-438(ra) # 8000358e <balloc>
    8000374c:	0005099b          	sext.w	s3,a0
    80003750:	0534a823          	sw	s3,80(s1)
    80003754:	b7e9                	j	8000371e <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003756:	4108                	lw	a0,0(a0)
    80003758:	00000097          	auipc	ra,0x0
    8000375c:	e36080e7          	jalr	-458(ra) # 8000358e <balloc>
    80003760:	0005059b          	sext.w	a1,a0
    80003764:	08b92023          	sw	a1,128(s2)
    80003768:	b759                	j	800036ee <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000376a:	00092503          	lw	a0,0(s2)
    8000376e:	00000097          	auipc	ra,0x0
    80003772:	e20080e7          	jalr	-480(ra) # 8000358e <balloc>
    80003776:	0005099b          	sext.w	s3,a0
    8000377a:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000377e:	8552                	mv	a0,s4
    80003780:	00001097          	auipc	ra,0x1
    80003784:	ef8080e7          	jalr	-264(ra) # 80004678 <log_write>
    80003788:	b771                	j	80003714 <bmap+0x54>
  panic("bmap: out of range");
    8000378a:	00005517          	auipc	a0,0x5
    8000378e:	dbe50513          	addi	a0,a0,-578 # 80008548 <syscalls+0x128>
    80003792:	ffffd097          	auipc	ra,0xffffd
    80003796:	d98080e7          	jalr	-616(ra) # 8000052a <panic>

000000008000379a <iget>:
{
    8000379a:	7179                	addi	sp,sp,-48
    8000379c:	f406                	sd	ra,40(sp)
    8000379e:	f022                	sd	s0,32(sp)
    800037a0:	ec26                	sd	s1,24(sp)
    800037a2:	e84a                	sd	s2,16(sp)
    800037a4:	e44e                	sd	s3,8(sp)
    800037a6:	e052                	sd	s4,0(sp)
    800037a8:	1800                	addi	s0,sp,48
    800037aa:	89aa                	mv	s3,a0
    800037ac:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800037ae:	0002a517          	auipc	a0,0x2a
    800037b2:	00250513          	addi	a0,a0,2 # 8002d7b0 <icache>
    800037b6:	ffffd097          	auipc	ra,0xffffd
    800037ba:	40c080e7          	jalr	1036(ra) # 80000bc2 <acquire>
  empty = 0;
    800037be:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800037c0:	0002a497          	auipc	s1,0x2a
    800037c4:	00848493          	addi	s1,s1,8 # 8002d7c8 <icache+0x18>
    800037c8:	0002c697          	auipc	a3,0x2c
    800037cc:	a9068693          	addi	a3,a3,-1392 # 8002f258 <log>
    800037d0:	a039                	j	800037de <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037d2:	02090b63          	beqz	s2,80003808 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800037d6:	08848493          	addi	s1,s1,136
    800037da:	02d48a63          	beq	s1,a3,8000380e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800037de:	449c                	lw	a5,8(s1)
    800037e0:	fef059e3          	blez	a5,800037d2 <iget+0x38>
    800037e4:	4098                	lw	a4,0(s1)
    800037e6:	ff3716e3          	bne	a4,s3,800037d2 <iget+0x38>
    800037ea:	40d8                	lw	a4,4(s1)
    800037ec:	ff4713e3          	bne	a4,s4,800037d2 <iget+0x38>
      ip->ref++;
    800037f0:	2785                	addiw	a5,a5,1
    800037f2:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800037f4:	0002a517          	auipc	a0,0x2a
    800037f8:	fbc50513          	addi	a0,a0,-68 # 8002d7b0 <icache>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	47a080e7          	jalr	1146(ra) # 80000c76 <release>
      return ip;
    80003804:	8926                	mv	s2,s1
    80003806:	a03d                	j	80003834 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003808:	f7f9                	bnez	a5,800037d6 <iget+0x3c>
    8000380a:	8926                	mv	s2,s1
    8000380c:	b7e9                	j	800037d6 <iget+0x3c>
  if(empty == 0)
    8000380e:	02090c63          	beqz	s2,80003846 <iget+0xac>
  ip->dev = dev;
    80003812:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003816:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000381a:	4785                	li	a5,1
    8000381c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003820:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003824:	0002a517          	auipc	a0,0x2a
    80003828:	f8c50513          	addi	a0,a0,-116 # 8002d7b0 <icache>
    8000382c:	ffffd097          	auipc	ra,0xffffd
    80003830:	44a080e7          	jalr	1098(ra) # 80000c76 <release>
}
    80003834:	854a                	mv	a0,s2
    80003836:	70a2                	ld	ra,40(sp)
    80003838:	7402                	ld	s0,32(sp)
    8000383a:	64e2                	ld	s1,24(sp)
    8000383c:	6942                	ld	s2,16(sp)
    8000383e:	69a2                	ld	s3,8(sp)
    80003840:	6a02                	ld	s4,0(sp)
    80003842:	6145                	addi	sp,sp,48
    80003844:	8082                	ret
    panic("iget: no inodes");
    80003846:	00005517          	auipc	a0,0x5
    8000384a:	d1a50513          	addi	a0,a0,-742 # 80008560 <syscalls+0x140>
    8000384e:	ffffd097          	auipc	ra,0xffffd
    80003852:	cdc080e7          	jalr	-804(ra) # 8000052a <panic>

0000000080003856 <fsinit>:
fsinit(int dev) {
    80003856:	7179                	addi	sp,sp,-48
    80003858:	f406                	sd	ra,40(sp)
    8000385a:	f022                	sd	s0,32(sp)
    8000385c:	ec26                	sd	s1,24(sp)
    8000385e:	e84a                	sd	s2,16(sp)
    80003860:	e44e                	sd	s3,8(sp)
    80003862:	1800                	addi	s0,sp,48
    80003864:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003866:	4585                	li	a1,1
    80003868:	00000097          	auipc	ra,0x0
    8000386c:	a64080e7          	jalr	-1436(ra) # 800032cc <bread>
    80003870:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003872:	0002a997          	auipc	s3,0x2a
    80003876:	f1e98993          	addi	s3,s3,-226 # 8002d790 <sb>
    8000387a:	02000613          	li	a2,32
    8000387e:	05850593          	addi	a1,a0,88
    80003882:	854e                	mv	a0,s3
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	496080e7          	jalr	1174(ra) # 80000d1a <memmove>
  brelse(bp);
    8000388c:	8526                	mv	a0,s1
    8000388e:	00000097          	auipc	ra,0x0
    80003892:	b6e080e7          	jalr	-1170(ra) # 800033fc <brelse>
  if(sb.magic != FSMAGIC)
    80003896:	0009a703          	lw	a4,0(s3)
    8000389a:	102037b7          	lui	a5,0x10203
    8000389e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800038a2:	02f71263          	bne	a4,a5,800038c6 <fsinit+0x70>
  initlog(dev, &sb);
    800038a6:	0002a597          	auipc	a1,0x2a
    800038aa:	eea58593          	addi	a1,a1,-278 # 8002d790 <sb>
    800038ae:	854a                	mv	a0,s2
    800038b0:	00001097          	auipc	ra,0x1
    800038b4:	b4c080e7          	jalr	-1204(ra) # 800043fc <initlog>
}
    800038b8:	70a2                	ld	ra,40(sp)
    800038ba:	7402                	ld	s0,32(sp)
    800038bc:	64e2                	ld	s1,24(sp)
    800038be:	6942                	ld	s2,16(sp)
    800038c0:	69a2                	ld	s3,8(sp)
    800038c2:	6145                	addi	sp,sp,48
    800038c4:	8082                	ret
    panic("invalid file system");
    800038c6:	00005517          	auipc	a0,0x5
    800038ca:	caa50513          	addi	a0,a0,-854 # 80008570 <syscalls+0x150>
    800038ce:	ffffd097          	auipc	ra,0xffffd
    800038d2:	c5c080e7          	jalr	-932(ra) # 8000052a <panic>

00000000800038d6 <iinit>:
{
    800038d6:	7179                	addi	sp,sp,-48
    800038d8:	f406                	sd	ra,40(sp)
    800038da:	f022                	sd	s0,32(sp)
    800038dc:	ec26                	sd	s1,24(sp)
    800038de:	e84a                	sd	s2,16(sp)
    800038e0:	e44e                	sd	s3,8(sp)
    800038e2:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800038e4:	00005597          	auipc	a1,0x5
    800038e8:	ca458593          	addi	a1,a1,-860 # 80008588 <syscalls+0x168>
    800038ec:	0002a517          	auipc	a0,0x2a
    800038f0:	ec450513          	addi	a0,a0,-316 # 8002d7b0 <icache>
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	23e080e7          	jalr	574(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    800038fc:	0002a497          	auipc	s1,0x2a
    80003900:	edc48493          	addi	s1,s1,-292 # 8002d7d8 <icache+0x28>
    80003904:	0002c997          	auipc	s3,0x2c
    80003908:	96498993          	addi	s3,s3,-1692 # 8002f268 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000390c:	00005917          	auipc	s2,0x5
    80003910:	c8490913          	addi	s2,s2,-892 # 80008590 <syscalls+0x170>
    80003914:	85ca                	mv	a1,s2
    80003916:	8526                	mv	a0,s1
    80003918:	00001097          	auipc	ra,0x1
    8000391c:	e4e080e7          	jalr	-434(ra) # 80004766 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003920:	08848493          	addi	s1,s1,136
    80003924:	ff3498e3          	bne	s1,s3,80003914 <iinit+0x3e>
}
    80003928:	70a2                	ld	ra,40(sp)
    8000392a:	7402                	ld	s0,32(sp)
    8000392c:	64e2                	ld	s1,24(sp)
    8000392e:	6942                	ld	s2,16(sp)
    80003930:	69a2                	ld	s3,8(sp)
    80003932:	6145                	addi	sp,sp,48
    80003934:	8082                	ret

0000000080003936 <ialloc>:
{
    80003936:	715d                	addi	sp,sp,-80
    80003938:	e486                	sd	ra,72(sp)
    8000393a:	e0a2                	sd	s0,64(sp)
    8000393c:	fc26                	sd	s1,56(sp)
    8000393e:	f84a                	sd	s2,48(sp)
    80003940:	f44e                	sd	s3,40(sp)
    80003942:	f052                	sd	s4,32(sp)
    80003944:	ec56                	sd	s5,24(sp)
    80003946:	e85a                	sd	s6,16(sp)
    80003948:	e45e                	sd	s7,8(sp)
    8000394a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000394c:	0002a717          	auipc	a4,0x2a
    80003950:	e5072703          	lw	a4,-432(a4) # 8002d79c <sb+0xc>
    80003954:	4785                	li	a5,1
    80003956:	04e7fa63          	bgeu	a5,a4,800039aa <ialloc+0x74>
    8000395a:	8aaa                	mv	s5,a0
    8000395c:	8bae                	mv	s7,a1
    8000395e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003960:	0002aa17          	auipc	s4,0x2a
    80003964:	e30a0a13          	addi	s4,s4,-464 # 8002d790 <sb>
    80003968:	00048b1b          	sext.w	s6,s1
    8000396c:	0044d793          	srli	a5,s1,0x4
    80003970:	018a2583          	lw	a1,24(s4)
    80003974:	9dbd                	addw	a1,a1,a5
    80003976:	8556                	mv	a0,s5
    80003978:	00000097          	auipc	ra,0x0
    8000397c:	954080e7          	jalr	-1708(ra) # 800032cc <bread>
    80003980:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003982:	05850993          	addi	s3,a0,88
    80003986:	00f4f793          	andi	a5,s1,15
    8000398a:	079a                	slli	a5,a5,0x6
    8000398c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000398e:	00099783          	lh	a5,0(s3)
    80003992:	c785                	beqz	a5,800039ba <ialloc+0x84>
    brelse(bp);
    80003994:	00000097          	auipc	ra,0x0
    80003998:	a68080e7          	jalr	-1432(ra) # 800033fc <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000399c:	0485                	addi	s1,s1,1
    8000399e:	00ca2703          	lw	a4,12(s4)
    800039a2:	0004879b          	sext.w	a5,s1
    800039a6:	fce7e1e3          	bltu	a5,a4,80003968 <ialloc+0x32>
  panic("ialloc: no inodes");
    800039aa:	00005517          	auipc	a0,0x5
    800039ae:	bee50513          	addi	a0,a0,-1042 # 80008598 <syscalls+0x178>
    800039b2:	ffffd097          	auipc	ra,0xffffd
    800039b6:	b78080e7          	jalr	-1160(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    800039ba:	04000613          	li	a2,64
    800039be:	4581                	li	a1,0
    800039c0:	854e                	mv	a0,s3
    800039c2:	ffffd097          	auipc	ra,0xffffd
    800039c6:	2fc080e7          	jalr	764(ra) # 80000cbe <memset>
      dip->type = type;
    800039ca:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800039ce:	854a                	mv	a0,s2
    800039d0:	00001097          	auipc	ra,0x1
    800039d4:	ca8080e7          	jalr	-856(ra) # 80004678 <log_write>
      brelse(bp);
    800039d8:	854a                	mv	a0,s2
    800039da:	00000097          	auipc	ra,0x0
    800039de:	a22080e7          	jalr	-1502(ra) # 800033fc <brelse>
      return iget(dev, inum);
    800039e2:	85da                	mv	a1,s6
    800039e4:	8556                	mv	a0,s5
    800039e6:	00000097          	auipc	ra,0x0
    800039ea:	db4080e7          	jalr	-588(ra) # 8000379a <iget>
}
    800039ee:	60a6                	ld	ra,72(sp)
    800039f0:	6406                	ld	s0,64(sp)
    800039f2:	74e2                	ld	s1,56(sp)
    800039f4:	7942                	ld	s2,48(sp)
    800039f6:	79a2                	ld	s3,40(sp)
    800039f8:	7a02                	ld	s4,32(sp)
    800039fa:	6ae2                	ld	s5,24(sp)
    800039fc:	6b42                	ld	s6,16(sp)
    800039fe:	6ba2                	ld	s7,8(sp)
    80003a00:	6161                	addi	sp,sp,80
    80003a02:	8082                	ret

0000000080003a04 <iupdate>:
{
    80003a04:	1101                	addi	sp,sp,-32
    80003a06:	ec06                	sd	ra,24(sp)
    80003a08:	e822                	sd	s0,16(sp)
    80003a0a:	e426                	sd	s1,8(sp)
    80003a0c:	e04a                	sd	s2,0(sp)
    80003a0e:	1000                	addi	s0,sp,32
    80003a10:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a12:	415c                	lw	a5,4(a0)
    80003a14:	0047d79b          	srliw	a5,a5,0x4
    80003a18:	0002a597          	auipc	a1,0x2a
    80003a1c:	d905a583          	lw	a1,-624(a1) # 8002d7a8 <sb+0x18>
    80003a20:	9dbd                	addw	a1,a1,a5
    80003a22:	4108                	lw	a0,0(a0)
    80003a24:	00000097          	auipc	ra,0x0
    80003a28:	8a8080e7          	jalr	-1880(ra) # 800032cc <bread>
    80003a2c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a2e:	05850793          	addi	a5,a0,88
    80003a32:	40c8                	lw	a0,4(s1)
    80003a34:	893d                	andi	a0,a0,15
    80003a36:	051a                	slli	a0,a0,0x6
    80003a38:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003a3a:	04449703          	lh	a4,68(s1)
    80003a3e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003a42:	04649703          	lh	a4,70(s1)
    80003a46:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003a4a:	04849703          	lh	a4,72(s1)
    80003a4e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003a52:	04a49703          	lh	a4,74(s1)
    80003a56:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003a5a:	44f8                	lw	a4,76(s1)
    80003a5c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a5e:	03400613          	li	a2,52
    80003a62:	05048593          	addi	a1,s1,80
    80003a66:	0531                	addi	a0,a0,12
    80003a68:	ffffd097          	auipc	ra,0xffffd
    80003a6c:	2b2080e7          	jalr	690(ra) # 80000d1a <memmove>
  log_write(bp);
    80003a70:	854a                	mv	a0,s2
    80003a72:	00001097          	auipc	ra,0x1
    80003a76:	c06080e7          	jalr	-1018(ra) # 80004678 <log_write>
  brelse(bp);
    80003a7a:	854a                	mv	a0,s2
    80003a7c:	00000097          	auipc	ra,0x0
    80003a80:	980080e7          	jalr	-1664(ra) # 800033fc <brelse>
}
    80003a84:	60e2                	ld	ra,24(sp)
    80003a86:	6442                	ld	s0,16(sp)
    80003a88:	64a2                	ld	s1,8(sp)
    80003a8a:	6902                	ld	s2,0(sp)
    80003a8c:	6105                	addi	sp,sp,32
    80003a8e:	8082                	ret

0000000080003a90 <idup>:
{
    80003a90:	1101                	addi	sp,sp,-32
    80003a92:	ec06                	sd	ra,24(sp)
    80003a94:	e822                	sd	s0,16(sp)
    80003a96:	e426                	sd	s1,8(sp)
    80003a98:	1000                	addi	s0,sp,32
    80003a9a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a9c:	0002a517          	auipc	a0,0x2a
    80003aa0:	d1450513          	addi	a0,a0,-748 # 8002d7b0 <icache>
    80003aa4:	ffffd097          	auipc	ra,0xffffd
    80003aa8:	11e080e7          	jalr	286(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003aac:	449c                	lw	a5,8(s1)
    80003aae:	2785                	addiw	a5,a5,1
    80003ab0:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003ab2:	0002a517          	auipc	a0,0x2a
    80003ab6:	cfe50513          	addi	a0,a0,-770 # 8002d7b0 <icache>
    80003aba:	ffffd097          	auipc	ra,0xffffd
    80003abe:	1bc080e7          	jalr	444(ra) # 80000c76 <release>
}
    80003ac2:	8526                	mv	a0,s1
    80003ac4:	60e2                	ld	ra,24(sp)
    80003ac6:	6442                	ld	s0,16(sp)
    80003ac8:	64a2                	ld	s1,8(sp)
    80003aca:	6105                	addi	sp,sp,32
    80003acc:	8082                	ret

0000000080003ace <ilock>:
{
    80003ace:	1101                	addi	sp,sp,-32
    80003ad0:	ec06                	sd	ra,24(sp)
    80003ad2:	e822                	sd	s0,16(sp)
    80003ad4:	e426                	sd	s1,8(sp)
    80003ad6:	e04a                	sd	s2,0(sp)
    80003ad8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ada:	c115                	beqz	a0,80003afe <ilock+0x30>
    80003adc:	84aa                	mv	s1,a0
    80003ade:	451c                	lw	a5,8(a0)
    80003ae0:	00f05f63          	blez	a5,80003afe <ilock+0x30>
  acquiresleep(&ip->lock);
    80003ae4:	0541                	addi	a0,a0,16
    80003ae6:	00001097          	auipc	ra,0x1
    80003aea:	cba080e7          	jalr	-838(ra) # 800047a0 <acquiresleep>
  if(ip->valid == 0){
    80003aee:	40bc                	lw	a5,64(s1)
    80003af0:	cf99                	beqz	a5,80003b0e <ilock+0x40>
}
    80003af2:	60e2                	ld	ra,24(sp)
    80003af4:	6442                	ld	s0,16(sp)
    80003af6:	64a2                	ld	s1,8(sp)
    80003af8:	6902                	ld	s2,0(sp)
    80003afa:	6105                	addi	sp,sp,32
    80003afc:	8082                	ret
    panic("ilock");
    80003afe:	00005517          	auipc	a0,0x5
    80003b02:	ab250513          	addi	a0,a0,-1358 # 800085b0 <syscalls+0x190>
    80003b06:	ffffd097          	auipc	ra,0xffffd
    80003b0a:	a24080e7          	jalr	-1500(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b0e:	40dc                	lw	a5,4(s1)
    80003b10:	0047d79b          	srliw	a5,a5,0x4
    80003b14:	0002a597          	auipc	a1,0x2a
    80003b18:	c945a583          	lw	a1,-876(a1) # 8002d7a8 <sb+0x18>
    80003b1c:	9dbd                	addw	a1,a1,a5
    80003b1e:	4088                	lw	a0,0(s1)
    80003b20:	fffff097          	auipc	ra,0xfffff
    80003b24:	7ac080e7          	jalr	1964(ra) # 800032cc <bread>
    80003b28:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b2a:	05850593          	addi	a1,a0,88
    80003b2e:	40dc                	lw	a5,4(s1)
    80003b30:	8bbd                	andi	a5,a5,15
    80003b32:	079a                	slli	a5,a5,0x6
    80003b34:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b36:	00059783          	lh	a5,0(a1)
    80003b3a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b3e:	00259783          	lh	a5,2(a1)
    80003b42:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b46:	00459783          	lh	a5,4(a1)
    80003b4a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b4e:	00659783          	lh	a5,6(a1)
    80003b52:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b56:	459c                	lw	a5,8(a1)
    80003b58:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b5a:	03400613          	li	a2,52
    80003b5e:	05b1                	addi	a1,a1,12
    80003b60:	05048513          	addi	a0,s1,80
    80003b64:	ffffd097          	auipc	ra,0xffffd
    80003b68:	1b6080e7          	jalr	438(ra) # 80000d1a <memmove>
    brelse(bp);
    80003b6c:	854a                	mv	a0,s2
    80003b6e:	00000097          	auipc	ra,0x0
    80003b72:	88e080e7          	jalr	-1906(ra) # 800033fc <brelse>
    ip->valid = 1;
    80003b76:	4785                	li	a5,1
    80003b78:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003b7a:	04449783          	lh	a5,68(s1)
    80003b7e:	fbb5                	bnez	a5,80003af2 <ilock+0x24>
      panic("ilock: no type");
    80003b80:	00005517          	auipc	a0,0x5
    80003b84:	a3850513          	addi	a0,a0,-1480 # 800085b8 <syscalls+0x198>
    80003b88:	ffffd097          	auipc	ra,0xffffd
    80003b8c:	9a2080e7          	jalr	-1630(ra) # 8000052a <panic>

0000000080003b90 <iunlock>:
{
    80003b90:	1101                	addi	sp,sp,-32
    80003b92:	ec06                	sd	ra,24(sp)
    80003b94:	e822                	sd	s0,16(sp)
    80003b96:	e426                	sd	s1,8(sp)
    80003b98:	e04a                	sd	s2,0(sp)
    80003b9a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b9c:	c905                	beqz	a0,80003bcc <iunlock+0x3c>
    80003b9e:	84aa                	mv	s1,a0
    80003ba0:	01050913          	addi	s2,a0,16
    80003ba4:	854a                	mv	a0,s2
    80003ba6:	00001097          	auipc	ra,0x1
    80003baa:	c94080e7          	jalr	-876(ra) # 8000483a <holdingsleep>
    80003bae:	cd19                	beqz	a0,80003bcc <iunlock+0x3c>
    80003bb0:	449c                	lw	a5,8(s1)
    80003bb2:	00f05d63          	blez	a5,80003bcc <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003bb6:	854a                	mv	a0,s2
    80003bb8:	00001097          	auipc	ra,0x1
    80003bbc:	c3e080e7          	jalr	-962(ra) # 800047f6 <releasesleep>
}
    80003bc0:	60e2                	ld	ra,24(sp)
    80003bc2:	6442                	ld	s0,16(sp)
    80003bc4:	64a2                	ld	s1,8(sp)
    80003bc6:	6902                	ld	s2,0(sp)
    80003bc8:	6105                	addi	sp,sp,32
    80003bca:	8082                	ret
    panic("iunlock");
    80003bcc:	00005517          	auipc	a0,0x5
    80003bd0:	9fc50513          	addi	a0,a0,-1540 # 800085c8 <syscalls+0x1a8>
    80003bd4:	ffffd097          	auipc	ra,0xffffd
    80003bd8:	956080e7          	jalr	-1706(ra) # 8000052a <panic>

0000000080003bdc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003bdc:	7179                	addi	sp,sp,-48
    80003bde:	f406                	sd	ra,40(sp)
    80003be0:	f022                	sd	s0,32(sp)
    80003be2:	ec26                	sd	s1,24(sp)
    80003be4:	e84a                	sd	s2,16(sp)
    80003be6:	e44e                	sd	s3,8(sp)
    80003be8:	e052                	sd	s4,0(sp)
    80003bea:	1800                	addi	s0,sp,48
    80003bec:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003bee:	05050493          	addi	s1,a0,80
    80003bf2:	08050913          	addi	s2,a0,128
    80003bf6:	a021                	j	80003bfe <itrunc+0x22>
    80003bf8:	0491                	addi	s1,s1,4
    80003bfa:	01248d63          	beq	s1,s2,80003c14 <itrunc+0x38>
    if(ip->addrs[i]){
    80003bfe:	408c                	lw	a1,0(s1)
    80003c00:	dde5                	beqz	a1,80003bf8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c02:	0009a503          	lw	a0,0(s3)
    80003c06:	00000097          	auipc	ra,0x0
    80003c0a:	90c080e7          	jalr	-1780(ra) # 80003512 <bfree>
      ip->addrs[i] = 0;
    80003c0e:	0004a023          	sw	zero,0(s1)
    80003c12:	b7dd                	j	80003bf8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c14:	0809a583          	lw	a1,128(s3)
    80003c18:	e185                	bnez	a1,80003c38 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c1a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c1e:	854e                	mv	a0,s3
    80003c20:	00000097          	auipc	ra,0x0
    80003c24:	de4080e7          	jalr	-540(ra) # 80003a04 <iupdate>
}
    80003c28:	70a2                	ld	ra,40(sp)
    80003c2a:	7402                	ld	s0,32(sp)
    80003c2c:	64e2                	ld	s1,24(sp)
    80003c2e:	6942                	ld	s2,16(sp)
    80003c30:	69a2                	ld	s3,8(sp)
    80003c32:	6a02                	ld	s4,0(sp)
    80003c34:	6145                	addi	sp,sp,48
    80003c36:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c38:	0009a503          	lw	a0,0(s3)
    80003c3c:	fffff097          	auipc	ra,0xfffff
    80003c40:	690080e7          	jalr	1680(ra) # 800032cc <bread>
    80003c44:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c46:	05850493          	addi	s1,a0,88
    80003c4a:	45850913          	addi	s2,a0,1112
    80003c4e:	a021                	j	80003c56 <itrunc+0x7a>
    80003c50:	0491                	addi	s1,s1,4
    80003c52:	01248b63          	beq	s1,s2,80003c68 <itrunc+0x8c>
      if(a[j])
    80003c56:	408c                	lw	a1,0(s1)
    80003c58:	dde5                	beqz	a1,80003c50 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003c5a:	0009a503          	lw	a0,0(s3)
    80003c5e:	00000097          	auipc	ra,0x0
    80003c62:	8b4080e7          	jalr	-1868(ra) # 80003512 <bfree>
    80003c66:	b7ed                	j	80003c50 <itrunc+0x74>
    brelse(bp);
    80003c68:	8552                	mv	a0,s4
    80003c6a:	fffff097          	auipc	ra,0xfffff
    80003c6e:	792080e7          	jalr	1938(ra) # 800033fc <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c72:	0809a583          	lw	a1,128(s3)
    80003c76:	0009a503          	lw	a0,0(s3)
    80003c7a:	00000097          	auipc	ra,0x0
    80003c7e:	898080e7          	jalr	-1896(ra) # 80003512 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c82:	0809a023          	sw	zero,128(s3)
    80003c86:	bf51                	j	80003c1a <itrunc+0x3e>

0000000080003c88 <iput>:
{
    80003c88:	1101                	addi	sp,sp,-32
    80003c8a:	ec06                	sd	ra,24(sp)
    80003c8c:	e822                	sd	s0,16(sp)
    80003c8e:	e426                	sd	s1,8(sp)
    80003c90:	e04a                	sd	s2,0(sp)
    80003c92:	1000                	addi	s0,sp,32
    80003c94:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003c96:	0002a517          	auipc	a0,0x2a
    80003c9a:	b1a50513          	addi	a0,a0,-1254 # 8002d7b0 <icache>
    80003c9e:	ffffd097          	auipc	ra,0xffffd
    80003ca2:	f24080e7          	jalr	-220(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ca6:	4498                	lw	a4,8(s1)
    80003ca8:	4785                	li	a5,1
    80003caa:	02f70363          	beq	a4,a5,80003cd0 <iput+0x48>
  ip->ref--;
    80003cae:	449c                	lw	a5,8(s1)
    80003cb0:	37fd                	addiw	a5,a5,-1
    80003cb2:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003cb4:	0002a517          	auipc	a0,0x2a
    80003cb8:	afc50513          	addi	a0,a0,-1284 # 8002d7b0 <icache>
    80003cbc:	ffffd097          	auipc	ra,0xffffd
    80003cc0:	fba080e7          	jalr	-70(ra) # 80000c76 <release>
}
    80003cc4:	60e2                	ld	ra,24(sp)
    80003cc6:	6442                	ld	s0,16(sp)
    80003cc8:	64a2                	ld	s1,8(sp)
    80003cca:	6902                	ld	s2,0(sp)
    80003ccc:	6105                	addi	sp,sp,32
    80003cce:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cd0:	40bc                	lw	a5,64(s1)
    80003cd2:	dff1                	beqz	a5,80003cae <iput+0x26>
    80003cd4:	04a49783          	lh	a5,74(s1)
    80003cd8:	fbf9                	bnez	a5,80003cae <iput+0x26>
    acquiresleep(&ip->lock);
    80003cda:	01048913          	addi	s2,s1,16
    80003cde:	854a                	mv	a0,s2
    80003ce0:	00001097          	auipc	ra,0x1
    80003ce4:	ac0080e7          	jalr	-1344(ra) # 800047a0 <acquiresleep>
    release(&icache.lock);
    80003ce8:	0002a517          	auipc	a0,0x2a
    80003cec:	ac850513          	addi	a0,a0,-1336 # 8002d7b0 <icache>
    80003cf0:	ffffd097          	auipc	ra,0xffffd
    80003cf4:	f86080e7          	jalr	-122(ra) # 80000c76 <release>
    itrunc(ip);
    80003cf8:	8526                	mv	a0,s1
    80003cfa:	00000097          	auipc	ra,0x0
    80003cfe:	ee2080e7          	jalr	-286(ra) # 80003bdc <itrunc>
    ip->type = 0;
    80003d02:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d06:	8526                	mv	a0,s1
    80003d08:	00000097          	auipc	ra,0x0
    80003d0c:	cfc080e7          	jalr	-772(ra) # 80003a04 <iupdate>
    ip->valid = 0;
    80003d10:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d14:	854a                	mv	a0,s2
    80003d16:	00001097          	auipc	ra,0x1
    80003d1a:	ae0080e7          	jalr	-1312(ra) # 800047f6 <releasesleep>
    acquire(&icache.lock);
    80003d1e:	0002a517          	auipc	a0,0x2a
    80003d22:	a9250513          	addi	a0,a0,-1390 # 8002d7b0 <icache>
    80003d26:	ffffd097          	auipc	ra,0xffffd
    80003d2a:	e9c080e7          	jalr	-356(ra) # 80000bc2 <acquire>
    80003d2e:	b741                	j	80003cae <iput+0x26>

0000000080003d30 <iunlockput>:
{
    80003d30:	1101                	addi	sp,sp,-32
    80003d32:	ec06                	sd	ra,24(sp)
    80003d34:	e822                	sd	s0,16(sp)
    80003d36:	e426                	sd	s1,8(sp)
    80003d38:	1000                	addi	s0,sp,32
    80003d3a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	e54080e7          	jalr	-428(ra) # 80003b90 <iunlock>
  iput(ip);
    80003d44:	8526                	mv	a0,s1
    80003d46:	00000097          	auipc	ra,0x0
    80003d4a:	f42080e7          	jalr	-190(ra) # 80003c88 <iput>
}
    80003d4e:	60e2                	ld	ra,24(sp)
    80003d50:	6442                	ld	s0,16(sp)
    80003d52:	64a2                	ld	s1,8(sp)
    80003d54:	6105                	addi	sp,sp,32
    80003d56:	8082                	ret

0000000080003d58 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d58:	1141                	addi	sp,sp,-16
    80003d5a:	e422                	sd	s0,8(sp)
    80003d5c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d5e:	411c                	lw	a5,0(a0)
    80003d60:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d62:	415c                	lw	a5,4(a0)
    80003d64:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d66:	04451783          	lh	a5,68(a0)
    80003d6a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d6e:	04a51783          	lh	a5,74(a0)
    80003d72:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d76:	04c56783          	lwu	a5,76(a0)
    80003d7a:	e99c                	sd	a5,16(a1)
}
    80003d7c:	6422                	ld	s0,8(sp)
    80003d7e:	0141                	addi	sp,sp,16
    80003d80:	8082                	ret

0000000080003d82 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d82:	457c                	lw	a5,76(a0)
    80003d84:	0ed7e963          	bltu	a5,a3,80003e76 <readi+0xf4>
{
    80003d88:	7159                	addi	sp,sp,-112
    80003d8a:	f486                	sd	ra,104(sp)
    80003d8c:	f0a2                	sd	s0,96(sp)
    80003d8e:	eca6                	sd	s1,88(sp)
    80003d90:	e8ca                	sd	s2,80(sp)
    80003d92:	e4ce                	sd	s3,72(sp)
    80003d94:	e0d2                	sd	s4,64(sp)
    80003d96:	fc56                	sd	s5,56(sp)
    80003d98:	f85a                	sd	s6,48(sp)
    80003d9a:	f45e                	sd	s7,40(sp)
    80003d9c:	f062                	sd	s8,32(sp)
    80003d9e:	ec66                	sd	s9,24(sp)
    80003da0:	e86a                	sd	s10,16(sp)
    80003da2:	e46e                	sd	s11,8(sp)
    80003da4:	1880                	addi	s0,sp,112
    80003da6:	8baa                	mv	s7,a0
    80003da8:	8c2e                	mv	s8,a1
    80003daa:	8ab2                	mv	s5,a2
    80003dac:	84b6                	mv	s1,a3
    80003dae:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003db0:	9f35                	addw	a4,a4,a3
    return 0;
    80003db2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003db4:	0ad76063          	bltu	a4,a3,80003e54 <readi+0xd2>
  if(off + n > ip->size)
    80003db8:	00e7f463          	bgeu	a5,a4,80003dc0 <readi+0x3e>
    n = ip->size - off;
    80003dbc:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dc0:	0a0b0963          	beqz	s6,80003e72 <readi+0xf0>
    80003dc4:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dc6:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003dca:	5cfd                	li	s9,-1
    80003dcc:	a82d                	j	80003e06 <readi+0x84>
    80003dce:	020a1d93          	slli	s11,s4,0x20
    80003dd2:	020ddd93          	srli	s11,s11,0x20
    80003dd6:	05890793          	addi	a5,s2,88
    80003dda:	86ee                	mv	a3,s11
    80003ddc:	963e                	add	a2,a2,a5
    80003dde:	85d6                	mv	a1,s5
    80003de0:	8562                	mv	a0,s8
    80003de2:	fffff097          	auipc	ra,0xfffff
    80003de6:	ad6080e7          	jalr	-1322(ra) # 800028b8 <either_copyout>
    80003dea:	05950d63          	beq	a0,s9,80003e44 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003dee:	854a                	mv	a0,s2
    80003df0:	fffff097          	auipc	ra,0xfffff
    80003df4:	60c080e7          	jalr	1548(ra) # 800033fc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003df8:	013a09bb          	addw	s3,s4,s3
    80003dfc:	009a04bb          	addw	s1,s4,s1
    80003e00:	9aee                	add	s5,s5,s11
    80003e02:	0569f763          	bgeu	s3,s6,80003e50 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e06:	000ba903          	lw	s2,0(s7)
    80003e0a:	00a4d59b          	srliw	a1,s1,0xa
    80003e0e:	855e                	mv	a0,s7
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	8b0080e7          	jalr	-1872(ra) # 800036c0 <bmap>
    80003e18:	0005059b          	sext.w	a1,a0
    80003e1c:	854a                	mv	a0,s2
    80003e1e:	fffff097          	auipc	ra,0xfffff
    80003e22:	4ae080e7          	jalr	1198(ra) # 800032cc <bread>
    80003e26:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e28:	3ff4f613          	andi	a2,s1,1023
    80003e2c:	40cd07bb          	subw	a5,s10,a2
    80003e30:	413b073b          	subw	a4,s6,s3
    80003e34:	8a3e                	mv	s4,a5
    80003e36:	2781                	sext.w	a5,a5
    80003e38:	0007069b          	sext.w	a3,a4
    80003e3c:	f8f6f9e3          	bgeu	a3,a5,80003dce <readi+0x4c>
    80003e40:	8a3a                	mv	s4,a4
    80003e42:	b771                	j	80003dce <readi+0x4c>
      brelse(bp);
    80003e44:	854a                	mv	a0,s2
    80003e46:	fffff097          	auipc	ra,0xfffff
    80003e4a:	5b6080e7          	jalr	1462(ra) # 800033fc <brelse>
      tot = -1;
    80003e4e:	59fd                	li	s3,-1
  }
  return tot;
    80003e50:	0009851b          	sext.w	a0,s3
}
    80003e54:	70a6                	ld	ra,104(sp)
    80003e56:	7406                	ld	s0,96(sp)
    80003e58:	64e6                	ld	s1,88(sp)
    80003e5a:	6946                	ld	s2,80(sp)
    80003e5c:	69a6                	ld	s3,72(sp)
    80003e5e:	6a06                	ld	s4,64(sp)
    80003e60:	7ae2                	ld	s5,56(sp)
    80003e62:	7b42                	ld	s6,48(sp)
    80003e64:	7ba2                	ld	s7,40(sp)
    80003e66:	7c02                	ld	s8,32(sp)
    80003e68:	6ce2                	ld	s9,24(sp)
    80003e6a:	6d42                	ld	s10,16(sp)
    80003e6c:	6da2                	ld	s11,8(sp)
    80003e6e:	6165                	addi	sp,sp,112
    80003e70:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e72:	89da                	mv	s3,s6
    80003e74:	bff1                	j	80003e50 <readi+0xce>
    return 0;
    80003e76:	4501                	li	a0,0
}
    80003e78:	8082                	ret

0000000080003e7a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e7a:	457c                	lw	a5,76(a0)
    80003e7c:	10d7e863          	bltu	a5,a3,80003f8c <writei+0x112>
{
    80003e80:	7159                	addi	sp,sp,-112
    80003e82:	f486                	sd	ra,104(sp)
    80003e84:	f0a2                	sd	s0,96(sp)
    80003e86:	eca6                	sd	s1,88(sp)
    80003e88:	e8ca                	sd	s2,80(sp)
    80003e8a:	e4ce                	sd	s3,72(sp)
    80003e8c:	e0d2                	sd	s4,64(sp)
    80003e8e:	fc56                	sd	s5,56(sp)
    80003e90:	f85a                	sd	s6,48(sp)
    80003e92:	f45e                	sd	s7,40(sp)
    80003e94:	f062                	sd	s8,32(sp)
    80003e96:	ec66                	sd	s9,24(sp)
    80003e98:	e86a                	sd	s10,16(sp)
    80003e9a:	e46e                	sd	s11,8(sp)
    80003e9c:	1880                	addi	s0,sp,112
    80003e9e:	8b2a                	mv	s6,a0
    80003ea0:	8c2e                	mv	s8,a1
    80003ea2:	8ab2                	mv	s5,a2
    80003ea4:	8936                	mv	s2,a3
    80003ea6:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003ea8:	00e687bb          	addw	a5,a3,a4
    80003eac:	0ed7e263          	bltu	a5,a3,80003f90 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003eb0:	00043737          	lui	a4,0x43
    80003eb4:	0ef76063          	bltu	a4,a5,80003f94 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003eb8:	0c0b8863          	beqz	s7,80003f88 <writei+0x10e>
    80003ebc:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ebe:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ec2:	5cfd                	li	s9,-1
    80003ec4:	a091                	j	80003f08 <writei+0x8e>
    80003ec6:	02099d93          	slli	s11,s3,0x20
    80003eca:	020ddd93          	srli	s11,s11,0x20
    80003ece:	05848793          	addi	a5,s1,88
    80003ed2:	86ee                	mv	a3,s11
    80003ed4:	8656                	mv	a2,s5
    80003ed6:	85e2                	mv	a1,s8
    80003ed8:	953e                	add	a0,a0,a5
    80003eda:	fffff097          	auipc	ra,0xfffff
    80003ede:	a34080e7          	jalr	-1484(ra) # 8000290e <either_copyin>
    80003ee2:	07950263          	beq	a0,s9,80003f46 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ee6:	8526                	mv	a0,s1
    80003ee8:	00000097          	auipc	ra,0x0
    80003eec:	790080e7          	jalr	1936(ra) # 80004678 <log_write>
    brelse(bp);
    80003ef0:	8526                	mv	a0,s1
    80003ef2:	fffff097          	auipc	ra,0xfffff
    80003ef6:	50a080e7          	jalr	1290(ra) # 800033fc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003efa:	01498a3b          	addw	s4,s3,s4
    80003efe:	0129893b          	addw	s2,s3,s2
    80003f02:	9aee                	add	s5,s5,s11
    80003f04:	057a7663          	bgeu	s4,s7,80003f50 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003f08:	000b2483          	lw	s1,0(s6)
    80003f0c:	00a9559b          	srliw	a1,s2,0xa
    80003f10:	855a                	mv	a0,s6
    80003f12:	fffff097          	auipc	ra,0xfffff
    80003f16:	7ae080e7          	jalr	1966(ra) # 800036c0 <bmap>
    80003f1a:	0005059b          	sext.w	a1,a0
    80003f1e:	8526                	mv	a0,s1
    80003f20:	fffff097          	auipc	ra,0xfffff
    80003f24:	3ac080e7          	jalr	940(ra) # 800032cc <bread>
    80003f28:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f2a:	3ff97513          	andi	a0,s2,1023
    80003f2e:	40ad07bb          	subw	a5,s10,a0
    80003f32:	414b873b          	subw	a4,s7,s4
    80003f36:	89be                	mv	s3,a5
    80003f38:	2781                	sext.w	a5,a5
    80003f3a:	0007069b          	sext.w	a3,a4
    80003f3e:	f8f6f4e3          	bgeu	a3,a5,80003ec6 <writei+0x4c>
    80003f42:	89ba                	mv	s3,a4
    80003f44:	b749                	j	80003ec6 <writei+0x4c>
      brelse(bp);
    80003f46:	8526                	mv	a0,s1
    80003f48:	fffff097          	auipc	ra,0xfffff
    80003f4c:	4b4080e7          	jalr	1204(ra) # 800033fc <brelse>
  }

  if(off > ip->size)
    80003f50:	04cb2783          	lw	a5,76(s6)
    80003f54:	0127f463          	bgeu	a5,s2,80003f5c <writei+0xe2>
    ip->size = off;
    80003f58:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f5c:	855a                	mv	a0,s6
    80003f5e:	00000097          	auipc	ra,0x0
    80003f62:	aa6080e7          	jalr	-1370(ra) # 80003a04 <iupdate>

  return tot;
    80003f66:	000a051b          	sext.w	a0,s4
}
    80003f6a:	70a6                	ld	ra,104(sp)
    80003f6c:	7406                	ld	s0,96(sp)
    80003f6e:	64e6                	ld	s1,88(sp)
    80003f70:	6946                	ld	s2,80(sp)
    80003f72:	69a6                	ld	s3,72(sp)
    80003f74:	6a06                	ld	s4,64(sp)
    80003f76:	7ae2                	ld	s5,56(sp)
    80003f78:	7b42                	ld	s6,48(sp)
    80003f7a:	7ba2                	ld	s7,40(sp)
    80003f7c:	7c02                	ld	s8,32(sp)
    80003f7e:	6ce2                	ld	s9,24(sp)
    80003f80:	6d42                	ld	s10,16(sp)
    80003f82:	6da2                	ld	s11,8(sp)
    80003f84:	6165                	addi	sp,sp,112
    80003f86:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f88:	8a5e                	mv	s4,s7
    80003f8a:	bfc9                	j	80003f5c <writei+0xe2>
    return -1;
    80003f8c:	557d                	li	a0,-1
}
    80003f8e:	8082                	ret
    return -1;
    80003f90:	557d                	li	a0,-1
    80003f92:	bfe1                	j	80003f6a <writei+0xf0>
    return -1;
    80003f94:	557d                	li	a0,-1
    80003f96:	bfd1                	j	80003f6a <writei+0xf0>

0000000080003f98 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f98:	1141                	addi	sp,sp,-16
    80003f9a:	e406                	sd	ra,8(sp)
    80003f9c:	e022                	sd	s0,0(sp)
    80003f9e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003fa0:	4639                	li	a2,14
    80003fa2:	ffffd097          	auipc	ra,0xffffd
    80003fa6:	df4080e7          	jalr	-524(ra) # 80000d96 <strncmp>
}
    80003faa:	60a2                	ld	ra,8(sp)
    80003fac:	6402                	ld	s0,0(sp)
    80003fae:	0141                	addi	sp,sp,16
    80003fb0:	8082                	ret

0000000080003fb2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003fb2:	7139                	addi	sp,sp,-64
    80003fb4:	fc06                	sd	ra,56(sp)
    80003fb6:	f822                	sd	s0,48(sp)
    80003fb8:	f426                	sd	s1,40(sp)
    80003fba:	f04a                	sd	s2,32(sp)
    80003fbc:	ec4e                	sd	s3,24(sp)
    80003fbe:	e852                	sd	s4,16(sp)
    80003fc0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003fc2:	04451703          	lh	a4,68(a0)
    80003fc6:	4785                	li	a5,1
    80003fc8:	00f71a63          	bne	a4,a5,80003fdc <dirlookup+0x2a>
    80003fcc:	892a                	mv	s2,a0
    80003fce:	89ae                	mv	s3,a1
    80003fd0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fd2:	457c                	lw	a5,76(a0)
    80003fd4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003fd6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fd8:	e79d                	bnez	a5,80004006 <dirlookup+0x54>
    80003fda:	a8a5                	j	80004052 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003fdc:	00004517          	auipc	a0,0x4
    80003fe0:	5f450513          	addi	a0,a0,1524 # 800085d0 <syscalls+0x1b0>
    80003fe4:	ffffc097          	auipc	ra,0xffffc
    80003fe8:	546080e7          	jalr	1350(ra) # 8000052a <panic>
      panic("dirlookup read");
    80003fec:	00004517          	auipc	a0,0x4
    80003ff0:	5fc50513          	addi	a0,a0,1532 # 800085e8 <syscalls+0x1c8>
    80003ff4:	ffffc097          	auipc	ra,0xffffc
    80003ff8:	536080e7          	jalr	1334(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ffc:	24c1                	addiw	s1,s1,16
    80003ffe:	04c92783          	lw	a5,76(s2)
    80004002:	04f4f763          	bgeu	s1,a5,80004050 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004006:	4741                	li	a4,16
    80004008:	86a6                	mv	a3,s1
    8000400a:	fc040613          	addi	a2,s0,-64
    8000400e:	4581                	li	a1,0
    80004010:	854a                	mv	a0,s2
    80004012:	00000097          	auipc	ra,0x0
    80004016:	d70080e7          	jalr	-656(ra) # 80003d82 <readi>
    8000401a:	47c1                	li	a5,16
    8000401c:	fcf518e3          	bne	a0,a5,80003fec <dirlookup+0x3a>
    if(de.inum == 0)
    80004020:	fc045783          	lhu	a5,-64(s0)
    80004024:	dfe1                	beqz	a5,80003ffc <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004026:	fc240593          	addi	a1,s0,-62
    8000402a:	854e                	mv	a0,s3
    8000402c:	00000097          	auipc	ra,0x0
    80004030:	f6c080e7          	jalr	-148(ra) # 80003f98 <namecmp>
    80004034:	f561                	bnez	a0,80003ffc <dirlookup+0x4a>
      if(poff)
    80004036:	000a0463          	beqz	s4,8000403e <dirlookup+0x8c>
        *poff = off;
    8000403a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000403e:	fc045583          	lhu	a1,-64(s0)
    80004042:	00092503          	lw	a0,0(s2)
    80004046:	fffff097          	auipc	ra,0xfffff
    8000404a:	754080e7          	jalr	1876(ra) # 8000379a <iget>
    8000404e:	a011                	j	80004052 <dirlookup+0xa0>
  return 0;
    80004050:	4501                	li	a0,0
}
    80004052:	70e2                	ld	ra,56(sp)
    80004054:	7442                	ld	s0,48(sp)
    80004056:	74a2                	ld	s1,40(sp)
    80004058:	7902                	ld	s2,32(sp)
    8000405a:	69e2                	ld	s3,24(sp)
    8000405c:	6a42                	ld	s4,16(sp)
    8000405e:	6121                	addi	sp,sp,64
    80004060:	8082                	ret

0000000080004062 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004062:	711d                	addi	sp,sp,-96
    80004064:	ec86                	sd	ra,88(sp)
    80004066:	e8a2                	sd	s0,80(sp)
    80004068:	e4a6                	sd	s1,72(sp)
    8000406a:	e0ca                	sd	s2,64(sp)
    8000406c:	fc4e                	sd	s3,56(sp)
    8000406e:	f852                	sd	s4,48(sp)
    80004070:	f456                	sd	s5,40(sp)
    80004072:	f05a                	sd	s6,32(sp)
    80004074:	ec5e                	sd	s7,24(sp)
    80004076:	e862                	sd	s8,16(sp)
    80004078:	e466                	sd	s9,8(sp)
    8000407a:	1080                	addi	s0,sp,96
    8000407c:	84aa                	mv	s1,a0
    8000407e:	8aae                	mv	s5,a1
    80004080:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004082:	00054703          	lbu	a4,0(a0)
    80004086:	02f00793          	li	a5,47
    8000408a:	02f70363          	beq	a4,a5,800040b0 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000408e:	ffffe097          	auipc	ra,0xffffe
    80004092:	d18080e7          	jalr	-744(ra) # 80001da6 <myproc>
    80004096:	15053503          	ld	a0,336(a0)
    8000409a:	00000097          	auipc	ra,0x0
    8000409e:	9f6080e7          	jalr	-1546(ra) # 80003a90 <idup>
    800040a2:	89aa                	mv	s3,a0
  while(*path == '/')
    800040a4:	02f00913          	li	s2,47
  len = path - s;
    800040a8:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800040aa:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800040ac:	4b85                	li	s7,1
    800040ae:	a865                	j	80004166 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800040b0:	4585                	li	a1,1
    800040b2:	4505                	li	a0,1
    800040b4:	fffff097          	auipc	ra,0xfffff
    800040b8:	6e6080e7          	jalr	1766(ra) # 8000379a <iget>
    800040bc:	89aa                	mv	s3,a0
    800040be:	b7dd                	j	800040a4 <namex+0x42>
      iunlockput(ip);
    800040c0:	854e                	mv	a0,s3
    800040c2:	00000097          	auipc	ra,0x0
    800040c6:	c6e080e7          	jalr	-914(ra) # 80003d30 <iunlockput>
      return 0;
    800040ca:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800040cc:	854e                	mv	a0,s3
    800040ce:	60e6                	ld	ra,88(sp)
    800040d0:	6446                	ld	s0,80(sp)
    800040d2:	64a6                	ld	s1,72(sp)
    800040d4:	6906                	ld	s2,64(sp)
    800040d6:	79e2                	ld	s3,56(sp)
    800040d8:	7a42                	ld	s4,48(sp)
    800040da:	7aa2                	ld	s5,40(sp)
    800040dc:	7b02                	ld	s6,32(sp)
    800040de:	6be2                	ld	s7,24(sp)
    800040e0:	6c42                	ld	s8,16(sp)
    800040e2:	6ca2                	ld	s9,8(sp)
    800040e4:	6125                	addi	sp,sp,96
    800040e6:	8082                	ret
      iunlock(ip);
    800040e8:	854e                	mv	a0,s3
    800040ea:	00000097          	auipc	ra,0x0
    800040ee:	aa6080e7          	jalr	-1370(ra) # 80003b90 <iunlock>
      return ip;
    800040f2:	bfe9                	j	800040cc <namex+0x6a>
      iunlockput(ip);
    800040f4:	854e                	mv	a0,s3
    800040f6:	00000097          	auipc	ra,0x0
    800040fa:	c3a080e7          	jalr	-966(ra) # 80003d30 <iunlockput>
      return 0;
    800040fe:	89e6                	mv	s3,s9
    80004100:	b7f1                	j	800040cc <namex+0x6a>
  len = path - s;
    80004102:	40b48633          	sub	a2,s1,a1
    80004106:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000410a:	099c5463          	bge	s8,s9,80004192 <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000410e:	4639                	li	a2,14
    80004110:	8552                	mv	a0,s4
    80004112:	ffffd097          	auipc	ra,0xffffd
    80004116:	c08080e7          	jalr	-1016(ra) # 80000d1a <memmove>
  while(*path == '/')
    8000411a:	0004c783          	lbu	a5,0(s1)
    8000411e:	01279763          	bne	a5,s2,8000412c <namex+0xca>
    path++;
    80004122:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004124:	0004c783          	lbu	a5,0(s1)
    80004128:	ff278de3          	beq	a5,s2,80004122 <namex+0xc0>
    ilock(ip);
    8000412c:	854e                	mv	a0,s3
    8000412e:	00000097          	auipc	ra,0x0
    80004132:	9a0080e7          	jalr	-1632(ra) # 80003ace <ilock>
    if(ip->type != T_DIR){
    80004136:	04499783          	lh	a5,68(s3)
    8000413a:	f97793e3          	bne	a5,s7,800040c0 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000413e:	000a8563          	beqz	s5,80004148 <namex+0xe6>
    80004142:	0004c783          	lbu	a5,0(s1)
    80004146:	d3cd                	beqz	a5,800040e8 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004148:	865a                	mv	a2,s6
    8000414a:	85d2                	mv	a1,s4
    8000414c:	854e                	mv	a0,s3
    8000414e:	00000097          	auipc	ra,0x0
    80004152:	e64080e7          	jalr	-412(ra) # 80003fb2 <dirlookup>
    80004156:	8caa                	mv	s9,a0
    80004158:	dd51                	beqz	a0,800040f4 <namex+0x92>
    iunlockput(ip);
    8000415a:	854e                	mv	a0,s3
    8000415c:	00000097          	auipc	ra,0x0
    80004160:	bd4080e7          	jalr	-1068(ra) # 80003d30 <iunlockput>
    ip = next;
    80004164:	89e6                	mv	s3,s9
  while(*path == '/')
    80004166:	0004c783          	lbu	a5,0(s1)
    8000416a:	05279763          	bne	a5,s2,800041b8 <namex+0x156>
    path++;
    8000416e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004170:	0004c783          	lbu	a5,0(s1)
    80004174:	ff278de3          	beq	a5,s2,8000416e <namex+0x10c>
  if(*path == 0)
    80004178:	c79d                	beqz	a5,800041a6 <namex+0x144>
    path++;
    8000417a:	85a6                	mv	a1,s1
  len = path - s;
    8000417c:	8cda                	mv	s9,s6
    8000417e:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004180:	01278963          	beq	a5,s2,80004192 <namex+0x130>
    80004184:	dfbd                	beqz	a5,80004102 <namex+0xa0>
    path++;
    80004186:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004188:	0004c783          	lbu	a5,0(s1)
    8000418c:	ff279ce3          	bne	a5,s2,80004184 <namex+0x122>
    80004190:	bf8d                	j	80004102 <namex+0xa0>
    memmove(name, s, len);
    80004192:	2601                	sext.w	a2,a2
    80004194:	8552                	mv	a0,s4
    80004196:	ffffd097          	auipc	ra,0xffffd
    8000419a:	b84080e7          	jalr	-1148(ra) # 80000d1a <memmove>
    name[len] = 0;
    8000419e:	9cd2                	add	s9,s9,s4
    800041a0:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800041a4:	bf9d                	j	8000411a <namex+0xb8>
  if(nameiparent){
    800041a6:	f20a83e3          	beqz	s5,800040cc <namex+0x6a>
    iput(ip);
    800041aa:	854e                	mv	a0,s3
    800041ac:	00000097          	auipc	ra,0x0
    800041b0:	adc080e7          	jalr	-1316(ra) # 80003c88 <iput>
    return 0;
    800041b4:	4981                	li	s3,0
    800041b6:	bf19                	j	800040cc <namex+0x6a>
  if(*path == 0)
    800041b8:	d7fd                	beqz	a5,800041a6 <namex+0x144>
  while(*path != '/' && *path != 0)
    800041ba:	0004c783          	lbu	a5,0(s1)
    800041be:	85a6                	mv	a1,s1
    800041c0:	b7d1                	j	80004184 <namex+0x122>

00000000800041c2 <dirlink>:
{
    800041c2:	7139                	addi	sp,sp,-64
    800041c4:	fc06                	sd	ra,56(sp)
    800041c6:	f822                	sd	s0,48(sp)
    800041c8:	f426                	sd	s1,40(sp)
    800041ca:	f04a                	sd	s2,32(sp)
    800041cc:	ec4e                	sd	s3,24(sp)
    800041ce:	e852                	sd	s4,16(sp)
    800041d0:	0080                	addi	s0,sp,64
    800041d2:	892a                	mv	s2,a0
    800041d4:	8a2e                	mv	s4,a1
    800041d6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041d8:	4601                	li	a2,0
    800041da:	00000097          	auipc	ra,0x0
    800041de:	dd8080e7          	jalr	-552(ra) # 80003fb2 <dirlookup>
    800041e2:	e93d                	bnez	a0,80004258 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041e4:	04c92483          	lw	s1,76(s2)
    800041e8:	c49d                	beqz	s1,80004216 <dirlink+0x54>
    800041ea:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041ec:	4741                	li	a4,16
    800041ee:	86a6                	mv	a3,s1
    800041f0:	fc040613          	addi	a2,s0,-64
    800041f4:	4581                	li	a1,0
    800041f6:	854a                	mv	a0,s2
    800041f8:	00000097          	auipc	ra,0x0
    800041fc:	b8a080e7          	jalr	-1142(ra) # 80003d82 <readi>
    80004200:	47c1                	li	a5,16
    80004202:	06f51163          	bne	a0,a5,80004264 <dirlink+0xa2>
    if(de.inum == 0)
    80004206:	fc045783          	lhu	a5,-64(s0)
    8000420a:	c791                	beqz	a5,80004216 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000420c:	24c1                	addiw	s1,s1,16
    8000420e:	04c92783          	lw	a5,76(s2)
    80004212:	fcf4ede3          	bltu	s1,a5,800041ec <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004216:	4639                	li	a2,14
    80004218:	85d2                	mv	a1,s4
    8000421a:	fc240513          	addi	a0,s0,-62
    8000421e:	ffffd097          	auipc	ra,0xffffd
    80004222:	bb4080e7          	jalr	-1100(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    80004226:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000422a:	4741                	li	a4,16
    8000422c:	86a6                	mv	a3,s1
    8000422e:	fc040613          	addi	a2,s0,-64
    80004232:	4581                	li	a1,0
    80004234:	854a                	mv	a0,s2
    80004236:	00000097          	auipc	ra,0x0
    8000423a:	c44080e7          	jalr	-956(ra) # 80003e7a <writei>
    8000423e:	872a                	mv	a4,a0
    80004240:	47c1                	li	a5,16
  return 0;
    80004242:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004244:	02f71863          	bne	a4,a5,80004274 <dirlink+0xb2>
}
    80004248:	70e2                	ld	ra,56(sp)
    8000424a:	7442                	ld	s0,48(sp)
    8000424c:	74a2                	ld	s1,40(sp)
    8000424e:	7902                	ld	s2,32(sp)
    80004250:	69e2                	ld	s3,24(sp)
    80004252:	6a42                	ld	s4,16(sp)
    80004254:	6121                	addi	sp,sp,64
    80004256:	8082                	ret
    iput(ip);
    80004258:	00000097          	auipc	ra,0x0
    8000425c:	a30080e7          	jalr	-1488(ra) # 80003c88 <iput>
    return -1;
    80004260:	557d                	li	a0,-1
    80004262:	b7dd                	j	80004248 <dirlink+0x86>
      panic("dirlink read");
    80004264:	00004517          	auipc	a0,0x4
    80004268:	39450513          	addi	a0,a0,916 # 800085f8 <syscalls+0x1d8>
    8000426c:	ffffc097          	auipc	ra,0xffffc
    80004270:	2be080e7          	jalr	702(ra) # 8000052a <panic>
    panic("dirlink");
    80004274:	00004517          	auipc	a0,0x4
    80004278:	49450513          	addi	a0,a0,1172 # 80008708 <syscalls+0x2e8>
    8000427c:	ffffc097          	auipc	ra,0xffffc
    80004280:	2ae080e7          	jalr	686(ra) # 8000052a <panic>

0000000080004284 <namei>:

struct inode*
namei(char *path)
{
    80004284:	1101                	addi	sp,sp,-32
    80004286:	ec06                	sd	ra,24(sp)
    80004288:	e822                	sd	s0,16(sp)
    8000428a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000428c:	fe040613          	addi	a2,s0,-32
    80004290:	4581                	li	a1,0
    80004292:	00000097          	auipc	ra,0x0
    80004296:	dd0080e7          	jalr	-560(ra) # 80004062 <namex>
}
    8000429a:	60e2                	ld	ra,24(sp)
    8000429c:	6442                	ld	s0,16(sp)
    8000429e:	6105                	addi	sp,sp,32
    800042a0:	8082                	ret

00000000800042a2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800042a2:	1141                	addi	sp,sp,-16
    800042a4:	e406                	sd	ra,8(sp)
    800042a6:	e022                	sd	s0,0(sp)
    800042a8:	0800                	addi	s0,sp,16
    800042aa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800042ac:	4585                	li	a1,1
    800042ae:	00000097          	auipc	ra,0x0
    800042b2:	db4080e7          	jalr	-588(ra) # 80004062 <namex>
}
    800042b6:	60a2                	ld	ra,8(sp)
    800042b8:	6402                	ld	s0,0(sp)
    800042ba:	0141                	addi	sp,sp,16
    800042bc:	8082                	ret

00000000800042be <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042be:	1101                	addi	sp,sp,-32
    800042c0:	ec06                	sd	ra,24(sp)
    800042c2:	e822                	sd	s0,16(sp)
    800042c4:	e426                	sd	s1,8(sp)
    800042c6:	e04a                	sd	s2,0(sp)
    800042c8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042ca:	0002b917          	auipc	s2,0x2b
    800042ce:	f8e90913          	addi	s2,s2,-114 # 8002f258 <log>
    800042d2:	01892583          	lw	a1,24(s2)
    800042d6:	02892503          	lw	a0,40(s2)
    800042da:	fffff097          	auipc	ra,0xfffff
    800042de:	ff2080e7          	jalr	-14(ra) # 800032cc <bread>
    800042e2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800042e4:	02c92683          	lw	a3,44(s2)
    800042e8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800042ea:	02d05763          	blez	a3,80004318 <write_head+0x5a>
    800042ee:	0002b797          	auipc	a5,0x2b
    800042f2:	f9a78793          	addi	a5,a5,-102 # 8002f288 <log+0x30>
    800042f6:	05c50713          	addi	a4,a0,92
    800042fa:	36fd                	addiw	a3,a3,-1
    800042fc:	1682                	slli	a3,a3,0x20
    800042fe:	9281                	srli	a3,a3,0x20
    80004300:	068a                	slli	a3,a3,0x2
    80004302:	0002b617          	auipc	a2,0x2b
    80004306:	f8a60613          	addi	a2,a2,-118 # 8002f28c <log+0x34>
    8000430a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000430c:	4390                	lw	a2,0(a5)
    8000430e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004310:	0791                	addi	a5,a5,4
    80004312:	0711                	addi	a4,a4,4
    80004314:	fed79ce3          	bne	a5,a3,8000430c <write_head+0x4e>
  }
  bwrite(buf);
    80004318:	8526                	mv	a0,s1
    8000431a:	fffff097          	auipc	ra,0xfffff
    8000431e:	0a4080e7          	jalr	164(ra) # 800033be <bwrite>
  brelse(buf);
    80004322:	8526                	mv	a0,s1
    80004324:	fffff097          	auipc	ra,0xfffff
    80004328:	0d8080e7          	jalr	216(ra) # 800033fc <brelse>
}
    8000432c:	60e2                	ld	ra,24(sp)
    8000432e:	6442                	ld	s0,16(sp)
    80004330:	64a2                	ld	s1,8(sp)
    80004332:	6902                	ld	s2,0(sp)
    80004334:	6105                	addi	sp,sp,32
    80004336:	8082                	ret

0000000080004338 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004338:	0002b797          	auipc	a5,0x2b
    8000433c:	f4c7a783          	lw	a5,-180(a5) # 8002f284 <log+0x2c>
    80004340:	0af05d63          	blez	a5,800043fa <install_trans+0xc2>
{
    80004344:	7139                	addi	sp,sp,-64
    80004346:	fc06                	sd	ra,56(sp)
    80004348:	f822                	sd	s0,48(sp)
    8000434a:	f426                	sd	s1,40(sp)
    8000434c:	f04a                	sd	s2,32(sp)
    8000434e:	ec4e                	sd	s3,24(sp)
    80004350:	e852                	sd	s4,16(sp)
    80004352:	e456                	sd	s5,8(sp)
    80004354:	e05a                	sd	s6,0(sp)
    80004356:	0080                	addi	s0,sp,64
    80004358:	8b2a                	mv	s6,a0
    8000435a:	0002ba97          	auipc	s5,0x2b
    8000435e:	f2ea8a93          	addi	s5,s5,-210 # 8002f288 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004362:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004364:	0002b997          	auipc	s3,0x2b
    80004368:	ef498993          	addi	s3,s3,-268 # 8002f258 <log>
    8000436c:	a00d                	j	8000438e <install_trans+0x56>
    brelse(lbuf);
    8000436e:	854a                	mv	a0,s2
    80004370:	fffff097          	auipc	ra,0xfffff
    80004374:	08c080e7          	jalr	140(ra) # 800033fc <brelse>
    brelse(dbuf);
    80004378:	8526                	mv	a0,s1
    8000437a:	fffff097          	auipc	ra,0xfffff
    8000437e:	082080e7          	jalr	130(ra) # 800033fc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004382:	2a05                	addiw	s4,s4,1
    80004384:	0a91                	addi	s5,s5,4
    80004386:	02c9a783          	lw	a5,44(s3)
    8000438a:	04fa5e63          	bge	s4,a5,800043e6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000438e:	0189a583          	lw	a1,24(s3)
    80004392:	014585bb          	addw	a1,a1,s4
    80004396:	2585                	addiw	a1,a1,1
    80004398:	0289a503          	lw	a0,40(s3)
    8000439c:	fffff097          	auipc	ra,0xfffff
    800043a0:	f30080e7          	jalr	-208(ra) # 800032cc <bread>
    800043a4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800043a6:	000aa583          	lw	a1,0(s5)
    800043aa:	0289a503          	lw	a0,40(s3)
    800043ae:	fffff097          	auipc	ra,0xfffff
    800043b2:	f1e080e7          	jalr	-226(ra) # 800032cc <bread>
    800043b6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800043b8:	40000613          	li	a2,1024
    800043bc:	05890593          	addi	a1,s2,88
    800043c0:	05850513          	addi	a0,a0,88
    800043c4:	ffffd097          	auipc	ra,0xffffd
    800043c8:	956080e7          	jalr	-1706(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    800043cc:	8526                	mv	a0,s1
    800043ce:	fffff097          	auipc	ra,0xfffff
    800043d2:	ff0080e7          	jalr	-16(ra) # 800033be <bwrite>
    if(recovering == 0)
    800043d6:	f80b1ce3          	bnez	s6,8000436e <install_trans+0x36>
      bunpin(dbuf);
    800043da:	8526                	mv	a0,s1
    800043dc:	fffff097          	auipc	ra,0xfffff
    800043e0:	0fa080e7          	jalr	250(ra) # 800034d6 <bunpin>
    800043e4:	b769                	j	8000436e <install_trans+0x36>
}
    800043e6:	70e2                	ld	ra,56(sp)
    800043e8:	7442                	ld	s0,48(sp)
    800043ea:	74a2                	ld	s1,40(sp)
    800043ec:	7902                	ld	s2,32(sp)
    800043ee:	69e2                	ld	s3,24(sp)
    800043f0:	6a42                	ld	s4,16(sp)
    800043f2:	6aa2                	ld	s5,8(sp)
    800043f4:	6b02                	ld	s6,0(sp)
    800043f6:	6121                	addi	sp,sp,64
    800043f8:	8082                	ret
    800043fa:	8082                	ret

00000000800043fc <initlog>:
{
    800043fc:	7179                	addi	sp,sp,-48
    800043fe:	f406                	sd	ra,40(sp)
    80004400:	f022                	sd	s0,32(sp)
    80004402:	ec26                	sd	s1,24(sp)
    80004404:	e84a                	sd	s2,16(sp)
    80004406:	e44e                	sd	s3,8(sp)
    80004408:	1800                	addi	s0,sp,48
    8000440a:	892a                	mv	s2,a0
    8000440c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000440e:	0002b497          	auipc	s1,0x2b
    80004412:	e4a48493          	addi	s1,s1,-438 # 8002f258 <log>
    80004416:	00004597          	auipc	a1,0x4
    8000441a:	1f258593          	addi	a1,a1,498 # 80008608 <syscalls+0x1e8>
    8000441e:	8526                	mv	a0,s1
    80004420:	ffffc097          	auipc	ra,0xffffc
    80004424:	712080e7          	jalr	1810(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004428:	0149a583          	lw	a1,20(s3)
    8000442c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000442e:	0109a783          	lw	a5,16(s3)
    80004432:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004434:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004438:	854a                	mv	a0,s2
    8000443a:	fffff097          	auipc	ra,0xfffff
    8000443e:	e92080e7          	jalr	-366(ra) # 800032cc <bread>
  log.lh.n = lh->n;
    80004442:	4d34                	lw	a3,88(a0)
    80004444:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004446:	02d05563          	blez	a3,80004470 <initlog+0x74>
    8000444a:	05c50793          	addi	a5,a0,92
    8000444e:	0002b717          	auipc	a4,0x2b
    80004452:	e3a70713          	addi	a4,a4,-454 # 8002f288 <log+0x30>
    80004456:	36fd                	addiw	a3,a3,-1
    80004458:	1682                	slli	a3,a3,0x20
    8000445a:	9281                	srli	a3,a3,0x20
    8000445c:	068a                	slli	a3,a3,0x2
    8000445e:	06050613          	addi	a2,a0,96
    80004462:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004464:	4390                	lw	a2,0(a5)
    80004466:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004468:	0791                	addi	a5,a5,4
    8000446a:	0711                	addi	a4,a4,4
    8000446c:	fed79ce3          	bne	a5,a3,80004464 <initlog+0x68>
  brelse(buf);
    80004470:	fffff097          	auipc	ra,0xfffff
    80004474:	f8c080e7          	jalr	-116(ra) # 800033fc <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004478:	4505                	li	a0,1
    8000447a:	00000097          	auipc	ra,0x0
    8000447e:	ebe080e7          	jalr	-322(ra) # 80004338 <install_trans>
  log.lh.n = 0;
    80004482:	0002b797          	auipc	a5,0x2b
    80004486:	e007a123          	sw	zero,-510(a5) # 8002f284 <log+0x2c>
  write_head(); // clear the log
    8000448a:	00000097          	auipc	ra,0x0
    8000448e:	e34080e7          	jalr	-460(ra) # 800042be <write_head>
}
    80004492:	70a2                	ld	ra,40(sp)
    80004494:	7402                	ld	s0,32(sp)
    80004496:	64e2                	ld	s1,24(sp)
    80004498:	6942                	ld	s2,16(sp)
    8000449a:	69a2                	ld	s3,8(sp)
    8000449c:	6145                	addi	sp,sp,48
    8000449e:	8082                	ret

00000000800044a0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800044a0:	1101                	addi	sp,sp,-32
    800044a2:	ec06                	sd	ra,24(sp)
    800044a4:	e822                	sd	s0,16(sp)
    800044a6:	e426                	sd	s1,8(sp)
    800044a8:	e04a                	sd	s2,0(sp)
    800044aa:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800044ac:	0002b517          	auipc	a0,0x2b
    800044b0:	dac50513          	addi	a0,a0,-596 # 8002f258 <log>
    800044b4:	ffffc097          	auipc	ra,0xffffc
    800044b8:	70e080e7          	jalr	1806(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    800044bc:	0002b497          	auipc	s1,0x2b
    800044c0:	d9c48493          	addi	s1,s1,-612 # 8002f258 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044c4:	4979                	li	s2,30
    800044c6:	a039                	j	800044d4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800044c8:	85a6                	mv	a1,s1
    800044ca:	8526                	mv	a0,s1
    800044cc:	ffffe097          	auipc	ra,0xffffe
    800044d0:	192080e7          	jalr	402(ra) # 8000265e <sleep>
    if(log.committing){
    800044d4:	50dc                	lw	a5,36(s1)
    800044d6:	fbed                	bnez	a5,800044c8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044d8:	509c                	lw	a5,32(s1)
    800044da:	0017871b          	addiw	a4,a5,1
    800044de:	0007069b          	sext.w	a3,a4
    800044e2:	0027179b          	slliw	a5,a4,0x2
    800044e6:	9fb9                	addw	a5,a5,a4
    800044e8:	0017979b          	slliw	a5,a5,0x1
    800044ec:	54d8                	lw	a4,44(s1)
    800044ee:	9fb9                	addw	a5,a5,a4
    800044f0:	00f95963          	bge	s2,a5,80004502 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800044f4:	85a6                	mv	a1,s1
    800044f6:	8526                	mv	a0,s1
    800044f8:	ffffe097          	auipc	ra,0xffffe
    800044fc:	166080e7          	jalr	358(ra) # 8000265e <sleep>
    80004500:	bfd1                	j	800044d4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004502:	0002b517          	auipc	a0,0x2b
    80004506:	d5650513          	addi	a0,a0,-682 # 8002f258 <log>
    8000450a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000450c:	ffffc097          	auipc	ra,0xffffc
    80004510:	76a080e7          	jalr	1898(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004514:	60e2                	ld	ra,24(sp)
    80004516:	6442                	ld	s0,16(sp)
    80004518:	64a2                	ld	s1,8(sp)
    8000451a:	6902                	ld	s2,0(sp)
    8000451c:	6105                	addi	sp,sp,32
    8000451e:	8082                	ret

0000000080004520 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004520:	7139                	addi	sp,sp,-64
    80004522:	fc06                	sd	ra,56(sp)
    80004524:	f822                	sd	s0,48(sp)
    80004526:	f426                	sd	s1,40(sp)
    80004528:	f04a                	sd	s2,32(sp)
    8000452a:	ec4e                	sd	s3,24(sp)
    8000452c:	e852                	sd	s4,16(sp)
    8000452e:	e456                	sd	s5,8(sp)
    80004530:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004532:	0002b497          	auipc	s1,0x2b
    80004536:	d2648493          	addi	s1,s1,-730 # 8002f258 <log>
    8000453a:	8526                	mv	a0,s1
    8000453c:	ffffc097          	auipc	ra,0xffffc
    80004540:	686080e7          	jalr	1670(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004544:	509c                	lw	a5,32(s1)
    80004546:	37fd                	addiw	a5,a5,-1
    80004548:	0007891b          	sext.w	s2,a5
    8000454c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000454e:	50dc                	lw	a5,36(s1)
    80004550:	e7b9                	bnez	a5,8000459e <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004552:	04091e63          	bnez	s2,800045ae <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004556:	0002b497          	auipc	s1,0x2b
    8000455a:	d0248493          	addi	s1,s1,-766 # 8002f258 <log>
    8000455e:	4785                	li	a5,1
    80004560:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004562:	8526                	mv	a0,s1
    80004564:	ffffc097          	auipc	ra,0xffffc
    80004568:	712080e7          	jalr	1810(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000456c:	54dc                	lw	a5,44(s1)
    8000456e:	06f04763          	bgtz	a5,800045dc <end_op+0xbc>
    acquire(&log.lock);
    80004572:	0002b497          	auipc	s1,0x2b
    80004576:	ce648493          	addi	s1,s1,-794 # 8002f258 <log>
    8000457a:	8526                	mv	a0,s1
    8000457c:	ffffc097          	auipc	ra,0xffffc
    80004580:	646080e7          	jalr	1606(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004584:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004588:	8526                	mv	a0,s1
    8000458a:	ffffe097          	auipc	ra,0xffffe
    8000458e:	254080e7          	jalr	596(ra) # 800027de <wakeup>
    release(&log.lock);
    80004592:	8526                	mv	a0,s1
    80004594:	ffffc097          	auipc	ra,0xffffc
    80004598:	6e2080e7          	jalr	1762(ra) # 80000c76 <release>
}
    8000459c:	a03d                	j	800045ca <end_op+0xaa>
    panic("log.committing");
    8000459e:	00004517          	auipc	a0,0x4
    800045a2:	07250513          	addi	a0,a0,114 # 80008610 <syscalls+0x1f0>
    800045a6:	ffffc097          	auipc	ra,0xffffc
    800045aa:	f84080e7          	jalr	-124(ra) # 8000052a <panic>
    wakeup(&log);
    800045ae:	0002b497          	auipc	s1,0x2b
    800045b2:	caa48493          	addi	s1,s1,-854 # 8002f258 <log>
    800045b6:	8526                	mv	a0,s1
    800045b8:	ffffe097          	auipc	ra,0xffffe
    800045bc:	226080e7          	jalr	550(ra) # 800027de <wakeup>
  release(&log.lock);
    800045c0:	8526                	mv	a0,s1
    800045c2:	ffffc097          	auipc	ra,0xffffc
    800045c6:	6b4080e7          	jalr	1716(ra) # 80000c76 <release>
}
    800045ca:	70e2                	ld	ra,56(sp)
    800045cc:	7442                	ld	s0,48(sp)
    800045ce:	74a2                	ld	s1,40(sp)
    800045d0:	7902                	ld	s2,32(sp)
    800045d2:	69e2                	ld	s3,24(sp)
    800045d4:	6a42                	ld	s4,16(sp)
    800045d6:	6aa2                	ld	s5,8(sp)
    800045d8:	6121                	addi	sp,sp,64
    800045da:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800045dc:	0002ba97          	auipc	s5,0x2b
    800045e0:	caca8a93          	addi	s5,s5,-852 # 8002f288 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800045e4:	0002ba17          	auipc	s4,0x2b
    800045e8:	c74a0a13          	addi	s4,s4,-908 # 8002f258 <log>
    800045ec:	018a2583          	lw	a1,24(s4)
    800045f0:	012585bb          	addw	a1,a1,s2
    800045f4:	2585                	addiw	a1,a1,1
    800045f6:	028a2503          	lw	a0,40(s4)
    800045fa:	fffff097          	auipc	ra,0xfffff
    800045fe:	cd2080e7          	jalr	-814(ra) # 800032cc <bread>
    80004602:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004604:	000aa583          	lw	a1,0(s5)
    80004608:	028a2503          	lw	a0,40(s4)
    8000460c:	fffff097          	auipc	ra,0xfffff
    80004610:	cc0080e7          	jalr	-832(ra) # 800032cc <bread>
    80004614:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004616:	40000613          	li	a2,1024
    8000461a:	05850593          	addi	a1,a0,88
    8000461e:	05848513          	addi	a0,s1,88
    80004622:	ffffc097          	auipc	ra,0xffffc
    80004626:	6f8080e7          	jalr	1784(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    8000462a:	8526                	mv	a0,s1
    8000462c:	fffff097          	auipc	ra,0xfffff
    80004630:	d92080e7          	jalr	-622(ra) # 800033be <bwrite>
    brelse(from);
    80004634:	854e                	mv	a0,s3
    80004636:	fffff097          	auipc	ra,0xfffff
    8000463a:	dc6080e7          	jalr	-570(ra) # 800033fc <brelse>
    brelse(to);
    8000463e:	8526                	mv	a0,s1
    80004640:	fffff097          	auipc	ra,0xfffff
    80004644:	dbc080e7          	jalr	-580(ra) # 800033fc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004648:	2905                	addiw	s2,s2,1
    8000464a:	0a91                	addi	s5,s5,4
    8000464c:	02ca2783          	lw	a5,44(s4)
    80004650:	f8f94ee3          	blt	s2,a5,800045ec <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004654:	00000097          	auipc	ra,0x0
    80004658:	c6a080e7          	jalr	-918(ra) # 800042be <write_head>
    install_trans(0); // Now install writes to home locations
    8000465c:	4501                	li	a0,0
    8000465e:	00000097          	auipc	ra,0x0
    80004662:	cda080e7          	jalr	-806(ra) # 80004338 <install_trans>
    log.lh.n = 0;
    80004666:	0002b797          	auipc	a5,0x2b
    8000466a:	c007af23          	sw	zero,-994(a5) # 8002f284 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000466e:	00000097          	auipc	ra,0x0
    80004672:	c50080e7          	jalr	-944(ra) # 800042be <write_head>
    80004676:	bdf5                	j	80004572 <end_op+0x52>

0000000080004678 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004678:	1101                	addi	sp,sp,-32
    8000467a:	ec06                	sd	ra,24(sp)
    8000467c:	e822                	sd	s0,16(sp)
    8000467e:	e426                	sd	s1,8(sp)
    80004680:	e04a                	sd	s2,0(sp)
    80004682:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004684:	0002b717          	auipc	a4,0x2b
    80004688:	c0072703          	lw	a4,-1024(a4) # 8002f284 <log+0x2c>
    8000468c:	47f5                	li	a5,29
    8000468e:	08e7c063          	blt	a5,a4,8000470e <log_write+0x96>
    80004692:	84aa                	mv	s1,a0
    80004694:	0002b797          	auipc	a5,0x2b
    80004698:	be07a783          	lw	a5,-1056(a5) # 8002f274 <log+0x1c>
    8000469c:	37fd                	addiw	a5,a5,-1
    8000469e:	06f75863          	bge	a4,a5,8000470e <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046a2:	0002b797          	auipc	a5,0x2b
    800046a6:	bd67a783          	lw	a5,-1066(a5) # 8002f278 <log+0x20>
    800046aa:	06f05a63          	blez	a5,8000471e <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800046ae:	0002b917          	auipc	s2,0x2b
    800046b2:	baa90913          	addi	s2,s2,-1110 # 8002f258 <log>
    800046b6:	854a                	mv	a0,s2
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	50a080e7          	jalr	1290(ra) # 80000bc2 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800046c0:	02c92603          	lw	a2,44(s2)
    800046c4:	06c05563          	blez	a2,8000472e <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046c8:	44cc                	lw	a1,12(s1)
    800046ca:	0002b717          	auipc	a4,0x2b
    800046ce:	bbe70713          	addi	a4,a4,-1090 # 8002f288 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800046d2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046d4:	4314                	lw	a3,0(a4)
    800046d6:	04b68d63          	beq	a3,a1,80004730 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800046da:	2785                	addiw	a5,a5,1
    800046dc:	0711                	addi	a4,a4,4
    800046de:	fec79be3          	bne	a5,a2,800046d4 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046e2:	0621                	addi	a2,a2,8
    800046e4:	060a                	slli	a2,a2,0x2
    800046e6:	0002b797          	auipc	a5,0x2b
    800046ea:	b7278793          	addi	a5,a5,-1166 # 8002f258 <log>
    800046ee:	963e                	add	a2,a2,a5
    800046f0:	44dc                	lw	a5,12(s1)
    800046f2:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800046f4:	8526                	mv	a0,s1
    800046f6:	fffff097          	auipc	ra,0xfffff
    800046fa:	da4080e7          	jalr	-604(ra) # 8000349a <bpin>
    log.lh.n++;
    800046fe:	0002b717          	auipc	a4,0x2b
    80004702:	b5a70713          	addi	a4,a4,-1190 # 8002f258 <log>
    80004706:	575c                	lw	a5,44(a4)
    80004708:	2785                	addiw	a5,a5,1
    8000470a:	d75c                	sw	a5,44(a4)
    8000470c:	a83d                	j	8000474a <log_write+0xd2>
    panic("too big a transaction");
    8000470e:	00004517          	auipc	a0,0x4
    80004712:	f1250513          	addi	a0,a0,-238 # 80008620 <syscalls+0x200>
    80004716:	ffffc097          	auipc	ra,0xffffc
    8000471a:	e14080e7          	jalr	-492(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    8000471e:	00004517          	auipc	a0,0x4
    80004722:	f1a50513          	addi	a0,a0,-230 # 80008638 <syscalls+0x218>
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	e04080e7          	jalr	-508(ra) # 8000052a <panic>
  for (i = 0; i < log.lh.n; i++) {
    8000472e:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004730:	00878713          	addi	a4,a5,8
    80004734:	00271693          	slli	a3,a4,0x2
    80004738:	0002b717          	auipc	a4,0x2b
    8000473c:	b2070713          	addi	a4,a4,-1248 # 8002f258 <log>
    80004740:	9736                	add	a4,a4,a3
    80004742:	44d4                	lw	a3,12(s1)
    80004744:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004746:	faf607e3          	beq	a2,a5,800046f4 <log_write+0x7c>
  }
  release(&log.lock);
    8000474a:	0002b517          	auipc	a0,0x2b
    8000474e:	b0e50513          	addi	a0,a0,-1266 # 8002f258 <log>
    80004752:	ffffc097          	auipc	ra,0xffffc
    80004756:	524080e7          	jalr	1316(ra) # 80000c76 <release>
}
    8000475a:	60e2                	ld	ra,24(sp)
    8000475c:	6442                	ld	s0,16(sp)
    8000475e:	64a2                	ld	s1,8(sp)
    80004760:	6902                	ld	s2,0(sp)
    80004762:	6105                	addi	sp,sp,32
    80004764:	8082                	ret

0000000080004766 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004766:	1101                	addi	sp,sp,-32
    80004768:	ec06                	sd	ra,24(sp)
    8000476a:	e822                	sd	s0,16(sp)
    8000476c:	e426                	sd	s1,8(sp)
    8000476e:	e04a                	sd	s2,0(sp)
    80004770:	1000                	addi	s0,sp,32
    80004772:	84aa                	mv	s1,a0
    80004774:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004776:	00004597          	auipc	a1,0x4
    8000477a:	ee258593          	addi	a1,a1,-286 # 80008658 <syscalls+0x238>
    8000477e:	0521                	addi	a0,a0,8
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	3b2080e7          	jalr	946(ra) # 80000b32 <initlock>
  lk->name = name;
    80004788:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000478c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004790:	0204a423          	sw	zero,40(s1)
}
    80004794:	60e2                	ld	ra,24(sp)
    80004796:	6442                	ld	s0,16(sp)
    80004798:	64a2                	ld	s1,8(sp)
    8000479a:	6902                	ld	s2,0(sp)
    8000479c:	6105                	addi	sp,sp,32
    8000479e:	8082                	ret

00000000800047a0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800047a0:	1101                	addi	sp,sp,-32
    800047a2:	ec06                	sd	ra,24(sp)
    800047a4:	e822                	sd	s0,16(sp)
    800047a6:	e426                	sd	s1,8(sp)
    800047a8:	e04a                	sd	s2,0(sp)
    800047aa:	1000                	addi	s0,sp,32
    800047ac:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047ae:	00850913          	addi	s2,a0,8
    800047b2:	854a                	mv	a0,s2
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	40e080e7          	jalr	1038(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    800047bc:	409c                	lw	a5,0(s1)
    800047be:	cb89                	beqz	a5,800047d0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800047c0:	85ca                	mv	a1,s2
    800047c2:	8526                	mv	a0,s1
    800047c4:	ffffe097          	auipc	ra,0xffffe
    800047c8:	e9a080e7          	jalr	-358(ra) # 8000265e <sleep>
  while (lk->locked) {
    800047cc:	409c                	lw	a5,0(s1)
    800047ce:	fbed                	bnez	a5,800047c0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047d0:	4785                	li	a5,1
    800047d2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047d4:	ffffd097          	auipc	ra,0xffffd
    800047d8:	5d2080e7          	jalr	1490(ra) # 80001da6 <myproc>
    800047dc:	5d1c                	lw	a5,56(a0)
    800047de:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800047e0:	854a                	mv	a0,s2
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	494080e7          	jalr	1172(ra) # 80000c76 <release>
}
    800047ea:	60e2                	ld	ra,24(sp)
    800047ec:	6442                	ld	s0,16(sp)
    800047ee:	64a2                	ld	s1,8(sp)
    800047f0:	6902                	ld	s2,0(sp)
    800047f2:	6105                	addi	sp,sp,32
    800047f4:	8082                	ret

00000000800047f6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800047f6:	1101                	addi	sp,sp,-32
    800047f8:	ec06                	sd	ra,24(sp)
    800047fa:	e822                	sd	s0,16(sp)
    800047fc:	e426                	sd	s1,8(sp)
    800047fe:	e04a                	sd	s2,0(sp)
    80004800:	1000                	addi	s0,sp,32
    80004802:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004804:	00850913          	addi	s2,a0,8
    80004808:	854a                	mv	a0,s2
    8000480a:	ffffc097          	auipc	ra,0xffffc
    8000480e:	3b8080e7          	jalr	952(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80004812:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004816:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000481a:	8526                	mv	a0,s1
    8000481c:	ffffe097          	auipc	ra,0xffffe
    80004820:	fc2080e7          	jalr	-62(ra) # 800027de <wakeup>
  release(&lk->lk);
    80004824:	854a                	mv	a0,s2
    80004826:	ffffc097          	auipc	ra,0xffffc
    8000482a:	450080e7          	jalr	1104(ra) # 80000c76 <release>
}
    8000482e:	60e2                	ld	ra,24(sp)
    80004830:	6442                	ld	s0,16(sp)
    80004832:	64a2                	ld	s1,8(sp)
    80004834:	6902                	ld	s2,0(sp)
    80004836:	6105                	addi	sp,sp,32
    80004838:	8082                	ret

000000008000483a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000483a:	7179                	addi	sp,sp,-48
    8000483c:	f406                	sd	ra,40(sp)
    8000483e:	f022                	sd	s0,32(sp)
    80004840:	ec26                	sd	s1,24(sp)
    80004842:	e84a                	sd	s2,16(sp)
    80004844:	e44e                	sd	s3,8(sp)
    80004846:	1800                	addi	s0,sp,48
    80004848:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000484a:	00850913          	addi	s2,a0,8
    8000484e:	854a                	mv	a0,s2
    80004850:	ffffc097          	auipc	ra,0xffffc
    80004854:	372080e7          	jalr	882(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004858:	409c                	lw	a5,0(s1)
    8000485a:	ef99                	bnez	a5,80004878 <holdingsleep+0x3e>
    8000485c:	4481                	li	s1,0
  release(&lk->lk);
    8000485e:	854a                	mv	a0,s2
    80004860:	ffffc097          	auipc	ra,0xffffc
    80004864:	416080e7          	jalr	1046(ra) # 80000c76 <release>
  return r;
}
    80004868:	8526                	mv	a0,s1
    8000486a:	70a2                	ld	ra,40(sp)
    8000486c:	7402                	ld	s0,32(sp)
    8000486e:	64e2                	ld	s1,24(sp)
    80004870:	6942                	ld	s2,16(sp)
    80004872:	69a2                	ld	s3,8(sp)
    80004874:	6145                	addi	sp,sp,48
    80004876:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004878:	0284a983          	lw	s3,40(s1)
    8000487c:	ffffd097          	auipc	ra,0xffffd
    80004880:	52a080e7          	jalr	1322(ra) # 80001da6 <myproc>
    80004884:	5d04                	lw	s1,56(a0)
    80004886:	413484b3          	sub	s1,s1,s3
    8000488a:	0014b493          	seqz	s1,s1
    8000488e:	bfc1                	j	8000485e <holdingsleep+0x24>

0000000080004890 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004890:	1141                	addi	sp,sp,-16
    80004892:	e406                	sd	ra,8(sp)
    80004894:	e022                	sd	s0,0(sp)
    80004896:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004898:	00004597          	auipc	a1,0x4
    8000489c:	dd058593          	addi	a1,a1,-560 # 80008668 <syscalls+0x248>
    800048a0:	0002b517          	auipc	a0,0x2b
    800048a4:	b0050513          	addi	a0,a0,-1280 # 8002f3a0 <ftable>
    800048a8:	ffffc097          	auipc	ra,0xffffc
    800048ac:	28a080e7          	jalr	650(ra) # 80000b32 <initlock>
}
    800048b0:	60a2                	ld	ra,8(sp)
    800048b2:	6402                	ld	s0,0(sp)
    800048b4:	0141                	addi	sp,sp,16
    800048b6:	8082                	ret

00000000800048b8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800048b8:	1101                	addi	sp,sp,-32
    800048ba:	ec06                	sd	ra,24(sp)
    800048bc:	e822                	sd	s0,16(sp)
    800048be:	e426                	sd	s1,8(sp)
    800048c0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048c2:	0002b517          	auipc	a0,0x2b
    800048c6:	ade50513          	addi	a0,a0,-1314 # 8002f3a0 <ftable>
    800048ca:	ffffc097          	auipc	ra,0xffffc
    800048ce:	2f8080e7          	jalr	760(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048d2:	0002b497          	auipc	s1,0x2b
    800048d6:	ae648493          	addi	s1,s1,-1306 # 8002f3b8 <ftable+0x18>
    800048da:	0002c717          	auipc	a4,0x2c
    800048de:	a7e70713          	addi	a4,a4,-1410 # 80030358 <ftable+0xfb8>
    if(f->ref == 0){
    800048e2:	40dc                	lw	a5,4(s1)
    800048e4:	cf99                	beqz	a5,80004902 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048e6:	02848493          	addi	s1,s1,40
    800048ea:	fee49ce3          	bne	s1,a4,800048e2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800048ee:	0002b517          	auipc	a0,0x2b
    800048f2:	ab250513          	addi	a0,a0,-1358 # 8002f3a0 <ftable>
    800048f6:	ffffc097          	auipc	ra,0xffffc
    800048fa:	380080e7          	jalr	896(ra) # 80000c76 <release>
  return 0;
    800048fe:	4481                	li	s1,0
    80004900:	a819                	j	80004916 <filealloc+0x5e>
      f->ref = 1;
    80004902:	4785                	li	a5,1
    80004904:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004906:	0002b517          	auipc	a0,0x2b
    8000490a:	a9a50513          	addi	a0,a0,-1382 # 8002f3a0 <ftable>
    8000490e:	ffffc097          	auipc	ra,0xffffc
    80004912:	368080e7          	jalr	872(ra) # 80000c76 <release>
}
    80004916:	8526                	mv	a0,s1
    80004918:	60e2                	ld	ra,24(sp)
    8000491a:	6442                	ld	s0,16(sp)
    8000491c:	64a2                	ld	s1,8(sp)
    8000491e:	6105                	addi	sp,sp,32
    80004920:	8082                	ret

0000000080004922 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004922:	1101                	addi	sp,sp,-32
    80004924:	ec06                	sd	ra,24(sp)
    80004926:	e822                	sd	s0,16(sp)
    80004928:	e426                	sd	s1,8(sp)
    8000492a:	1000                	addi	s0,sp,32
    8000492c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000492e:	0002b517          	auipc	a0,0x2b
    80004932:	a7250513          	addi	a0,a0,-1422 # 8002f3a0 <ftable>
    80004936:	ffffc097          	auipc	ra,0xffffc
    8000493a:	28c080e7          	jalr	652(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    8000493e:	40dc                	lw	a5,4(s1)
    80004940:	02f05263          	blez	a5,80004964 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004944:	2785                	addiw	a5,a5,1
    80004946:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004948:	0002b517          	auipc	a0,0x2b
    8000494c:	a5850513          	addi	a0,a0,-1448 # 8002f3a0 <ftable>
    80004950:	ffffc097          	auipc	ra,0xffffc
    80004954:	326080e7          	jalr	806(ra) # 80000c76 <release>
  return f;
}
    80004958:	8526                	mv	a0,s1
    8000495a:	60e2                	ld	ra,24(sp)
    8000495c:	6442                	ld	s0,16(sp)
    8000495e:	64a2                	ld	s1,8(sp)
    80004960:	6105                	addi	sp,sp,32
    80004962:	8082                	ret
    panic("filedup");
    80004964:	00004517          	auipc	a0,0x4
    80004968:	d0c50513          	addi	a0,a0,-756 # 80008670 <syscalls+0x250>
    8000496c:	ffffc097          	auipc	ra,0xffffc
    80004970:	bbe080e7          	jalr	-1090(ra) # 8000052a <panic>

0000000080004974 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004974:	7139                	addi	sp,sp,-64
    80004976:	fc06                	sd	ra,56(sp)
    80004978:	f822                	sd	s0,48(sp)
    8000497a:	f426                	sd	s1,40(sp)
    8000497c:	f04a                	sd	s2,32(sp)
    8000497e:	ec4e                	sd	s3,24(sp)
    80004980:	e852                	sd	s4,16(sp)
    80004982:	e456                	sd	s5,8(sp)
    80004984:	0080                	addi	s0,sp,64
    80004986:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004988:	0002b517          	auipc	a0,0x2b
    8000498c:	a1850513          	addi	a0,a0,-1512 # 8002f3a0 <ftable>
    80004990:	ffffc097          	auipc	ra,0xffffc
    80004994:	232080e7          	jalr	562(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004998:	40dc                	lw	a5,4(s1)
    8000499a:	06f05163          	blez	a5,800049fc <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000499e:	37fd                	addiw	a5,a5,-1
    800049a0:	0007871b          	sext.w	a4,a5
    800049a4:	c0dc                	sw	a5,4(s1)
    800049a6:	06e04363          	bgtz	a4,80004a0c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800049aa:	0004a903          	lw	s2,0(s1)
    800049ae:	0094ca83          	lbu	s5,9(s1)
    800049b2:	0104ba03          	ld	s4,16(s1)
    800049b6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049ba:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049be:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049c2:	0002b517          	auipc	a0,0x2b
    800049c6:	9de50513          	addi	a0,a0,-1570 # 8002f3a0 <ftable>
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	2ac080e7          	jalr	684(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    800049d2:	4785                	li	a5,1
    800049d4:	04f90d63          	beq	s2,a5,80004a2e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049d8:	3979                	addiw	s2,s2,-2
    800049da:	4785                	li	a5,1
    800049dc:	0527e063          	bltu	a5,s2,80004a1c <fileclose+0xa8>
    begin_op();
    800049e0:	00000097          	auipc	ra,0x0
    800049e4:	ac0080e7          	jalr	-1344(ra) # 800044a0 <begin_op>
    iput(ff.ip);
    800049e8:	854e                	mv	a0,s3
    800049ea:	fffff097          	auipc	ra,0xfffff
    800049ee:	29e080e7          	jalr	670(ra) # 80003c88 <iput>
    end_op();
    800049f2:	00000097          	auipc	ra,0x0
    800049f6:	b2e080e7          	jalr	-1234(ra) # 80004520 <end_op>
    800049fa:	a00d                	j	80004a1c <fileclose+0xa8>
    panic("fileclose");
    800049fc:	00004517          	auipc	a0,0x4
    80004a00:	c7c50513          	addi	a0,a0,-900 # 80008678 <syscalls+0x258>
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	b26080e7          	jalr	-1242(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004a0c:	0002b517          	auipc	a0,0x2b
    80004a10:	99450513          	addi	a0,a0,-1644 # 8002f3a0 <ftable>
    80004a14:	ffffc097          	auipc	ra,0xffffc
    80004a18:	262080e7          	jalr	610(ra) # 80000c76 <release>
  }
}
    80004a1c:	70e2                	ld	ra,56(sp)
    80004a1e:	7442                	ld	s0,48(sp)
    80004a20:	74a2                	ld	s1,40(sp)
    80004a22:	7902                	ld	s2,32(sp)
    80004a24:	69e2                	ld	s3,24(sp)
    80004a26:	6a42                	ld	s4,16(sp)
    80004a28:	6aa2                	ld	s5,8(sp)
    80004a2a:	6121                	addi	sp,sp,64
    80004a2c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a2e:	85d6                	mv	a1,s5
    80004a30:	8552                	mv	a0,s4
    80004a32:	00000097          	auipc	ra,0x0
    80004a36:	34c080e7          	jalr	844(ra) # 80004d7e <pipeclose>
    80004a3a:	b7cd                	j	80004a1c <fileclose+0xa8>

0000000080004a3c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a3c:	715d                	addi	sp,sp,-80
    80004a3e:	e486                	sd	ra,72(sp)
    80004a40:	e0a2                	sd	s0,64(sp)
    80004a42:	fc26                	sd	s1,56(sp)
    80004a44:	f84a                	sd	s2,48(sp)
    80004a46:	f44e                	sd	s3,40(sp)
    80004a48:	0880                	addi	s0,sp,80
    80004a4a:	84aa                	mv	s1,a0
    80004a4c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a4e:	ffffd097          	auipc	ra,0xffffd
    80004a52:	358080e7          	jalr	856(ra) # 80001da6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a56:	409c                	lw	a5,0(s1)
    80004a58:	37f9                	addiw	a5,a5,-2
    80004a5a:	4705                	li	a4,1
    80004a5c:	04f76763          	bltu	a4,a5,80004aaa <filestat+0x6e>
    80004a60:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a62:	6c88                	ld	a0,24(s1)
    80004a64:	fffff097          	auipc	ra,0xfffff
    80004a68:	06a080e7          	jalr	106(ra) # 80003ace <ilock>
    stati(f->ip, &st);
    80004a6c:	fb840593          	addi	a1,s0,-72
    80004a70:	6c88                	ld	a0,24(s1)
    80004a72:	fffff097          	auipc	ra,0xfffff
    80004a76:	2e6080e7          	jalr	742(ra) # 80003d58 <stati>
    iunlock(f->ip);
    80004a7a:	6c88                	ld	a0,24(s1)
    80004a7c:	fffff097          	auipc	ra,0xfffff
    80004a80:	114080e7          	jalr	276(ra) # 80003b90 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a84:	46e1                	li	a3,24
    80004a86:	fb840613          	addi	a2,s0,-72
    80004a8a:	85ce                	mv	a1,s3
    80004a8c:	05093503          	ld	a0,80(s2)
    80004a90:	ffffd097          	auipc	ra,0xffffd
    80004a94:	bd2080e7          	jalr	-1070(ra) # 80001662 <copyout>
    80004a98:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a9c:	60a6                	ld	ra,72(sp)
    80004a9e:	6406                	ld	s0,64(sp)
    80004aa0:	74e2                	ld	s1,56(sp)
    80004aa2:	7942                	ld	s2,48(sp)
    80004aa4:	79a2                	ld	s3,40(sp)
    80004aa6:	6161                	addi	sp,sp,80
    80004aa8:	8082                	ret
  return -1;
    80004aaa:	557d                	li	a0,-1
    80004aac:	bfc5                	j	80004a9c <filestat+0x60>

0000000080004aae <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004aae:	7179                	addi	sp,sp,-48
    80004ab0:	f406                	sd	ra,40(sp)
    80004ab2:	f022                	sd	s0,32(sp)
    80004ab4:	ec26                	sd	s1,24(sp)
    80004ab6:	e84a                	sd	s2,16(sp)
    80004ab8:	e44e                	sd	s3,8(sp)
    80004aba:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004abc:	00854783          	lbu	a5,8(a0)
    80004ac0:	c3d5                	beqz	a5,80004b64 <fileread+0xb6>
    80004ac2:	84aa                	mv	s1,a0
    80004ac4:	89ae                	mv	s3,a1
    80004ac6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ac8:	411c                	lw	a5,0(a0)
    80004aca:	4705                	li	a4,1
    80004acc:	04e78963          	beq	a5,a4,80004b1e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ad0:	470d                	li	a4,3
    80004ad2:	04e78d63          	beq	a5,a4,80004b2c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ad6:	4709                	li	a4,2
    80004ad8:	06e79e63          	bne	a5,a4,80004b54 <fileread+0xa6>
    ilock(f->ip);
    80004adc:	6d08                	ld	a0,24(a0)
    80004ade:	fffff097          	auipc	ra,0xfffff
    80004ae2:	ff0080e7          	jalr	-16(ra) # 80003ace <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ae6:	874a                	mv	a4,s2
    80004ae8:	5094                	lw	a3,32(s1)
    80004aea:	864e                	mv	a2,s3
    80004aec:	4585                	li	a1,1
    80004aee:	6c88                	ld	a0,24(s1)
    80004af0:	fffff097          	auipc	ra,0xfffff
    80004af4:	292080e7          	jalr	658(ra) # 80003d82 <readi>
    80004af8:	892a                	mv	s2,a0
    80004afa:	00a05563          	blez	a0,80004b04 <fileread+0x56>
      f->off += r;
    80004afe:	509c                	lw	a5,32(s1)
    80004b00:	9fa9                	addw	a5,a5,a0
    80004b02:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b04:	6c88                	ld	a0,24(s1)
    80004b06:	fffff097          	auipc	ra,0xfffff
    80004b0a:	08a080e7          	jalr	138(ra) # 80003b90 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b0e:	854a                	mv	a0,s2
    80004b10:	70a2                	ld	ra,40(sp)
    80004b12:	7402                	ld	s0,32(sp)
    80004b14:	64e2                	ld	s1,24(sp)
    80004b16:	6942                	ld	s2,16(sp)
    80004b18:	69a2                	ld	s3,8(sp)
    80004b1a:	6145                	addi	sp,sp,48
    80004b1c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b1e:	6908                	ld	a0,16(a0)
    80004b20:	00000097          	auipc	ra,0x0
    80004b24:	3c0080e7          	jalr	960(ra) # 80004ee0 <piperead>
    80004b28:	892a                	mv	s2,a0
    80004b2a:	b7d5                	j	80004b0e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b2c:	02451783          	lh	a5,36(a0)
    80004b30:	03079693          	slli	a3,a5,0x30
    80004b34:	92c1                	srli	a3,a3,0x30
    80004b36:	4725                	li	a4,9
    80004b38:	02d76863          	bltu	a4,a3,80004b68 <fileread+0xba>
    80004b3c:	0792                	slli	a5,a5,0x4
    80004b3e:	0002a717          	auipc	a4,0x2a
    80004b42:	7c270713          	addi	a4,a4,1986 # 8002f300 <devsw>
    80004b46:	97ba                	add	a5,a5,a4
    80004b48:	639c                	ld	a5,0(a5)
    80004b4a:	c38d                	beqz	a5,80004b6c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b4c:	4505                	li	a0,1
    80004b4e:	9782                	jalr	a5
    80004b50:	892a                	mv	s2,a0
    80004b52:	bf75                	j	80004b0e <fileread+0x60>
    panic("fileread");
    80004b54:	00004517          	auipc	a0,0x4
    80004b58:	b3450513          	addi	a0,a0,-1228 # 80008688 <syscalls+0x268>
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	9ce080e7          	jalr	-1586(ra) # 8000052a <panic>
    return -1;
    80004b64:	597d                	li	s2,-1
    80004b66:	b765                	j	80004b0e <fileread+0x60>
      return -1;
    80004b68:	597d                	li	s2,-1
    80004b6a:	b755                	j	80004b0e <fileread+0x60>
    80004b6c:	597d                	li	s2,-1
    80004b6e:	b745                	j	80004b0e <fileread+0x60>

0000000080004b70 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004b70:	715d                	addi	sp,sp,-80
    80004b72:	e486                	sd	ra,72(sp)
    80004b74:	e0a2                	sd	s0,64(sp)
    80004b76:	fc26                	sd	s1,56(sp)
    80004b78:	f84a                	sd	s2,48(sp)
    80004b7a:	f44e                	sd	s3,40(sp)
    80004b7c:	f052                	sd	s4,32(sp)
    80004b7e:	ec56                	sd	s5,24(sp)
    80004b80:	e85a                	sd	s6,16(sp)
    80004b82:	e45e                	sd	s7,8(sp)
    80004b84:	e062                	sd	s8,0(sp)
    80004b86:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004b88:	00954783          	lbu	a5,9(a0)
    80004b8c:	10078663          	beqz	a5,80004c98 <filewrite+0x128>
    80004b90:	892a                	mv	s2,a0
    80004b92:	8aae                	mv	s5,a1
    80004b94:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b96:	411c                	lw	a5,0(a0)
    80004b98:	4705                	li	a4,1
    80004b9a:	02e78263          	beq	a5,a4,80004bbe <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b9e:	470d                	li	a4,3
    80004ba0:	02e78663          	beq	a5,a4,80004bcc <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ba4:	4709                	li	a4,2
    80004ba6:	0ee79163          	bne	a5,a4,80004c88 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004baa:	0ac05d63          	blez	a2,80004c64 <filewrite+0xf4>
    int i = 0;
    80004bae:	4981                	li	s3,0
    80004bb0:	6b05                	lui	s6,0x1
    80004bb2:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004bb6:	6b85                	lui	s7,0x1
    80004bb8:	c00b8b9b          	addiw	s7,s7,-1024
    80004bbc:	a861                	j	80004c54 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004bbe:	6908                	ld	a0,16(a0)
    80004bc0:	00000097          	auipc	ra,0x0
    80004bc4:	22e080e7          	jalr	558(ra) # 80004dee <pipewrite>
    80004bc8:	8a2a                	mv	s4,a0
    80004bca:	a045                	j	80004c6a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004bcc:	02451783          	lh	a5,36(a0)
    80004bd0:	03079693          	slli	a3,a5,0x30
    80004bd4:	92c1                	srli	a3,a3,0x30
    80004bd6:	4725                	li	a4,9
    80004bd8:	0cd76263          	bltu	a4,a3,80004c9c <filewrite+0x12c>
    80004bdc:	0792                	slli	a5,a5,0x4
    80004bde:	0002a717          	auipc	a4,0x2a
    80004be2:	72270713          	addi	a4,a4,1826 # 8002f300 <devsw>
    80004be6:	97ba                	add	a5,a5,a4
    80004be8:	679c                	ld	a5,8(a5)
    80004bea:	cbdd                	beqz	a5,80004ca0 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004bec:	4505                	li	a0,1
    80004bee:	9782                	jalr	a5
    80004bf0:	8a2a                	mv	s4,a0
    80004bf2:	a8a5                	j	80004c6a <filewrite+0xfa>
    80004bf4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004bf8:	00000097          	auipc	ra,0x0
    80004bfc:	8a8080e7          	jalr	-1880(ra) # 800044a0 <begin_op>
      ilock(f->ip);
    80004c00:	01893503          	ld	a0,24(s2)
    80004c04:	fffff097          	auipc	ra,0xfffff
    80004c08:	eca080e7          	jalr	-310(ra) # 80003ace <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c0c:	8762                	mv	a4,s8
    80004c0e:	02092683          	lw	a3,32(s2)
    80004c12:	01598633          	add	a2,s3,s5
    80004c16:	4585                	li	a1,1
    80004c18:	01893503          	ld	a0,24(s2)
    80004c1c:	fffff097          	auipc	ra,0xfffff
    80004c20:	25e080e7          	jalr	606(ra) # 80003e7a <writei>
    80004c24:	84aa                	mv	s1,a0
    80004c26:	00a05763          	blez	a0,80004c34 <filewrite+0xc4>
        f->off += r;
    80004c2a:	02092783          	lw	a5,32(s2)
    80004c2e:	9fa9                	addw	a5,a5,a0
    80004c30:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c34:	01893503          	ld	a0,24(s2)
    80004c38:	fffff097          	auipc	ra,0xfffff
    80004c3c:	f58080e7          	jalr	-168(ra) # 80003b90 <iunlock>
      end_op();
    80004c40:	00000097          	auipc	ra,0x0
    80004c44:	8e0080e7          	jalr	-1824(ra) # 80004520 <end_op>

      if(r != n1){
    80004c48:	009c1f63          	bne	s8,s1,80004c66 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004c4c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c50:	0149db63          	bge	s3,s4,80004c66 <filewrite+0xf6>
      int n1 = n - i;
    80004c54:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004c58:	84be                	mv	s1,a5
    80004c5a:	2781                	sext.w	a5,a5
    80004c5c:	f8fb5ce3          	bge	s6,a5,80004bf4 <filewrite+0x84>
    80004c60:	84de                	mv	s1,s7
    80004c62:	bf49                	j	80004bf4 <filewrite+0x84>
    int i = 0;
    80004c64:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c66:	013a1f63          	bne	s4,s3,80004c84 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c6a:	8552                	mv	a0,s4
    80004c6c:	60a6                	ld	ra,72(sp)
    80004c6e:	6406                	ld	s0,64(sp)
    80004c70:	74e2                	ld	s1,56(sp)
    80004c72:	7942                	ld	s2,48(sp)
    80004c74:	79a2                	ld	s3,40(sp)
    80004c76:	7a02                	ld	s4,32(sp)
    80004c78:	6ae2                	ld	s5,24(sp)
    80004c7a:	6b42                	ld	s6,16(sp)
    80004c7c:	6ba2                	ld	s7,8(sp)
    80004c7e:	6c02                	ld	s8,0(sp)
    80004c80:	6161                	addi	sp,sp,80
    80004c82:	8082                	ret
    ret = (i == n ? n : -1);
    80004c84:	5a7d                	li	s4,-1
    80004c86:	b7d5                	j	80004c6a <filewrite+0xfa>
    panic("filewrite");
    80004c88:	00004517          	auipc	a0,0x4
    80004c8c:	a1050513          	addi	a0,a0,-1520 # 80008698 <syscalls+0x278>
    80004c90:	ffffc097          	auipc	ra,0xffffc
    80004c94:	89a080e7          	jalr	-1894(ra) # 8000052a <panic>
    return -1;
    80004c98:	5a7d                	li	s4,-1
    80004c9a:	bfc1                	j	80004c6a <filewrite+0xfa>
      return -1;
    80004c9c:	5a7d                	li	s4,-1
    80004c9e:	b7f1                	j	80004c6a <filewrite+0xfa>
    80004ca0:	5a7d                	li	s4,-1
    80004ca2:	b7e1                	j	80004c6a <filewrite+0xfa>

0000000080004ca4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ca4:	7179                	addi	sp,sp,-48
    80004ca6:	f406                	sd	ra,40(sp)
    80004ca8:	f022                	sd	s0,32(sp)
    80004caa:	ec26                	sd	s1,24(sp)
    80004cac:	e84a                	sd	s2,16(sp)
    80004cae:	e44e                	sd	s3,8(sp)
    80004cb0:	e052                	sd	s4,0(sp)
    80004cb2:	1800                	addi	s0,sp,48
    80004cb4:	84aa                	mv	s1,a0
    80004cb6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004cb8:	0005b023          	sd	zero,0(a1)
    80004cbc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004cc0:	00000097          	auipc	ra,0x0
    80004cc4:	bf8080e7          	jalr	-1032(ra) # 800048b8 <filealloc>
    80004cc8:	e088                	sd	a0,0(s1)
    80004cca:	c551                	beqz	a0,80004d56 <pipealloc+0xb2>
    80004ccc:	00000097          	auipc	ra,0x0
    80004cd0:	bec080e7          	jalr	-1044(ra) # 800048b8 <filealloc>
    80004cd4:	00aa3023          	sd	a0,0(s4)
    80004cd8:	c92d                	beqz	a0,80004d4a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004cda:	ffffc097          	auipc	ra,0xffffc
    80004cde:	df8080e7          	jalr	-520(ra) # 80000ad2 <kalloc>
    80004ce2:	892a                	mv	s2,a0
    80004ce4:	c125                	beqz	a0,80004d44 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ce6:	4985                	li	s3,1
    80004ce8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004cec:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004cf0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004cf4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004cf8:	00004597          	auipc	a1,0x4
    80004cfc:	9b058593          	addi	a1,a1,-1616 # 800086a8 <syscalls+0x288>
    80004d00:	ffffc097          	auipc	ra,0xffffc
    80004d04:	e32080e7          	jalr	-462(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004d08:	609c                	ld	a5,0(s1)
    80004d0a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d0e:	609c                	ld	a5,0(s1)
    80004d10:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d14:	609c                	ld	a5,0(s1)
    80004d16:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d1a:	609c                	ld	a5,0(s1)
    80004d1c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d20:	000a3783          	ld	a5,0(s4)
    80004d24:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d28:	000a3783          	ld	a5,0(s4)
    80004d2c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d30:	000a3783          	ld	a5,0(s4)
    80004d34:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d38:	000a3783          	ld	a5,0(s4)
    80004d3c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d40:	4501                	li	a0,0
    80004d42:	a025                	j	80004d6a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d44:	6088                	ld	a0,0(s1)
    80004d46:	e501                	bnez	a0,80004d4e <pipealloc+0xaa>
    80004d48:	a039                	j	80004d56 <pipealloc+0xb2>
    80004d4a:	6088                	ld	a0,0(s1)
    80004d4c:	c51d                	beqz	a0,80004d7a <pipealloc+0xd6>
    fileclose(*f0);
    80004d4e:	00000097          	auipc	ra,0x0
    80004d52:	c26080e7          	jalr	-986(ra) # 80004974 <fileclose>
  if(*f1)
    80004d56:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d5a:	557d                	li	a0,-1
  if(*f1)
    80004d5c:	c799                	beqz	a5,80004d6a <pipealloc+0xc6>
    fileclose(*f1);
    80004d5e:	853e                	mv	a0,a5
    80004d60:	00000097          	auipc	ra,0x0
    80004d64:	c14080e7          	jalr	-1004(ra) # 80004974 <fileclose>
  return -1;
    80004d68:	557d                	li	a0,-1
}
    80004d6a:	70a2                	ld	ra,40(sp)
    80004d6c:	7402                	ld	s0,32(sp)
    80004d6e:	64e2                	ld	s1,24(sp)
    80004d70:	6942                	ld	s2,16(sp)
    80004d72:	69a2                	ld	s3,8(sp)
    80004d74:	6a02                	ld	s4,0(sp)
    80004d76:	6145                	addi	sp,sp,48
    80004d78:	8082                	ret
  return -1;
    80004d7a:	557d                	li	a0,-1
    80004d7c:	b7fd                	j	80004d6a <pipealloc+0xc6>

0000000080004d7e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d7e:	1101                	addi	sp,sp,-32
    80004d80:	ec06                	sd	ra,24(sp)
    80004d82:	e822                	sd	s0,16(sp)
    80004d84:	e426                	sd	s1,8(sp)
    80004d86:	e04a                	sd	s2,0(sp)
    80004d88:	1000                	addi	s0,sp,32
    80004d8a:	84aa                	mv	s1,a0
    80004d8c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d8e:	ffffc097          	auipc	ra,0xffffc
    80004d92:	e34080e7          	jalr	-460(ra) # 80000bc2 <acquire>
  if(writable){
    80004d96:	02090d63          	beqz	s2,80004dd0 <pipeclose+0x52>
    pi->writeopen = 0;
    80004d9a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d9e:	21848513          	addi	a0,s1,536
    80004da2:	ffffe097          	auipc	ra,0xffffe
    80004da6:	a3c080e7          	jalr	-1476(ra) # 800027de <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004daa:	2204b783          	ld	a5,544(s1)
    80004dae:	eb95                	bnez	a5,80004de2 <pipeclose+0x64>
    release(&pi->lock);
    80004db0:	8526                	mv	a0,s1
    80004db2:	ffffc097          	auipc	ra,0xffffc
    80004db6:	ec4080e7          	jalr	-316(ra) # 80000c76 <release>
    kfree((char*)pi);
    80004dba:	8526                	mv	a0,s1
    80004dbc:	ffffc097          	auipc	ra,0xffffc
    80004dc0:	c1a080e7          	jalr	-998(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80004dc4:	60e2                	ld	ra,24(sp)
    80004dc6:	6442                	ld	s0,16(sp)
    80004dc8:	64a2                	ld	s1,8(sp)
    80004dca:	6902                	ld	s2,0(sp)
    80004dcc:	6105                	addi	sp,sp,32
    80004dce:	8082                	ret
    pi->readopen = 0;
    80004dd0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004dd4:	21c48513          	addi	a0,s1,540
    80004dd8:	ffffe097          	auipc	ra,0xffffe
    80004ddc:	a06080e7          	jalr	-1530(ra) # 800027de <wakeup>
    80004de0:	b7e9                	j	80004daa <pipeclose+0x2c>
    release(&pi->lock);
    80004de2:	8526                	mv	a0,s1
    80004de4:	ffffc097          	auipc	ra,0xffffc
    80004de8:	e92080e7          	jalr	-366(ra) # 80000c76 <release>
}
    80004dec:	bfe1                	j	80004dc4 <pipeclose+0x46>

0000000080004dee <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004dee:	711d                	addi	sp,sp,-96
    80004df0:	ec86                	sd	ra,88(sp)
    80004df2:	e8a2                	sd	s0,80(sp)
    80004df4:	e4a6                	sd	s1,72(sp)
    80004df6:	e0ca                	sd	s2,64(sp)
    80004df8:	fc4e                	sd	s3,56(sp)
    80004dfa:	f852                	sd	s4,48(sp)
    80004dfc:	f456                	sd	s5,40(sp)
    80004dfe:	f05a                	sd	s6,32(sp)
    80004e00:	ec5e                	sd	s7,24(sp)
    80004e02:	e862                	sd	s8,16(sp)
    80004e04:	1080                	addi	s0,sp,96
    80004e06:	84aa                	mv	s1,a0
    80004e08:	8aae                	mv	s5,a1
    80004e0a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e0c:	ffffd097          	auipc	ra,0xffffd
    80004e10:	f9a080e7          	jalr	-102(ra) # 80001da6 <myproc>
    80004e14:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e16:	8526                	mv	a0,s1
    80004e18:	ffffc097          	auipc	ra,0xffffc
    80004e1c:	daa080e7          	jalr	-598(ra) # 80000bc2 <acquire>
  while(i < n){
    80004e20:	0b405363          	blez	s4,80004ec6 <pipewrite+0xd8>
  int i = 0;
    80004e24:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e26:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e28:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e2c:	21c48b93          	addi	s7,s1,540
    80004e30:	a089                	j	80004e72 <pipewrite+0x84>
      release(&pi->lock);
    80004e32:	8526                	mv	a0,s1
    80004e34:	ffffc097          	auipc	ra,0xffffc
    80004e38:	e42080e7          	jalr	-446(ra) # 80000c76 <release>
      return -1;
    80004e3c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e3e:	854a                	mv	a0,s2
    80004e40:	60e6                	ld	ra,88(sp)
    80004e42:	6446                	ld	s0,80(sp)
    80004e44:	64a6                	ld	s1,72(sp)
    80004e46:	6906                	ld	s2,64(sp)
    80004e48:	79e2                	ld	s3,56(sp)
    80004e4a:	7a42                	ld	s4,48(sp)
    80004e4c:	7aa2                	ld	s5,40(sp)
    80004e4e:	7b02                	ld	s6,32(sp)
    80004e50:	6be2                	ld	s7,24(sp)
    80004e52:	6c42                	ld	s8,16(sp)
    80004e54:	6125                	addi	sp,sp,96
    80004e56:	8082                	ret
      wakeup(&pi->nread);
    80004e58:	8562                	mv	a0,s8
    80004e5a:	ffffe097          	auipc	ra,0xffffe
    80004e5e:	984080e7          	jalr	-1660(ra) # 800027de <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e62:	85a6                	mv	a1,s1
    80004e64:	855e                	mv	a0,s7
    80004e66:	ffffd097          	auipc	ra,0xffffd
    80004e6a:	7f8080e7          	jalr	2040(ra) # 8000265e <sleep>
  while(i < n){
    80004e6e:	05495d63          	bge	s2,s4,80004ec8 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004e72:	2204a783          	lw	a5,544(s1)
    80004e76:	dfd5                	beqz	a5,80004e32 <pipewrite+0x44>
    80004e78:	0309a783          	lw	a5,48(s3)
    80004e7c:	fbdd                	bnez	a5,80004e32 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e7e:	2184a783          	lw	a5,536(s1)
    80004e82:	21c4a703          	lw	a4,540(s1)
    80004e86:	2007879b          	addiw	a5,a5,512
    80004e8a:	fcf707e3          	beq	a4,a5,80004e58 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e8e:	4685                	li	a3,1
    80004e90:	01590633          	add	a2,s2,s5
    80004e94:	faf40593          	addi	a1,s0,-81
    80004e98:	0509b503          	ld	a0,80(s3)
    80004e9c:	ffffd097          	auipc	ra,0xffffd
    80004ea0:	852080e7          	jalr	-1966(ra) # 800016ee <copyin>
    80004ea4:	03650263          	beq	a0,s6,80004ec8 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ea8:	21c4a783          	lw	a5,540(s1)
    80004eac:	0017871b          	addiw	a4,a5,1
    80004eb0:	20e4ae23          	sw	a4,540(s1)
    80004eb4:	1ff7f793          	andi	a5,a5,511
    80004eb8:	97a6                	add	a5,a5,s1
    80004eba:	faf44703          	lbu	a4,-81(s0)
    80004ebe:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ec2:	2905                	addiw	s2,s2,1
    80004ec4:	b76d                	j	80004e6e <pipewrite+0x80>
  int i = 0;
    80004ec6:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ec8:	21848513          	addi	a0,s1,536
    80004ecc:	ffffe097          	auipc	ra,0xffffe
    80004ed0:	912080e7          	jalr	-1774(ra) # 800027de <wakeup>
  release(&pi->lock);
    80004ed4:	8526                	mv	a0,s1
    80004ed6:	ffffc097          	auipc	ra,0xffffc
    80004eda:	da0080e7          	jalr	-608(ra) # 80000c76 <release>
  return i;
    80004ede:	b785                	j	80004e3e <pipewrite+0x50>

0000000080004ee0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ee0:	715d                	addi	sp,sp,-80
    80004ee2:	e486                	sd	ra,72(sp)
    80004ee4:	e0a2                	sd	s0,64(sp)
    80004ee6:	fc26                	sd	s1,56(sp)
    80004ee8:	f84a                	sd	s2,48(sp)
    80004eea:	f44e                	sd	s3,40(sp)
    80004eec:	f052                	sd	s4,32(sp)
    80004eee:	ec56                	sd	s5,24(sp)
    80004ef0:	e85a                	sd	s6,16(sp)
    80004ef2:	0880                	addi	s0,sp,80
    80004ef4:	84aa                	mv	s1,a0
    80004ef6:	892e                	mv	s2,a1
    80004ef8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004efa:	ffffd097          	auipc	ra,0xffffd
    80004efe:	eac080e7          	jalr	-340(ra) # 80001da6 <myproc>
    80004f02:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f04:	8526                	mv	a0,s1
    80004f06:	ffffc097          	auipc	ra,0xffffc
    80004f0a:	cbc080e7          	jalr	-836(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f0e:	2184a703          	lw	a4,536(s1)
    80004f12:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f16:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f1a:	02f71463          	bne	a4,a5,80004f42 <piperead+0x62>
    80004f1e:	2244a783          	lw	a5,548(s1)
    80004f22:	c385                	beqz	a5,80004f42 <piperead+0x62>
    if(pr->killed){
    80004f24:	030a2783          	lw	a5,48(s4)
    80004f28:	ebc1                	bnez	a5,80004fb8 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f2a:	85a6                	mv	a1,s1
    80004f2c:	854e                	mv	a0,s3
    80004f2e:	ffffd097          	auipc	ra,0xffffd
    80004f32:	730080e7          	jalr	1840(ra) # 8000265e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f36:	2184a703          	lw	a4,536(s1)
    80004f3a:	21c4a783          	lw	a5,540(s1)
    80004f3e:	fef700e3          	beq	a4,a5,80004f1e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f42:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f44:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f46:	05505363          	blez	s5,80004f8c <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004f4a:	2184a783          	lw	a5,536(s1)
    80004f4e:	21c4a703          	lw	a4,540(s1)
    80004f52:	02f70d63          	beq	a4,a5,80004f8c <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f56:	0017871b          	addiw	a4,a5,1
    80004f5a:	20e4ac23          	sw	a4,536(s1)
    80004f5e:	1ff7f793          	andi	a5,a5,511
    80004f62:	97a6                	add	a5,a5,s1
    80004f64:	0187c783          	lbu	a5,24(a5)
    80004f68:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f6c:	4685                	li	a3,1
    80004f6e:	fbf40613          	addi	a2,s0,-65
    80004f72:	85ca                	mv	a1,s2
    80004f74:	050a3503          	ld	a0,80(s4)
    80004f78:	ffffc097          	auipc	ra,0xffffc
    80004f7c:	6ea080e7          	jalr	1770(ra) # 80001662 <copyout>
    80004f80:	01650663          	beq	a0,s6,80004f8c <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f84:	2985                	addiw	s3,s3,1
    80004f86:	0905                	addi	s2,s2,1
    80004f88:	fd3a91e3          	bne	s5,s3,80004f4a <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f8c:	21c48513          	addi	a0,s1,540
    80004f90:	ffffe097          	auipc	ra,0xffffe
    80004f94:	84e080e7          	jalr	-1970(ra) # 800027de <wakeup>
  release(&pi->lock);
    80004f98:	8526                	mv	a0,s1
    80004f9a:	ffffc097          	auipc	ra,0xffffc
    80004f9e:	cdc080e7          	jalr	-804(ra) # 80000c76 <release>
  return i;
}
    80004fa2:	854e                	mv	a0,s3
    80004fa4:	60a6                	ld	ra,72(sp)
    80004fa6:	6406                	ld	s0,64(sp)
    80004fa8:	74e2                	ld	s1,56(sp)
    80004faa:	7942                	ld	s2,48(sp)
    80004fac:	79a2                	ld	s3,40(sp)
    80004fae:	7a02                	ld	s4,32(sp)
    80004fb0:	6ae2                	ld	s5,24(sp)
    80004fb2:	6b42                	ld	s6,16(sp)
    80004fb4:	6161                	addi	sp,sp,80
    80004fb6:	8082                	ret
      release(&pi->lock);
    80004fb8:	8526                	mv	a0,s1
    80004fba:	ffffc097          	auipc	ra,0xffffc
    80004fbe:	cbc080e7          	jalr	-836(ra) # 80000c76 <release>
      return -1;
    80004fc2:	59fd                	li	s3,-1
    80004fc4:	bff9                	j	80004fa2 <piperead+0xc2>

0000000080004fc6 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004fc6:	de010113          	addi	sp,sp,-544
    80004fca:	20113c23          	sd	ra,536(sp)
    80004fce:	20813823          	sd	s0,528(sp)
    80004fd2:	20913423          	sd	s1,520(sp)
    80004fd6:	21213023          	sd	s2,512(sp)
    80004fda:	ffce                	sd	s3,504(sp)
    80004fdc:	fbd2                	sd	s4,496(sp)
    80004fde:	f7d6                	sd	s5,488(sp)
    80004fe0:	f3da                	sd	s6,480(sp)
    80004fe2:	efde                	sd	s7,472(sp)
    80004fe4:	ebe2                	sd	s8,464(sp)
    80004fe6:	e7e6                	sd	s9,456(sp)
    80004fe8:	e3ea                	sd	s10,448(sp)
    80004fea:	ff6e                	sd	s11,440(sp)
    80004fec:	1400                	addi	s0,sp,544
    80004fee:	892a                	mv	s2,a0
    80004ff0:	dea43423          	sd	a0,-536(s0)
    80004ff4:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ff8:	ffffd097          	auipc	ra,0xffffd
    80004ffc:	dae080e7          	jalr	-594(ra) # 80001da6 <myproc>
    80005000:	84aa                	mv	s1,a0

  begin_op();
    80005002:	fffff097          	auipc	ra,0xfffff
    80005006:	49e080e7          	jalr	1182(ra) # 800044a0 <begin_op>

  if((ip = namei(path)) == 0){
    8000500a:	854a                	mv	a0,s2
    8000500c:	fffff097          	auipc	ra,0xfffff
    80005010:	278080e7          	jalr	632(ra) # 80004284 <namei>
    80005014:	c93d                	beqz	a0,8000508a <exec+0xc4>
    80005016:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005018:	fffff097          	auipc	ra,0xfffff
    8000501c:	ab6080e7          	jalr	-1354(ra) # 80003ace <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005020:	04000713          	li	a4,64
    80005024:	4681                	li	a3,0
    80005026:	e4840613          	addi	a2,s0,-440
    8000502a:	4581                	li	a1,0
    8000502c:	8556                	mv	a0,s5
    8000502e:	fffff097          	auipc	ra,0xfffff
    80005032:	d54080e7          	jalr	-684(ra) # 80003d82 <readi>
    80005036:	04000793          	li	a5,64
    8000503a:	00f51a63          	bne	a0,a5,8000504e <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000503e:	e4842703          	lw	a4,-440(s0)
    80005042:	464c47b7          	lui	a5,0x464c4
    80005046:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000504a:	04f70663          	beq	a4,a5,80005096 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000504e:	8556                	mv	a0,s5
    80005050:	fffff097          	auipc	ra,0xfffff
    80005054:	ce0080e7          	jalr	-800(ra) # 80003d30 <iunlockput>
    end_op();
    80005058:	fffff097          	auipc	ra,0xfffff
    8000505c:	4c8080e7          	jalr	1224(ra) # 80004520 <end_op>
  }
  return -1;
    80005060:	557d                	li	a0,-1
}
    80005062:	21813083          	ld	ra,536(sp)
    80005066:	21013403          	ld	s0,528(sp)
    8000506a:	20813483          	ld	s1,520(sp)
    8000506e:	20013903          	ld	s2,512(sp)
    80005072:	79fe                	ld	s3,504(sp)
    80005074:	7a5e                	ld	s4,496(sp)
    80005076:	7abe                	ld	s5,488(sp)
    80005078:	7b1e                	ld	s6,480(sp)
    8000507a:	6bfe                	ld	s7,472(sp)
    8000507c:	6c5e                	ld	s8,464(sp)
    8000507e:	6cbe                	ld	s9,456(sp)
    80005080:	6d1e                	ld	s10,448(sp)
    80005082:	7dfa                	ld	s11,440(sp)
    80005084:	22010113          	addi	sp,sp,544
    80005088:	8082                	ret
    end_op();
    8000508a:	fffff097          	auipc	ra,0xfffff
    8000508e:	496080e7          	jalr	1174(ra) # 80004520 <end_op>
    return -1;
    80005092:	557d                	li	a0,-1
    80005094:	b7f9                	j	80005062 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005096:	8526                	mv	a0,s1
    80005098:	ffffd097          	auipc	ra,0xffffd
    8000509c:	dd2080e7          	jalr	-558(ra) # 80001e6a <proc_pagetable>
    800050a0:	8b2a                	mv	s6,a0
    800050a2:	d555                	beqz	a0,8000504e <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050a4:	e6842783          	lw	a5,-408(s0)
    800050a8:	e8045703          	lhu	a4,-384(s0)
    800050ac:	c735                	beqz	a4,80005118 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800050ae:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050b0:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800050b4:	6a05                	lui	s4,0x1
    800050b6:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800050ba:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800050be:	6d85                	lui	s11,0x1
    800050c0:	7d7d                	lui	s10,0xfffff
    800050c2:	ac1d                	j	800052f8 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800050c4:	00003517          	auipc	a0,0x3
    800050c8:	5ec50513          	addi	a0,a0,1516 # 800086b0 <syscalls+0x290>
    800050cc:	ffffb097          	auipc	ra,0xffffb
    800050d0:	45e080e7          	jalr	1118(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800050d4:	874a                	mv	a4,s2
    800050d6:	009c86bb          	addw	a3,s9,s1
    800050da:	4581                	li	a1,0
    800050dc:	8556                	mv	a0,s5
    800050de:	fffff097          	auipc	ra,0xfffff
    800050e2:	ca4080e7          	jalr	-860(ra) # 80003d82 <readi>
    800050e6:	2501                	sext.w	a0,a0
    800050e8:	1aa91863          	bne	s2,a0,80005298 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    800050ec:	009d84bb          	addw	s1,s11,s1
    800050f0:	013d09bb          	addw	s3,s10,s3
    800050f4:	1f74f263          	bgeu	s1,s7,800052d8 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    800050f8:	02049593          	slli	a1,s1,0x20
    800050fc:	9181                	srli	a1,a1,0x20
    800050fe:	95e2                	add	a1,a1,s8
    80005100:	855a                	mv	a0,s6
    80005102:	ffffc097          	auipc	ra,0xffffc
    80005106:	f6e080e7          	jalr	-146(ra) # 80001070 <walkaddr>
    8000510a:	862a                	mv	a2,a0
    if(pa == 0)
    8000510c:	dd45                	beqz	a0,800050c4 <exec+0xfe>
      n = PGSIZE;
    8000510e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005110:	fd49f2e3          	bgeu	s3,s4,800050d4 <exec+0x10e>
      n = sz - i;
    80005114:	894e                	mv	s2,s3
    80005116:	bf7d                	j	800050d4 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005118:	4481                	li	s1,0
  iunlockput(ip);
    8000511a:	8556                	mv	a0,s5
    8000511c:	fffff097          	auipc	ra,0xfffff
    80005120:	c14080e7          	jalr	-1004(ra) # 80003d30 <iunlockput>
  end_op();
    80005124:	fffff097          	auipc	ra,0xfffff
    80005128:	3fc080e7          	jalr	1020(ra) # 80004520 <end_op>
  p = myproc();
    8000512c:	ffffd097          	auipc	ra,0xffffd
    80005130:	c7a080e7          	jalr	-902(ra) # 80001da6 <myproc>
    80005134:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005136:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000513a:	6785                	lui	a5,0x1
    8000513c:	17fd                	addi	a5,a5,-1
    8000513e:	94be                	add	s1,s1,a5
    80005140:	77fd                	lui	a5,0xfffff
    80005142:	8fe5                	and	a5,a5,s1
    80005144:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005148:	6609                	lui	a2,0x2
    8000514a:	963e                	add	a2,a2,a5
    8000514c:	85be                	mv	a1,a5
    8000514e:	855a                	mv	a0,s6
    80005150:	ffffc097          	auipc	ra,0xffffc
    80005154:	2c2080e7          	jalr	706(ra) # 80001412 <uvmalloc>
    80005158:	8c2a                	mv	s8,a0
  ip = 0;
    8000515a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000515c:	12050e63          	beqz	a0,80005298 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005160:	75f9                	lui	a1,0xffffe
    80005162:	95aa                	add	a1,a1,a0
    80005164:	855a                	mv	a0,s6
    80005166:	ffffc097          	auipc	ra,0xffffc
    8000516a:	4ca080e7          	jalr	1226(ra) # 80001630 <uvmclear>
  stackbase = sp - PGSIZE;
    8000516e:	7afd                	lui	s5,0xfffff
    80005170:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005172:	df043783          	ld	a5,-528(s0)
    80005176:	6388                	ld	a0,0(a5)
    80005178:	c925                	beqz	a0,800051e8 <exec+0x222>
    8000517a:	e8840993          	addi	s3,s0,-376
    8000517e:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005182:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005184:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005186:	ffffc097          	auipc	ra,0xffffc
    8000518a:	cbc080e7          	jalr	-836(ra) # 80000e42 <strlen>
    8000518e:	0015079b          	addiw	a5,a0,1
    80005192:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005196:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000519a:	13596363          	bltu	s2,s5,800052c0 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000519e:	df043d83          	ld	s11,-528(s0)
    800051a2:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800051a6:	8552                	mv	a0,s4
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	c9a080e7          	jalr	-870(ra) # 80000e42 <strlen>
    800051b0:	0015069b          	addiw	a3,a0,1
    800051b4:	8652                	mv	a2,s4
    800051b6:	85ca                	mv	a1,s2
    800051b8:	855a                	mv	a0,s6
    800051ba:	ffffc097          	auipc	ra,0xffffc
    800051be:	4a8080e7          	jalr	1192(ra) # 80001662 <copyout>
    800051c2:	10054363          	bltz	a0,800052c8 <exec+0x302>
    ustack[argc] = sp;
    800051c6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051ca:	0485                	addi	s1,s1,1
    800051cc:	008d8793          	addi	a5,s11,8
    800051d0:	def43823          	sd	a5,-528(s0)
    800051d4:	008db503          	ld	a0,8(s11)
    800051d8:	c911                	beqz	a0,800051ec <exec+0x226>
    if(argc >= MAXARG)
    800051da:	09a1                	addi	s3,s3,8
    800051dc:	fb3c95e3          	bne	s9,s3,80005186 <exec+0x1c0>
  sz = sz1;
    800051e0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051e4:	4a81                	li	s5,0
    800051e6:	a84d                	j	80005298 <exec+0x2d2>
  sp = sz;
    800051e8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800051ea:	4481                	li	s1,0
  ustack[argc] = 0;
    800051ec:	00349793          	slli	a5,s1,0x3
    800051f0:	f9040713          	addi	a4,s0,-112
    800051f4:	97ba                	add	a5,a5,a4
    800051f6:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcaef8>
  sp -= (argc+1) * sizeof(uint64);
    800051fa:	00148693          	addi	a3,s1,1
    800051fe:	068e                	slli	a3,a3,0x3
    80005200:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005204:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005208:	01597663          	bgeu	s2,s5,80005214 <exec+0x24e>
  sz = sz1;
    8000520c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005210:	4a81                	li	s5,0
    80005212:	a059                	j	80005298 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005214:	e8840613          	addi	a2,s0,-376
    80005218:	85ca                	mv	a1,s2
    8000521a:	855a                	mv	a0,s6
    8000521c:	ffffc097          	auipc	ra,0xffffc
    80005220:	446080e7          	jalr	1094(ra) # 80001662 <copyout>
    80005224:	0a054663          	bltz	a0,800052d0 <exec+0x30a>
  p->trapframe->a1 = sp;
    80005228:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    8000522c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005230:	de843783          	ld	a5,-536(s0)
    80005234:	0007c703          	lbu	a4,0(a5)
    80005238:	cf11                	beqz	a4,80005254 <exec+0x28e>
    8000523a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000523c:	02f00693          	li	a3,47
    80005240:	a039                	j	8000524e <exec+0x288>
      last = s+1;
    80005242:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005246:	0785                	addi	a5,a5,1
    80005248:	fff7c703          	lbu	a4,-1(a5)
    8000524c:	c701                	beqz	a4,80005254 <exec+0x28e>
    if(*s == '/')
    8000524e:	fed71ce3          	bne	a4,a3,80005246 <exec+0x280>
    80005252:	bfc5                	j	80005242 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005254:	4641                	li	a2,16
    80005256:	de843583          	ld	a1,-536(s0)
    8000525a:	158b8513          	addi	a0,s7,344
    8000525e:	ffffc097          	auipc	ra,0xffffc
    80005262:	bb2080e7          	jalr	-1102(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005266:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000526a:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000526e:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005272:	058bb783          	ld	a5,88(s7)
    80005276:	e6043703          	ld	a4,-416(s0)
    8000527a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000527c:	058bb783          	ld	a5,88(s7)
    80005280:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005284:	85ea                	mv	a1,s10
    80005286:	ffffd097          	auipc	ra,0xffffd
    8000528a:	c80080e7          	jalr	-896(ra) # 80001f06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000528e:	0004851b          	sext.w	a0,s1
    80005292:	bbc1                	j	80005062 <exec+0x9c>
    80005294:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005298:	df843583          	ld	a1,-520(s0)
    8000529c:	855a                	mv	a0,s6
    8000529e:	ffffd097          	auipc	ra,0xffffd
    800052a2:	c68080e7          	jalr	-920(ra) # 80001f06 <proc_freepagetable>
  if(ip){
    800052a6:	da0a94e3          	bnez	s5,8000504e <exec+0x88>
  return -1;
    800052aa:	557d                	li	a0,-1
    800052ac:	bb5d                	j	80005062 <exec+0x9c>
    800052ae:	de943c23          	sd	s1,-520(s0)
    800052b2:	b7dd                	j	80005298 <exec+0x2d2>
    800052b4:	de943c23          	sd	s1,-520(s0)
    800052b8:	b7c5                	j	80005298 <exec+0x2d2>
    800052ba:	de943c23          	sd	s1,-520(s0)
    800052be:	bfe9                	j	80005298 <exec+0x2d2>
  sz = sz1;
    800052c0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052c4:	4a81                	li	s5,0
    800052c6:	bfc9                	j	80005298 <exec+0x2d2>
  sz = sz1;
    800052c8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052cc:	4a81                	li	s5,0
    800052ce:	b7e9                	j	80005298 <exec+0x2d2>
  sz = sz1;
    800052d0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052d4:	4a81                	li	s5,0
    800052d6:	b7c9                	j	80005298 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800052d8:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052dc:	e0843783          	ld	a5,-504(s0)
    800052e0:	0017869b          	addiw	a3,a5,1
    800052e4:	e0d43423          	sd	a3,-504(s0)
    800052e8:	e0043783          	ld	a5,-512(s0)
    800052ec:	0387879b          	addiw	a5,a5,56
    800052f0:	e8045703          	lhu	a4,-384(s0)
    800052f4:	e2e6d3e3          	bge	a3,a4,8000511a <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052f8:	2781                	sext.w	a5,a5
    800052fa:	e0f43023          	sd	a5,-512(s0)
    800052fe:	03800713          	li	a4,56
    80005302:	86be                	mv	a3,a5
    80005304:	e1040613          	addi	a2,s0,-496
    80005308:	4581                	li	a1,0
    8000530a:	8556                	mv	a0,s5
    8000530c:	fffff097          	auipc	ra,0xfffff
    80005310:	a76080e7          	jalr	-1418(ra) # 80003d82 <readi>
    80005314:	03800793          	li	a5,56
    80005318:	f6f51ee3          	bne	a0,a5,80005294 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    8000531c:	e1042783          	lw	a5,-496(s0)
    80005320:	4705                	li	a4,1
    80005322:	fae79de3          	bne	a5,a4,800052dc <exec+0x316>
    if(ph.memsz < ph.filesz)
    80005326:	e3843603          	ld	a2,-456(s0)
    8000532a:	e3043783          	ld	a5,-464(s0)
    8000532e:	f8f660e3          	bltu	a2,a5,800052ae <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005332:	e2043783          	ld	a5,-480(s0)
    80005336:	963e                	add	a2,a2,a5
    80005338:	f6f66ee3          	bltu	a2,a5,800052b4 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000533c:	85a6                	mv	a1,s1
    8000533e:	855a                	mv	a0,s6
    80005340:	ffffc097          	auipc	ra,0xffffc
    80005344:	0d2080e7          	jalr	210(ra) # 80001412 <uvmalloc>
    80005348:	dea43c23          	sd	a0,-520(s0)
    8000534c:	d53d                	beqz	a0,800052ba <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    8000534e:	e2043c03          	ld	s8,-480(s0)
    80005352:	de043783          	ld	a5,-544(s0)
    80005356:	00fc77b3          	and	a5,s8,a5
    8000535a:	ff9d                	bnez	a5,80005298 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000535c:	e1842c83          	lw	s9,-488(s0)
    80005360:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005364:	f60b8ae3          	beqz	s7,800052d8 <exec+0x312>
    80005368:	89de                	mv	s3,s7
    8000536a:	4481                	li	s1,0
    8000536c:	b371                	j	800050f8 <exec+0x132>

000000008000536e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000536e:	7179                	addi	sp,sp,-48
    80005370:	f406                	sd	ra,40(sp)
    80005372:	f022                	sd	s0,32(sp)
    80005374:	ec26                	sd	s1,24(sp)
    80005376:	e84a                	sd	s2,16(sp)
    80005378:	1800                	addi	s0,sp,48
    8000537a:	892e                	mv	s2,a1
    8000537c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000537e:	fdc40593          	addi	a1,s0,-36
    80005382:	ffffe097          	auipc	ra,0xffffe
    80005386:	bdc080e7          	jalr	-1060(ra) # 80002f5e <argint>
    8000538a:	04054063          	bltz	a0,800053ca <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000538e:	fdc42703          	lw	a4,-36(s0)
    80005392:	47bd                	li	a5,15
    80005394:	02e7ed63          	bltu	a5,a4,800053ce <argfd+0x60>
    80005398:	ffffd097          	auipc	ra,0xffffd
    8000539c:	a0e080e7          	jalr	-1522(ra) # 80001da6 <myproc>
    800053a0:	fdc42703          	lw	a4,-36(s0)
    800053a4:	01a70793          	addi	a5,a4,26
    800053a8:	078e                	slli	a5,a5,0x3
    800053aa:	953e                	add	a0,a0,a5
    800053ac:	611c                	ld	a5,0(a0)
    800053ae:	c395                	beqz	a5,800053d2 <argfd+0x64>
    return -1;
  if(pfd)
    800053b0:	00090463          	beqz	s2,800053b8 <argfd+0x4a>
    *pfd = fd;
    800053b4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800053b8:	4501                	li	a0,0
  if(pf)
    800053ba:	c091                	beqz	s1,800053be <argfd+0x50>
    *pf = f;
    800053bc:	e09c                	sd	a5,0(s1)
}
    800053be:	70a2                	ld	ra,40(sp)
    800053c0:	7402                	ld	s0,32(sp)
    800053c2:	64e2                	ld	s1,24(sp)
    800053c4:	6942                	ld	s2,16(sp)
    800053c6:	6145                	addi	sp,sp,48
    800053c8:	8082                	ret
    return -1;
    800053ca:	557d                	li	a0,-1
    800053cc:	bfcd                	j	800053be <argfd+0x50>
    return -1;
    800053ce:	557d                	li	a0,-1
    800053d0:	b7fd                	j	800053be <argfd+0x50>
    800053d2:	557d                	li	a0,-1
    800053d4:	b7ed                	j	800053be <argfd+0x50>

00000000800053d6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053d6:	1101                	addi	sp,sp,-32
    800053d8:	ec06                	sd	ra,24(sp)
    800053da:	e822                	sd	s0,16(sp)
    800053dc:	e426                	sd	s1,8(sp)
    800053de:	1000                	addi	s0,sp,32
    800053e0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053e2:	ffffd097          	auipc	ra,0xffffd
    800053e6:	9c4080e7          	jalr	-1596(ra) # 80001da6 <myproc>
    800053ea:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053ec:	0d050793          	addi	a5,a0,208
    800053f0:	4501                	li	a0,0
    800053f2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800053f4:	6398                	ld	a4,0(a5)
    800053f6:	cb19                	beqz	a4,8000540c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800053f8:	2505                	addiw	a0,a0,1
    800053fa:	07a1                	addi	a5,a5,8
    800053fc:	fed51ce3          	bne	a0,a3,800053f4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005400:	557d                	li	a0,-1
}
    80005402:	60e2                	ld	ra,24(sp)
    80005404:	6442                	ld	s0,16(sp)
    80005406:	64a2                	ld	s1,8(sp)
    80005408:	6105                	addi	sp,sp,32
    8000540a:	8082                	ret
      p->ofile[fd] = f;
    8000540c:	01a50793          	addi	a5,a0,26
    80005410:	078e                	slli	a5,a5,0x3
    80005412:	963e                	add	a2,a2,a5
    80005414:	e204                	sd	s1,0(a2)
      return fd;
    80005416:	b7f5                	j	80005402 <fdalloc+0x2c>

0000000080005418 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005418:	715d                	addi	sp,sp,-80
    8000541a:	e486                	sd	ra,72(sp)
    8000541c:	e0a2                	sd	s0,64(sp)
    8000541e:	fc26                	sd	s1,56(sp)
    80005420:	f84a                	sd	s2,48(sp)
    80005422:	f44e                	sd	s3,40(sp)
    80005424:	f052                	sd	s4,32(sp)
    80005426:	ec56                	sd	s5,24(sp)
    80005428:	0880                	addi	s0,sp,80
    8000542a:	89ae                	mv	s3,a1
    8000542c:	8ab2                	mv	s5,a2
    8000542e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005430:	fb040593          	addi	a1,s0,-80
    80005434:	fffff097          	auipc	ra,0xfffff
    80005438:	e6e080e7          	jalr	-402(ra) # 800042a2 <nameiparent>
    8000543c:	892a                	mv	s2,a0
    8000543e:	12050e63          	beqz	a0,8000557a <create+0x162>
    return 0;

  ilock(dp);
    80005442:	ffffe097          	auipc	ra,0xffffe
    80005446:	68c080e7          	jalr	1676(ra) # 80003ace <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000544a:	4601                	li	a2,0
    8000544c:	fb040593          	addi	a1,s0,-80
    80005450:	854a                	mv	a0,s2
    80005452:	fffff097          	auipc	ra,0xfffff
    80005456:	b60080e7          	jalr	-1184(ra) # 80003fb2 <dirlookup>
    8000545a:	84aa                	mv	s1,a0
    8000545c:	c921                	beqz	a0,800054ac <create+0x94>
    iunlockput(dp);
    8000545e:	854a                	mv	a0,s2
    80005460:	fffff097          	auipc	ra,0xfffff
    80005464:	8d0080e7          	jalr	-1840(ra) # 80003d30 <iunlockput>
    ilock(ip);
    80005468:	8526                	mv	a0,s1
    8000546a:	ffffe097          	auipc	ra,0xffffe
    8000546e:	664080e7          	jalr	1636(ra) # 80003ace <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005472:	2981                	sext.w	s3,s3
    80005474:	4789                	li	a5,2
    80005476:	02f99463          	bne	s3,a5,8000549e <create+0x86>
    8000547a:	0444d783          	lhu	a5,68(s1)
    8000547e:	37f9                	addiw	a5,a5,-2
    80005480:	17c2                	slli	a5,a5,0x30
    80005482:	93c1                	srli	a5,a5,0x30
    80005484:	4705                	li	a4,1
    80005486:	00f76c63          	bltu	a4,a5,8000549e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000548a:	8526                	mv	a0,s1
    8000548c:	60a6                	ld	ra,72(sp)
    8000548e:	6406                	ld	s0,64(sp)
    80005490:	74e2                	ld	s1,56(sp)
    80005492:	7942                	ld	s2,48(sp)
    80005494:	79a2                	ld	s3,40(sp)
    80005496:	7a02                	ld	s4,32(sp)
    80005498:	6ae2                	ld	s5,24(sp)
    8000549a:	6161                	addi	sp,sp,80
    8000549c:	8082                	ret
    iunlockput(ip);
    8000549e:	8526                	mv	a0,s1
    800054a0:	fffff097          	auipc	ra,0xfffff
    800054a4:	890080e7          	jalr	-1904(ra) # 80003d30 <iunlockput>
    return 0;
    800054a8:	4481                	li	s1,0
    800054aa:	b7c5                	j	8000548a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800054ac:	85ce                	mv	a1,s3
    800054ae:	00092503          	lw	a0,0(s2)
    800054b2:	ffffe097          	auipc	ra,0xffffe
    800054b6:	484080e7          	jalr	1156(ra) # 80003936 <ialloc>
    800054ba:	84aa                	mv	s1,a0
    800054bc:	c521                	beqz	a0,80005504 <create+0xec>
  ilock(ip);
    800054be:	ffffe097          	auipc	ra,0xffffe
    800054c2:	610080e7          	jalr	1552(ra) # 80003ace <ilock>
  ip->major = major;
    800054c6:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800054ca:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800054ce:	4a05                	li	s4,1
    800054d0:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800054d4:	8526                	mv	a0,s1
    800054d6:	ffffe097          	auipc	ra,0xffffe
    800054da:	52e080e7          	jalr	1326(ra) # 80003a04 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054de:	2981                	sext.w	s3,s3
    800054e0:	03498a63          	beq	s3,s4,80005514 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800054e4:	40d0                	lw	a2,4(s1)
    800054e6:	fb040593          	addi	a1,s0,-80
    800054ea:	854a                	mv	a0,s2
    800054ec:	fffff097          	auipc	ra,0xfffff
    800054f0:	cd6080e7          	jalr	-810(ra) # 800041c2 <dirlink>
    800054f4:	06054b63          	bltz	a0,8000556a <create+0x152>
  iunlockput(dp);
    800054f8:	854a                	mv	a0,s2
    800054fa:	fffff097          	auipc	ra,0xfffff
    800054fe:	836080e7          	jalr	-1994(ra) # 80003d30 <iunlockput>
  return ip;
    80005502:	b761                	j	8000548a <create+0x72>
    panic("create: ialloc");
    80005504:	00003517          	auipc	a0,0x3
    80005508:	1cc50513          	addi	a0,a0,460 # 800086d0 <syscalls+0x2b0>
    8000550c:	ffffb097          	auipc	ra,0xffffb
    80005510:	01e080e7          	jalr	30(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    80005514:	04a95783          	lhu	a5,74(s2)
    80005518:	2785                	addiw	a5,a5,1
    8000551a:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000551e:	854a                	mv	a0,s2
    80005520:	ffffe097          	auipc	ra,0xffffe
    80005524:	4e4080e7          	jalr	1252(ra) # 80003a04 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005528:	40d0                	lw	a2,4(s1)
    8000552a:	00003597          	auipc	a1,0x3
    8000552e:	1b658593          	addi	a1,a1,438 # 800086e0 <syscalls+0x2c0>
    80005532:	8526                	mv	a0,s1
    80005534:	fffff097          	auipc	ra,0xfffff
    80005538:	c8e080e7          	jalr	-882(ra) # 800041c2 <dirlink>
    8000553c:	00054f63          	bltz	a0,8000555a <create+0x142>
    80005540:	00492603          	lw	a2,4(s2)
    80005544:	00003597          	auipc	a1,0x3
    80005548:	1a458593          	addi	a1,a1,420 # 800086e8 <syscalls+0x2c8>
    8000554c:	8526                	mv	a0,s1
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	c74080e7          	jalr	-908(ra) # 800041c2 <dirlink>
    80005556:	f80557e3          	bgez	a0,800054e4 <create+0xcc>
      panic("create dots");
    8000555a:	00003517          	auipc	a0,0x3
    8000555e:	19650513          	addi	a0,a0,406 # 800086f0 <syscalls+0x2d0>
    80005562:	ffffb097          	auipc	ra,0xffffb
    80005566:	fc8080e7          	jalr	-56(ra) # 8000052a <panic>
    panic("create: dirlink");
    8000556a:	00003517          	auipc	a0,0x3
    8000556e:	19650513          	addi	a0,a0,406 # 80008700 <syscalls+0x2e0>
    80005572:	ffffb097          	auipc	ra,0xffffb
    80005576:	fb8080e7          	jalr	-72(ra) # 8000052a <panic>
    return 0;
    8000557a:	84aa                	mv	s1,a0
    8000557c:	b739                	j	8000548a <create+0x72>

000000008000557e <sys_dup>:
{
    8000557e:	7179                	addi	sp,sp,-48
    80005580:	f406                	sd	ra,40(sp)
    80005582:	f022                	sd	s0,32(sp)
    80005584:	ec26                	sd	s1,24(sp)
    80005586:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005588:	fd840613          	addi	a2,s0,-40
    8000558c:	4581                	li	a1,0
    8000558e:	4501                	li	a0,0
    80005590:	00000097          	auipc	ra,0x0
    80005594:	dde080e7          	jalr	-546(ra) # 8000536e <argfd>
    return -1;
    80005598:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000559a:	02054363          	bltz	a0,800055c0 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000559e:	fd843503          	ld	a0,-40(s0)
    800055a2:	00000097          	auipc	ra,0x0
    800055a6:	e34080e7          	jalr	-460(ra) # 800053d6 <fdalloc>
    800055aa:	84aa                	mv	s1,a0
    return -1;
    800055ac:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800055ae:	00054963          	bltz	a0,800055c0 <sys_dup+0x42>
  filedup(f);
    800055b2:	fd843503          	ld	a0,-40(s0)
    800055b6:	fffff097          	auipc	ra,0xfffff
    800055ba:	36c080e7          	jalr	876(ra) # 80004922 <filedup>
  return fd;
    800055be:	87a6                	mv	a5,s1
}
    800055c0:	853e                	mv	a0,a5
    800055c2:	70a2                	ld	ra,40(sp)
    800055c4:	7402                	ld	s0,32(sp)
    800055c6:	64e2                	ld	s1,24(sp)
    800055c8:	6145                	addi	sp,sp,48
    800055ca:	8082                	ret

00000000800055cc <sys_read>:
{
    800055cc:	7179                	addi	sp,sp,-48
    800055ce:	f406                	sd	ra,40(sp)
    800055d0:	f022                	sd	s0,32(sp)
    800055d2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055d4:	fe840613          	addi	a2,s0,-24
    800055d8:	4581                	li	a1,0
    800055da:	4501                	li	a0,0
    800055dc:	00000097          	auipc	ra,0x0
    800055e0:	d92080e7          	jalr	-622(ra) # 8000536e <argfd>
    return -1;
    800055e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055e6:	04054163          	bltz	a0,80005628 <sys_read+0x5c>
    800055ea:	fe440593          	addi	a1,s0,-28
    800055ee:	4509                	li	a0,2
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	96e080e7          	jalr	-1682(ra) # 80002f5e <argint>
    return -1;
    800055f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055fa:	02054763          	bltz	a0,80005628 <sys_read+0x5c>
    800055fe:	fd840593          	addi	a1,s0,-40
    80005602:	4505                	li	a0,1
    80005604:	ffffe097          	auipc	ra,0xffffe
    80005608:	97c080e7          	jalr	-1668(ra) # 80002f80 <argaddr>
    return -1;
    8000560c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000560e:	00054d63          	bltz	a0,80005628 <sys_read+0x5c>
  return fileread(f, p, n);
    80005612:	fe442603          	lw	a2,-28(s0)
    80005616:	fd843583          	ld	a1,-40(s0)
    8000561a:	fe843503          	ld	a0,-24(s0)
    8000561e:	fffff097          	auipc	ra,0xfffff
    80005622:	490080e7          	jalr	1168(ra) # 80004aae <fileread>
    80005626:	87aa                	mv	a5,a0
}
    80005628:	853e                	mv	a0,a5
    8000562a:	70a2                	ld	ra,40(sp)
    8000562c:	7402                	ld	s0,32(sp)
    8000562e:	6145                	addi	sp,sp,48
    80005630:	8082                	ret

0000000080005632 <sys_write>:
{
    80005632:	7179                	addi	sp,sp,-48
    80005634:	f406                	sd	ra,40(sp)
    80005636:	f022                	sd	s0,32(sp)
    80005638:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000563a:	fe840613          	addi	a2,s0,-24
    8000563e:	4581                	li	a1,0
    80005640:	4501                	li	a0,0
    80005642:	00000097          	auipc	ra,0x0
    80005646:	d2c080e7          	jalr	-724(ra) # 8000536e <argfd>
    return -1;
    8000564a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000564c:	04054163          	bltz	a0,8000568e <sys_write+0x5c>
    80005650:	fe440593          	addi	a1,s0,-28
    80005654:	4509                	li	a0,2
    80005656:	ffffe097          	auipc	ra,0xffffe
    8000565a:	908080e7          	jalr	-1784(ra) # 80002f5e <argint>
    return -1;
    8000565e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005660:	02054763          	bltz	a0,8000568e <sys_write+0x5c>
    80005664:	fd840593          	addi	a1,s0,-40
    80005668:	4505                	li	a0,1
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	916080e7          	jalr	-1770(ra) # 80002f80 <argaddr>
    return -1;
    80005672:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005674:	00054d63          	bltz	a0,8000568e <sys_write+0x5c>
  return filewrite(f, p, n);
    80005678:	fe442603          	lw	a2,-28(s0)
    8000567c:	fd843583          	ld	a1,-40(s0)
    80005680:	fe843503          	ld	a0,-24(s0)
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	4ec080e7          	jalr	1260(ra) # 80004b70 <filewrite>
    8000568c:	87aa                	mv	a5,a0
}
    8000568e:	853e                	mv	a0,a5
    80005690:	70a2                	ld	ra,40(sp)
    80005692:	7402                	ld	s0,32(sp)
    80005694:	6145                	addi	sp,sp,48
    80005696:	8082                	ret

0000000080005698 <sys_close>:
{
    80005698:	1101                	addi	sp,sp,-32
    8000569a:	ec06                	sd	ra,24(sp)
    8000569c:	e822                	sd	s0,16(sp)
    8000569e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800056a0:	fe040613          	addi	a2,s0,-32
    800056a4:	fec40593          	addi	a1,s0,-20
    800056a8:	4501                	li	a0,0
    800056aa:	00000097          	auipc	ra,0x0
    800056ae:	cc4080e7          	jalr	-828(ra) # 8000536e <argfd>
    return -1;
    800056b2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800056b4:	02054463          	bltz	a0,800056dc <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800056b8:	ffffc097          	auipc	ra,0xffffc
    800056bc:	6ee080e7          	jalr	1774(ra) # 80001da6 <myproc>
    800056c0:	fec42783          	lw	a5,-20(s0)
    800056c4:	07e9                	addi	a5,a5,26
    800056c6:	078e                	slli	a5,a5,0x3
    800056c8:	97aa                	add	a5,a5,a0
    800056ca:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800056ce:	fe043503          	ld	a0,-32(s0)
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	2a2080e7          	jalr	674(ra) # 80004974 <fileclose>
  return 0;
    800056da:	4781                	li	a5,0
}
    800056dc:	853e                	mv	a0,a5
    800056de:	60e2                	ld	ra,24(sp)
    800056e0:	6442                	ld	s0,16(sp)
    800056e2:	6105                	addi	sp,sp,32
    800056e4:	8082                	ret

00000000800056e6 <sys_fstat>:
{
    800056e6:	1101                	addi	sp,sp,-32
    800056e8:	ec06                	sd	ra,24(sp)
    800056ea:	e822                	sd	s0,16(sp)
    800056ec:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056ee:	fe840613          	addi	a2,s0,-24
    800056f2:	4581                	li	a1,0
    800056f4:	4501                	li	a0,0
    800056f6:	00000097          	auipc	ra,0x0
    800056fa:	c78080e7          	jalr	-904(ra) # 8000536e <argfd>
    return -1;
    800056fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005700:	02054563          	bltz	a0,8000572a <sys_fstat+0x44>
    80005704:	fe040593          	addi	a1,s0,-32
    80005708:	4505                	li	a0,1
    8000570a:	ffffe097          	auipc	ra,0xffffe
    8000570e:	876080e7          	jalr	-1930(ra) # 80002f80 <argaddr>
    return -1;
    80005712:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005714:	00054b63          	bltz	a0,8000572a <sys_fstat+0x44>
  return filestat(f, st);
    80005718:	fe043583          	ld	a1,-32(s0)
    8000571c:	fe843503          	ld	a0,-24(s0)
    80005720:	fffff097          	auipc	ra,0xfffff
    80005724:	31c080e7          	jalr	796(ra) # 80004a3c <filestat>
    80005728:	87aa                	mv	a5,a0
}
    8000572a:	853e                	mv	a0,a5
    8000572c:	60e2                	ld	ra,24(sp)
    8000572e:	6442                	ld	s0,16(sp)
    80005730:	6105                	addi	sp,sp,32
    80005732:	8082                	ret

0000000080005734 <sys_link>:
{
    80005734:	7169                	addi	sp,sp,-304
    80005736:	f606                	sd	ra,296(sp)
    80005738:	f222                	sd	s0,288(sp)
    8000573a:	ee26                	sd	s1,280(sp)
    8000573c:	ea4a                	sd	s2,272(sp)
    8000573e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005740:	08000613          	li	a2,128
    80005744:	ed040593          	addi	a1,s0,-304
    80005748:	4501                	li	a0,0
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	858080e7          	jalr	-1960(ra) # 80002fa2 <argstr>
    return -1;
    80005752:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005754:	10054e63          	bltz	a0,80005870 <sys_link+0x13c>
    80005758:	08000613          	li	a2,128
    8000575c:	f5040593          	addi	a1,s0,-176
    80005760:	4505                	li	a0,1
    80005762:	ffffe097          	auipc	ra,0xffffe
    80005766:	840080e7          	jalr	-1984(ra) # 80002fa2 <argstr>
    return -1;
    8000576a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000576c:	10054263          	bltz	a0,80005870 <sys_link+0x13c>
  begin_op();
    80005770:	fffff097          	auipc	ra,0xfffff
    80005774:	d30080e7          	jalr	-720(ra) # 800044a0 <begin_op>
  if((ip = namei(old)) == 0){
    80005778:	ed040513          	addi	a0,s0,-304
    8000577c:	fffff097          	auipc	ra,0xfffff
    80005780:	b08080e7          	jalr	-1272(ra) # 80004284 <namei>
    80005784:	84aa                	mv	s1,a0
    80005786:	c551                	beqz	a0,80005812 <sys_link+0xde>
  ilock(ip);
    80005788:	ffffe097          	auipc	ra,0xffffe
    8000578c:	346080e7          	jalr	838(ra) # 80003ace <ilock>
  if(ip->type == T_DIR){
    80005790:	04449703          	lh	a4,68(s1)
    80005794:	4785                	li	a5,1
    80005796:	08f70463          	beq	a4,a5,8000581e <sys_link+0xea>
  ip->nlink++;
    8000579a:	04a4d783          	lhu	a5,74(s1)
    8000579e:	2785                	addiw	a5,a5,1
    800057a0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057a4:	8526                	mv	a0,s1
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	25e080e7          	jalr	606(ra) # 80003a04 <iupdate>
  iunlock(ip);
    800057ae:	8526                	mv	a0,s1
    800057b0:	ffffe097          	auipc	ra,0xffffe
    800057b4:	3e0080e7          	jalr	992(ra) # 80003b90 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800057b8:	fd040593          	addi	a1,s0,-48
    800057bc:	f5040513          	addi	a0,s0,-176
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	ae2080e7          	jalr	-1310(ra) # 800042a2 <nameiparent>
    800057c8:	892a                	mv	s2,a0
    800057ca:	c935                	beqz	a0,8000583e <sys_link+0x10a>
  ilock(dp);
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	302080e7          	jalr	770(ra) # 80003ace <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057d4:	00092703          	lw	a4,0(s2)
    800057d8:	409c                	lw	a5,0(s1)
    800057da:	04f71d63          	bne	a4,a5,80005834 <sys_link+0x100>
    800057de:	40d0                	lw	a2,4(s1)
    800057e0:	fd040593          	addi	a1,s0,-48
    800057e4:	854a                	mv	a0,s2
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	9dc080e7          	jalr	-1572(ra) # 800041c2 <dirlink>
    800057ee:	04054363          	bltz	a0,80005834 <sys_link+0x100>
  iunlockput(dp);
    800057f2:	854a                	mv	a0,s2
    800057f4:	ffffe097          	auipc	ra,0xffffe
    800057f8:	53c080e7          	jalr	1340(ra) # 80003d30 <iunlockput>
  iput(ip);
    800057fc:	8526                	mv	a0,s1
    800057fe:	ffffe097          	auipc	ra,0xffffe
    80005802:	48a080e7          	jalr	1162(ra) # 80003c88 <iput>
  end_op();
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	d1a080e7          	jalr	-742(ra) # 80004520 <end_op>
  return 0;
    8000580e:	4781                	li	a5,0
    80005810:	a085                	j	80005870 <sys_link+0x13c>
    end_op();
    80005812:	fffff097          	auipc	ra,0xfffff
    80005816:	d0e080e7          	jalr	-754(ra) # 80004520 <end_op>
    return -1;
    8000581a:	57fd                	li	a5,-1
    8000581c:	a891                	j	80005870 <sys_link+0x13c>
    iunlockput(ip);
    8000581e:	8526                	mv	a0,s1
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	510080e7          	jalr	1296(ra) # 80003d30 <iunlockput>
    end_op();
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	cf8080e7          	jalr	-776(ra) # 80004520 <end_op>
    return -1;
    80005830:	57fd                	li	a5,-1
    80005832:	a83d                	j	80005870 <sys_link+0x13c>
    iunlockput(dp);
    80005834:	854a                	mv	a0,s2
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	4fa080e7          	jalr	1274(ra) # 80003d30 <iunlockput>
  ilock(ip);
    8000583e:	8526                	mv	a0,s1
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	28e080e7          	jalr	654(ra) # 80003ace <ilock>
  ip->nlink--;
    80005848:	04a4d783          	lhu	a5,74(s1)
    8000584c:	37fd                	addiw	a5,a5,-1
    8000584e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005852:	8526                	mv	a0,s1
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	1b0080e7          	jalr	432(ra) # 80003a04 <iupdate>
  iunlockput(ip);
    8000585c:	8526                	mv	a0,s1
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	4d2080e7          	jalr	1234(ra) # 80003d30 <iunlockput>
  end_op();
    80005866:	fffff097          	auipc	ra,0xfffff
    8000586a:	cba080e7          	jalr	-838(ra) # 80004520 <end_op>
  return -1;
    8000586e:	57fd                	li	a5,-1
}
    80005870:	853e                	mv	a0,a5
    80005872:	70b2                	ld	ra,296(sp)
    80005874:	7412                	ld	s0,288(sp)
    80005876:	64f2                	ld	s1,280(sp)
    80005878:	6952                	ld	s2,272(sp)
    8000587a:	6155                	addi	sp,sp,304
    8000587c:	8082                	ret

000000008000587e <sys_unlink>:
{
    8000587e:	7151                	addi	sp,sp,-240
    80005880:	f586                	sd	ra,232(sp)
    80005882:	f1a2                	sd	s0,224(sp)
    80005884:	eda6                	sd	s1,216(sp)
    80005886:	e9ca                	sd	s2,208(sp)
    80005888:	e5ce                	sd	s3,200(sp)
    8000588a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000588c:	08000613          	li	a2,128
    80005890:	f3040593          	addi	a1,s0,-208
    80005894:	4501                	li	a0,0
    80005896:	ffffd097          	auipc	ra,0xffffd
    8000589a:	70c080e7          	jalr	1804(ra) # 80002fa2 <argstr>
    8000589e:	18054163          	bltz	a0,80005a20 <sys_unlink+0x1a2>
  begin_op();
    800058a2:	fffff097          	auipc	ra,0xfffff
    800058a6:	bfe080e7          	jalr	-1026(ra) # 800044a0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800058aa:	fb040593          	addi	a1,s0,-80
    800058ae:	f3040513          	addi	a0,s0,-208
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	9f0080e7          	jalr	-1552(ra) # 800042a2 <nameiparent>
    800058ba:	84aa                	mv	s1,a0
    800058bc:	c979                	beqz	a0,80005992 <sys_unlink+0x114>
  ilock(dp);
    800058be:	ffffe097          	auipc	ra,0xffffe
    800058c2:	210080e7          	jalr	528(ra) # 80003ace <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058c6:	00003597          	auipc	a1,0x3
    800058ca:	e1a58593          	addi	a1,a1,-486 # 800086e0 <syscalls+0x2c0>
    800058ce:	fb040513          	addi	a0,s0,-80
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	6c6080e7          	jalr	1734(ra) # 80003f98 <namecmp>
    800058da:	14050a63          	beqz	a0,80005a2e <sys_unlink+0x1b0>
    800058de:	00003597          	auipc	a1,0x3
    800058e2:	e0a58593          	addi	a1,a1,-502 # 800086e8 <syscalls+0x2c8>
    800058e6:	fb040513          	addi	a0,s0,-80
    800058ea:	ffffe097          	auipc	ra,0xffffe
    800058ee:	6ae080e7          	jalr	1710(ra) # 80003f98 <namecmp>
    800058f2:	12050e63          	beqz	a0,80005a2e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800058f6:	f2c40613          	addi	a2,s0,-212
    800058fa:	fb040593          	addi	a1,s0,-80
    800058fe:	8526                	mv	a0,s1
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	6b2080e7          	jalr	1714(ra) # 80003fb2 <dirlookup>
    80005908:	892a                	mv	s2,a0
    8000590a:	12050263          	beqz	a0,80005a2e <sys_unlink+0x1b0>
  ilock(ip);
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	1c0080e7          	jalr	448(ra) # 80003ace <ilock>
  if(ip->nlink < 1)
    80005916:	04a91783          	lh	a5,74(s2)
    8000591a:	08f05263          	blez	a5,8000599e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000591e:	04491703          	lh	a4,68(s2)
    80005922:	4785                	li	a5,1
    80005924:	08f70563          	beq	a4,a5,800059ae <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005928:	4641                	li	a2,16
    8000592a:	4581                	li	a1,0
    8000592c:	fc040513          	addi	a0,s0,-64
    80005930:	ffffb097          	auipc	ra,0xffffb
    80005934:	38e080e7          	jalr	910(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005938:	4741                	li	a4,16
    8000593a:	f2c42683          	lw	a3,-212(s0)
    8000593e:	fc040613          	addi	a2,s0,-64
    80005942:	4581                	li	a1,0
    80005944:	8526                	mv	a0,s1
    80005946:	ffffe097          	auipc	ra,0xffffe
    8000594a:	534080e7          	jalr	1332(ra) # 80003e7a <writei>
    8000594e:	47c1                	li	a5,16
    80005950:	0af51563          	bne	a0,a5,800059fa <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005954:	04491703          	lh	a4,68(s2)
    80005958:	4785                	li	a5,1
    8000595a:	0af70863          	beq	a4,a5,80005a0a <sys_unlink+0x18c>
  iunlockput(dp);
    8000595e:	8526                	mv	a0,s1
    80005960:	ffffe097          	auipc	ra,0xffffe
    80005964:	3d0080e7          	jalr	976(ra) # 80003d30 <iunlockput>
  ip->nlink--;
    80005968:	04a95783          	lhu	a5,74(s2)
    8000596c:	37fd                	addiw	a5,a5,-1
    8000596e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005972:	854a                	mv	a0,s2
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	090080e7          	jalr	144(ra) # 80003a04 <iupdate>
  iunlockput(ip);
    8000597c:	854a                	mv	a0,s2
    8000597e:	ffffe097          	auipc	ra,0xffffe
    80005982:	3b2080e7          	jalr	946(ra) # 80003d30 <iunlockput>
  end_op();
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	b9a080e7          	jalr	-1126(ra) # 80004520 <end_op>
  return 0;
    8000598e:	4501                	li	a0,0
    80005990:	a84d                	j	80005a42 <sys_unlink+0x1c4>
    end_op();
    80005992:	fffff097          	auipc	ra,0xfffff
    80005996:	b8e080e7          	jalr	-1138(ra) # 80004520 <end_op>
    return -1;
    8000599a:	557d                	li	a0,-1
    8000599c:	a05d                	j	80005a42 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000599e:	00003517          	auipc	a0,0x3
    800059a2:	d7250513          	addi	a0,a0,-654 # 80008710 <syscalls+0x2f0>
    800059a6:	ffffb097          	auipc	ra,0xffffb
    800059aa:	b84080e7          	jalr	-1148(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059ae:	04c92703          	lw	a4,76(s2)
    800059b2:	02000793          	li	a5,32
    800059b6:	f6e7f9e3          	bgeu	a5,a4,80005928 <sys_unlink+0xaa>
    800059ba:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059be:	4741                	li	a4,16
    800059c0:	86ce                	mv	a3,s3
    800059c2:	f1840613          	addi	a2,s0,-232
    800059c6:	4581                	li	a1,0
    800059c8:	854a                	mv	a0,s2
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	3b8080e7          	jalr	952(ra) # 80003d82 <readi>
    800059d2:	47c1                	li	a5,16
    800059d4:	00f51b63          	bne	a0,a5,800059ea <sys_unlink+0x16c>
    if(de.inum != 0)
    800059d8:	f1845783          	lhu	a5,-232(s0)
    800059dc:	e7a1                	bnez	a5,80005a24 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059de:	29c1                	addiw	s3,s3,16
    800059e0:	04c92783          	lw	a5,76(s2)
    800059e4:	fcf9ede3          	bltu	s3,a5,800059be <sys_unlink+0x140>
    800059e8:	b781                	j	80005928 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800059ea:	00003517          	auipc	a0,0x3
    800059ee:	d3e50513          	addi	a0,a0,-706 # 80008728 <syscalls+0x308>
    800059f2:	ffffb097          	auipc	ra,0xffffb
    800059f6:	b38080e7          	jalr	-1224(ra) # 8000052a <panic>
    panic("unlink: writei");
    800059fa:	00003517          	auipc	a0,0x3
    800059fe:	d4650513          	addi	a0,a0,-698 # 80008740 <syscalls+0x320>
    80005a02:	ffffb097          	auipc	ra,0xffffb
    80005a06:	b28080e7          	jalr	-1240(ra) # 8000052a <panic>
    dp->nlink--;
    80005a0a:	04a4d783          	lhu	a5,74(s1)
    80005a0e:	37fd                	addiw	a5,a5,-1
    80005a10:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a14:	8526                	mv	a0,s1
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	fee080e7          	jalr	-18(ra) # 80003a04 <iupdate>
    80005a1e:	b781                	j	8000595e <sys_unlink+0xe0>
    return -1;
    80005a20:	557d                	li	a0,-1
    80005a22:	a005                	j	80005a42 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a24:	854a                	mv	a0,s2
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	30a080e7          	jalr	778(ra) # 80003d30 <iunlockput>
  iunlockput(dp);
    80005a2e:	8526                	mv	a0,s1
    80005a30:	ffffe097          	auipc	ra,0xffffe
    80005a34:	300080e7          	jalr	768(ra) # 80003d30 <iunlockput>
  end_op();
    80005a38:	fffff097          	auipc	ra,0xfffff
    80005a3c:	ae8080e7          	jalr	-1304(ra) # 80004520 <end_op>
  return -1;
    80005a40:	557d                	li	a0,-1
}
    80005a42:	70ae                	ld	ra,232(sp)
    80005a44:	740e                	ld	s0,224(sp)
    80005a46:	64ee                	ld	s1,216(sp)
    80005a48:	694e                	ld	s2,208(sp)
    80005a4a:	69ae                	ld	s3,200(sp)
    80005a4c:	616d                	addi	sp,sp,240
    80005a4e:	8082                	ret

0000000080005a50 <sys_open>:

uint64
sys_open(void)
{
    80005a50:	7131                	addi	sp,sp,-192
    80005a52:	fd06                	sd	ra,184(sp)
    80005a54:	f922                	sd	s0,176(sp)
    80005a56:	f526                	sd	s1,168(sp)
    80005a58:	f14a                	sd	s2,160(sp)
    80005a5a:	ed4e                	sd	s3,152(sp)
    80005a5c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a5e:	08000613          	li	a2,128
    80005a62:	f5040593          	addi	a1,s0,-176
    80005a66:	4501                	li	a0,0
    80005a68:	ffffd097          	auipc	ra,0xffffd
    80005a6c:	53a080e7          	jalr	1338(ra) # 80002fa2 <argstr>
    return -1;
    80005a70:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a72:	0c054163          	bltz	a0,80005b34 <sys_open+0xe4>
    80005a76:	f4c40593          	addi	a1,s0,-180
    80005a7a:	4505                	li	a0,1
    80005a7c:	ffffd097          	auipc	ra,0xffffd
    80005a80:	4e2080e7          	jalr	1250(ra) # 80002f5e <argint>
    80005a84:	0a054863          	bltz	a0,80005b34 <sys_open+0xe4>

  begin_op();
    80005a88:	fffff097          	auipc	ra,0xfffff
    80005a8c:	a18080e7          	jalr	-1512(ra) # 800044a0 <begin_op>

  if(omode & O_CREATE){
    80005a90:	f4c42783          	lw	a5,-180(s0)
    80005a94:	2007f793          	andi	a5,a5,512
    80005a98:	cbdd                	beqz	a5,80005b4e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a9a:	4681                	li	a3,0
    80005a9c:	4601                	li	a2,0
    80005a9e:	4589                	li	a1,2
    80005aa0:	f5040513          	addi	a0,s0,-176
    80005aa4:	00000097          	auipc	ra,0x0
    80005aa8:	974080e7          	jalr	-1676(ra) # 80005418 <create>
    80005aac:	892a                	mv	s2,a0
    if(ip == 0){
    80005aae:	c959                	beqz	a0,80005b44 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ab0:	04491703          	lh	a4,68(s2)
    80005ab4:	478d                	li	a5,3
    80005ab6:	00f71763          	bne	a4,a5,80005ac4 <sys_open+0x74>
    80005aba:	04695703          	lhu	a4,70(s2)
    80005abe:	47a5                	li	a5,9
    80005ac0:	0ce7ec63          	bltu	a5,a4,80005b98 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ac4:	fffff097          	auipc	ra,0xfffff
    80005ac8:	df4080e7          	jalr	-524(ra) # 800048b8 <filealloc>
    80005acc:	89aa                	mv	s3,a0
    80005ace:	10050263          	beqz	a0,80005bd2 <sys_open+0x182>
    80005ad2:	00000097          	auipc	ra,0x0
    80005ad6:	904080e7          	jalr	-1788(ra) # 800053d6 <fdalloc>
    80005ada:	84aa                	mv	s1,a0
    80005adc:	0e054663          	bltz	a0,80005bc8 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ae0:	04491703          	lh	a4,68(s2)
    80005ae4:	478d                	li	a5,3
    80005ae6:	0cf70463          	beq	a4,a5,80005bae <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005aea:	4789                	li	a5,2
    80005aec:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005af0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005af4:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005af8:	f4c42783          	lw	a5,-180(s0)
    80005afc:	0017c713          	xori	a4,a5,1
    80005b00:	8b05                	andi	a4,a4,1
    80005b02:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b06:	0037f713          	andi	a4,a5,3
    80005b0a:	00e03733          	snez	a4,a4
    80005b0e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b12:	4007f793          	andi	a5,a5,1024
    80005b16:	c791                	beqz	a5,80005b22 <sys_open+0xd2>
    80005b18:	04491703          	lh	a4,68(s2)
    80005b1c:	4789                	li	a5,2
    80005b1e:	08f70f63          	beq	a4,a5,80005bbc <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b22:	854a                	mv	a0,s2
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	06c080e7          	jalr	108(ra) # 80003b90 <iunlock>
  end_op();
    80005b2c:	fffff097          	auipc	ra,0xfffff
    80005b30:	9f4080e7          	jalr	-1548(ra) # 80004520 <end_op>

  return fd;
}
    80005b34:	8526                	mv	a0,s1
    80005b36:	70ea                	ld	ra,184(sp)
    80005b38:	744a                	ld	s0,176(sp)
    80005b3a:	74aa                	ld	s1,168(sp)
    80005b3c:	790a                	ld	s2,160(sp)
    80005b3e:	69ea                	ld	s3,152(sp)
    80005b40:	6129                	addi	sp,sp,192
    80005b42:	8082                	ret
      end_op();
    80005b44:	fffff097          	auipc	ra,0xfffff
    80005b48:	9dc080e7          	jalr	-1572(ra) # 80004520 <end_op>
      return -1;
    80005b4c:	b7e5                	j	80005b34 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005b4e:	f5040513          	addi	a0,s0,-176
    80005b52:	ffffe097          	auipc	ra,0xffffe
    80005b56:	732080e7          	jalr	1842(ra) # 80004284 <namei>
    80005b5a:	892a                	mv	s2,a0
    80005b5c:	c905                	beqz	a0,80005b8c <sys_open+0x13c>
    ilock(ip);
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	f70080e7          	jalr	-144(ra) # 80003ace <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b66:	04491703          	lh	a4,68(s2)
    80005b6a:	4785                	li	a5,1
    80005b6c:	f4f712e3          	bne	a4,a5,80005ab0 <sys_open+0x60>
    80005b70:	f4c42783          	lw	a5,-180(s0)
    80005b74:	dba1                	beqz	a5,80005ac4 <sys_open+0x74>
      iunlockput(ip);
    80005b76:	854a                	mv	a0,s2
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	1b8080e7          	jalr	440(ra) # 80003d30 <iunlockput>
      end_op();
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	9a0080e7          	jalr	-1632(ra) # 80004520 <end_op>
      return -1;
    80005b88:	54fd                	li	s1,-1
    80005b8a:	b76d                	j	80005b34 <sys_open+0xe4>
      end_op();
    80005b8c:	fffff097          	auipc	ra,0xfffff
    80005b90:	994080e7          	jalr	-1644(ra) # 80004520 <end_op>
      return -1;
    80005b94:	54fd                	li	s1,-1
    80005b96:	bf79                	j	80005b34 <sys_open+0xe4>
    iunlockput(ip);
    80005b98:	854a                	mv	a0,s2
    80005b9a:	ffffe097          	auipc	ra,0xffffe
    80005b9e:	196080e7          	jalr	406(ra) # 80003d30 <iunlockput>
    end_op();
    80005ba2:	fffff097          	auipc	ra,0xfffff
    80005ba6:	97e080e7          	jalr	-1666(ra) # 80004520 <end_op>
    return -1;
    80005baa:	54fd                	li	s1,-1
    80005bac:	b761                	j	80005b34 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005bae:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005bb2:	04691783          	lh	a5,70(s2)
    80005bb6:	02f99223          	sh	a5,36(s3)
    80005bba:	bf2d                	j	80005af4 <sys_open+0xa4>
    itrunc(ip);
    80005bbc:	854a                	mv	a0,s2
    80005bbe:	ffffe097          	auipc	ra,0xffffe
    80005bc2:	01e080e7          	jalr	30(ra) # 80003bdc <itrunc>
    80005bc6:	bfb1                	j	80005b22 <sys_open+0xd2>
      fileclose(f);
    80005bc8:	854e                	mv	a0,s3
    80005bca:	fffff097          	auipc	ra,0xfffff
    80005bce:	daa080e7          	jalr	-598(ra) # 80004974 <fileclose>
    iunlockput(ip);
    80005bd2:	854a                	mv	a0,s2
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	15c080e7          	jalr	348(ra) # 80003d30 <iunlockput>
    end_op();
    80005bdc:	fffff097          	auipc	ra,0xfffff
    80005be0:	944080e7          	jalr	-1724(ra) # 80004520 <end_op>
    return -1;
    80005be4:	54fd                	li	s1,-1
    80005be6:	b7b9                	j	80005b34 <sys_open+0xe4>

0000000080005be8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005be8:	7175                	addi	sp,sp,-144
    80005bea:	e506                	sd	ra,136(sp)
    80005bec:	e122                	sd	s0,128(sp)
    80005bee:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005bf0:	fffff097          	auipc	ra,0xfffff
    80005bf4:	8b0080e7          	jalr	-1872(ra) # 800044a0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005bf8:	08000613          	li	a2,128
    80005bfc:	f7040593          	addi	a1,s0,-144
    80005c00:	4501                	li	a0,0
    80005c02:	ffffd097          	auipc	ra,0xffffd
    80005c06:	3a0080e7          	jalr	928(ra) # 80002fa2 <argstr>
    80005c0a:	02054963          	bltz	a0,80005c3c <sys_mkdir+0x54>
    80005c0e:	4681                	li	a3,0
    80005c10:	4601                	li	a2,0
    80005c12:	4585                	li	a1,1
    80005c14:	f7040513          	addi	a0,s0,-144
    80005c18:	00000097          	auipc	ra,0x0
    80005c1c:	800080e7          	jalr	-2048(ra) # 80005418 <create>
    80005c20:	cd11                	beqz	a0,80005c3c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c22:	ffffe097          	auipc	ra,0xffffe
    80005c26:	10e080e7          	jalr	270(ra) # 80003d30 <iunlockput>
  end_op();
    80005c2a:	fffff097          	auipc	ra,0xfffff
    80005c2e:	8f6080e7          	jalr	-1802(ra) # 80004520 <end_op>
  return 0;
    80005c32:	4501                	li	a0,0
}
    80005c34:	60aa                	ld	ra,136(sp)
    80005c36:	640a                	ld	s0,128(sp)
    80005c38:	6149                	addi	sp,sp,144
    80005c3a:	8082                	ret
    end_op();
    80005c3c:	fffff097          	auipc	ra,0xfffff
    80005c40:	8e4080e7          	jalr	-1820(ra) # 80004520 <end_op>
    return -1;
    80005c44:	557d                	li	a0,-1
    80005c46:	b7fd                	j	80005c34 <sys_mkdir+0x4c>

0000000080005c48 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c48:	7135                	addi	sp,sp,-160
    80005c4a:	ed06                	sd	ra,152(sp)
    80005c4c:	e922                	sd	s0,144(sp)
    80005c4e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c50:	fffff097          	auipc	ra,0xfffff
    80005c54:	850080e7          	jalr	-1968(ra) # 800044a0 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c58:	08000613          	li	a2,128
    80005c5c:	f7040593          	addi	a1,s0,-144
    80005c60:	4501                	li	a0,0
    80005c62:	ffffd097          	auipc	ra,0xffffd
    80005c66:	340080e7          	jalr	832(ra) # 80002fa2 <argstr>
    80005c6a:	04054a63          	bltz	a0,80005cbe <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005c6e:	f6c40593          	addi	a1,s0,-148
    80005c72:	4505                	li	a0,1
    80005c74:	ffffd097          	auipc	ra,0xffffd
    80005c78:	2ea080e7          	jalr	746(ra) # 80002f5e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c7c:	04054163          	bltz	a0,80005cbe <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005c80:	f6840593          	addi	a1,s0,-152
    80005c84:	4509                	li	a0,2
    80005c86:	ffffd097          	auipc	ra,0xffffd
    80005c8a:	2d8080e7          	jalr	728(ra) # 80002f5e <argint>
     argint(1, &major) < 0 ||
    80005c8e:	02054863          	bltz	a0,80005cbe <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c92:	f6841683          	lh	a3,-152(s0)
    80005c96:	f6c41603          	lh	a2,-148(s0)
    80005c9a:	458d                	li	a1,3
    80005c9c:	f7040513          	addi	a0,s0,-144
    80005ca0:	fffff097          	auipc	ra,0xfffff
    80005ca4:	778080e7          	jalr	1912(ra) # 80005418 <create>
     argint(2, &minor) < 0 ||
    80005ca8:	c919                	beqz	a0,80005cbe <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005caa:	ffffe097          	auipc	ra,0xffffe
    80005cae:	086080e7          	jalr	134(ra) # 80003d30 <iunlockput>
  end_op();
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	86e080e7          	jalr	-1938(ra) # 80004520 <end_op>
  return 0;
    80005cba:	4501                	li	a0,0
    80005cbc:	a031                	j	80005cc8 <sys_mknod+0x80>
    end_op();
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	862080e7          	jalr	-1950(ra) # 80004520 <end_op>
    return -1;
    80005cc6:	557d                	li	a0,-1
}
    80005cc8:	60ea                	ld	ra,152(sp)
    80005cca:	644a                	ld	s0,144(sp)
    80005ccc:	610d                	addi	sp,sp,160
    80005cce:	8082                	ret

0000000080005cd0 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005cd0:	7135                	addi	sp,sp,-160
    80005cd2:	ed06                	sd	ra,152(sp)
    80005cd4:	e922                	sd	s0,144(sp)
    80005cd6:	e526                	sd	s1,136(sp)
    80005cd8:	e14a                	sd	s2,128(sp)
    80005cda:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005cdc:	ffffc097          	auipc	ra,0xffffc
    80005ce0:	0ca080e7          	jalr	202(ra) # 80001da6 <myproc>
    80005ce4:	892a                	mv	s2,a0
  
  begin_op();
    80005ce6:	ffffe097          	auipc	ra,0xffffe
    80005cea:	7ba080e7          	jalr	1978(ra) # 800044a0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005cee:	08000613          	li	a2,128
    80005cf2:	f6040593          	addi	a1,s0,-160
    80005cf6:	4501                	li	a0,0
    80005cf8:	ffffd097          	auipc	ra,0xffffd
    80005cfc:	2aa080e7          	jalr	682(ra) # 80002fa2 <argstr>
    80005d00:	04054b63          	bltz	a0,80005d56 <sys_chdir+0x86>
    80005d04:	f6040513          	addi	a0,s0,-160
    80005d08:	ffffe097          	auipc	ra,0xffffe
    80005d0c:	57c080e7          	jalr	1404(ra) # 80004284 <namei>
    80005d10:	84aa                	mv	s1,a0
    80005d12:	c131                	beqz	a0,80005d56 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d14:	ffffe097          	auipc	ra,0xffffe
    80005d18:	dba080e7          	jalr	-582(ra) # 80003ace <ilock>
  if(ip->type != T_DIR){
    80005d1c:	04449703          	lh	a4,68(s1)
    80005d20:	4785                	li	a5,1
    80005d22:	04f71063          	bne	a4,a5,80005d62 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d26:	8526                	mv	a0,s1
    80005d28:	ffffe097          	auipc	ra,0xffffe
    80005d2c:	e68080e7          	jalr	-408(ra) # 80003b90 <iunlock>
  iput(p->cwd);
    80005d30:	15093503          	ld	a0,336(s2)
    80005d34:	ffffe097          	auipc	ra,0xffffe
    80005d38:	f54080e7          	jalr	-172(ra) # 80003c88 <iput>
  end_op();
    80005d3c:	ffffe097          	auipc	ra,0xffffe
    80005d40:	7e4080e7          	jalr	2020(ra) # 80004520 <end_op>
  p->cwd = ip;
    80005d44:	14993823          	sd	s1,336(s2)
  return 0;
    80005d48:	4501                	li	a0,0
}
    80005d4a:	60ea                	ld	ra,152(sp)
    80005d4c:	644a                	ld	s0,144(sp)
    80005d4e:	64aa                	ld	s1,136(sp)
    80005d50:	690a                	ld	s2,128(sp)
    80005d52:	610d                	addi	sp,sp,160
    80005d54:	8082                	ret
    end_op();
    80005d56:	ffffe097          	auipc	ra,0xffffe
    80005d5a:	7ca080e7          	jalr	1994(ra) # 80004520 <end_op>
    return -1;
    80005d5e:	557d                	li	a0,-1
    80005d60:	b7ed                	j	80005d4a <sys_chdir+0x7a>
    iunlockput(ip);
    80005d62:	8526                	mv	a0,s1
    80005d64:	ffffe097          	auipc	ra,0xffffe
    80005d68:	fcc080e7          	jalr	-52(ra) # 80003d30 <iunlockput>
    end_op();
    80005d6c:	ffffe097          	auipc	ra,0xffffe
    80005d70:	7b4080e7          	jalr	1972(ra) # 80004520 <end_op>
    return -1;
    80005d74:	557d                	li	a0,-1
    80005d76:	bfd1                	j	80005d4a <sys_chdir+0x7a>

0000000080005d78 <sys_exec>:

uint64
sys_exec(void)
{
    80005d78:	7145                	addi	sp,sp,-464
    80005d7a:	e786                	sd	ra,456(sp)
    80005d7c:	e3a2                	sd	s0,448(sp)
    80005d7e:	ff26                	sd	s1,440(sp)
    80005d80:	fb4a                	sd	s2,432(sp)
    80005d82:	f74e                	sd	s3,424(sp)
    80005d84:	f352                	sd	s4,416(sp)
    80005d86:	ef56                	sd	s5,408(sp)
    80005d88:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d8a:	08000613          	li	a2,128
    80005d8e:	f4040593          	addi	a1,s0,-192
    80005d92:	4501                	li	a0,0
    80005d94:	ffffd097          	auipc	ra,0xffffd
    80005d98:	20e080e7          	jalr	526(ra) # 80002fa2 <argstr>
    return -1;
    80005d9c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d9e:	0c054a63          	bltz	a0,80005e72 <sys_exec+0xfa>
    80005da2:	e3840593          	addi	a1,s0,-456
    80005da6:	4505                	li	a0,1
    80005da8:	ffffd097          	auipc	ra,0xffffd
    80005dac:	1d8080e7          	jalr	472(ra) # 80002f80 <argaddr>
    80005db0:	0c054163          	bltz	a0,80005e72 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005db4:	10000613          	li	a2,256
    80005db8:	4581                	li	a1,0
    80005dba:	e4040513          	addi	a0,s0,-448
    80005dbe:	ffffb097          	auipc	ra,0xffffb
    80005dc2:	f00080e7          	jalr	-256(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005dc6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005dca:	89a6                	mv	s3,s1
    80005dcc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005dce:	02000a13          	li	s4,32
    80005dd2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005dd6:	00391793          	slli	a5,s2,0x3
    80005dda:	e3040593          	addi	a1,s0,-464
    80005dde:	e3843503          	ld	a0,-456(s0)
    80005de2:	953e                	add	a0,a0,a5
    80005de4:	ffffd097          	auipc	ra,0xffffd
    80005de8:	0e0080e7          	jalr	224(ra) # 80002ec4 <fetchaddr>
    80005dec:	02054a63          	bltz	a0,80005e20 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005df0:	e3043783          	ld	a5,-464(s0)
    80005df4:	c3b9                	beqz	a5,80005e3a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005df6:	ffffb097          	auipc	ra,0xffffb
    80005dfa:	cdc080e7          	jalr	-804(ra) # 80000ad2 <kalloc>
    80005dfe:	85aa                	mv	a1,a0
    80005e00:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e04:	cd11                	beqz	a0,80005e20 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e06:	6605                	lui	a2,0x1
    80005e08:	e3043503          	ld	a0,-464(s0)
    80005e0c:	ffffd097          	auipc	ra,0xffffd
    80005e10:	10a080e7          	jalr	266(ra) # 80002f16 <fetchstr>
    80005e14:	00054663          	bltz	a0,80005e20 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005e18:	0905                	addi	s2,s2,1
    80005e1a:	09a1                	addi	s3,s3,8
    80005e1c:	fb491be3          	bne	s2,s4,80005dd2 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e20:	10048913          	addi	s2,s1,256
    80005e24:	6088                	ld	a0,0(s1)
    80005e26:	c529                	beqz	a0,80005e70 <sys_exec+0xf8>
    kfree(argv[i]);
    80005e28:	ffffb097          	auipc	ra,0xffffb
    80005e2c:	bae080e7          	jalr	-1106(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e30:	04a1                	addi	s1,s1,8
    80005e32:	ff2499e3          	bne	s1,s2,80005e24 <sys_exec+0xac>
  return -1;
    80005e36:	597d                	li	s2,-1
    80005e38:	a82d                	j	80005e72 <sys_exec+0xfa>
      argv[i] = 0;
    80005e3a:	0a8e                	slli	s5,s5,0x3
    80005e3c:	fc040793          	addi	a5,s0,-64
    80005e40:	9abe                	add	s5,s5,a5
    80005e42:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffcae80>
  int ret = exec(path, argv);
    80005e46:	e4040593          	addi	a1,s0,-448
    80005e4a:	f4040513          	addi	a0,s0,-192
    80005e4e:	fffff097          	auipc	ra,0xfffff
    80005e52:	178080e7          	jalr	376(ra) # 80004fc6 <exec>
    80005e56:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e58:	10048993          	addi	s3,s1,256
    80005e5c:	6088                	ld	a0,0(s1)
    80005e5e:	c911                	beqz	a0,80005e72 <sys_exec+0xfa>
    kfree(argv[i]);
    80005e60:	ffffb097          	auipc	ra,0xffffb
    80005e64:	b76080e7          	jalr	-1162(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e68:	04a1                	addi	s1,s1,8
    80005e6a:	ff3499e3          	bne	s1,s3,80005e5c <sys_exec+0xe4>
    80005e6e:	a011                	j	80005e72 <sys_exec+0xfa>
  return -1;
    80005e70:	597d                	li	s2,-1
}
    80005e72:	854a                	mv	a0,s2
    80005e74:	60be                	ld	ra,456(sp)
    80005e76:	641e                	ld	s0,448(sp)
    80005e78:	74fa                	ld	s1,440(sp)
    80005e7a:	795a                	ld	s2,432(sp)
    80005e7c:	79ba                	ld	s3,424(sp)
    80005e7e:	7a1a                	ld	s4,416(sp)
    80005e80:	6afa                	ld	s5,408(sp)
    80005e82:	6179                	addi	sp,sp,464
    80005e84:	8082                	ret

0000000080005e86 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e86:	7139                	addi	sp,sp,-64
    80005e88:	fc06                	sd	ra,56(sp)
    80005e8a:	f822                	sd	s0,48(sp)
    80005e8c:	f426                	sd	s1,40(sp)
    80005e8e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e90:	ffffc097          	auipc	ra,0xffffc
    80005e94:	f16080e7          	jalr	-234(ra) # 80001da6 <myproc>
    80005e98:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005e9a:	fd840593          	addi	a1,s0,-40
    80005e9e:	4501                	li	a0,0
    80005ea0:	ffffd097          	auipc	ra,0xffffd
    80005ea4:	0e0080e7          	jalr	224(ra) # 80002f80 <argaddr>
    return -1;
    80005ea8:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005eaa:	0e054063          	bltz	a0,80005f8a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005eae:	fc840593          	addi	a1,s0,-56
    80005eb2:	fd040513          	addi	a0,s0,-48
    80005eb6:	fffff097          	auipc	ra,0xfffff
    80005eba:	dee080e7          	jalr	-530(ra) # 80004ca4 <pipealloc>
    return -1;
    80005ebe:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ec0:	0c054563          	bltz	a0,80005f8a <sys_pipe+0x104>
  fd0 = -1;
    80005ec4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ec8:	fd043503          	ld	a0,-48(s0)
    80005ecc:	fffff097          	auipc	ra,0xfffff
    80005ed0:	50a080e7          	jalr	1290(ra) # 800053d6 <fdalloc>
    80005ed4:	fca42223          	sw	a0,-60(s0)
    80005ed8:	08054c63          	bltz	a0,80005f70 <sys_pipe+0xea>
    80005edc:	fc843503          	ld	a0,-56(s0)
    80005ee0:	fffff097          	auipc	ra,0xfffff
    80005ee4:	4f6080e7          	jalr	1270(ra) # 800053d6 <fdalloc>
    80005ee8:	fca42023          	sw	a0,-64(s0)
    80005eec:	06054863          	bltz	a0,80005f5c <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ef0:	4691                	li	a3,4
    80005ef2:	fc440613          	addi	a2,s0,-60
    80005ef6:	fd843583          	ld	a1,-40(s0)
    80005efa:	68a8                	ld	a0,80(s1)
    80005efc:	ffffb097          	auipc	ra,0xffffb
    80005f00:	766080e7          	jalr	1894(ra) # 80001662 <copyout>
    80005f04:	02054063          	bltz	a0,80005f24 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f08:	4691                	li	a3,4
    80005f0a:	fc040613          	addi	a2,s0,-64
    80005f0e:	fd843583          	ld	a1,-40(s0)
    80005f12:	0591                	addi	a1,a1,4
    80005f14:	68a8                	ld	a0,80(s1)
    80005f16:	ffffb097          	auipc	ra,0xffffb
    80005f1a:	74c080e7          	jalr	1868(ra) # 80001662 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f1e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f20:	06055563          	bgez	a0,80005f8a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005f24:	fc442783          	lw	a5,-60(s0)
    80005f28:	07e9                	addi	a5,a5,26
    80005f2a:	078e                	slli	a5,a5,0x3
    80005f2c:	97a6                	add	a5,a5,s1
    80005f2e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f32:	fc042503          	lw	a0,-64(s0)
    80005f36:	0569                	addi	a0,a0,26
    80005f38:	050e                	slli	a0,a0,0x3
    80005f3a:	9526                	add	a0,a0,s1
    80005f3c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f40:	fd043503          	ld	a0,-48(s0)
    80005f44:	fffff097          	auipc	ra,0xfffff
    80005f48:	a30080e7          	jalr	-1488(ra) # 80004974 <fileclose>
    fileclose(wf);
    80005f4c:	fc843503          	ld	a0,-56(s0)
    80005f50:	fffff097          	auipc	ra,0xfffff
    80005f54:	a24080e7          	jalr	-1500(ra) # 80004974 <fileclose>
    return -1;
    80005f58:	57fd                	li	a5,-1
    80005f5a:	a805                	j	80005f8a <sys_pipe+0x104>
    if(fd0 >= 0)
    80005f5c:	fc442783          	lw	a5,-60(s0)
    80005f60:	0007c863          	bltz	a5,80005f70 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005f64:	01a78513          	addi	a0,a5,26
    80005f68:	050e                	slli	a0,a0,0x3
    80005f6a:	9526                	add	a0,a0,s1
    80005f6c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f70:	fd043503          	ld	a0,-48(s0)
    80005f74:	fffff097          	auipc	ra,0xfffff
    80005f78:	a00080e7          	jalr	-1536(ra) # 80004974 <fileclose>
    fileclose(wf);
    80005f7c:	fc843503          	ld	a0,-56(s0)
    80005f80:	fffff097          	auipc	ra,0xfffff
    80005f84:	9f4080e7          	jalr	-1548(ra) # 80004974 <fileclose>
    return -1;
    80005f88:	57fd                	li	a5,-1
}
    80005f8a:	853e                	mv	a0,a5
    80005f8c:	70e2                	ld	ra,56(sp)
    80005f8e:	7442                	ld	s0,48(sp)
    80005f90:	74a2                	ld	s1,40(sp)
    80005f92:	6121                	addi	sp,sp,64
    80005f94:	8082                	ret

0000000080005f96 <sys_mmap>:

uint64
sys_mmap(void)
{
    80005f96:	715d                	addi	sp,sp,-80
    80005f98:	e486                	sd	ra,72(sp)
    80005f9a:	e0a2                	sd	s0,64(sp)
    80005f9c:	fc26                	sd	s1,56(sp)
    80005f9e:	f84a                	sd	s2,48(sp)
    80005fa0:	f44e                	sd	s3,40(sp)
    80005fa2:	0880                	addi	s0,sp,80
  int i;
  uint64 addr;
  int prot, flags, length, offset;
  struct file *f;
  struct proc *p = myproc();
    80005fa4:	ffffc097          	auipc	ra,0xffffc
    80005fa8:	e02080e7          	jalr	-510(ra) # 80001da6 <myproc>
    80005fac:	892a                	mv	s2,a0
  struct vma *a = 0;

  if(argaddr(0, &addr) || argint(1, &length) || argint(2, &prot) ||
    80005fae:	fc840593          	addi	a1,s0,-56
    80005fb2:	4501                	li	a0,0
    80005fb4:	ffffd097          	auipc	ra,0xffffd
    80005fb8:	fcc080e7          	jalr	-52(ra) # 80002f80 <argaddr>
    argint(3, &flags) || argfd(4, 0, &f) < 0 || argint(5, &offset) < 0 )
    return -1;
    80005fbc:	57fd                	li	a5,-1
  if(argaddr(0, &addr) || argint(1, &length) || argint(2, &prot) ||
    80005fbe:	12051263          	bnez	a0,800060e2 <sys_mmap+0x14c>
    80005fc2:	fbc40593          	addi	a1,s0,-68
    80005fc6:	4505                	li	a0,1
    80005fc8:	ffffd097          	auipc	ra,0xffffd
    80005fcc:	f96080e7          	jalr	-106(ra) # 80002f5e <argint>
    return -1;
    80005fd0:	57fd                	li	a5,-1
  if(argaddr(0, &addr) || argint(1, &length) || argint(2, &prot) ||
    80005fd2:	10051863          	bnez	a0,800060e2 <sys_mmap+0x14c>
    80005fd6:	fc440593          	addi	a1,s0,-60
    80005fda:	4509                	li	a0,2
    80005fdc:	ffffd097          	auipc	ra,0xffffd
    80005fe0:	f82080e7          	jalr	-126(ra) # 80002f5e <argint>
    return -1;
    80005fe4:	57fd                	li	a5,-1
  if(argaddr(0, &addr) || argint(1, &length) || argint(2, &prot) ||
    80005fe6:	ed75                	bnez	a0,800060e2 <sys_mmap+0x14c>
    argint(3, &flags) || argfd(4, 0, &f) < 0 || argint(5, &offset) < 0 )
    80005fe8:	fc040593          	addi	a1,s0,-64
    80005fec:	450d                	li	a0,3
    80005fee:	ffffd097          	auipc	ra,0xffffd
    80005ff2:	f70080e7          	jalr	-144(ra) # 80002f5e <argint>
    80005ff6:	84aa                	mv	s1,a0
    return -1;
    80005ff8:	57fd                	li	a5,-1
  if(argaddr(0, &addr) || argint(1, &length) || argint(2, &prot) ||
    80005ffa:	e565                	bnez	a0,800060e2 <sys_mmap+0x14c>
    argint(3, &flags) || argfd(4, 0, &f) < 0 || argint(5, &offset) < 0 )
    80005ffc:	fb040613          	addi	a2,s0,-80
    80006000:	4581                	li	a1,0
    80006002:	4511                	li	a0,4
    80006004:	fffff097          	auipc	ra,0xfffff
    80006008:	36a080e7          	jalr	874(ra) # 8000536e <argfd>
    return -1;
    8000600c:	57fd                	li	a5,-1
    argint(3, &flags) || argfd(4, 0, &f) < 0 || argint(5, &offset) < 0 )
    8000600e:	0c054a63          	bltz	a0,800060e2 <sys_mmap+0x14c>
    80006012:	fb840593          	addi	a1,s0,-72
    80006016:	4515                	li	a0,5
    80006018:	ffffd097          	auipc	ra,0xffffd
    8000601c:	f46080e7          	jalr	-186(ra) # 80002f5e <argint>
    80006020:	0c054963          	bltz	a0,800060f2 <sys_mmap+0x15c>
  
  if((flags & MAP_SHARED) && !f->writable && (prot & PROT_WRITE))
    80006024:	fc042583          	lw	a1,-64(s0)
    80006028:	0015f793          	andi	a5,a1,1
    8000602c:	c791                	beqz	a5,80006038 <sys_mmap+0xa2>
    8000602e:	fb043783          	ld	a5,-80(s0)
    80006032:	0097c783          	lbu	a5,9(a5)
    80006036:	cf91                	beqz	a5,80006052 <sys_mmap+0xbc>
    return -1;

  for(i = 0; i < NVMA; i++){
    80006038:	16890793          	addi	a5,s2,360
{
    8000603c:	873e                	mv	a4,a5
  for(i = 0; i < NVMA; i++){
    8000603e:	4641                	li	a2,16
    if(!p->vmas[i].used){
    80006040:	4314                	lw	a3,0(a4)
    80006042:	ce91                	beqz	a3,8000605e <sys_mmap+0xc8>
  for(i = 0; i < NVMA; i++){
    80006044:	2485                	addiw	s1,s1,1
    80006046:	03870713          	addi	a4,a4,56
    8000604a:	fec49be3          	bne	s1,a2,80006040 <sys_mmap+0xaa>
      a = &p->vmas[i];
      break;
    }
  }

  if(a == 0) return -1;
    8000604e:	57fd                	li	a5,-1
    80006050:	a849                	j	800060e2 <sys_mmap+0x14c>
  if((flags & MAP_SHARED) && !f->writable && (prot & PROT_WRITE))
    80006052:	fc442703          	lw	a4,-60(s0)
    80006056:	8b09                	andi	a4,a4,2
    return -1;
    80006058:	57fd                	li	a5,-1
  if((flags & MAP_SHARED) && !f->writable && (prot & PROT_WRITE))
    8000605a:	df79                	beqz	a4,80006038 <sys_mmap+0xa2>
    8000605c:	a059                	j	800060e2 <sys_mmap+0x14c>
  if(a == 0) return -1;
    8000605e:	4e890613          	addi	a2,s2,1256
    if(!p->vmas[i].used){
    80006062:	4685                	li	a3,1
    80006064:	1682                	slli	a3,a3,0x20
    80006066:	a029                	j	80006070 <sys_mmap+0xda>

  uint64 maxend = VMA_BASE;
  for(i = 0; i < NVMA; i++){
    80006068:	03878793          	addi	a5,a5,56
    8000606c:	00c78963          	beq	a5,a2,8000607e <sys_mmap+0xe8>
    if(p->vmas[i].used && p->vmas[i].end > maxend)
    80006070:	4398                	lw	a4,0(a5)
    80006072:	db7d                	beqz	a4,80006068 <sys_mmap+0xd2>
    80006074:	7b98                	ld	a4,48(a5)
    80006076:	fee6f9e3          	bgeu	a3,a4,80006068 <sys_mmap+0xd2>
    8000607a:	86ba                	mv	a3,a4
    8000607c:	b7f5                	j	80006068 <sys_mmap+0xd2>
      maxend = p->vmas[i].end;
  }
  
  a->used = 1;
    8000607e:	00349993          	slli	s3,s1,0x3
    80006082:	409987b3          	sub	a5,s3,s1
    80006086:	078e                	slli	a5,a5,0x3
    80006088:	97ca                	add	a5,a5,s2
    8000608a:	4705                	li	a4,1
    8000608c:	16e7a423          	sw	a4,360(a5)
  a->start = maxend;
    80006090:	18d7b823          	sd	a3,400(a5)
  a->end = PGROUNDUP(a->start + length);
    80006094:	fbc42703          	lw	a4,-68(s0)
    80006098:	6605                	lui	a2,0x1
    8000609a:	167d                	addi	a2,a2,-1
    8000609c:	9732                	add	a4,a4,a2
    8000609e:	9736                	add	a4,a4,a3
    800060a0:	767d                	lui	a2,0xfffff
    800060a2:	8f71                	and	a4,a4,a2
    800060a4:	18e7bc23          	sd	a4,408(a5)
  a->addr = a->start;
    800060a8:	16d7b823          	sd	a3,368(a5)
  a->length = a->end - a->start;
    800060ac:	9f15                	subw	a4,a4,a3
    800060ae:	16e7ac23          	sw	a4,376(a5)
  a->f = f;
    800060b2:	fb043503          	ld	a0,-80(s0)
    800060b6:	18a7b423          	sd	a0,392(a5)
  a->offset = offset;
    800060ba:	fb842703          	lw	a4,-72(s0)
    800060be:	18e7a223          	sw	a4,388(a5)
  a->permissions = prot;
    800060c2:	fc442703          	lw	a4,-60(s0)
    800060c6:	16e7ae23          	sw	a4,380(a5)
  a->flags = flags;
    800060ca:	18b7a023          	sw	a1,384(a5)

  filedup(f);
    800060ce:	fffff097          	auipc	ra,0xfffff
    800060d2:	854080e7          	jalr	-1964(ra) # 80004922 <filedup>

  return a->start;
    800060d6:	40998533          	sub	a0,s3,s1
    800060da:	050e                	slli	a0,a0,0x3
    800060dc:	954a                	add	a0,a0,s2
    800060de:	19053783          	ld	a5,400(a0)
}
    800060e2:	853e                	mv	a0,a5
    800060e4:	60a6                	ld	ra,72(sp)
    800060e6:	6406                	ld	s0,64(sp)
    800060e8:	74e2                	ld	s1,56(sp)
    800060ea:	7942                	ld	s2,48(sp)
    800060ec:	79a2                	ld	s3,40(sp)
    800060ee:	6161                	addi	sp,sp,80
    800060f0:	8082                	ret
    return -1;
    800060f2:	57fd                	li	a5,-1
    800060f4:	b7fd                	j	800060e2 <sys_mmap+0x14c>

00000000800060f6 <sys_munmap>:

uint64
sys_munmap(void)
{
    800060f6:	1101                	addi	sp,sp,-32
    800060f8:	ec06                	sd	ra,24(sp)
    800060fa:	e822                	sd	s0,16(sp)
    800060fc:	1000                	addi	s0,sp,32
  uint64 addr;
  int length;

  if(argaddr(0, &addr) || argint(1, &length))
    800060fe:	fe840593          	addi	a1,s0,-24
    80006102:	4501                	li	a0,0
    80006104:	ffffd097          	auipc	ra,0xffffd
    80006108:	e7c080e7          	jalr	-388(ra) # 80002f80 <argaddr>
    return -1;
    8000610c:	57fd                	li	a5,-1
  if(argaddr(0, &addr) || argint(1, &length))
    8000610e:	e11d                	bnez	a0,80006134 <sys_munmap+0x3e>
    80006110:	fe440593          	addi	a1,s0,-28
    80006114:	4505                	li	a0,1
    80006116:	ffffd097          	auipc	ra,0xffffd
    8000611a:	e48080e7          	jalr	-440(ra) # 80002f5e <argint>
    return -1;
    8000611e:	57fd                	li	a5,-1
  if(argaddr(0, &addr) || argint(1, &length))
    80006120:	e911                	bnez	a0,80006134 <sys_munmap+0x3e>
  
  return munmap(addr, length);
    80006122:	fe442583          	lw	a1,-28(s0)
    80006126:	fe843503          	ld	a0,-24(s0)
    8000612a:	ffffc097          	auipc	ra,0xffffc
    8000612e:	936080e7          	jalr	-1738(ra) # 80001a60 <munmap>
    80006132:	87aa                	mv	a5,a0
    80006134:	853e                	mv	a0,a5
    80006136:	60e2                	ld	ra,24(sp)
    80006138:	6442                	ld	s0,16(sp)
    8000613a:	6105                	addi	sp,sp,32
    8000613c:	8082                	ret
	...

0000000080006140 <kernelvec>:
    80006140:	7111                	addi	sp,sp,-256
    80006142:	e006                	sd	ra,0(sp)
    80006144:	e40a                	sd	sp,8(sp)
    80006146:	e80e                	sd	gp,16(sp)
    80006148:	ec12                	sd	tp,24(sp)
    8000614a:	f016                	sd	t0,32(sp)
    8000614c:	f41a                	sd	t1,40(sp)
    8000614e:	f81e                	sd	t2,48(sp)
    80006150:	fc22                	sd	s0,56(sp)
    80006152:	e0a6                	sd	s1,64(sp)
    80006154:	e4aa                	sd	a0,72(sp)
    80006156:	e8ae                	sd	a1,80(sp)
    80006158:	ecb2                	sd	a2,88(sp)
    8000615a:	f0b6                	sd	a3,96(sp)
    8000615c:	f4ba                	sd	a4,104(sp)
    8000615e:	f8be                	sd	a5,112(sp)
    80006160:	fcc2                	sd	a6,120(sp)
    80006162:	e146                	sd	a7,128(sp)
    80006164:	e54a                	sd	s2,136(sp)
    80006166:	e94e                	sd	s3,144(sp)
    80006168:	ed52                	sd	s4,152(sp)
    8000616a:	f156                	sd	s5,160(sp)
    8000616c:	f55a                	sd	s6,168(sp)
    8000616e:	f95e                	sd	s7,176(sp)
    80006170:	fd62                	sd	s8,184(sp)
    80006172:	e1e6                	sd	s9,192(sp)
    80006174:	e5ea                	sd	s10,200(sp)
    80006176:	e9ee                	sd	s11,208(sp)
    80006178:	edf2                	sd	t3,216(sp)
    8000617a:	f1f6                	sd	t4,224(sp)
    8000617c:	f5fa                	sd	t5,232(sp)
    8000617e:	f9fe                	sd	t6,240(sp)
    80006180:	c11fc0ef          	jal	ra,80002d90 <kerneltrap>
    80006184:	6082                	ld	ra,0(sp)
    80006186:	6122                	ld	sp,8(sp)
    80006188:	61c2                	ld	gp,16(sp)
    8000618a:	7282                	ld	t0,32(sp)
    8000618c:	7322                	ld	t1,40(sp)
    8000618e:	73c2                	ld	t2,48(sp)
    80006190:	7462                	ld	s0,56(sp)
    80006192:	6486                	ld	s1,64(sp)
    80006194:	6526                	ld	a0,72(sp)
    80006196:	65c6                	ld	a1,80(sp)
    80006198:	6666                	ld	a2,88(sp)
    8000619a:	7686                	ld	a3,96(sp)
    8000619c:	7726                	ld	a4,104(sp)
    8000619e:	77c6                	ld	a5,112(sp)
    800061a0:	7866                	ld	a6,120(sp)
    800061a2:	688a                	ld	a7,128(sp)
    800061a4:	692a                	ld	s2,136(sp)
    800061a6:	69ca                	ld	s3,144(sp)
    800061a8:	6a6a                	ld	s4,152(sp)
    800061aa:	7a8a                	ld	s5,160(sp)
    800061ac:	7b2a                	ld	s6,168(sp)
    800061ae:	7bca                	ld	s7,176(sp)
    800061b0:	7c6a                	ld	s8,184(sp)
    800061b2:	6c8e                	ld	s9,192(sp)
    800061b4:	6d2e                	ld	s10,200(sp)
    800061b6:	6dce                	ld	s11,208(sp)
    800061b8:	6e6e                	ld	t3,216(sp)
    800061ba:	7e8e                	ld	t4,224(sp)
    800061bc:	7f2e                	ld	t5,232(sp)
    800061be:	7fce                	ld	t6,240(sp)
    800061c0:	6111                	addi	sp,sp,256
    800061c2:	10200073          	sret
    800061c6:	00000013          	nop
    800061ca:	00000013          	nop
    800061ce:	0001                	nop

00000000800061d0 <timervec>:
    800061d0:	34051573          	csrrw	a0,mscratch,a0
    800061d4:	e10c                	sd	a1,0(a0)
    800061d6:	e510                	sd	a2,8(a0)
    800061d8:	e914                	sd	a3,16(a0)
    800061da:	6d0c                	ld	a1,24(a0)
    800061dc:	7110                	ld	a2,32(a0)
    800061de:	6194                	ld	a3,0(a1)
    800061e0:	96b2                	add	a3,a3,a2
    800061e2:	e194                	sd	a3,0(a1)
    800061e4:	4589                	li	a1,2
    800061e6:	14459073          	csrw	sip,a1
    800061ea:	6914                	ld	a3,16(a0)
    800061ec:	6510                	ld	a2,8(a0)
    800061ee:	610c                	ld	a1,0(a0)
    800061f0:	34051573          	csrrw	a0,mscratch,a0
    800061f4:	30200073          	mret
	...

00000000800061fa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800061fa:	1141                	addi	sp,sp,-16
    800061fc:	e422                	sd	s0,8(sp)
    800061fe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006200:	0c0007b7          	lui	a5,0xc000
    80006204:	4705                	li	a4,1
    80006206:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006208:	c3d8                	sw	a4,4(a5)
}
    8000620a:	6422                	ld	s0,8(sp)
    8000620c:	0141                	addi	sp,sp,16
    8000620e:	8082                	ret

0000000080006210 <plicinithart>:

void
plicinithart(void)
{
    80006210:	1141                	addi	sp,sp,-16
    80006212:	e406                	sd	ra,8(sp)
    80006214:	e022                	sd	s0,0(sp)
    80006216:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006218:	ffffc097          	auipc	ra,0xffffc
    8000621c:	b62080e7          	jalr	-1182(ra) # 80001d7a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006220:	0085171b          	slliw	a4,a0,0x8
    80006224:	0c0027b7          	lui	a5,0xc002
    80006228:	97ba                	add	a5,a5,a4
    8000622a:	40200713          	li	a4,1026
    8000622e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006232:	00d5151b          	slliw	a0,a0,0xd
    80006236:	0c2017b7          	lui	a5,0xc201
    8000623a:	953e                	add	a0,a0,a5
    8000623c:	00052023          	sw	zero,0(a0)
}
    80006240:	60a2                	ld	ra,8(sp)
    80006242:	6402                	ld	s0,0(sp)
    80006244:	0141                	addi	sp,sp,16
    80006246:	8082                	ret

0000000080006248 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006248:	1141                	addi	sp,sp,-16
    8000624a:	e406                	sd	ra,8(sp)
    8000624c:	e022                	sd	s0,0(sp)
    8000624e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006250:	ffffc097          	auipc	ra,0xffffc
    80006254:	b2a080e7          	jalr	-1238(ra) # 80001d7a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006258:	00d5179b          	slliw	a5,a0,0xd
    8000625c:	0c201537          	lui	a0,0xc201
    80006260:	953e                	add	a0,a0,a5
  return irq;
}
    80006262:	4148                	lw	a0,4(a0)
    80006264:	60a2                	ld	ra,8(sp)
    80006266:	6402                	ld	s0,0(sp)
    80006268:	0141                	addi	sp,sp,16
    8000626a:	8082                	ret

000000008000626c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000626c:	1101                	addi	sp,sp,-32
    8000626e:	ec06                	sd	ra,24(sp)
    80006270:	e822                	sd	s0,16(sp)
    80006272:	e426                	sd	s1,8(sp)
    80006274:	1000                	addi	s0,sp,32
    80006276:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006278:	ffffc097          	auipc	ra,0xffffc
    8000627c:	b02080e7          	jalr	-1278(ra) # 80001d7a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006280:	00d5151b          	slliw	a0,a0,0xd
    80006284:	0c2017b7          	lui	a5,0xc201
    80006288:	97aa                	add	a5,a5,a0
    8000628a:	c3c4                	sw	s1,4(a5)
}
    8000628c:	60e2                	ld	ra,24(sp)
    8000628e:	6442                	ld	s0,16(sp)
    80006290:	64a2                	ld	s1,8(sp)
    80006292:	6105                	addi	sp,sp,32
    80006294:	8082                	ret

0000000080006296 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006296:	1141                	addi	sp,sp,-16
    80006298:	e406                	sd	ra,8(sp)
    8000629a:	e022                	sd	s0,0(sp)
    8000629c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000629e:	479d                	li	a5,7
    800062a0:	06a7c963          	blt	a5,a0,80006312 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800062a4:	0002b797          	auipc	a5,0x2b
    800062a8:	d5c78793          	addi	a5,a5,-676 # 80031000 <disk>
    800062ac:	00a78733          	add	a4,a5,a0
    800062b0:	6789                	lui	a5,0x2
    800062b2:	97ba                	add	a5,a5,a4
    800062b4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800062b8:	e7ad                	bnez	a5,80006322 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800062ba:	00451793          	slli	a5,a0,0x4
    800062be:	0002d717          	auipc	a4,0x2d
    800062c2:	d4270713          	addi	a4,a4,-702 # 80033000 <disk+0x2000>
    800062c6:	6314                	ld	a3,0(a4)
    800062c8:	96be                	add	a3,a3,a5
    800062ca:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800062ce:	6314                	ld	a3,0(a4)
    800062d0:	96be                	add	a3,a3,a5
    800062d2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800062d6:	6314                	ld	a3,0(a4)
    800062d8:	96be                	add	a3,a3,a5
    800062da:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800062de:	6318                	ld	a4,0(a4)
    800062e0:	97ba                	add	a5,a5,a4
    800062e2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800062e6:	0002b797          	auipc	a5,0x2b
    800062ea:	d1a78793          	addi	a5,a5,-742 # 80031000 <disk>
    800062ee:	97aa                	add	a5,a5,a0
    800062f0:	6509                	lui	a0,0x2
    800062f2:	953e                	add	a0,a0,a5
    800062f4:	4785                	li	a5,1
    800062f6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800062fa:	0002d517          	auipc	a0,0x2d
    800062fe:	d1e50513          	addi	a0,a0,-738 # 80033018 <disk+0x2018>
    80006302:	ffffc097          	auipc	ra,0xffffc
    80006306:	4dc080e7          	jalr	1244(ra) # 800027de <wakeup>
}
    8000630a:	60a2                	ld	ra,8(sp)
    8000630c:	6402                	ld	s0,0(sp)
    8000630e:	0141                	addi	sp,sp,16
    80006310:	8082                	ret
    panic("free_desc 1");
    80006312:	00002517          	auipc	a0,0x2
    80006316:	43e50513          	addi	a0,a0,1086 # 80008750 <syscalls+0x330>
    8000631a:	ffffa097          	auipc	ra,0xffffa
    8000631e:	210080e7          	jalr	528(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006322:	00002517          	auipc	a0,0x2
    80006326:	43e50513          	addi	a0,a0,1086 # 80008760 <syscalls+0x340>
    8000632a:	ffffa097          	auipc	ra,0xffffa
    8000632e:	200080e7          	jalr	512(ra) # 8000052a <panic>

0000000080006332 <virtio_disk_init>:
{
    80006332:	1101                	addi	sp,sp,-32
    80006334:	ec06                	sd	ra,24(sp)
    80006336:	e822                	sd	s0,16(sp)
    80006338:	e426                	sd	s1,8(sp)
    8000633a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000633c:	00002597          	auipc	a1,0x2
    80006340:	43458593          	addi	a1,a1,1076 # 80008770 <syscalls+0x350>
    80006344:	0002d517          	auipc	a0,0x2d
    80006348:	de450513          	addi	a0,a0,-540 # 80033128 <disk+0x2128>
    8000634c:	ffffa097          	auipc	ra,0xffffa
    80006350:	7e6080e7          	jalr	2022(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006354:	100017b7          	lui	a5,0x10001
    80006358:	4398                	lw	a4,0(a5)
    8000635a:	2701                	sext.w	a4,a4
    8000635c:	747277b7          	lui	a5,0x74727
    80006360:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006364:	0ef71163          	bne	a4,a5,80006446 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006368:	100017b7          	lui	a5,0x10001
    8000636c:	43dc                	lw	a5,4(a5)
    8000636e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006370:	4705                	li	a4,1
    80006372:	0ce79a63          	bne	a5,a4,80006446 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006376:	100017b7          	lui	a5,0x10001
    8000637a:	479c                	lw	a5,8(a5)
    8000637c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000637e:	4709                	li	a4,2
    80006380:	0ce79363          	bne	a5,a4,80006446 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006384:	100017b7          	lui	a5,0x10001
    80006388:	47d8                	lw	a4,12(a5)
    8000638a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000638c:	554d47b7          	lui	a5,0x554d4
    80006390:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006394:	0af71963          	bne	a4,a5,80006446 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006398:	100017b7          	lui	a5,0x10001
    8000639c:	4705                	li	a4,1
    8000639e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063a0:	470d                	li	a4,3
    800063a2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063a4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063a6:	c7ffe737          	lui	a4,0xc7ffe
    800063aa:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fca75f>
    800063ae:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063b0:	2701                	sext.w	a4,a4
    800063b2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063b4:	472d                	li	a4,11
    800063b6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063b8:	473d                	li	a4,15
    800063ba:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800063bc:	6705                	lui	a4,0x1
    800063be:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800063c0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800063c4:	5bdc                	lw	a5,52(a5)
    800063c6:	2781                	sext.w	a5,a5
  if(max == 0)
    800063c8:	c7d9                	beqz	a5,80006456 <virtio_disk_init+0x124>
  if(max < NUM)
    800063ca:	471d                	li	a4,7
    800063cc:	08f77d63          	bgeu	a4,a5,80006466 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063d0:	100014b7          	lui	s1,0x10001
    800063d4:	47a1                	li	a5,8
    800063d6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800063d8:	6609                	lui	a2,0x2
    800063da:	4581                	li	a1,0
    800063dc:	0002b517          	auipc	a0,0x2b
    800063e0:	c2450513          	addi	a0,a0,-988 # 80031000 <disk>
    800063e4:	ffffb097          	auipc	ra,0xffffb
    800063e8:	8da080e7          	jalr	-1830(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800063ec:	0002b717          	auipc	a4,0x2b
    800063f0:	c1470713          	addi	a4,a4,-1004 # 80031000 <disk>
    800063f4:	00c75793          	srli	a5,a4,0xc
    800063f8:	2781                	sext.w	a5,a5
    800063fa:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800063fc:	0002d797          	auipc	a5,0x2d
    80006400:	c0478793          	addi	a5,a5,-1020 # 80033000 <disk+0x2000>
    80006404:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006406:	0002b717          	auipc	a4,0x2b
    8000640a:	c7a70713          	addi	a4,a4,-902 # 80031080 <disk+0x80>
    8000640e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006410:	0002c717          	auipc	a4,0x2c
    80006414:	bf070713          	addi	a4,a4,-1040 # 80032000 <disk+0x1000>
    80006418:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000641a:	4705                	li	a4,1
    8000641c:	00e78c23          	sb	a4,24(a5)
    80006420:	00e78ca3          	sb	a4,25(a5)
    80006424:	00e78d23          	sb	a4,26(a5)
    80006428:	00e78da3          	sb	a4,27(a5)
    8000642c:	00e78e23          	sb	a4,28(a5)
    80006430:	00e78ea3          	sb	a4,29(a5)
    80006434:	00e78f23          	sb	a4,30(a5)
    80006438:	00e78fa3          	sb	a4,31(a5)
}
    8000643c:	60e2                	ld	ra,24(sp)
    8000643e:	6442                	ld	s0,16(sp)
    80006440:	64a2                	ld	s1,8(sp)
    80006442:	6105                	addi	sp,sp,32
    80006444:	8082                	ret
    panic("could not find virtio disk");
    80006446:	00002517          	auipc	a0,0x2
    8000644a:	33a50513          	addi	a0,a0,826 # 80008780 <syscalls+0x360>
    8000644e:	ffffa097          	auipc	ra,0xffffa
    80006452:	0dc080e7          	jalr	220(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006456:	00002517          	auipc	a0,0x2
    8000645a:	34a50513          	addi	a0,a0,842 # 800087a0 <syscalls+0x380>
    8000645e:	ffffa097          	auipc	ra,0xffffa
    80006462:	0cc080e7          	jalr	204(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006466:	00002517          	auipc	a0,0x2
    8000646a:	35a50513          	addi	a0,a0,858 # 800087c0 <syscalls+0x3a0>
    8000646e:	ffffa097          	auipc	ra,0xffffa
    80006472:	0bc080e7          	jalr	188(ra) # 8000052a <panic>

0000000080006476 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006476:	7119                	addi	sp,sp,-128
    80006478:	fc86                	sd	ra,120(sp)
    8000647a:	f8a2                	sd	s0,112(sp)
    8000647c:	f4a6                	sd	s1,104(sp)
    8000647e:	f0ca                	sd	s2,96(sp)
    80006480:	ecce                	sd	s3,88(sp)
    80006482:	e8d2                	sd	s4,80(sp)
    80006484:	e4d6                	sd	s5,72(sp)
    80006486:	e0da                	sd	s6,64(sp)
    80006488:	fc5e                	sd	s7,56(sp)
    8000648a:	f862                	sd	s8,48(sp)
    8000648c:	f466                	sd	s9,40(sp)
    8000648e:	f06a                	sd	s10,32(sp)
    80006490:	ec6e                	sd	s11,24(sp)
    80006492:	0100                	addi	s0,sp,128
    80006494:	8aaa                	mv	s5,a0
    80006496:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006498:	00c52c83          	lw	s9,12(a0)
    8000649c:	001c9c9b          	slliw	s9,s9,0x1
    800064a0:	1c82                	slli	s9,s9,0x20
    800064a2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800064a6:	0002d517          	auipc	a0,0x2d
    800064aa:	c8250513          	addi	a0,a0,-894 # 80033128 <disk+0x2128>
    800064ae:	ffffa097          	auipc	ra,0xffffa
    800064b2:	714080e7          	jalr	1812(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    800064b6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064b8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064ba:	0002bc17          	auipc	s8,0x2b
    800064be:	b46c0c13          	addi	s8,s8,-1210 # 80031000 <disk>
    800064c2:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800064c4:	4b0d                	li	s6,3
    800064c6:	a0ad                	j	80006530 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800064c8:	00fc0733          	add	a4,s8,a5
    800064cc:	975e                	add	a4,a4,s7
    800064ce:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800064d2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800064d4:	0207c563          	bltz	a5,800064fe <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800064d8:	2905                	addiw	s2,s2,1
    800064da:	0611                	addi	a2,a2,4
    800064dc:	19690d63          	beq	s2,s6,80006676 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    800064e0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800064e2:	0002d717          	auipc	a4,0x2d
    800064e6:	b3670713          	addi	a4,a4,-1226 # 80033018 <disk+0x2018>
    800064ea:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800064ec:	00074683          	lbu	a3,0(a4)
    800064f0:	fee1                	bnez	a3,800064c8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800064f2:	2785                	addiw	a5,a5,1
    800064f4:	0705                	addi	a4,a4,1
    800064f6:	fe979be3          	bne	a5,s1,800064ec <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800064fa:	57fd                	li	a5,-1
    800064fc:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800064fe:	01205d63          	blez	s2,80006518 <virtio_disk_rw+0xa2>
    80006502:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006504:	000a2503          	lw	a0,0(s4)
    80006508:	00000097          	auipc	ra,0x0
    8000650c:	d8e080e7          	jalr	-626(ra) # 80006296 <free_desc>
      for(int j = 0; j < i; j++)
    80006510:	2d85                	addiw	s11,s11,1
    80006512:	0a11                	addi	s4,s4,4
    80006514:	ffb918e3          	bne	s2,s11,80006504 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006518:	0002d597          	auipc	a1,0x2d
    8000651c:	c1058593          	addi	a1,a1,-1008 # 80033128 <disk+0x2128>
    80006520:	0002d517          	auipc	a0,0x2d
    80006524:	af850513          	addi	a0,a0,-1288 # 80033018 <disk+0x2018>
    80006528:	ffffc097          	auipc	ra,0xffffc
    8000652c:	136080e7          	jalr	310(ra) # 8000265e <sleep>
  for(int i = 0; i < 3; i++){
    80006530:	f8040a13          	addi	s4,s0,-128
{
    80006534:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006536:	894e                	mv	s2,s3
    80006538:	b765                	j	800064e0 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000653a:	0002d697          	auipc	a3,0x2d
    8000653e:	ac66b683          	ld	a3,-1338(a3) # 80033000 <disk+0x2000>
    80006542:	96ba                	add	a3,a3,a4
    80006544:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006548:	0002b817          	auipc	a6,0x2b
    8000654c:	ab880813          	addi	a6,a6,-1352 # 80031000 <disk>
    80006550:	0002d697          	auipc	a3,0x2d
    80006554:	ab068693          	addi	a3,a3,-1360 # 80033000 <disk+0x2000>
    80006558:	6290                	ld	a2,0(a3)
    8000655a:	963a                	add	a2,a2,a4
    8000655c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006560:	0015e593          	ori	a1,a1,1
    80006564:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006568:	f8842603          	lw	a2,-120(s0)
    8000656c:	628c                	ld	a1,0(a3)
    8000656e:	972e                	add	a4,a4,a1
    80006570:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006574:	20050593          	addi	a1,a0,512
    80006578:	0592                	slli	a1,a1,0x4
    8000657a:	95c2                	add	a1,a1,a6
    8000657c:	577d                	li	a4,-1
    8000657e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006582:	00461713          	slli	a4,a2,0x4
    80006586:	6290                	ld	a2,0(a3)
    80006588:	963a                	add	a2,a2,a4
    8000658a:	03078793          	addi	a5,a5,48
    8000658e:	97c2                	add	a5,a5,a6
    80006590:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006592:	629c                	ld	a5,0(a3)
    80006594:	97ba                	add	a5,a5,a4
    80006596:	4605                	li	a2,1
    80006598:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000659a:	629c                	ld	a5,0(a3)
    8000659c:	97ba                	add	a5,a5,a4
    8000659e:	4809                	li	a6,2
    800065a0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800065a4:	629c                	ld	a5,0(a3)
    800065a6:	973e                	add	a4,a4,a5
    800065a8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800065ac:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800065b0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800065b4:	6698                	ld	a4,8(a3)
    800065b6:	00275783          	lhu	a5,2(a4)
    800065ba:	8b9d                	andi	a5,a5,7
    800065bc:	0786                	slli	a5,a5,0x1
    800065be:	97ba                	add	a5,a5,a4
    800065c0:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    800065c4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800065c8:	6698                	ld	a4,8(a3)
    800065ca:	00275783          	lhu	a5,2(a4)
    800065ce:	2785                	addiw	a5,a5,1
    800065d0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800065d4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800065d8:	100017b7          	lui	a5,0x10001
    800065dc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800065e0:	004aa783          	lw	a5,4(s5)
    800065e4:	02c79163          	bne	a5,a2,80006606 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800065e8:	0002d917          	auipc	s2,0x2d
    800065ec:	b4090913          	addi	s2,s2,-1216 # 80033128 <disk+0x2128>
  while(b->disk == 1) {
    800065f0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800065f2:	85ca                	mv	a1,s2
    800065f4:	8556                	mv	a0,s5
    800065f6:	ffffc097          	auipc	ra,0xffffc
    800065fa:	068080e7          	jalr	104(ra) # 8000265e <sleep>
  while(b->disk == 1) {
    800065fe:	004aa783          	lw	a5,4(s5)
    80006602:	fe9788e3          	beq	a5,s1,800065f2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006606:	f8042903          	lw	s2,-128(s0)
    8000660a:	20090793          	addi	a5,s2,512
    8000660e:	00479713          	slli	a4,a5,0x4
    80006612:	0002b797          	auipc	a5,0x2b
    80006616:	9ee78793          	addi	a5,a5,-1554 # 80031000 <disk>
    8000661a:	97ba                	add	a5,a5,a4
    8000661c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006620:	0002d997          	auipc	s3,0x2d
    80006624:	9e098993          	addi	s3,s3,-1568 # 80033000 <disk+0x2000>
    80006628:	00491713          	slli	a4,s2,0x4
    8000662c:	0009b783          	ld	a5,0(s3)
    80006630:	97ba                	add	a5,a5,a4
    80006632:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006636:	854a                	mv	a0,s2
    80006638:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000663c:	00000097          	auipc	ra,0x0
    80006640:	c5a080e7          	jalr	-934(ra) # 80006296 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006644:	8885                	andi	s1,s1,1
    80006646:	f0ed                	bnez	s1,80006628 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006648:	0002d517          	auipc	a0,0x2d
    8000664c:	ae050513          	addi	a0,a0,-1312 # 80033128 <disk+0x2128>
    80006650:	ffffa097          	auipc	ra,0xffffa
    80006654:	626080e7          	jalr	1574(ra) # 80000c76 <release>
}
    80006658:	70e6                	ld	ra,120(sp)
    8000665a:	7446                	ld	s0,112(sp)
    8000665c:	74a6                	ld	s1,104(sp)
    8000665e:	7906                	ld	s2,96(sp)
    80006660:	69e6                	ld	s3,88(sp)
    80006662:	6a46                	ld	s4,80(sp)
    80006664:	6aa6                	ld	s5,72(sp)
    80006666:	6b06                	ld	s6,64(sp)
    80006668:	7be2                	ld	s7,56(sp)
    8000666a:	7c42                	ld	s8,48(sp)
    8000666c:	7ca2                	ld	s9,40(sp)
    8000666e:	7d02                	ld	s10,32(sp)
    80006670:	6de2                	ld	s11,24(sp)
    80006672:	6109                	addi	sp,sp,128
    80006674:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006676:	f8042503          	lw	a0,-128(s0)
    8000667a:	20050793          	addi	a5,a0,512
    8000667e:	0792                	slli	a5,a5,0x4
  if(write)
    80006680:	0002b817          	auipc	a6,0x2b
    80006684:	98080813          	addi	a6,a6,-1664 # 80031000 <disk>
    80006688:	00f80733          	add	a4,a6,a5
    8000668c:	01a036b3          	snez	a3,s10
    80006690:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006694:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006698:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000669c:	7679                	lui	a2,0xffffe
    8000669e:	963e                	add	a2,a2,a5
    800066a0:	0002d697          	auipc	a3,0x2d
    800066a4:	96068693          	addi	a3,a3,-1696 # 80033000 <disk+0x2000>
    800066a8:	6298                	ld	a4,0(a3)
    800066aa:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066ac:	0a878593          	addi	a1,a5,168
    800066b0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066b2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800066b4:	6298                	ld	a4,0(a3)
    800066b6:	9732                	add	a4,a4,a2
    800066b8:	45c1                	li	a1,16
    800066ba:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800066bc:	6298                	ld	a4,0(a3)
    800066be:	9732                	add	a4,a4,a2
    800066c0:	4585                	li	a1,1
    800066c2:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800066c6:	f8442703          	lw	a4,-124(s0)
    800066ca:	628c                	ld	a1,0(a3)
    800066cc:	962e                	add	a2,a2,a1
    800066ce:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffca00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800066d2:	0712                	slli	a4,a4,0x4
    800066d4:	6290                	ld	a2,0(a3)
    800066d6:	963a                	add	a2,a2,a4
    800066d8:	058a8593          	addi	a1,s5,88
    800066dc:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800066de:	6294                	ld	a3,0(a3)
    800066e0:	96ba                	add	a3,a3,a4
    800066e2:	40000613          	li	a2,1024
    800066e6:	c690                	sw	a2,8(a3)
  if(write)
    800066e8:	e40d19e3          	bnez	s10,8000653a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800066ec:	0002d697          	auipc	a3,0x2d
    800066f0:	9146b683          	ld	a3,-1772(a3) # 80033000 <disk+0x2000>
    800066f4:	96ba                	add	a3,a3,a4
    800066f6:	4609                	li	a2,2
    800066f8:	00c69623          	sh	a2,12(a3)
    800066fc:	b5b1                	j	80006548 <virtio_disk_rw+0xd2>

00000000800066fe <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800066fe:	1101                	addi	sp,sp,-32
    80006700:	ec06                	sd	ra,24(sp)
    80006702:	e822                	sd	s0,16(sp)
    80006704:	e426                	sd	s1,8(sp)
    80006706:	e04a                	sd	s2,0(sp)
    80006708:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000670a:	0002d517          	auipc	a0,0x2d
    8000670e:	a1e50513          	addi	a0,a0,-1506 # 80033128 <disk+0x2128>
    80006712:	ffffa097          	auipc	ra,0xffffa
    80006716:	4b0080e7          	jalr	1200(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000671a:	10001737          	lui	a4,0x10001
    8000671e:	533c                	lw	a5,96(a4)
    80006720:	8b8d                	andi	a5,a5,3
    80006722:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006724:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006728:	0002d797          	auipc	a5,0x2d
    8000672c:	8d878793          	addi	a5,a5,-1832 # 80033000 <disk+0x2000>
    80006730:	6b94                	ld	a3,16(a5)
    80006732:	0207d703          	lhu	a4,32(a5)
    80006736:	0026d783          	lhu	a5,2(a3)
    8000673a:	06f70163          	beq	a4,a5,8000679c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000673e:	0002b917          	auipc	s2,0x2b
    80006742:	8c290913          	addi	s2,s2,-1854 # 80031000 <disk>
    80006746:	0002d497          	auipc	s1,0x2d
    8000674a:	8ba48493          	addi	s1,s1,-1862 # 80033000 <disk+0x2000>
    __sync_synchronize();
    8000674e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006752:	6898                	ld	a4,16(s1)
    80006754:	0204d783          	lhu	a5,32(s1)
    80006758:	8b9d                	andi	a5,a5,7
    8000675a:	078e                	slli	a5,a5,0x3
    8000675c:	97ba                	add	a5,a5,a4
    8000675e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006760:	20078713          	addi	a4,a5,512
    80006764:	0712                	slli	a4,a4,0x4
    80006766:	974a                	add	a4,a4,s2
    80006768:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000676c:	e731                	bnez	a4,800067b8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000676e:	20078793          	addi	a5,a5,512
    80006772:	0792                	slli	a5,a5,0x4
    80006774:	97ca                	add	a5,a5,s2
    80006776:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006778:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000677c:	ffffc097          	auipc	ra,0xffffc
    80006780:	062080e7          	jalr	98(ra) # 800027de <wakeup>

    disk.used_idx += 1;
    80006784:	0204d783          	lhu	a5,32(s1)
    80006788:	2785                	addiw	a5,a5,1
    8000678a:	17c2                	slli	a5,a5,0x30
    8000678c:	93c1                	srli	a5,a5,0x30
    8000678e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006792:	6898                	ld	a4,16(s1)
    80006794:	00275703          	lhu	a4,2(a4)
    80006798:	faf71be3          	bne	a4,a5,8000674e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000679c:	0002d517          	auipc	a0,0x2d
    800067a0:	98c50513          	addi	a0,a0,-1652 # 80033128 <disk+0x2128>
    800067a4:	ffffa097          	auipc	ra,0xffffa
    800067a8:	4d2080e7          	jalr	1234(ra) # 80000c76 <release>
}
    800067ac:	60e2                	ld	ra,24(sp)
    800067ae:	6442                	ld	s0,16(sp)
    800067b0:	64a2                	ld	s1,8(sp)
    800067b2:	6902                	ld	s2,0(sp)
    800067b4:	6105                	addi	sp,sp,32
    800067b6:	8082                	ret
      panic("virtio_disk_intr status");
    800067b8:	00002517          	auipc	a0,0x2
    800067bc:	02850513          	addi	a0,a0,40 # 800087e0 <syscalls+0x3c0>
    800067c0:	ffffa097          	auipc	ra,0xffffa
    800067c4:	d6a080e7          	jalr	-662(ra) # 8000052a <panic>
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
