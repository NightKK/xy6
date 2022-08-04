
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	17010113          	addi	sp,sp,368 # 80009170 <stack0>
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
    80000056:	fde70713          	addi	a4,a4,-34 # 80009030 <timer_scratch>
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
    80000068:	15c78793          	addi	a5,a5,348 # 800061c0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd27d7>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	1dc78793          	addi	a5,a5,476 # 8000128a <main>
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
    80000106:	8a2a                	mv	s4,a0
    80000108:	84ae                	mv	s1,a1
    8000010a:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    8000010c:	00011517          	auipc	a0,0x11
    80000110:	06450513          	addi	a0,a0,100 # 80011170 <cons>
    80000114:	00001097          	auipc	ra,0x1
    80000118:	be8080e7          	jalr	-1048(ra) # 80000cfc <acquire>
  for(i = 0; i < n; i++){
    8000011c:	05305b63          	blez	s3,80000172 <consolewrite+0x7e>
    80000120:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000122:	5afd                	li	s5,-1
    80000124:	4685                	li	a3,1
    80000126:	8626                	mv	a2,s1
    80000128:	85d2                	mv	a1,s4
    8000012a:	fbf40513          	addi	a0,s0,-65
    8000012e:	00002097          	auipc	ra,0x2
    80000132:	6d8080e7          	jalr	1752(ra) # 80002806 <either_copyin>
    80000136:	01550c63          	beq	a0,s5,8000014e <consolewrite+0x5a>
      break;
    uartputc(c);
    8000013a:	fbf44503          	lbu	a0,-65(s0)
    8000013e:	00000097          	auipc	ra,0x0
    80000142:	796080e7          	jalr	1942(ra) # 800008d4 <uartputc>
  for(i = 0; i < n; i++){
    80000146:	2905                	addiw	s2,s2,1
    80000148:	0485                	addi	s1,s1,1
    8000014a:	fd299de3          	bne	s3,s2,80000124 <consolewrite+0x30>
  }
  release(&cons.lock);
    8000014e:	00011517          	auipc	a0,0x11
    80000152:	02250513          	addi	a0,a0,34 # 80011170 <cons>
    80000156:	00001097          	auipc	ra,0x1
    8000015a:	c76080e7          	jalr	-906(ra) # 80000dcc <release>

  return i;
}
    8000015e:	854a                	mv	a0,s2
    80000160:	60a6                	ld	ra,72(sp)
    80000162:	6406                	ld	s0,64(sp)
    80000164:	74e2                	ld	s1,56(sp)
    80000166:	7942                	ld	s2,48(sp)
    80000168:	79a2                	ld	s3,40(sp)
    8000016a:	7a02                	ld	s4,32(sp)
    8000016c:	6ae2                	ld	s5,24(sp)
    8000016e:	6161                	addi	sp,sp,80
    80000170:	8082                	ret
  for(i = 0; i < n; i++){
    80000172:	4901                	li	s2,0
    80000174:	bfe9                	j	8000014e <consolewrite+0x5a>

0000000080000176 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	7159                	addi	sp,sp,-112
    80000178:	f486                	sd	ra,104(sp)
    8000017a:	f0a2                	sd	s0,96(sp)
    8000017c:	eca6                	sd	s1,88(sp)
    8000017e:	e8ca                	sd	s2,80(sp)
    80000180:	e4ce                	sd	s3,72(sp)
    80000182:	e0d2                	sd	s4,64(sp)
    80000184:	fc56                	sd	s5,56(sp)
    80000186:	f85a                	sd	s6,48(sp)
    80000188:	f45e                	sd	s7,40(sp)
    8000018a:	f062                	sd	s8,32(sp)
    8000018c:	ec66                	sd	s9,24(sp)
    8000018e:	e86a                	sd	s10,16(sp)
    80000190:	1880                	addi	s0,sp,112
    80000192:	8aaa                	mv	s5,a0
    80000194:	8a2e                	mv	s4,a1
    80000196:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000198:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000019c:	00011517          	auipc	a0,0x11
    800001a0:	fd450513          	addi	a0,a0,-44 # 80011170 <cons>
    800001a4:	00001097          	auipc	ra,0x1
    800001a8:	b58080e7          	jalr	-1192(ra) # 80000cfc <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001ac:	00011497          	auipc	s1,0x11
    800001b0:	fc448493          	addi	s1,s1,-60 # 80011170 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00011917          	auipc	s2,0x11
    800001b8:	05c90913          	addi	s2,s2,92 # 80011210 <cons+0xa0>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001bc:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001be:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001c0:	4ca9                	li	s9,10
  while(n > 0){
    800001c2:	07305863          	blez	s3,80000232 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001c6:	0a04a783          	lw	a5,160(s1)
    800001ca:	0a44a703          	lw	a4,164(s1)
    800001ce:	02f71463          	bne	a4,a5,800001f6 <consoleread+0x80>
      if(myproc()->killed){
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	b70080e7          	jalr	-1168(ra) # 80001d42 <myproc>
    800001da:	5d1c                	lw	a5,56(a0)
    800001dc:	e7b5                	bnez	a5,80000248 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001de:	85a6                	mv	a1,s1
    800001e0:	854a                	mv	a0,s2
    800001e2:	00002097          	auipc	ra,0x2
    800001e6:	374080e7          	jalr	884(ra) # 80002556 <sleep>
    while(cons.r == cons.w){
    800001ea:	0a04a783          	lw	a5,160(s1)
    800001ee:	0a44a703          	lw	a4,164(s1)
    800001f2:	fef700e3          	beq	a4,a5,800001d2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f6:	0017871b          	addiw	a4,a5,1
    800001fa:	0ae4a023          	sw	a4,160(s1)
    800001fe:	07f7f713          	andi	a4,a5,127
    80000202:	9726                	add	a4,a4,s1
    80000204:	02074703          	lbu	a4,32(a4)
    80000208:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    8000020c:	077d0563          	beq	s10,s7,80000276 <consoleread+0x100>
    cbuf = c;
    80000210:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000214:	4685                	li	a3,1
    80000216:	f9f40613          	addi	a2,s0,-97
    8000021a:	85d2                	mv	a1,s4
    8000021c:	8556                	mv	a0,s5
    8000021e:	00002097          	auipc	ra,0x2
    80000222:	592080e7          	jalr	1426(ra) # 800027b0 <either_copyout>
    80000226:	01850663          	beq	a0,s8,80000232 <consoleread+0xbc>
    dst++;
    8000022a:	0a05                	addi	s4,s4,1
    --n;
    8000022c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000022e:	f99d1ae3          	bne	s10,s9,800001c2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000232:	00011517          	auipc	a0,0x11
    80000236:	f3e50513          	addi	a0,a0,-194 # 80011170 <cons>
    8000023a:	00001097          	auipc	ra,0x1
    8000023e:	b92080e7          	jalr	-1134(ra) # 80000dcc <release>

  return target - n;
    80000242:	413b053b          	subw	a0,s6,s3
    80000246:	a811                	j	8000025a <consoleread+0xe4>
        release(&cons.lock);
    80000248:	00011517          	auipc	a0,0x11
    8000024c:	f2850513          	addi	a0,a0,-216 # 80011170 <cons>
    80000250:	00001097          	auipc	ra,0x1
    80000254:	b7c080e7          	jalr	-1156(ra) # 80000dcc <release>
        return -1;
    80000258:	557d                	li	a0,-1
}
    8000025a:	70a6                	ld	ra,104(sp)
    8000025c:	7406                	ld	s0,96(sp)
    8000025e:	64e6                	ld	s1,88(sp)
    80000260:	6946                	ld	s2,80(sp)
    80000262:	69a6                	ld	s3,72(sp)
    80000264:	6a06                	ld	s4,64(sp)
    80000266:	7ae2                	ld	s5,56(sp)
    80000268:	7b42                	ld	s6,48(sp)
    8000026a:	7ba2                	ld	s7,40(sp)
    8000026c:	7c02                	ld	s8,32(sp)
    8000026e:	6ce2                	ld	s9,24(sp)
    80000270:	6d42                	ld	s10,16(sp)
    80000272:	6165                	addi	sp,sp,112
    80000274:	8082                	ret
      if(n < target){
    80000276:	0009871b          	sext.w	a4,s3
    8000027a:	fb677ce3          	bgeu	a4,s6,80000232 <consoleread+0xbc>
        cons.r--;
    8000027e:	00011717          	auipc	a4,0x11
    80000282:	f8f72923          	sw	a5,-110(a4) # 80011210 <cons+0xa0>
    80000286:	b775                	j	80000232 <consoleread+0xbc>

0000000080000288 <consputc>:
{
    80000288:	1141                	addi	sp,sp,-16
    8000028a:	e406                	sd	ra,8(sp)
    8000028c:	e022                	sd	s0,0(sp)
    8000028e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000290:	10000793          	li	a5,256
    80000294:	00f50a63          	beq	a0,a5,800002a8 <consputc+0x20>
    uartputc_sync(c);
    80000298:	00000097          	auipc	ra,0x0
    8000029c:	55e080e7          	jalr	1374(ra) # 800007f6 <uartputc_sync>
}
    800002a0:	60a2                	ld	ra,8(sp)
    800002a2:	6402                	ld	s0,0(sp)
    800002a4:	0141                	addi	sp,sp,16
    800002a6:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a8:	4521                	li	a0,8
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	54c080e7          	jalr	1356(ra) # 800007f6 <uartputc_sync>
    800002b2:	02000513          	li	a0,32
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	540080e7          	jalr	1344(ra) # 800007f6 <uartputc_sync>
    800002be:	4521                	li	a0,8
    800002c0:	00000097          	auipc	ra,0x0
    800002c4:	536080e7          	jalr	1334(ra) # 800007f6 <uartputc_sync>
    800002c8:	bfe1                	j	800002a0 <consputc+0x18>

00000000800002ca <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ca:	1101                	addi	sp,sp,-32
    800002cc:	ec06                	sd	ra,24(sp)
    800002ce:	e822                	sd	s0,16(sp)
    800002d0:	e426                	sd	s1,8(sp)
    800002d2:	e04a                	sd	s2,0(sp)
    800002d4:	1000                	addi	s0,sp,32
    800002d6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d8:	00011517          	auipc	a0,0x11
    800002dc:	e9850513          	addi	a0,a0,-360 # 80011170 <cons>
    800002e0:	00001097          	auipc	ra,0x1
    800002e4:	a1c080e7          	jalr	-1508(ra) # 80000cfc <acquire>

  switch(c){
    800002e8:	47d5                	li	a5,21
    800002ea:	0af48663          	beq	s1,a5,80000396 <consoleintr+0xcc>
    800002ee:	0297ca63          	blt	a5,s1,80000322 <consoleintr+0x58>
    800002f2:	47a1                	li	a5,8
    800002f4:	0ef48763          	beq	s1,a5,800003e2 <consoleintr+0x118>
    800002f8:	47c1                	li	a5,16
    800002fa:	10f49a63          	bne	s1,a5,8000040e <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fe:	00002097          	auipc	ra,0x2
    80000302:	55e080e7          	jalr	1374(ra) # 8000285c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000306:	00011517          	auipc	a0,0x11
    8000030a:	e6a50513          	addi	a0,a0,-406 # 80011170 <cons>
    8000030e:	00001097          	auipc	ra,0x1
    80000312:	abe080e7          	jalr	-1346(ra) # 80000dcc <release>
}
    80000316:	60e2                	ld	ra,24(sp)
    80000318:	6442                	ld	s0,16(sp)
    8000031a:	64a2                	ld	s1,8(sp)
    8000031c:	6902                	ld	s2,0(sp)
    8000031e:	6105                	addi	sp,sp,32
    80000320:	8082                	ret
  switch(c){
    80000322:	07f00793          	li	a5,127
    80000326:	0af48e63          	beq	s1,a5,800003e2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000032a:	00011717          	auipc	a4,0x11
    8000032e:	e4670713          	addi	a4,a4,-442 # 80011170 <cons>
    80000332:	0a872783          	lw	a5,168(a4)
    80000336:	0a072703          	lw	a4,160(a4)
    8000033a:	9f99                	subw	a5,a5,a4
    8000033c:	07f00713          	li	a4,127
    80000340:	fcf763e3          	bltu	a4,a5,80000306 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000344:	47b5                	li	a5,13
    80000346:	0cf48763          	beq	s1,a5,80000414 <consoleintr+0x14a>
      consputc(c);
    8000034a:	8526                	mv	a0,s1
    8000034c:	00000097          	auipc	ra,0x0
    80000350:	f3c080e7          	jalr	-196(ra) # 80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000354:	00011797          	auipc	a5,0x11
    80000358:	e1c78793          	addi	a5,a5,-484 # 80011170 <cons>
    8000035c:	0a87a703          	lw	a4,168(a5)
    80000360:	0017069b          	addiw	a3,a4,1
    80000364:	0006861b          	sext.w	a2,a3
    80000368:	0ad7a423          	sw	a3,168(a5)
    8000036c:	07f77713          	andi	a4,a4,127
    80000370:	97ba                	add	a5,a5,a4
    80000372:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000376:	47a9                	li	a5,10
    80000378:	0cf48563          	beq	s1,a5,80000442 <consoleintr+0x178>
    8000037c:	4791                	li	a5,4
    8000037e:	0cf48263          	beq	s1,a5,80000442 <consoleintr+0x178>
    80000382:	00011797          	auipc	a5,0x11
    80000386:	e8e7a783          	lw	a5,-370(a5) # 80011210 <cons+0xa0>
    8000038a:	0807879b          	addiw	a5,a5,128
    8000038e:	f6f61ce3          	bne	a2,a5,80000306 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000392:	863e                	mv	a2,a5
    80000394:	a07d                	j	80000442 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000396:	00011717          	auipc	a4,0x11
    8000039a:	dda70713          	addi	a4,a4,-550 # 80011170 <cons>
    8000039e:	0a872783          	lw	a5,168(a4)
    800003a2:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a6:	00011497          	auipc	s1,0x11
    800003aa:	dca48493          	addi	s1,s1,-566 # 80011170 <cons>
    while(cons.e != cons.w &&
    800003ae:	4929                	li	s2,10
    800003b0:	f4f70be3          	beq	a4,a5,80000306 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b4:	37fd                	addiw	a5,a5,-1
    800003b6:	07f7f713          	andi	a4,a5,127
    800003ba:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003bc:	02074703          	lbu	a4,32(a4)
    800003c0:	f52703e3          	beq	a4,s2,80000306 <consoleintr+0x3c>
      cons.e--;
    800003c4:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    800003c8:	10000513          	li	a0,256
    800003cc:	00000097          	auipc	ra,0x0
    800003d0:	ebc080e7          	jalr	-324(ra) # 80000288 <consputc>
    while(cons.e != cons.w &&
    800003d4:	0a84a783          	lw	a5,168(s1)
    800003d8:	0a44a703          	lw	a4,164(s1)
    800003dc:	fcf71ce3          	bne	a4,a5,800003b4 <consoleintr+0xea>
    800003e0:	b71d                	j	80000306 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e2:	00011717          	auipc	a4,0x11
    800003e6:	d8e70713          	addi	a4,a4,-626 # 80011170 <cons>
    800003ea:	0a872783          	lw	a5,168(a4)
    800003ee:	0a472703          	lw	a4,164(a4)
    800003f2:	f0f70ae3          	beq	a4,a5,80000306 <consoleintr+0x3c>
      cons.e--;
    800003f6:	37fd                	addiw	a5,a5,-1
    800003f8:	00011717          	auipc	a4,0x11
    800003fc:	e2f72023          	sw	a5,-480(a4) # 80011218 <cons+0xa8>
      consputc(BACKSPACE);
    80000400:	10000513          	li	a0,256
    80000404:	00000097          	auipc	ra,0x0
    80000408:	e84080e7          	jalr	-380(ra) # 80000288 <consputc>
    8000040c:	bded                	j	80000306 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040e:	ee048ce3          	beqz	s1,80000306 <consoleintr+0x3c>
    80000412:	bf21                	j	8000032a <consoleintr+0x60>
      consputc(c);
    80000414:	4529                	li	a0,10
    80000416:	00000097          	auipc	ra,0x0
    8000041a:	e72080e7          	jalr	-398(ra) # 80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041e:	00011797          	auipc	a5,0x11
    80000422:	d5278793          	addi	a5,a5,-686 # 80011170 <cons>
    80000426:	0a87a703          	lw	a4,168(a5)
    8000042a:	0017069b          	addiw	a3,a4,1
    8000042e:	0006861b          	sext.w	a2,a3
    80000432:	0ad7a423          	sw	a3,168(a5)
    80000436:	07f77713          	andi	a4,a4,127
    8000043a:	97ba                	add	a5,a5,a4
    8000043c:	4729                	li	a4,10
    8000043e:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    80000442:	00011797          	auipc	a5,0x11
    80000446:	dcc7a923          	sw	a2,-558(a5) # 80011214 <cons+0xa4>
        wakeup(&cons.r);
    8000044a:	00011517          	auipc	a0,0x11
    8000044e:	dc650513          	addi	a0,a0,-570 # 80011210 <cons+0xa0>
    80000452:	00002097          	auipc	ra,0x2
    80000456:	284080e7          	jalr	644(ra) # 800026d6 <wakeup>
    8000045a:	b575                	j	80000306 <consoleintr+0x3c>

000000008000045c <consoleinit>:

void
consoleinit(void)
{
    8000045c:	1141                	addi	sp,sp,-16
    8000045e:	e406                	sd	ra,8(sp)
    80000460:	e022                	sd	s0,0(sp)
    80000462:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000464:	00008597          	auipc	a1,0x8
    80000468:	bac58593          	addi	a1,a1,-1108 # 80008010 <etext+0x10>
    8000046c:	00011517          	auipc	a0,0x11
    80000470:	d0450513          	addi	a0,a0,-764 # 80011170 <cons>
    80000474:	00001097          	auipc	ra,0x1
    80000478:	a04080e7          	jalr	-1532(ra) # 80000e78 <initlock>

  uartinit();
    8000047c:	00000097          	auipc	ra,0x0
    80000480:	32a080e7          	jalr	810(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000484:	00026797          	auipc	a5,0x26
    80000488:	03478793          	addi	a5,a5,52 # 800264b8 <devsw>
    8000048c:	00000717          	auipc	a4,0x0
    80000490:	cea70713          	addi	a4,a4,-790 # 80000176 <consoleread>
    80000494:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000496:	00000717          	auipc	a4,0x0
    8000049a:	c5e70713          	addi	a4,a4,-930 # 800000f4 <consolewrite>
    8000049e:	ef98                	sd	a4,24(a5)
}
    800004a0:	60a2                	ld	ra,8(sp)
    800004a2:	6402                	ld	s0,0(sp)
    800004a4:	0141                	addi	sp,sp,16
    800004a6:	8082                	ret

00000000800004a8 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a8:	7179                	addi	sp,sp,-48
    800004aa:	f406                	sd	ra,40(sp)
    800004ac:	f022                	sd	s0,32(sp)
    800004ae:	ec26                	sd	s1,24(sp)
    800004b0:	e84a                	sd	s2,16(sp)
    800004b2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b4:	c219                	beqz	a2,800004ba <printint+0x12>
    800004b6:	08054663          	bltz	a0,80000542 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ba:	2501                	sext.w	a0,a0
    800004bc:	4881                	li	a7,0
    800004be:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c4:	2581                	sext.w	a1,a1
    800004c6:	00008617          	auipc	a2,0x8
    800004ca:	b7a60613          	addi	a2,a2,-1158 # 80008040 <digits>
    800004ce:	883a                	mv	a6,a4
    800004d0:	2705                	addiw	a4,a4,1
    800004d2:	02b577bb          	remuw	a5,a0,a1
    800004d6:	1782                	slli	a5,a5,0x20
    800004d8:	9381                	srli	a5,a5,0x20
    800004da:	97b2                	add	a5,a5,a2
    800004dc:	0007c783          	lbu	a5,0(a5)
    800004e0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e4:	0005079b          	sext.w	a5,a0
    800004e8:	02b5553b          	divuw	a0,a0,a1
    800004ec:	0685                	addi	a3,a3,1
    800004ee:	feb7f0e3          	bgeu	a5,a1,800004ce <printint+0x26>

  if(sign)
    800004f2:	00088b63          	beqz	a7,80000508 <printint+0x60>
    buf[i++] = '-';
    800004f6:	fe040793          	addi	a5,s0,-32
    800004fa:	973e                	add	a4,a4,a5
    800004fc:	02d00793          	li	a5,45
    80000500:	fef70823          	sb	a5,-16(a4)
    80000504:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000508:	02e05763          	blez	a4,80000536 <printint+0x8e>
    8000050c:	fd040793          	addi	a5,s0,-48
    80000510:	00e784b3          	add	s1,a5,a4
    80000514:	fff78913          	addi	s2,a5,-1
    80000518:	993a                	add	s2,s2,a4
    8000051a:	377d                	addiw	a4,a4,-1
    8000051c:	1702                	slli	a4,a4,0x20
    8000051e:	9301                	srli	a4,a4,0x20
    80000520:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000524:	fff4c503          	lbu	a0,-1(s1)
    80000528:	00000097          	auipc	ra,0x0
    8000052c:	d60080e7          	jalr	-672(ra) # 80000288 <consputc>
  while(--i >= 0)
    80000530:	14fd                	addi	s1,s1,-1
    80000532:	ff2499e3          	bne	s1,s2,80000524 <printint+0x7c>
}
    80000536:	70a2                	ld	ra,40(sp)
    80000538:	7402                	ld	s0,32(sp)
    8000053a:	64e2                	ld	s1,24(sp)
    8000053c:	6942                	ld	s2,16(sp)
    8000053e:	6145                	addi	sp,sp,48
    80000540:	8082                	ret
    x = -xx;
    80000542:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000546:	4885                	li	a7,1
    x = -xx;
    80000548:	bf9d                	j	800004be <printint+0x16>

000000008000054a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000054a:	1101                	addi	sp,sp,-32
    8000054c:	ec06                	sd	ra,24(sp)
    8000054e:	e822                	sd	s0,16(sp)
    80000550:	e426                	sd	s1,8(sp)
    80000552:	1000                	addi	s0,sp,32
    80000554:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000556:	00011797          	auipc	a5,0x11
    8000055a:	ce07a523          	sw	zero,-790(a5) # 80011240 <pr+0x20>
  printf("panic: ");
    8000055e:	00008517          	auipc	a0,0x8
    80000562:	aba50513          	addi	a0,a0,-1350 # 80008018 <etext+0x18>
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	02e080e7          	jalr	46(ra) # 80000594 <printf>
  printf(s);
    8000056e:	8526                	mv	a0,s1
    80000570:	00000097          	auipc	ra,0x0
    80000574:	024080e7          	jalr	36(ra) # 80000594 <printf>
  printf("\n");
    80000578:	00008517          	auipc	a0,0x8
    8000057c:	bf050513          	addi	a0,a0,-1040 # 80008168 <digits+0x128>
    80000580:	00000097          	auipc	ra,0x0
    80000584:	014080e7          	jalr	20(ra) # 80000594 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000588:	4785                	li	a5,1
    8000058a:	00009717          	auipc	a4,0x9
    8000058e:	a6f72b23          	sw	a5,-1418(a4) # 80009000 <panicked>
  for(;;)
    80000592:	a001                	j	80000592 <panic+0x48>

0000000080000594 <printf>:
{
    80000594:	7131                	addi	sp,sp,-192
    80000596:	fc86                	sd	ra,120(sp)
    80000598:	f8a2                	sd	s0,112(sp)
    8000059a:	f4a6                	sd	s1,104(sp)
    8000059c:	f0ca                	sd	s2,96(sp)
    8000059e:	ecce                	sd	s3,88(sp)
    800005a0:	e8d2                	sd	s4,80(sp)
    800005a2:	e4d6                	sd	s5,72(sp)
    800005a4:	e0da                	sd	s6,64(sp)
    800005a6:	fc5e                	sd	s7,56(sp)
    800005a8:	f862                	sd	s8,48(sp)
    800005aa:	f466                	sd	s9,40(sp)
    800005ac:	f06a                	sd	s10,32(sp)
    800005ae:	ec6e                	sd	s11,24(sp)
    800005b0:	0100                	addi	s0,sp,128
    800005b2:	8a2a                	mv	s4,a0
    800005b4:	e40c                	sd	a1,8(s0)
    800005b6:	e810                	sd	a2,16(s0)
    800005b8:	ec14                	sd	a3,24(s0)
    800005ba:	f018                	sd	a4,32(s0)
    800005bc:	f41c                	sd	a5,40(s0)
    800005be:	03043823          	sd	a6,48(s0)
    800005c2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c6:	00011d97          	auipc	s11,0x11
    800005ca:	c7adad83          	lw	s11,-902(s11) # 80011240 <pr+0x20>
  if(locking)
    800005ce:	020d9b63          	bnez	s11,80000604 <printf+0x70>
  if (fmt == 0)
    800005d2:	040a0263          	beqz	s4,80000616 <printf+0x82>
  va_start(ap, fmt);
    800005d6:	00840793          	addi	a5,s0,8
    800005da:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005de:	000a4503          	lbu	a0,0(s4)
    800005e2:	14050f63          	beqz	a0,80000740 <printf+0x1ac>
    800005e6:	4981                	li	s3,0
    if(c != '%'){
    800005e8:	02500a93          	li	s5,37
    switch(c){
    800005ec:	07000b93          	li	s7,112
  consputc('x');
    800005f0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f2:	00008b17          	auipc	s6,0x8
    800005f6:	a4eb0b13          	addi	s6,s6,-1458 # 80008040 <digits>
    switch(c){
    800005fa:	07300c93          	li	s9,115
    800005fe:	06400c13          	li	s8,100
    80000602:	a82d                	j	8000063c <printf+0xa8>
    acquire(&pr.lock);
    80000604:	00011517          	auipc	a0,0x11
    80000608:	c1c50513          	addi	a0,a0,-996 # 80011220 <pr>
    8000060c:	00000097          	auipc	ra,0x0
    80000610:	6f0080e7          	jalr	1776(ra) # 80000cfc <acquire>
    80000614:	bf7d                	j	800005d2 <printf+0x3e>
    panic("null fmt");
    80000616:	00008517          	auipc	a0,0x8
    8000061a:	a1250513          	addi	a0,a0,-1518 # 80008028 <etext+0x28>
    8000061e:	00000097          	auipc	ra,0x0
    80000622:	f2c080e7          	jalr	-212(ra) # 8000054a <panic>
      consputc(c);
    80000626:	00000097          	auipc	ra,0x0
    8000062a:	c62080e7          	jalr	-926(ra) # 80000288 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062e:	2985                	addiw	s3,s3,1
    80000630:	013a07b3          	add	a5,s4,s3
    80000634:	0007c503          	lbu	a0,0(a5)
    80000638:	10050463          	beqz	a0,80000740 <printf+0x1ac>
    if(c != '%'){
    8000063c:	ff5515e3          	bne	a0,s5,80000626 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000640:	2985                	addiw	s3,s3,1
    80000642:	013a07b3          	add	a5,s4,s3
    80000646:	0007c783          	lbu	a5,0(a5)
    8000064a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000064e:	cbed                	beqz	a5,80000740 <printf+0x1ac>
    switch(c){
    80000650:	05778a63          	beq	a5,s7,800006a4 <printf+0x110>
    80000654:	02fbf663          	bgeu	s7,a5,80000680 <printf+0xec>
    80000658:	09978863          	beq	a5,s9,800006e8 <printf+0x154>
    8000065c:	07800713          	li	a4,120
    80000660:	0ce79563          	bne	a5,a4,8000072a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000664:	f8843783          	ld	a5,-120(s0)
    80000668:	00878713          	addi	a4,a5,8
    8000066c:	f8e43423          	sd	a4,-120(s0)
    80000670:	4605                	li	a2,1
    80000672:	85ea                	mv	a1,s10
    80000674:	4388                	lw	a0,0(a5)
    80000676:	00000097          	auipc	ra,0x0
    8000067a:	e32080e7          	jalr	-462(ra) # 800004a8 <printint>
      break;
    8000067e:	bf45                	j	8000062e <printf+0x9a>
    switch(c){
    80000680:	09578f63          	beq	a5,s5,8000071e <printf+0x18a>
    80000684:	0b879363          	bne	a5,s8,8000072a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000688:	f8843783          	ld	a5,-120(s0)
    8000068c:	00878713          	addi	a4,a5,8
    80000690:	f8e43423          	sd	a4,-120(s0)
    80000694:	4605                	li	a2,1
    80000696:	45a9                	li	a1,10
    80000698:	4388                	lw	a0,0(a5)
    8000069a:	00000097          	auipc	ra,0x0
    8000069e:	e0e080e7          	jalr	-498(ra) # 800004a8 <printint>
      break;
    800006a2:	b771                	j	8000062e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a4:	f8843783          	ld	a5,-120(s0)
    800006a8:	00878713          	addi	a4,a5,8
    800006ac:	f8e43423          	sd	a4,-120(s0)
    800006b0:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006b4:	03000513          	li	a0,48
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bd0080e7          	jalr	-1072(ra) # 80000288 <consputc>
  consputc('x');
    800006c0:	07800513          	li	a0,120
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	bc4080e7          	jalr	-1084(ra) # 80000288 <consputc>
    800006cc:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ce:	03c95793          	srli	a5,s2,0x3c
    800006d2:	97da                	add	a5,a5,s6
    800006d4:	0007c503          	lbu	a0,0(a5)
    800006d8:	00000097          	auipc	ra,0x0
    800006dc:	bb0080e7          	jalr	-1104(ra) # 80000288 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e0:	0912                	slli	s2,s2,0x4
    800006e2:	34fd                	addiw	s1,s1,-1
    800006e4:	f4ed                	bnez	s1,800006ce <printf+0x13a>
    800006e6:	b7a1                	j	8000062e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	6384                	ld	s1,0(a5)
    800006f6:	cc89                	beqz	s1,80000710 <printf+0x17c>
      for(; *s; s++)
    800006f8:	0004c503          	lbu	a0,0(s1)
    800006fc:	d90d                	beqz	a0,8000062e <printf+0x9a>
        consputc(*s);
    800006fe:	00000097          	auipc	ra,0x0
    80000702:	b8a080e7          	jalr	-1142(ra) # 80000288 <consputc>
      for(; *s; s++)
    80000706:	0485                	addi	s1,s1,1
    80000708:	0004c503          	lbu	a0,0(s1)
    8000070c:	f96d                	bnez	a0,800006fe <printf+0x16a>
    8000070e:	b705                	j	8000062e <printf+0x9a>
        s = "(null)";
    80000710:	00008497          	auipc	s1,0x8
    80000714:	91048493          	addi	s1,s1,-1776 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000718:	02800513          	li	a0,40
    8000071c:	b7cd                	j	800006fe <printf+0x16a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b68080e7          	jalr	-1176(ra) # 80000288 <consputc>
      break;
    80000728:	b719                	j	8000062e <printf+0x9a>
      consputc('%');
    8000072a:	8556                	mv	a0,s5
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b5c080e7          	jalr	-1188(ra) # 80000288 <consputc>
      consputc(c);
    80000734:	8526                	mv	a0,s1
    80000736:	00000097          	auipc	ra,0x0
    8000073a:	b52080e7          	jalr	-1198(ra) # 80000288 <consputc>
      break;
    8000073e:	bdc5                	j	8000062e <printf+0x9a>
  if(locking)
    80000740:	020d9163          	bnez	s11,80000762 <printf+0x1ce>
}
    80000744:	70e6                	ld	ra,120(sp)
    80000746:	7446                	ld	s0,112(sp)
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	7906                	ld	s2,96(sp)
    8000074c:	69e6                	ld	s3,88(sp)
    8000074e:	6a46                	ld	s4,80(sp)
    80000750:	6aa6                	ld	s5,72(sp)
    80000752:	6b06                	ld	s6,64(sp)
    80000754:	7be2                	ld	s7,56(sp)
    80000756:	7c42                	ld	s8,48(sp)
    80000758:	7ca2                	ld	s9,40(sp)
    8000075a:	7d02                	ld	s10,32(sp)
    8000075c:	6de2                	ld	s11,24(sp)
    8000075e:	6129                	addi	sp,sp,192
    80000760:	8082                	ret
    release(&pr.lock);
    80000762:	00011517          	auipc	a0,0x11
    80000766:	abe50513          	addi	a0,a0,-1346 # 80011220 <pr>
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	662080e7          	jalr	1634(ra) # 80000dcc <release>
}
    80000772:	bfc9                	j	80000744 <printf+0x1b0>

0000000080000774 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000774:	1101                	addi	sp,sp,-32
    80000776:	ec06                	sd	ra,24(sp)
    80000778:	e822                	sd	s0,16(sp)
    8000077a:	e426                	sd	s1,8(sp)
    8000077c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077e:	00011497          	auipc	s1,0x11
    80000782:	aa248493          	addi	s1,s1,-1374 # 80011220 <pr>
    80000786:	00008597          	auipc	a1,0x8
    8000078a:	8b258593          	addi	a1,a1,-1870 # 80008038 <etext+0x38>
    8000078e:	8526                	mv	a0,s1
    80000790:	00000097          	auipc	ra,0x0
    80000794:	6e8080e7          	jalr	1768(ra) # 80000e78 <initlock>
  pr.locking = 1;
    80000798:	4785                	li	a5,1
    8000079a:	d09c                	sw	a5,32(s1)
}
    8000079c:	60e2                	ld	ra,24(sp)
    8000079e:	6442                	ld	s0,16(sp)
    800007a0:	64a2                	ld	s1,8(sp)
    800007a2:	6105                	addi	sp,sp,32
    800007a4:	8082                	ret

00000000800007a6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a6:	1141                	addi	sp,sp,-16
    800007a8:	e406                	sd	ra,8(sp)
    800007aa:	e022                	sd	s0,0(sp)
    800007ac:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ae:	100007b7          	lui	a5,0x10000
    800007b2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b6:	f8000713          	li	a4,-128
    800007ba:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007be:	470d                	li	a4,3
    800007c0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007cc:	469d                	li	a3,7
    800007ce:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	88258593          	addi	a1,a1,-1918 # 80008058 <digits+0x18>
    800007de:	00011517          	auipc	a0,0x11
    800007e2:	a6a50513          	addi	a0,a0,-1430 # 80011248 <uart_tx_lock>
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	692080e7          	jalr	1682(ra) # 80000e78 <initlock>
}
    800007ee:	60a2                	ld	ra,8(sp)
    800007f0:	6402                	ld	s0,0(sp)
    800007f2:	0141                	addi	sp,sp,16
    800007f4:	8082                	ret

00000000800007f6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f6:	1101                	addi	sp,sp,-32
    800007f8:	ec06                	sd	ra,24(sp)
    800007fa:	e822                	sd	s0,16(sp)
    800007fc:	e426                	sd	s1,8(sp)
    800007fe:	1000                	addi	s0,sp,32
    80000800:	84aa                	mv	s1,a0
  push_off();
    80000802:	00000097          	auipc	ra,0x0
    80000806:	4ae080e7          	jalr	1198(ra) # 80000cb0 <push_off>

  if(panicked){
    8000080a:	00008797          	auipc	a5,0x8
    8000080e:	7f67a783          	lw	a5,2038(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	10000737          	lui	a4,0x10000
  if(panicked){
    80000816:	c391                	beqz	a5,8000081a <uartputc_sync+0x24>
    for(;;)
    80000818:	a001                	j	80000818 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000081e:	0207f793          	andi	a5,a5,32
    80000822:	dfe5                	beqz	a5,8000081a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000824:	0ff4f513          	andi	a0,s1,255
    80000828:	100007b7          	lui	a5,0x10000
    8000082c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000830:	00000097          	auipc	ra,0x0
    80000834:	53c080e7          	jalr	1340(ra) # 80000d6c <pop_off>
}
    80000838:	60e2                	ld	ra,24(sp)
    8000083a:	6442                	ld	s0,16(sp)
    8000083c:	64a2                	ld	s1,8(sp)
    8000083e:	6105                	addi	sp,sp,32
    80000840:	8082                	ret

0000000080000842 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000842:	00008797          	auipc	a5,0x8
    80000846:	7c27a783          	lw	a5,1986(a5) # 80009004 <uart_tx_r>
    8000084a:	00008717          	auipc	a4,0x8
    8000084e:	7be72703          	lw	a4,1982(a4) # 80009008 <uart_tx_w>
    80000852:	08f70063          	beq	a4,a5,800008d2 <uartstart+0x90>
{
    80000856:	7139                	addi	sp,sp,-64
    80000858:	fc06                	sd	ra,56(sp)
    8000085a:	f822                	sd	s0,48(sp)
    8000085c:	f426                	sd	s1,40(sp)
    8000085e:	f04a                	sd	s2,32(sp)
    80000860:	ec4e                	sd	s3,24(sp)
    80000862:	e852                	sd	s4,16(sp)
    80000864:	e456                	sd	s5,8(sp)
    80000866:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000868:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    8000086c:	00011a97          	auipc	s5,0x11
    80000870:	9dca8a93          	addi	s5,s5,-1572 # 80011248 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000874:	00008497          	auipc	s1,0x8
    80000878:	79048493          	addi	s1,s1,1936 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000087c:	00008a17          	auipc	s4,0x8
    80000880:	78ca0a13          	addi	s4,s4,1932 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000884:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000888:	02077713          	andi	a4,a4,32
    8000088c:	cb15                	beqz	a4,800008c0 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r];
    8000088e:	00fa8733          	add	a4,s5,a5
    80000892:	02074983          	lbu	s3,32(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000896:	2785                	addiw	a5,a5,1
    80000898:	41f7d71b          	sraiw	a4,a5,0x1f
    8000089c:	01b7571b          	srliw	a4,a4,0x1b
    800008a0:	9fb9                	addw	a5,a5,a4
    800008a2:	8bfd                	andi	a5,a5,31
    800008a4:	9f99                	subw	a5,a5,a4
    800008a6:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a8:	8526                	mv	a0,s1
    800008aa:	00002097          	auipc	ra,0x2
    800008ae:	e2c080e7          	jalr	-468(ra) # 800026d6 <wakeup>
    
    WriteReg(THR, c);
    800008b2:	01390023          	sb	s3,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b6:	409c                	lw	a5,0(s1)
    800008b8:	000a2703          	lw	a4,0(s4)
    800008bc:	fcf714e3          	bne	a4,a5,80000884 <uartstart+0x42>
  }
}
    800008c0:	70e2                	ld	ra,56(sp)
    800008c2:	7442                	ld	s0,48(sp)
    800008c4:	74a2                	ld	s1,40(sp)
    800008c6:	7902                	ld	s2,32(sp)
    800008c8:	69e2                	ld	s3,24(sp)
    800008ca:	6a42                	ld	s4,16(sp)
    800008cc:	6aa2                	ld	s5,8(sp)
    800008ce:	6121                	addi	sp,sp,64
    800008d0:	8082                	ret
    800008d2:	8082                	ret

00000000800008d4 <uartputc>:
{
    800008d4:	7179                	addi	sp,sp,-48
    800008d6:	f406                	sd	ra,40(sp)
    800008d8:	f022                	sd	s0,32(sp)
    800008da:	ec26                	sd	s1,24(sp)
    800008dc:	e84a                	sd	s2,16(sp)
    800008de:	e44e                	sd	s3,8(sp)
    800008e0:	e052                	sd	s4,0(sp)
    800008e2:	1800                	addi	s0,sp,48
    800008e4:	84aa                	mv	s1,a0
  acquire(&uart_tx_lock);
    800008e6:	00011517          	auipc	a0,0x11
    800008ea:	96250513          	addi	a0,a0,-1694 # 80011248 <uart_tx_lock>
    800008ee:	00000097          	auipc	ra,0x0
    800008f2:	40e080e7          	jalr	1038(ra) # 80000cfc <acquire>
  if(panicked){
    800008f6:	00008797          	auipc	a5,0x8
    800008fa:	70a7a783          	lw	a5,1802(a5) # 80009000 <panicked>
    800008fe:	c391                	beqz	a5,80000902 <uartputc+0x2e>
    for(;;)
    80000900:	a001                	j	80000900 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000902:	00008697          	auipc	a3,0x8
    80000906:	7066a683          	lw	a3,1798(a3) # 80009008 <uart_tx_w>
    8000090a:	0016879b          	addiw	a5,a3,1
    8000090e:	41f7d71b          	sraiw	a4,a5,0x1f
    80000912:	01b7571b          	srliw	a4,a4,0x1b
    80000916:	9fb9                	addw	a5,a5,a4
    80000918:	8bfd                	andi	a5,a5,31
    8000091a:	9f99                	subw	a5,a5,a4
    8000091c:	00008717          	auipc	a4,0x8
    80000920:	6e872703          	lw	a4,1768(a4) # 80009004 <uart_tx_r>
    80000924:	04f71363          	bne	a4,a5,8000096a <uartputc+0x96>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000928:	00011a17          	auipc	s4,0x11
    8000092c:	920a0a13          	addi	s4,s4,-1760 # 80011248 <uart_tx_lock>
    80000930:	00008917          	auipc	s2,0x8
    80000934:	6d490913          	addi	s2,s2,1748 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000938:	00008997          	auipc	s3,0x8
    8000093c:	6d098993          	addi	s3,s3,1744 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000940:	85d2                	mv	a1,s4
    80000942:	854a                	mv	a0,s2
    80000944:	00002097          	auipc	ra,0x2
    80000948:	c12080e7          	jalr	-1006(ra) # 80002556 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000094c:	0009a683          	lw	a3,0(s3)
    80000950:	0016879b          	addiw	a5,a3,1
    80000954:	41f7d71b          	sraiw	a4,a5,0x1f
    80000958:	01b7571b          	srliw	a4,a4,0x1b
    8000095c:	9fb9                	addw	a5,a5,a4
    8000095e:	8bfd                	andi	a5,a5,31
    80000960:	9f99                	subw	a5,a5,a4
    80000962:	00092703          	lw	a4,0(s2)
    80000966:	fcf70de3          	beq	a4,a5,80000940 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    8000096a:	00011917          	auipc	s2,0x11
    8000096e:	8de90913          	addi	s2,s2,-1826 # 80011248 <uart_tx_lock>
    80000972:	96ca                	add	a3,a3,s2
    80000974:	02968023          	sb	s1,32(a3)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000978:	00008717          	auipc	a4,0x8
    8000097c:	68f72823          	sw	a5,1680(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000980:	00000097          	auipc	ra,0x0
    80000984:	ec2080e7          	jalr	-318(ra) # 80000842 <uartstart>
      release(&uart_tx_lock);
    80000988:	854a                	mv	a0,s2
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	442080e7          	jalr	1090(ra) # 80000dcc <release>
}
    80000992:	70a2                	ld	ra,40(sp)
    80000994:	7402                	ld	s0,32(sp)
    80000996:	64e2                	ld	s1,24(sp)
    80000998:	6942                	ld	s2,16(sp)
    8000099a:	69a2                	ld	s3,8(sp)
    8000099c:	6a02                	ld	s4,0(sp)
    8000099e:	6145                	addi	sp,sp,48
    800009a0:	8082                	ret

00000000800009a2 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009a2:	1141                	addi	sp,sp,-16
    800009a4:	e422                	sd	s0,8(sp)
    800009a6:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009a8:	100007b7          	lui	a5,0x10000
    800009ac:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009b0:	8b85                	andi	a5,a5,1
    800009b2:	cb91                	beqz	a5,800009c6 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009b4:	100007b7          	lui	a5,0x10000
    800009b8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009bc:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009c0:	6422                	ld	s0,8(sp)
    800009c2:	0141                	addi	sp,sp,16
    800009c4:	8082                	ret
    return -1;
    800009c6:	557d                	li	a0,-1
    800009c8:	bfe5                	j	800009c0 <uartgetc+0x1e>

00000000800009ca <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009ca:	1101                	addi	sp,sp,-32
    800009cc:	ec06                	sd	ra,24(sp)
    800009ce:	e822                	sd	s0,16(sp)
    800009d0:	e426                	sd	s1,8(sp)
    800009d2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009d4:	54fd                	li	s1,-1
    800009d6:	a029                	j	800009e0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	8f2080e7          	jalr	-1806(ra) # 800002ca <consoleintr>
    int c = uartgetc();
    800009e0:	00000097          	auipc	ra,0x0
    800009e4:	fc2080e7          	jalr	-62(ra) # 800009a2 <uartgetc>
    if(c == -1)
    800009e8:	fe9518e3          	bne	a0,s1,800009d8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ec:	00011497          	auipc	s1,0x11
    800009f0:	85c48493          	addi	s1,s1,-1956 # 80011248 <uart_tx_lock>
    800009f4:	8526                	mv	a0,s1
    800009f6:	00000097          	auipc	ra,0x0
    800009fa:	306080e7          	jalr	774(ra) # 80000cfc <acquire>
  uartstart();
    800009fe:	00000097          	auipc	ra,0x0
    80000a02:	e44080e7          	jalr	-444(ra) # 80000842 <uartstart>
  release(&uart_tx_lock);
    80000a06:	8526                	mv	a0,s1
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	3c4080e7          	jalr	964(ra) # 80000dcc <release>
}
    80000a10:	60e2                	ld	ra,24(sp)
    80000a12:	6442                	ld	s0,16(sp)
    80000a14:	64a2                	ld	s1,8(sp)
    80000a16:	6105                	addi	sp,sp,32
    80000a18:	8082                	ret

0000000080000a1a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1a:	7139                	addi	sp,sp,-64
    80000a1c:	fc06                	sd	ra,56(sp)
    80000a1e:	f822                	sd	s0,48(sp)
    80000a20:	f426                	sd	s1,40(sp)
    80000a22:	f04a                	sd	s2,32(sp)
    80000a24:	ec4e                	sd	s3,24(sp)
    80000a26:	e852                	sd	s4,16(sp)
    80000a28:	e456                	sd	s5,8(sp)
    80000a2a:	0080                	addi	s0,sp,64
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a2c:	03451793          	slli	a5,a0,0x34
    80000a30:	e3c1                	bnez	a5,80000ab0 <kfree+0x96>
    80000a32:	84aa                	mv	s1,a0
    80000a34:	0002b797          	auipc	a5,0x2b
    80000a38:	5f478793          	addi	a5,a5,1524 # 8002c028 <end>
    80000a3c:	06f56a63          	bltu	a0,a5,80000ab0 <kfree+0x96>
    80000a40:	47c5                	li	a5,17
    80000a42:	07ee                	slli	a5,a5,0x1b
    80000a44:	06f57663          	bgeu	a0,a5,80000ab0 <kfree+0x96>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a48:	6605                	lui	a2,0x1
    80000a4a:	4585                	li	a1,1
    80000a4c:	00000097          	auipc	ra,0x0
    80000a50:	690080e7          	jalr	1680(ra) # 800010dc <memset>

  r = (struct run*)pa;

  push_off();
    80000a54:	00000097          	auipc	ra,0x0
    80000a58:	25c080e7          	jalr	604(ra) # 80000cb0 <push_off>
  int cpu = cpuid();
    80000a5c:	00001097          	auipc	ra,0x1
    80000a60:	2ba080e7          	jalr	698(ra) # 80001d16 <cpuid>
  acquire(&kmem[cpu].lock);
    80000a64:	00011a97          	auipc	s5,0x11
    80000a68:	824a8a93          	addi	s5,s5,-2012 # 80011288 <kmem>
    80000a6c:	00151993          	slli	s3,a0,0x1
    80000a70:	00a98933          	add	s2,s3,a0
    80000a74:	0912                	slli	s2,s2,0x4
    80000a76:	9956                	add	s2,s2,s5
    80000a78:	854a                	mv	a0,s2
    80000a7a:	00000097          	auipc	ra,0x0
    80000a7e:	282080e7          	jalr	642(ra) # 80000cfc <acquire>
  r->next = kmem[cpu].freelist;
    80000a82:	02893783          	ld	a5,40(s2)
    80000a86:	e09c                	sd	a5,0(s1)
  kmem[cpu].freelist = r;
    80000a88:	02993423          	sd	s1,40(s2)
  release(&kmem[cpu].lock);
    80000a8c:	854a                	mv	a0,s2
    80000a8e:	00000097          	auipc	ra,0x0
    80000a92:	33e080e7          	jalr	830(ra) # 80000dcc <release>
  pop_off();
    80000a96:	00000097          	auipc	ra,0x0
    80000a9a:	2d6080e7          	jalr	726(ra) # 80000d6c <pop_off>
}
    80000a9e:	70e2                	ld	ra,56(sp)
    80000aa0:	7442                	ld	s0,48(sp)
    80000aa2:	74a2                	ld	s1,40(sp)
    80000aa4:	7902                	ld	s2,32(sp)
    80000aa6:	69e2                	ld	s3,24(sp)
    80000aa8:	6a42                	ld	s4,16(sp)
    80000aaa:	6aa2                	ld	s5,8(sp)
    80000aac:	6121                	addi	sp,sp,64
    80000aae:	8082                	ret
    panic("kfree");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	5b050513          	addi	a0,a0,1456 # 80008060 <digits+0x20>
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	a92080e7          	jalr	-1390(ra) # 8000054a <panic>

0000000080000ac0 <freerange>:
{
    80000ac0:	7179                	addi	sp,sp,-48
    80000ac2:	f406                	sd	ra,40(sp)
    80000ac4:	f022                	sd	s0,32(sp)
    80000ac6:	ec26                	sd	s1,24(sp)
    80000ac8:	e84a                	sd	s2,16(sp)
    80000aca:	e44e                	sd	s3,8(sp)
    80000acc:	e052                	sd	s4,0(sp)
    80000ace:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad0:	6785                	lui	a5,0x1
    80000ad2:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ad6:	94aa                	add	s1,s1,a0
    80000ad8:	757d                	lui	a0,0xfffff
    80000ada:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000adc:	94be                	add	s1,s1,a5
    80000ade:	0095ee63          	bltu	a1,s1,80000afa <freerange+0x3a>
    80000ae2:	892e                	mv	s2,a1
    kfree(p);
    80000ae4:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae6:	6985                	lui	s3,0x1
    kfree(p);
    80000ae8:	01448533          	add	a0,s1,s4
    80000aec:	00000097          	auipc	ra,0x0
    80000af0:	f2e080e7          	jalr	-210(ra) # 80000a1a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af4:	94ce                	add	s1,s1,s3
    80000af6:	fe9979e3          	bgeu	s2,s1,80000ae8 <freerange+0x28>
}
    80000afa:	70a2                	ld	ra,40(sp)
    80000afc:	7402                	ld	s0,32(sp)
    80000afe:	64e2                	ld	s1,24(sp)
    80000b00:	6942                	ld	s2,16(sp)
    80000b02:	69a2                	ld	s3,8(sp)
    80000b04:	6a02                	ld	s4,0(sp)
    80000b06:	6145                	addi	sp,sp,48
    80000b08:	8082                	ret

0000000080000b0a <kinit>:
{
    80000b0a:	7139                	addi	sp,sp,-64
    80000b0c:	fc06                	sd	ra,56(sp)
    80000b0e:	f822                	sd	s0,48(sp)
    80000b10:	f426                	sd	s1,40(sp)
    80000b12:	f04a                	sd	s2,32(sp)
    80000b14:	ec4e                	sd	s3,24(sp)
    80000b16:	e852                	sd	s4,16(sp)
    80000b18:	e456                	sd	s5,8(sp)
    80000b1a:	0080                	addi	s0,sp,64
  for(int i = 0; i < NCPU; i++) {
    80000b1c:	00010917          	auipc	s2,0x10
    80000b20:	76c90913          	addi	s2,s2,1900 # 80011288 <kmem>
    80000b24:	4481                	li	s1,0
    snprintf(kmem[i].lock_name, LOCK_NAME_N, "kmem%d", i);
    80000b26:	00007a97          	auipc	s5,0x7
    80000b2a:	542a8a93          	addi	s5,s5,1346 # 80008068 <digits+0x28>
  for(int i = 0; i < NCPU; i++) {
    80000b2e:	4a21                	li	s4,8
    snprintf(kmem[i].lock_name, LOCK_NAME_N, "kmem%d", i);
    80000b30:	02090993          	addi	s3,s2,32
    80000b34:	86a6                	mv	a3,s1
    80000b36:	8656                	mv	a2,s5
    80000b38:	4599                	li	a1,6
    80000b3a:	854e                	mv	a0,s3
    80000b3c:	00006097          	auipc	ra,0x6
    80000b40:	e38080e7          	jalr	-456(ra) # 80006974 <snprintf>
    initlock(&kmem[i].lock, kmem[i].lock_name);
    80000b44:	85ce                	mv	a1,s3
    80000b46:	854a                	mv	a0,s2
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	330080e7          	jalr	816(ra) # 80000e78 <initlock>
  for(int i = 0; i < NCPU; i++) {
    80000b50:	2485                	addiw	s1,s1,1
    80000b52:	03090913          	addi	s2,s2,48
    80000b56:	fd449de3          	bne	s1,s4,80000b30 <kinit+0x26>
  freerange(end, (void*)PHYSTOP);
    80000b5a:	45c5                	li	a1,17
    80000b5c:	05ee                	slli	a1,a1,0x1b
    80000b5e:	0002b517          	auipc	a0,0x2b
    80000b62:	4ca50513          	addi	a0,a0,1226 # 8002c028 <end>
    80000b66:	00000097          	auipc	ra,0x0
    80000b6a:	f5a080e7          	jalr	-166(ra) # 80000ac0 <freerange>
}
    80000b6e:	70e2                	ld	ra,56(sp)
    80000b70:	7442                	ld	s0,48(sp)
    80000b72:	74a2                	ld	s1,40(sp)
    80000b74:	7902                	ld	s2,32(sp)
    80000b76:	69e2                	ld	s3,24(sp)
    80000b78:	6a42                	ld	s4,16(sp)
    80000b7a:	6aa2                	ld	s5,8(sp)
    80000b7c:	6121                	addi	sp,sp,64
    80000b7e:	8082                	ret

0000000080000b80 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b80:	715d                	addi	sp,sp,-80
    80000b82:	e486                	sd	ra,72(sp)
    80000b84:	e0a2                	sd	s0,64(sp)
    80000b86:	fc26                	sd	s1,56(sp)
    80000b88:	f84a                	sd	s2,48(sp)
    80000b8a:	f44e                	sd	s3,40(sp)
    80000b8c:	f052                	sd	s4,32(sp)
    80000b8e:	ec56                	sd	s5,24(sp)
    80000b90:	e85a                	sd	s6,16(sp)
    80000b92:	e45e                	sd	s7,8(sp)
    80000b94:	0880                	addi	s0,sp,80
  struct run *r;
  
  push_off();
    80000b96:	00000097          	auipc	ra,0x0
    80000b9a:	11a080e7          	jalr	282(ra) # 80000cb0 <push_off>
  int cpu = cpuid();
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	178080e7          	jalr	376(ra) # 80001d16 <cpuid>
    80000ba6:	892a                	mv	s2,a0
  acquire(&kmem[cpu].lock);
    80000ba8:	00151493          	slli	s1,a0,0x1
    80000bac:	94aa                	add	s1,s1,a0
    80000bae:	00449793          	slli	a5,s1,0x4
    80000bb2:	00010497          	auipc	s1,0x10
    80000bb6:	6d648493          	addi	s1,s1,1750 # 80011288 <kmem>
    80000bba:	94be                	add	s1,s1,a5
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	00000097          	auipc	ra,0x0
    80000bc2:	13e080e7          	jalr	318(ra) # 80000cfc <acquire>
  r = kmem[cpu].freelist;
    80000bc6:	0284ba03          	ld	s4,40(s1)
  if(r) {
    80000bca:	040a0163          	beqz	s4,80000c0c <kalloc+0x8c>
    kmem[cpu].freelist = r->next;
    80000bce:	000a3703          	ld	a4,0(s4) # fffffffffffff000 <end+0xffffffff7ffd2fd8>
    80000bd2:	f498                	sd	a4,40(s1)
    release(&kmem[cpu].lock);
    80000bd4:	8526                	mv	a0,s1
    80000bd6:	00000097          	auipc	ra,0x0
    80000bda:	1f6080e7          	jalr	502(ra) # 80000dcc <release>
        }
        release(&kmem[nextid].lock);
      }
    }
  }
  pop_off();
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	18e080e7          	jalr	398(ra) # 80000d6c <pop_off>
  
  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000be6:	6605                	lui	a2,0x1
    80000be8:	4595                	li	a1,5
    80000bea:	8552                	mv	a0,s4
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	4f0080e7          	jalr	1264(ra) # 800010dc <memset>
  return (void*)r;
}
    80000bf4:	8552                	mv	a0,s4
    80000bf6:	60a6                	ld	ra,72(sp)
    80000bf8:	6406                	ld	s0,64(sp)
    80000bfa:	74e2                	ld	s1,56(sp)
    80000bfc:	7942                	ld	s2,48(sp)
    80000bfe:	79a2                	ld	s3,40(sp)
    80000c00:	7a02                	ld	s4,32(sp)
    80000c02:	6ae2                	ld	s5,24(sp)
    80000c04:	6b42                	ld	s6,16(sp)
    80000c06:	6ba2                	ld	s7,8(sp)
    80000c08:	6161                	addi	sp,sp,80
    80000c0a:	8082                	ret
    release(&kmem[cpu].lock);
    80000c0c:	8526                	mv	a0,s1
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	1be080e7          	jalr	446(ra) # 80000dcc <release>
    for(int nextid = 0; nextid < NCPU; nextid++) {
    80000c16:	00010497          	auipc	s1,0x10
    80000c1a:	67248493          	addi	s1,s1,1650 # 80011288 <kmem>
    80000c1e:	4981                	li	s3,0
    80000c20:	4b21                	li	s6,8
    80000c22:	a815                	j	80000c56 <kalloc+0xd6>
          kmem[nextid].freelist = r->next;
    80000c24:	000ab703          	ld	a4,0(s5)
    80000c28:	00199793          	slli	a5,s3,0x1
    80000c2c:	99be                	add	s3,s3,a5
    80000c2e:	0992                	slli	s3,s3,0x4
    80000c30:	00010797          	auipc	a5,0x10
    80000c34:	65878793          	addi	a5,a5,1624 # 80011288 <kmem>
    80000c38:	99be                	add	s3,s3,a5
    80000c3a:	02e9b423          	sd	a4,40(s3) # 1028 <_entry-0x7fffefd8>
          release(&kmem[nextid].lock);
    80000c3e:	8526                	mv	a0,s1
    80000c40:	00000097          	auipc	ra,0x0
    80000c44:	18c080e7          	jalr	396(ra) # 80000dcc <release>
        r = kmem[nextid].freelist;
    80000c48:	8a56                	mv	s4,s5
          break;
    80000c4a:	bf51                	j	80000bde <kalloc+0x5e>
    for(int nextid = 0; nextid < NCPU; nextid++) {
    80000c4c:	2985                	addiw	s3,s3,1
    80000c4e:	03048493          	addi	s1,s1,48
    80000c52:	03698363          	beq	s3,s6,80000c78 <kalloc+0xf8>
      if(cpu != nextid) {
    80000c56:	ff390be3          	beq	s2,s3,80000c4c <kalloc+0xcc>
        acquire(&kmem[nextid].lock);
    80000c5a:	8526                	mv	a0,s1
    80000c5c:	00000097          	auipc	ra,0x0
    80000c60:	0a0080e7          	jalr	160(ra) # 80000cfc <acquire>
        r = kmem[nextid].freelist;
    80000c64:	0284ba83          	ld	s5,40(s1)
        if(r) {
    80000c68:	fa0a9ee3          	bnez	s5,80000c24 <kalloc+0xa4>
        release(&kmem[nextid].lock);
    80000c6c:	8526                	mv	a0,s1
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	15e080e7          	jalr	350(ra) # 80000dcc <release>
    80000c76:	bfd9                	j	80000c4c <kalloc+0xcc>
  pop_off();
    80000c78:	00000097          	auipc	ra,0x0
    80000c7c:	0f4080e7          	jalr	244(ra) # 80000d6c <pop_off>
  return (void*)r;
    80000c80:	bf95                	j	80000bf4 <kalloc+0x74>

0000000080000c82 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c82:	411c                	lw	a5,0(a0)
    80000c84:	e399                	bnez	a5,80000c8a <holding+0x8>
    80000c86:	4501                	li	a0,0
  return r;
}
    80000c88:	8082                	ret
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c94:	6904                	ld	s1,16(a0)
    80000c96:	00001097          	auipc	ra,0x1
    80000c9a:	090080e7          	jalr	144(ra) # 80001d26 <mycpu>
    80000c9e:	40a48533          	sub	a0,s1,a0
    80000ca2:	00153513          	seqz	a0,a0
}
    80000ca6:	60e2                	ld	ra,24(sp)
    80000ca8:	6442                	ld	s0,16(sp)
    80000caa:	64a2                	ld	s1,8(sp)
    80000cac:	6105                	addi	sp,sp,32
    80000cae:	8082                	ret

0000000080000cb0 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000cb0:	1101                	addi	sp,sp,-32
    80000cb2:	ec06                	sd	ra,24(sp)
    80000cb4:	e822                	sd	s0,16(sp)
    80000cb6:	e426                	sd	s1,8(sp)
    80000cb8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cba:	100024f3          	csrr	s1,sstatus
    80000cbe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cc2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc4:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000cc8:	00001097          	auipc	ra,0x1
    80000ccc:	05e080e7          	jalr	94(ra) # 80001d26 <mycpu>
    80000cd0:	5d3c                	lw	a5,120(a0)
    80000cd2:	cf89                	beqz	a5,80000cec <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000cd4:	00001097          	auipc	ra,0x1
    80000cd8:	052080e7          	jalr	82(ra) # 80001d26 <mycpu>
    80000cdc:	5d3c                	lw	a5,120(a0)
    80000cde:	2785                	addiw	a5,a5,1
    80000ce0:	dd3c                	sw	a5,120(a0)
}
    80000ce2:	60e2                	ld	ra,24(sp)
    80000ce4:	6442                	ld	s0,16(sp)
    80000ce6:	64a2                	ld	s1,8(sp)
    80000ce8:	6105                	addi	sp,sp,32
    80000cea:	8082                	ret
    mycpu()->intena = old;
    80000cec:	00001097          	auipc	ra,0x1
    80000cf0:	03a080e7          	jalr	58(ra) # 80001d26 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000cf4:	8085                	srli	s1,s1,0x1
    80000cf6:	8885                	andi	s1,s1,1
    80000cf8:	dd64                	sw	s1,124(a0)
    80000cfa:	bfe9                	j	80000cd4 <push_off+0x24>

0000000080000cfc <acquire>:
{
    80000cfc:	1101                	addi	sp,sp,-32
    80000cfe:	ec06                	sd	ra,24(sp)
    80000d00:	e822                	sd	s0,16(sp)
    80000d02:	e426                	sd	s1,8(sp)
    80000d04:	1000                	addi	s0,sp,32
    80000d06:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d08:	00000097          	auipc	ra,0x0
    80000d0c:	fa8080e7          	jalr	-88(ra) # 80000cb0 <push_off>
  if(holding(lk))
    80000d10:	8526                	mv	a0,s1
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	f70080e7          	jalr	-144(ra) # 80000c82 <holding>
    80000d1a:	e911                	bnez	a0,80000d2e <acquire+0x32>
    __sync_fetch_and_add(&(lk->n), 1);
    80000d1c:	4785                	li	a5,1
    80000d1e:	01c48713          	addi	a4,s1,28
    80000d22:	0f50000f          	fence	iorw,ow
    80000d26:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000d2a:	4705                	li	a4,1
    80000d2c:	a839                	j	80000d4a <acquire+0x4e>
    panic("acquire");
    80000d2e:	00007517          	auipc	a0,0x7
    80000d32:	34250513          	addi	a0,a0,834 # 80008070 <digits+0x30>
    80000d36:	00000097          	auipc	ra,0x0
    80000d3a:	814080e7          	jalr	-2028(ra) # 8000054a <panic>
    __sync_fetch_and_add(&(lk->nts), 1);
    80000d3e:	01848793          	addi	a5,s1,24
    80000d42:	0f50000f          	fence	iorw,ow
    80000d46:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000d4a:	87ba                	mv	a5,a4
    80000d4c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d50:	2781                	sext.w	a5,a5
    80000d52:	f7f5                	bnez	a5,80000d3e <acquire+0x42>
  __sync_synchronize();
    80000d54:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d58:	00001097          	auipc	ra,0x1
    80000d5c:	fce080e7          	jalr	-50(ra) # 80001d26 <mycpu>
    80000d60:	e888                	sd	a0,16(s1)
}
    80000d62:	60e2                	ld	ra,24(sp)
    80000d64:	6442                	ld	s0,16(sp)
    80000d66:	64a2                	ld	s1,8(sp)
    80000d68:	6105                	addi	sp,sp,32
    80000d6a:	8082                	ret

0000000080000d6c <pop_off>:

void
pop_off(void)
{
    80000d6c:	1141                	addi	sp,sp,-16
    80000d6e:	e406                	sd	ra,8(sp)
    80000d70:	e022                	sd	s0,0(sp)
    80000d72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d74:	00001097          	auipc	ra,0x1
    80000d78:	fb2080e7          	jalr	-78(ra) # 80001d26 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d7c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d80:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d82:	e78d                	bnez	a5,80000dac <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d84:	5d3c                	lw	a5,120(a0)
    80000d86:	02f05b63          	blez	a5,80000dbc <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d8a:	37fd                	addiw	a5,a5,-1
    80000d8c:	0007871b          	sext.w	a4,a5
    80000d90:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d92:	eb09                	bnez	a4,80000da4 <pop_off+0x38>
    80000d94:	5d7c                	lw	a5,124(a0)
    80000d96:	c799                	beqz	a5,80000da4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d9c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000da0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000da4:	60a2                	ld	ra,8(sp)
    80000da6:	6402                	ld	s0,0(sp)
    80000da8:	0141                	addi	sp,sp,16
    80000daa:	8082                	ret
    panic("pop_off - interruptible");
    80000dac:	00007517          	auipc	a0,0x7
    80000db0:	2cc50513          	addi	a0,a0,716 # 80008078 <digits+0x38>
    80000db4:	fffff097          	auipc	ra,0xfffff
    80000db8:	796080e7          	jalr	1942(ra) # 8000054a <panic>
    panic("pop_off");
    80000dbc:	00007517          	auipc	a0,0x7
    80000dc0:	2d450513          	addi	a0,a0,724 # 80008090 <digits+0x50>
    80000dc4:	fffff097          	auipc	ra,0xfffff
    80000dc8:	786080e7          	jalr	1926(ra) # 8000054a <panic>

0000000080000dcc <release>:
{
    80000dcc:	1101                	addi	sp,sp,-32
    80000dce:	ec06                	sd	ra,24(sp)
    80000dd0:	e822                	sd	s0,16(sp)
    80000dd2:	e426                	sd	s1,8(sp)
    80000dd4:	1000                	addi	s0,sp,32
    80000dd6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000dd8:	00000097          	auipc	ra,0x0
    80000ddc:	eaa080e7          	jalr	-342(ra) # 80000c82 <holding>
    80000de0:	c115                	beqz	a0,80000e04 <release+0x38>
  lk->cpu = 0;
    80000de2:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000de6:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000dea:	0f50000f          	fence	iorw,ow
    80000dee:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000df2:	00000097          	auipc	ra,0x0
    80000df6:	f7a080e7          	jalr	-134(ra) # 80000d6c <pop_off>
}
    80000dfa:	60e2                	ld	ra,24(sp)
    80000dfc:	6442                	ld	s0,16(sp)
    80000dfe:	64a2                	ld	s1,8(sp)
    80000e00:	6105                	addi	sp,sp,32
    80000e02:	8082                	ret
    panic("release");
    80000e04:	00007517          	auipc	a0,0x7
    80000e08:	29450513          	addi	a0,a0,660 # 80008098 <digits+0x58>
    80000e0c:	fffff097          	auipc	ra,0xfffff
    80000e10:	73e080e7          	jalr	1854(ra) # 8000054a <panic>

0000000080000e14 <freelock>:
{
    80000e14:	1101                	addi	sp,sp,-32
    80000e16:	ec06                	sd	ra,24(sp)
    80000e18:	e822                	sd	s0,16(sp)
    80000e1a:	e426                	sd	s1,8(sp)
    80000e1c:	1000                	addi	s0,sp,32
    80000e1e:	84aa                	mv	s1,a0
  acquire(&lock_locks);
    80000e20:	00010517          	auipc	a0,0x10
    80000e24:	5e850513          	addi	a0,a0,1512 # 80011408 <lock_locks>
    80000e28:	00000097          	auipc	ra,0x0
    80000e2c:	ed4080e7          	jalr	-300(ra) # 80000cfc <acquire>
  for (i = 0; i < NLOCK; i++) {
    80000e30:	00010717          	auipc	a4,0x10
    80000e34:	5f870713          	addi	a4,a4,1528 # 80011428 <locks>
    80000e38:	4781                	li	a5,0
    80000e3a:	1f400613          	li	a2,500
    if(locks[i] == lk) {
    80000e3e:	6314                	ld	a3,0(a4)
    80000e40:	00968763          	beq	a3,s1,80000e4e <freelock+0x3a>
  for (i = 0; i < NLOCK; i++) {
    80000e44:	2785                	addiw	a5,a5,1
    80000e46:	0721                	addi	a4,a4,8
    80000e48:	fec79be3          	bne	a5,a2,80000e3e <freelock+0x2a>
    80000e4c:	a809                	j	80000e5e <freelock+0x4a>
      locks[i] = 0;
    80000e4e:	078e                	slli	a5,a5,0x3
    80000e50:	00010717          	auipc	a4,0x10
    80000e54:	5d870713          	addi	a4,a4,1496 # 80011428 <locks>
    80000e58:	97ba                	add	a5,a5,a4
    80000e5a:	0007b023          	sd	zero,0(a5)
  release(&lock_locks);
    80000e5e:	00010517          	auipc	a0,0x10
    80000e62:	5aa50513          	addi	a0,a0,1450 # 80011408 <lock_locks>
    80000e66:	00000097          	auipc	ra,0x0
    80000e6a:	f66080e7          	jalr	-154(ra) # 80000dcc <release>
}
    80000e6e:	60e2                	ld	ra,24(sp)
    80000e70:	6442                	ld	s0,16(sp)
    80000e72:	64a2                	ld	s1,8(sp)
    80000e74:	6105                	addi	sp,sp,32
    80000e76:	8082                	ret

0000000080000e78 <initlock>:
{
    80000e78:	1101                	addi	sp,sp,-32
    80000e7a:	ec06                	sd	ra,24(sp)
    80000e7c:	e822                	sd	s0,16(sp)
    80000e7e:	e426                	sd	s1,8(sp)
    80000e80:	1000                	addi	s0,sp,32
    80000e82:	84aa                	mv	s1,a0
  lk->name = name;
    80000e84:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000e86:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000e8a:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000e8e:	00052c23          	sw	zero,24(a0)
  lk->n = 0;
    80000e92:	00052e23          	sw	zero,28(a0)
  acquire(&lock_locks);
    80000e96:	00010517          	auipc	a0,0x10
    80000e9a:	57250513          	addi	a0,a0,1394 # 80011408 <lock_locks>
    80000e9e:	00000097          	auipc	ra,0x0
    80000ea2:	e5e080e7          	jalr	-418(ra) # 80000cfc <acquire>
  for (i = 0; i < NLOCK; i++) {
    80000ea6:	00010717          	auipc	a4,0x10
    80000eaa:	58270713          	addi	a4,a4,1410 # 80011428 <locks>
    80000eae:	4781                	li	a5,0
    80000eb0:	1f400613          	li	a2,500
    if(locks[i] == 0) {
    80000eb4:	6314                	ld	a3,0(a4)
    80000eb6:	ce89                	beqz	a3,80000ed0 <initlock+0x58>
  for (i = 0; i < NLOCK; i++) {
    80000eb8:	2785                	addiw	a5,a5,1
    80000eba:	0721                	addi	a4,a4,8
    80000ebc:	fec79ce3          	bne	a5,a2,80000eb4 <initlock+0x3c>
  panic("findslot");
    80000ec0:	00007517          	auipc	a0,0x7
    80000ec4:	1e050513          	addi	a0,a0,480 # 800080a0 <digits+0x60>
    80000ec8:	fffff097          	auipc	ra,0xfffff
    80000ecc:	682080e7          	jalr	1666(ra) # 8000054a <panic>
      locks[i] = lk;
    80000ed0:	078e                	slli	a5,a5,0x3
    80000ed2:	00010717          	auipc	a4,0x10
    80000ed6:	55670713          	addi	a4,a4,1366 # 80011428 <locks>
    80000eda:	97ba                	add	a5,a5,a4
    80000edc:	e384                	sd	s1,0(a5)
      release(&lock_locks);
    80000ede:	00010517          	auipc	a0,0x10
    80000ee2:	52a50513          	addi	a0,a0,1322 # 80011408 <lock_locks>
    80000ee6:	00000097          	auipc	ra,0x0
    80000eea:	ee6080e7          	jalr	-282(ra) # 80000dcc <release>
}
    80000eee:	60e2                	ld	ra,24(sp)
    80000ef0:	6442                	ld	s0,16(sp)
    80000ef2:	64a2                	ld	s1,8(sp)
    80000ef4:	6105                	addi	sp,sp,32
    80000ef6:	8082                	ret

0000000080000ef8 <snprint_lock>:
#ifdef LAB_LOCK
int
snprint_lock(char *buf, int sz, struct spinlock *lk)
{
  int n = 0;
  if(lk->n > 0) {
    80000ef8:	4e5c                	lw	a5,28(a2)
    80000efa:	00f04463          	bgtz	a5,80000f02 <snprint_lock+0xa>
  int n = 0;
    80000efe:	4501                	li	a0,0
    n = snprintf(buf, sz, "lock: %s: #fetch-and-add %d #acquire() %d\n",
                 lk->name, lk->nts, lk->n);
  }
  return n;
}
    80000f00:	8082                	ret
{
    80000f02:	1141                	addi	sp,sp,-16
    80000f04:	e406                	sd	ra,8(sp)
    80000f06:	e022                	sd	s0,0(sp)
    80000f08:	0800                	addi	s0,sp,16
    n = snprintf(buf, sz, "lock: %s: #fetch-and-add %d #acquire() %d\n",
    80000f0a:	4e18                	lw	a4,24(a2)
    80000f0c:	6614                	ld	a3,8(a2)
    80000f0e:	00007617          	auipc	a2,0x7
    80000f12:	1a260613          	addi	a2,a2,418 # 800080b0 <digits+0x70>
    80000f16:	00006097          	auipc	ra,0x6
    80000f1a:	a5e080e7          	jalr	-1442(ra) # 80006974 <snprintf>
}
    80000f1e:	60a2                	ld	ra,8(sp)
    80000f20:	6402                	ld	s0,0(sp)
    80000f22:	0141                	addi	sp,sp,16
    80000f24:	8082                	ret

0000000080000f26 <statslock>:

int
statslock(char *buf, int sz) {
    80000f26:	7159                	addi	sp,sp,-112
    80000f28:	f486                	sd	ra,104(sp)
    80000f2a:	f0a2                	sd	s0,96(sp)
    80000f2c:	eca6                	sd	s1,88(sp)
    80000f2e:	e8ca                	sd	s2,80(sp)
    80000f30:	e4ce                	sd	s3,72(sp)
    80000f32:	e0d2                	sd	s4,64(sp)
    80000f34:	fc56                	sd	s5,56(sp)
    80000f36:	f85a                	sd	s6,48(sp)
    80000f38:	f45e                	sd	s7,40(sp)
    80000f3a:	f062                	sd	s8,32(sp)
    80000f3c:	ec66                	sd	s9,24(sp)
    80000f3e:	e86a                	sd	s10,16(sp)
    80000f40:	e46e                	sd	s11,8(sp)
    80000f42:	1880                	addi	s0,sp,112
    80000f44:	8aaa                	mv	s5,a0
    80000f46:	8b2e                	mv	s6,a1
  int n;
  int tot = 0;

  acquire(&lock_locks);
    80000f48:	00010517          	auipc	a0,0x10
    80000f4c:	4c050513          	addi	a0,a0,1216 # 80011408 <lock_locks>
    80000f50:	00000097          	auipc	ra,0x0
    80000f54:	dac080e7          	jalr	-596(ra) # 80000cfc <acquire>
  n = snprintf(buf, sz, "--- lock kmem/bcache stats\n");
    80000f58:	00007617          	auipc	a2,0x7
    80000f5c:	18860613          	addi	a2,a2,392 # 800080e0 <digits+0xa0>
    80000f60:	85da                	mv	a1,s6
    80000f62:	8556                	mv	a0,s5
    80000f64:	00006097          	auipc	ra,0x6
    80000f68:	a10080e7          	jalr	-1520(ra) # 80006974 <snprintf>
    80000f6c:	892a                	mv	s2,a0
  for(int i = 0; i < NLOCK; i++) {
    80000f6e:	00010c97          	auipc	s9,0x10
    80000f72:	4bac8c93          	addi	s9,s9,1210 # 80011428 <locks>
    80000f76:	00011c17          	auipc	s8,0x11
    80000f7a:	452c0c13          	addi	s8,s8,1106 # 800123c8 <pid_lock>
  n = snprintf(buf, sz, "--- lock kmem/bcache stats\n");
    80000f7e:	84e6                	mv	s1,s9
  int tot = 0;
    80000f80:	4a01                	li	s4,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000f82:	00007b97          	auipc	s7,0x7
    80000f86:	17eb8b93          	addi	s7,s7,382 # 80008100 <digits+0xc0>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000f8a:	00007d17          	auipc	s10,0x7
    80000f8e:	17ed0d13          	addi	s10,s10,382 # 80008108 <digits+0xc8>
    80000f92:	a01d                	j	80000fb8 <statslock+0x92>
      tot += locks[i]->nts;
    80000f94:	0009b603          	ld	a2,0(s3)
    80000f98:	4e1c                	lw	a5,24(a2)
    80000f9a:	01478a3b          	addw	s4,a5,s4
      n += snprint_lock(buf +n, sz-n, locks[i]);
    80000f9e:	412b05bb          	subw	a1,s6,s2
    80000fa2:	012a8533          	add	a0,s5,s2
    80000fa6:	00000097          	auipc	ra,0x0
    80000faa:	f52080e7          	jalr	-174(ra) # 80000ef8 <snprint_lock>
    80000fae:	0125093b          	addw	s2,a0,s2
  for(int i = 0; i < NLOCK; i++) {
    80000fb2:	04a1                	addi	s1,s1,8
    80000fb4:	05848763          	beq	s1,s8,80001002 <statslock+0xdc>
    if(locks[i] == 0)
    80000fb8:	89a6                	mv	s3,s1
    80000fba:	609c                	ld	a5,0(s1)
    80000fbc:	c3b9                	beqz	a5,80001002 <statslock+0xdc>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000fbe:	0087bd83          	ld	s11,8(a5)
    80000fc2:	855e                	mv	a0,s7
    80000fc4:	00000097          	auipc	ra,0x0
    80000fc8:	29c080e7          	jalr	668(ra) # 80001260 <strlen>
    80000fcc:	0005061b          	sext.w	a2,a0
    80000fd0:	85de                	mv	a1,s7
    80000fd2:	856e                	mv	a0,s11
    80000fd4:	00000097          	auipc	ra,0x0
    80000fd8:	1e0080e7          	jalr	480(ra) # 800011b4 <strncmp>
    80000fdc:	dd45                	beqz	a0,80000f94 <statslock+0x6e>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000fde:	609c                	ld	a5,0(s1)
    80000fe0:	0087bd83          	ld	s11,8(a5)
    80000fe4:	856a                	mv	a0,s10
    80000fe6:	00000097          	auipc	ra,0x0
    80000fea:	27a080e7          	jalr	634(ra) # 80001260 <strlen>
    80000fee:	0005061b          	sext.w	a2,a0
    80000ff2:	85ea                	mv	a1,s10
    80000ff4:	856e                	mv	a0,s11
    80000ff6:	00000097          	auipc	ra,0x0
    80000ffa:	1be080e7          	jalr	446(ra) # 800011b4 <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000ffe:	f955                	bnez	a0,80000fb2 <statslock+0x8c>
    80001000:	bf51                	j	80000f94 <statslock+0x6e>
    }
  }
  
  n += snprintf(buf+n, sz-n, "--- top 5 contended locks:\n");
    80001002:	00007617          	auipc	a2,0x7
    80001006:	10e60613          	addi	a2,a2,270 # 80008110 <digits+0xd0>
    8000100a:	412b05bb          	subw	a1,s6,s2
    8000100e:	012a8533          	add	a0,s5,s2
    80001012:	00006097          	auipc	ra,0x6
    80001016:	962080e7          	jalr	-1694(ra) # 80006974 <snprintf>
    8000101a:	012509bb          	addw	s3,a0,s2
    8000101e:	4b95                	li	s7,5
  int last = 100000000;
    80001020:	05f5e537          	lui	a0,0x5f5e
    80001024:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t = 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    80001028:	4c01                	li	s8,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    8000102a:	00010497          	auipc	s1,0x10
    8000102e:	3fe48493          	addi	s1,s1,1022 # 80011428 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80001032:	1f400913          	li	s2,500
    80001036:	a881                	j	80001086 <statslock+0x160>
    80001038:	2705                	addiw	a4,a4,1
    8000103a:	06a1                	addi	a3,a3,8
    8000103c:	03270063          	beq	a4,s2,8000105c <statslock+0x136>
      if(locks[i] == 0)
    80001040:	629c                	ld	a5,0(a3)
    80001042:	cf89                	beqz	a5,8000105c <statslock+0x136>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80001044:	4f90                	lw	a2,24(a5)
    80001046:	00359793          	slli	a5,a1,0x3
    8000104a:	97a6                	add	a5,a5,s1
    8000104c:	639c                	ld	a5,0(a5)
    8000104e:	4f9c                	lw	a5,24(a5)
    80001050:	fec7d4e3          	bge	a5,a2,80001038 <statslock+0x112>
    80001054:	fea652e3          	bge	a2,a0,80001038 <statslock+0x112>
    80001058:	85ba                	mv	a1,a4
    8000105a:	bff9                	j	80001038 <statslock+0x112>
        top = i;
      }
    }
    n += snprint_lock(buf+n, sz-n, locks[top]);
    8000105c:	058e                	slli	a1,a1,0x3
    8000105e:	00b48d33          	add	s10,s1,a1
    80001062:	000d3603          	ld	a2,0(s10)
    80001066:	413b05bb          	subw	a1,s6,s3
    8000106a:	013a8533          	add	a0,s5,s3
    8000106e:	00000097          	auipc	ra,0x0
    80001072:	e8a080e7          	jalr	-374(ra) # 80000ef8 <snprint_lock>
    80001076:	013509bb          	addw	s3,a0,s3
    last = locks[top]->nts;
    8000107a:	000d3783          	ld	a5,0(s10)
    8000107e:	4f88                	lw	a0,24(a5)
  for(int t = 0; t < 5; t++) {
    80001080:	3bfd                	addiw	s7,s7,-1
    80001082:	000b8663          	beqz	s7,8000108e <statslock+0x168>
  int tot = 0;
    80001086:	86e6                	mv	a3,s9
    for(int i = 0; i < NLOCK; i++) {
    80001088:	8762                	mv	a4,s8
    int top = 0;
    8000108a:	85e2                	mv	a1,s8
    8000108c:	bf55                	j	80001040 <statslock+0x11a>
  }
  n += snprintf(buf+n, sz-n, "tot= %d\n", tot);
    8000108e:	86d2                	mv	a3,s4
    80001090:	00007617          	auipc	a2,0x7
    80001094:	0a060613          	addi	a2,a2,160 # 80008130 <digits+0xf0>
    80001098:	413b05bb          	subw	a1,s6,s3
    8000109c:	013a8533          	add	a0,s5,s3
    800010a0:	00006097          	auipc	ra,0x6
    800010a4:	8d4080e7          	jalr	-1836(ra) # 80006974 <snprintf>
    800010a8:	013509bb          	addw	s3,a0,s3
  release(&lock_locks);  
    800010ac:	00010517          	auipc	a0,0x10
    800010b0:	35c50513          	addi	a0,a0,860 # 80011408 <lock_locks>
    800010b4:	00000097          	auipc	ra,0x0
    800010b8:	d18080e7          	jalr	-744(ra) # 80000dcc <release>
  return n;
}
    800010bc:	854e                	mv	a0,s3
    800010be:	70a6                	ld	ra,104(sp)
    800010c0:	7406                	ld	s0,96(sp)
    800010c2:	64e6                	ld	s1,88(sp)
    800010c4:	6946                	ld	s2,80(sp)
    800010c6:	69a6                	ld	s3,72(sp)
    800010c8:	6a06                	ld	s4,64(sp)
    800010ca:	7ae2                	ld	s5,56(sp)
    800010cc:	7b42                	ld	s6,48(sp)
    800010ce:	7ba2                	ld	s7,40(sp)
    800010d0:	7c02                	ld	s8,32(sp)
    800010d2:	6ce2                	ld	s9,24(sp)
    800010d4:	6d42                	ld	s10,16(sp)
    800010d6:	6da2                	ld	s11,8(sp)
    800010d8:	6165                	addi	sp,sp,112
    800010da:	8082                	ret

00000000800010dc <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800010dc:	1141                	addi	sp,sp,-16
    800010de:	e422                	sd	s0,8(sp)
    800010e0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800010e2:	ca19                	beqz	a2,800010f8 <memset+0x1c>
    800010e4:	87aa                	mv	a5,a0
    800010e6:	1602                	slli	a2,a2,0x20
    800010e8:	9201                	srli	a2,a2,0x20
    800010ea:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    800010ee:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800010f2:	0785                	addi	a5,a5,1
    800010f4:	fee79de3          	bne	a5,a4,800010ee <memset+0x12>
  }
  return dst;
}
    800010f8:	6422                	ld	s0,8(sp)
    800010fa:	0141                	addi	sp,sp,16
    800010fc:	8082                	ret

00000000800010fe <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800010fe:	1141                	addi	sp,sp,-16
    80001100:	e422                	sd	s0,8(sp)
    80001102:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80001104:	ca05                	beqz	a2,80001134 <memcmp+0x36>
    80001106:	fff6069b          	addiw	a3,a2,-1
    8000110a:	1682                	slli	a3,a3,0x20
    8000110c:	9281                	srli	a3,a3,0x20
    8000110e:	0685                	addi	a3,a3,1
    80001110:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80001112:	00054783          	lbu	a5,0(a0)
    80001116:	0005c703          	lbu	a4,0(a1)
    8000111a:	00e79863          	bne	a5,a4,8000112a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    8000111e:	0505                	addi	a0,a0,1
    80001120:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80001122:	fed518e3          	bne	a0,a3,80001112 <memcmp+0x14>
  }

  return 0;
    80001126:	4501                	li	a0,0
    80001128:	a019                	j	8000112e <memcmp+0x30>
      return *s1 - *s2;
    8000112a:	40e7853b          	subw	a0,a5,a4
}
    8000112e:	6422                	ld	s0,8(sp)
    80001130:	0141                	addi	sp,sp,16
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	bfe5                	j	8000112e <memcmp+0x30>

0000000080001138 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80001138:	1141                	addi	sp,sp,-16
    8000113a:	e422                	sd	s0,8(sp)
    8000113c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    8000113e:	02a5e563          	bltu	a1,a0,80001168 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80001142:	fff6069b          	addiw	a3,a2,-1
    80001146:	ce11                	beqz	a2,80001162 <memmove+0x2a>
    80001148:	1682                	slli	a3,a3,0x20
    8000114a:	9281                	srli	a3,a3,0x20
    8000114c:	0685                	addi	a3,a3,1
    8000114e:	96ae                	add	a3,a3,a1
    80001150:	87aa                	mv	a5,a0
      *d++ = *s++;
    80001152:	0585                	addi	a1,a1,1
    80001154:	0785                	addi	a5,a5,1
    80001156:	fff5c703          	lbu	a4,-1(a1)
    8000115a:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    8000115e:	fed59ae3          	bne	a1,a3,80001152 <memmove+0x1a>

  return dst;
}
    80001162:	6422                	ld	s0,8(sp)
    80001164:	0141                	addi	sp,sp,16
    80001166:	8082                	ret
  if(s < d && s + n > d){
    80001168:	02061713          	slli	a4,a2,0x20
    8000116c:	9301                	srli	a4,a4,0x20
    8000116e:	00e587b3          	add	a5,a1,a4
    80001172:	fcf578e3          	bgeu	a0,a5,80001142 <memmove+0xa>
    d += n;
    80001176:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80001178:	fff6069b          	addiw	a3,a2,-1
    8000117c:	d27d                	beqz	a2,80001162 <memmove+0x2a>
    8000117e:	02069613          	slli	a2,a3,0x20
    80001182:	9201                	srli	a2,a2,0x20
    80001184:	fff64613          	not	a2,a2
    80001188:	963e                	add	a2,a2,a5
      *--d = *--s;
    8000118a:	17fd                	addi	a5,a5,-1
    8000118c:	177d                	addi	a4,a4,-1
    8000118e:	0007c683          	lbu	a3,0(a5)
    80001192:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80001196:	fef61ae3          	bne	a2,a5,8000118a <memmove+0x52>
    8000119a:	b7e1                	j	80001162 <memmove+0x2a>

000000008000119c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000119c:	1141                	addi	sp,sp,-16
    8000119e:	e406                	sd	ra,8(sp)
    800011a0:	e022                	sd	s0,0(sp)
    800011a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	f94080e7          	jalr	-108(ra) # 80001138 <memmove>
}
    800011ac:	60a2                	ld	ra,8(sp)
    800011ae:	6402                	ld	s0,0(sp)
    800011b0:	0141                	addi	sp,sp,16
    800011b2:	8082                	ret

00000000800011b4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    800011b4:	1141                	addi	sp,sp,-16
    800011b6:	e422                	sd	s0,8(sp)
    800011b8:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    800011ba:	ce11                	beqz	a2,800011d6 <strncmp+0x22>
    800011bc:	00054783          	lbu	a5,0(a0)
    800011c0:	cf89                	beqz	a5,800011da <strncmp+0x26>
    800011c2:	0005c703          	lbu	a4,0(a1)
    800011c6:	00f71a63          	bne	a4,a5,800011da <strncmp+0x26>
    n--, p++, q++;
    800011ca:	367d                	addiw	a2,a2,-1
    800011cc:	0505                	addi	a0,a0,1
    800011ce:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    800011d0:	f675                	bnez	a2,800011bc <strncmp+0x8>
  if(n == 0)
    return 0;
    800011d2:	4501                	li	a0,0
    800011d4:	a809                	j	800011e6 <strncmp+0x32>
    800011d6:	4501                	li	a0,0
    800011d8:	a039                	j	800011e6 <strncmp+0x32>
  if(n == 0)
    800011da:	ca09                	beqz	a2,800011ec <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800011dc:	00054503          	lbu	a0,0(a0)
    800011e0:	0005c783          	lbu	a5,0(a1)
    800011e4:	9d1d                	subw	a0,a0,a5
}
    800011e6:	6422                	ld	s0,8(sp)
    800011e8:	0141                	addi	sp,sp,16
    800011ea:	8082                	ret
    return 0;
    800011ec:	4501                	li	a0,0
    800011ee:	bfe5                	j	800011e6 <strncmp+0x32>

00000000800011f0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800011f0:	1141                	addi	sp,sp,-16
    800011f2:	e422                	sd	s0,8(sp)
    800011f4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800011f6:	872a                	mv	a4,a0
    800011f8:	8832                	mv	a6,a2
    800011fa:	367d                	addiw	a2,a2,-1
    800011fc:	01005963          	blez	a6,8000120e <strncpy+0x1e>
    80001200:	0705                	addi	a4,a4,1
    80001202:	0005c783          	lbu	a5,0(a1)
    80001206:	fef70fa3          	sb	a5,-1(a4)
    8000120a:	0585                	addi	a1,a1,1
    8000120c:	f7f5                	bnez	a5,800011f8 <strncpy+0x8>
    ;
  while(n-- > 0)
    8000120e:	86ba                	mv	a3,a4
    80001210:	00c05c63          	blez	a2,80001228 <strncpy+0x38>
    *s++ = 0;
    80001214:	0685                	addi	a3,a3,1
    80001216:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    8000121a:	fff6c793          	not	a5,a3
    8000121e:	9fb9                	addw	a5,a5,a4
    80001220:	010787bb          	addw	a5,a5,a6
    80001224:	fef048e3          	bgtz	a5,80001214 <strncpy+0x24>
  return os;
}
    80001228:	6422                	ld	s0,8(sp)
    8000122a:	0141                	addi	sp,sp,16
    8000122c:	8082                	ret

000000008000122e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000122e:	1141                	addi	sp,sp,-16
    80001230:	e422                	sd	s0,8(sp)
    80001232:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001234:	02c05363          	blez	a2,8000125a <safestrcpy+0x2c>
    80001238:	fff6069b          	addiw	a3,a2,-1
    8000123c:	1682                	slli	a3,a3,0x20
    8000123e:	9281                	srli	a3,a3,0x20
    80001240:	96ae                	add	a3,a3,a1
    80001242:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001244:	00d58963          	beq	a1,a3,80001256 <safestrcpy+0x28>
    80001248:	0585                	addi	a1,a1,1
    8000124a:	0785                	addi	a5,a5,1
    8000124c:	fff5c703          	lbu	a4,-1(a1)
    80001250:	fee78fa3          	sb	a4,-1(a5)
    80001254:	fb65                	bnez	a4,80001244 <safestrcpy+0x16>
    ;
  *s = 0;
    80001256:	00078023          	sb	zero,0(a5)
  return os;
}
    8000125a:	6422                	ld	s0,8(sp)
    8000125c:	0141                	addi	sp,sp,16
    8000125e:	8082                	ret

0000000080001260 <strlen>:

int
strlen(const char *s)
{
    80001260:	1141                	addi	sp,sp,-16
    80001262:	e422                	sd	s0,8(sp)
    80001264:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001266:	00054783          	lbu	a5,0(a0)
    8000126a:	cf91                	beqz	a5,80001286 <strlen+0x26>
    8000126c:	0505                	addi	a0,a0,1
    8000126e:	87aa                	mv	a5,a0
    80001270:	4685                	li	a3,1
    80001272:	9e89                	subw	a3,a3,a0
    80001274:	00f6853b          	addw	a0,a3,a5
    80001278:	0785                	addi	a5,a5,1
    8000127a:	fff7c703          	lbu	a4,-1(a5)
    8000127e:	fb7d                	bnez	a4,80001274 <strlen+0x14>
    ;
  return n;
}
    80001280:	6422                	ld	s0,8(sp)
    80001282:	0141                	addi	sp,sp,16
    80001284:	8082                	ret
  for(n = 0; s[n]; n++)
    80001286:	4501                	li	a0,0
    80001288:	bfe5                	j	80001280 <strlen+0x20>

000000008000128a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000128a:	1141                	addi	sp,sp,-16
    8000128c:	e406                	sd	ra,8(sp)
    8000128e:	e022                	sd	s0,0(sp)
    80001290:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001292:	00001097          	auipc	ra,0x1
    80001296:	a84080e7          	jalr	-1404(ra) # 80001d16 <cpuid>
#endif    
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000129a:	00008717          	auipc	a4,0x8
    8000129e:	d7270713          	addi	a4,a4,-654 # 8000900c <started>
  if(cpuid() == 0){
    800012a2:	c139                	beqz	a0,800012e8 <main+0x5e>
    while(started == 0)
    800012a4:	431c                	lw	a5,0(a4)
    800012a6:	2781                	sext.w	a5,a5
    800012a8:	dff5                	beqz	a5,800012a4 <main+0x1a>
      ;
    __sync_synchronize();
    800012aa:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800012ae:	00001097          	auipc	ra,0x1
    800012b2:	a68080e7          	jalr	-1432(ra) # 80001d16 <cpuid>
    800012b6:	85aa                	mv	a1,a0
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	ea050513          	addi	a0,a0,-352 # 80008158 <digits+0x118>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	2d4080e7          	jalr	724(ra) # 80000594 <printf>
    kvminithart();    // turn on paging
    800012c8:	00000097          	auipc	ra,0x0
    800012cc:	186080e7          	jalr	390(ra) # 8000144e <kvminithart>
    trapinithart();   // install kernel trap vector
    800012d0:	00001097          	auipc	ra,0x1
    800012d4:	6cc080e7          	jalr	1740(ra) # 8000299c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800012d8:	00005097          	auipc	ra,0x5
    800012dc:	f28080e7          	jalr	-216(ra) # 80006200 <plicinithart>
  }

  scheduler();        
    800012e0:	00001097          	auipc	ra,0x1
    800012e4:	f96080e7          	jalr	-106(ra) # 80002276 <scheduler>
    consoleinit();
    800012e8:	fffff097          	auipc	ra,0xfffff
    800012ec:	174080e7          	jalr	372(ra) # 8000045c <consoleinit>
    statsinit();
    800012f0:	00005097          	auipc	ra,0x5
    800012f4:	5a8080e7          	jalr	1448(ra) # 80006898 <statsinit>
    printfinit();
    800012f8:	fffff097          	auipc	ra,0xfffff
    800012fc:	47c080e7          	jalr	1148(ra) # 80000774 <printfinit>
    printf("\n");
    80001300:	00007517          	auipc	a0,0x7
    80001304:	e6850513          	addi	a0,a0,-408 # 80008168 <digits+0x128>
    80001308:	fffff097          	auipc	ra,0xfffff
    8000130c:	28c080e7          	jalr	652(ra) # 80000594 <printf>
    printf("xv6 kernel is booting\n");
    80001310:	00007517          	auipc	a0,0x7
    80001314:	e3050513          	addi	a0,a0,-464 # 80008140 <digits+0x100>
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	27c080e7          	jalr	636(ra) # 80000594 <printf>
    printf("\n");
    80001320:	00007517          	auipc	a0,0x7
    80001324:	e4850513          	addi	a0,a0,-440 # 80008168 <digits+0x128>
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	26c080e7          	jalr	620(ra) # 80000594 <printf>
    kinit();         // physical page allocator
    80001330:	fffff097          	auipc	ra,0xfffff
    80001334:	7da080e7          	jalr	2010(ra) # 80000b0a <kinit>
    kvminit();       // create kernel page table
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	242080e7          	jalr	578(ra) # 8000157a <kvminit>
    kvminithart();   // turn on paging
    80001340:	00000097          	auipc	ra,0x0
    80001344:	10e080e7          	jalr	270(ra) # 8000144e <kvminithart>
    procinit();      // process table
    80001348:	00001097          	auipc	ra,0x1
    8000134c:	8fe080e7          	jalr	-1794(ra) # 80001c46 <procinit>
    trapinit();      // trap vectors
    80001350:	00001097          	auipc	ra,0x1
    80001354:	624080e7          	jalr	1572(ra) # 80002974 <trapinit>
    trapinithart();  // install kernel trap vector
    80001358:	00001097          	auipc	ra,0x1
    8000135c:	644080e7          	jalr	1604(ra) # 8000299c <trapinithart>
    plicinit();      // set up interrupt controller
    80001360:	00005097          	auipc	ra,0x5
    80001364:	e8a080e7          	jalr	-374(ra) # 800061ea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001368:	00005097          	auipc	ra,0x5
    8000136c:	e98080e7          	jalr	-360(ra) # 80006200 <plicinithart>
    binit();         // buffer cache
    80001370:	00002097          	auipc	ra,0x2
    80001374:	d7e080e7          	jalr	-642(ra) # 800030ee <binit>
    iinit();         // inode cache
    80001378:	00002097          	auipc	ra,0x2
    8000137c:	6bc080e7          	jalr	1724(ra) # 80003a34 <iinit>
    fileinit();      // file table
    80001380:	00003097          	auipc	ra,0x3
    80001384:	66c080e7          	jalr	1644(ra) # 800049ec <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001388:	00005097          	auipc	ra,0x5
    8000138c:	f9a080e7          	jalr	-102(ra) # 80006322 <virtio_disk_init>
    userinit();      // first user process
    80001390:	00001097          	auipc	ra,0x1
    80001394:	c7c080e7          	jalr	-900(ra) # 8000200c <userinit>
    __sync_synchronize();
    80001398:	0ff0000f          	fence
    started = 1;
    8000139c:	4785                	li	a5,1
    8000139e:	00008717          	auipc	a4,0x8
    800013a2:	c6f72723          	sw	a5,-914(a4) # 8000900c <started>
    800013a6:	bf2d                	j	800012e0 <main+0x56>

00000000800013a8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800013a8:	7139                	addi	sp,sp,-64
    800013aa:	fc06                	sd	ra,56(sp)
    800013ac:	f822                	sd	s0,48(sp)
    800013ae:	f426                	sd	s1,40(sp)
    800013b0:	f04a                	sd	s2,32(sp)
    800013b2:	ec4e                	sd	s3,24(sp)
    800013b4:	e852                	sd	s4,16(sp)
    800013b6:	e456                	sd	s5,8(sp)
    800013b8:	e05a                	sd	s6,0(sp)
    800013ba:	0080                	addi	s0,sp,64
    800013bc:	84aa                	mv	s1,a0
    800013be:	89ae                	mv	s3,a1
    800013c0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800013c2:	57fd                	li	a5,-1
    800013c4:	83e9                	srli	a5,a5,0x1a
    800013c6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800013c8:	4b31                	li	s6,12
  if(va >= MAXVA)
    800013ca:	04b7f263          	bgeu	a5,a1,8000140e <walk+0x66>
    panic("walk");
    800013ce:	00007517          	auipc	a0,0x7
    800013d2:	da250513          	addi	a0,a0,-606 # 80008170 <digits+0x130>
    800013d6:	fffff097          	auipc	ra,0xfffff
    800013da:	174080e7          	jalr	372(ra) # 8000054a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800013de:	060a8663          	beqz	s5,8000144a <walk+0xa2>
    800013e2:	fffff097          	auipc	ra,0xfffff
    800013e6:	79e080e7          	jalr	1950(ra) # 80000b80 <kalloc>
    800013ea:	84aa                	mv	s1,a0
    800013ec:	c529                	beqz	a0,80001436 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800013ee:	6605                	lui	a2,0x1
    800013f0:	4581                	li	a1,0
    800013f2:	00000097          	auipc	ra,0x0
    800013f6:	cea080e7          	jalr	-790(ra) # 800010dc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800013fa:	00c4d793          	srli	a5,s1,0xc
    800013fe:	07aa                	slli	a5,a5,0xa
    80001400:	0017e793          	ori	a5,a5,1
    80001404:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001408:	3a5d                	addiw	s4,s4,-9
    8000140a:	036a0063          	beq	s4,s6,8000142a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000140e:	0149d933          	srl	s2,s3,s4
    80001412:	1ff97913          	andi	s2,s2,511
    80001416:	090e                	slli	s2,s2,0x3
    80001418:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000141a:	00093483          	ld	s1,0(s2)
    8000141e:	0014f793          	andi	a5,s1,1
    80001422:	dfd5                	beqz	a5,800013de <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001424:	80a9                	srli	s1,s1,0xa
    80001426:	04b2                	slli	s1,s1,0xc
    80001428:	b7c5                	j	80001408 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000142a:	00c9d513          	srli	a0,s3,0xc
    8000142e:	1ff57513          	andi	a0,a0,511
    80001432:	050e                	slli	a0,a0,0x3
    80001434:	9526                	add	a0,a0,s1
}
    80001436:	70e2                	ld	ra,56(sp)
    80001438:	7442                	ld	s0,48(sp)
    8000143a:	74a2                	ld	s1,40(sp)
    8000143c:	7902                	ld	s2,32(sp)
    8000143e:	69e2                	ld	s3,24(sp)
    80001440:	6a42                	ld	s4,16(sp)
    80001442:	6aa2                	ld	s5,8(sp)
    80001444:	6b02                	ld	s6,0(sp)
    80001446:	6121                	addi	sp,sp,64
    80001448:	8082                	ret
        return 0;
    8000144a:	4501                	li	a0,0
    8000144c:	b7ed                	j	80001436 <walk+0x8e>

000000008000144e <kvminithart>:
{
    8000144e:	1141                	addi	sp,sp,-16
    80001450:	e422                	sd	s0,8(sp)
    80001452:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001454:	00008797          	auipc	a5,0x8
    80001458:	bbc7b783          	ld	a5,-1092(a5) # 80009010 <kernel_pagetable>
    8000145c:	83b1                	srli	a5,a5,0xc
    8000145e:	577d                	li	a4,-1
    80001460:	177e                	slli	a4,a4,0x3f
    80001462:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001464:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001468:	12000073          	sfence.vma
}
    8000146c:	6422                	ld	s0,8(sp)
    8000146e:	0141                	addi	sp,sp,16
    80001470:	8082                	ret

0000000080001472 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001472:	57fd                	li	a5,-1
    80001474:	83e9                	srli	a5,a5,0x1a
    80001476:	00b7f463          	bgeu	a5,a1,8000147e <walkaddr+0xc>
    return 0;
    8000147a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000147c:	8082                	ret
{
    8000147e:	1141                	addi	sp,sp,-16
    80001480:	e406                	sd	ra,8(sp)
    80001482:	e022                	sd	s0,0(sp)
    80001484:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001486:	4601                	li	a2,0
    80001488:	00000097          	auipc	ra,0x0
    8000148c:	f20080e7          	jalr	-224(ra) # 800013a8 <walk>
  if(pte == 0)
    80001490:	c105                	beqz	a0,800014b0 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001492:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001494:	0117f693          	andi	a3,a5,17
    80001498:	4745                	li	a4,17
    return 0;
    8000149a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000149c:	00e68663          	beq	a3,a4,800014a8 <walkaddr+0x36>
}
    800014a0:	60a2                	ld	ra,8(sp)
    800014a2:	6402                	ld	s0,0(sp)
    800014a4:	0141                	addi	sp,sp,16
    800014a6:	8082                	ret
  pa = PTE2PA(*pte);
    800014a8:	00a7d513          	srli	a0,a5,0xa
    800014ac:	0532                	slli	a0,a0,0xc
  return pa;
    800014ae:	bfcd                	j	800014a0 <walkaddr+0x2e>
    return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	b7fd                	j	800014a0 <walkaddr+0x2e>

00000000800014b4 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800014b4:	715d                	addi	sp,sp,-80
    800014b6:	e486                	sd	ra,72(sp)
    800014b8:	e0a2                	sd	s0,64(sp)
    800014ba:	fc26                	sd	s1,56(sp)
    800014bc:	f84a                	sd	s2,48(sp)
    800014be:	f44e                	sd	s3,40(sp)
    800014c0:	f052                	sd	s4,32(sp)
    800014c2:	ec56                	sd	s5,24(sp)
    800014c4:	e85a                	sd	s6,16(sp)
    800014c6:	e45e                	sd	s7,8(sp)
    800014c8:	0880                	addi	s0,sp,80
    800014ca:	8aaa                	mv	s5,a0
    800014cc:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800014ce:	777d                	lui	a4,0xfffff
    800014d0:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800014d4:	167d                	addi	a2,a2,-1
    800014d6:	00b609b3          	add	s3,a2,a1
    800014da:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800014de:	893e                	mv	s2,a5
    800014e0:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800014e4:	6b85                	lui	s7,0x1
    800014e6:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800014ea:	4605                	li	a2,1
    800014ec:	85ca                	mv	a1,s2
    800014ee:	8556                	mv	a0,s5
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	eb8080e7          	jalr	-328(ra) # 800013a8 <walk>
    800014f8:	c51d                	beqz	a0,80001526 <mappages+0x72>
    if(*pte & PTE_V)
    800014fa:	611c                	ld	a5,0(a0)
    800014fc:	8b85                	andi	a5,a5,1
    800014fe:	ef81                	bnez	a5,80001516 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001500:	80b1                	srli	s1,s1,0xc
    80001502:	04aa                	slli	s1,s1,0xa
    80001504:	0164e4b3          	or	s1,s1,s6
    80001508:	0014e493          	ori	s1,s1,1
    8000150c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000150e:	03390863          	beq	s2,s3,8000153e <mappages+0x8a>
    a += PGSIZE;
    80001512:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001514:	bfc9                	j	800014e6 <mappages+0x32>
      panic("remap");
    80001516:	00007517          	auipc	a0,0x7
    8000151a:	c6250513          	addi	a0,a0,-926 # 80008178 <digits+0x138>
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	02c080e7          	jalr	44(ra) # 8000054a <panic>
      return -1;
    80001526:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001528:	60a6                	ld	ra,72(sp)
    8000152a:	6406                	ld	s0,64(sp)
    8000152c:	74e2                	ld	s1,56(sp)
    8000152e:	7942                	ld	s2,48(sp)
    80001530:	79a2                	ld	s3,40(sp)
    80001532:	7a02                	ld	s4,32(sp)
    80001534:	6ae2                	ld	s5,24(sp)
    80001536:	6b42                	ld	s6,16(sp)
    80001538:	6ba2                	ld	s7,8(sp)
    8000153a:	6161                	addi	sp,sp,80
    8000153c:	8082                	ret
  return 0;
    8000153e:	4501                	li	a0,0
    80001540:	b7e5                	j	80001528 <mappages+0x74>

0000000080001542 <kvmmap>:
{
    80001542:	1141                	addi	sp,sp,-16
    80001544:	e406                	sd	ra,8(sp)
    80001546:	e022                	sd	s0,0(sp)
    80001548:	0800                	addi	s0,sp,16
    8000154a:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000154c:	86ae                	mv	a3,a1
    8000154e:	85aa                	mv	a1,a0
    80001550:	00008517          	auipc	a0,0x8
    80001554:	ac053503          	ld	a0,-1344(a0) # 80009010 <kernel_pagetable>
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	f5c080e7          	jalr	-164(ra) # 800014b4 <mappages>
    80001560:	e509                	bnez	a0,8000156a <kvmmap+0x28>
}
    80001562:	60a2                	ld	ra,8(sp)
    80001564:	6402                	ld	s0,0(sp)
    80001566:	0141                	addi	sp,sp,16
    80001568:	8082                	ret
    panic("kvmmap");
    8000156a:	00007517          	auipc	a0,0x7
    8000156e:	c1650513          	addi	a0,a0,-1002 # 80008180 <digits+0x140>
    80001572:	fffff097          	auipc	ra,0xfffff
    80001576:	fd8080e7          	jalr	-40(ra) # 8000054a <panic>

000000008000157a <kvminit>:
{
    8000157a:	1101                	addi	sp,sp,-32
    8000157c:	ec06                	sd	ra,24(sp)
    8000157e:	e822                	sd	s0,16(sp)
    80001580:	e426                	sd	s1,8(sp)
    80001582:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001584:	fffff097          	auipc	ra,0xfffff
    80001588:	5fc080e7          	jalr	1532(ra) # 80000b80 <kalloc>
    8000158c:	00008797          	auipc	a5,0x8
    80001590:	a8a7b223          	sd	a0,-1404(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001594:	6605                	lui	a2,0x1
    80001596:	4581                	li	a1,0
    80001598:	00000097          	auipc	ra,0x0
    8000159c:	b44080e7          	jalr	-1212(ra) # 800010dc <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800015a0:	4699                	li	a3,6
    800015a2:	6605                	lui	a2,0x1
    800015a4:	100005b7          	lui	a1,0x10000
    800015a8:	10000537          	lui	a0,0x10000
    800015ac:	00000097          	auipc	ra,0x0
    800015b0:	f96080e7          	jalr	-106(ra) # 80001542 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800015b4:	4699                	li	a3,6
    800015b6:	6605                	lui	a2,0x1
    800015b8:	100015b7          	lui	a1,0x10001
    800015bc:	10001537          	lui	a0,0x10001
    800015c0:	00000097          	auipc	ra,0x0
    800015c4:	f82080e7          	jalr	-126(ra) # 80001542 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800015c8:	4699                	li	a3,6
    800015ca:	00400637          	lui	a2,0x400
    800015ce:	0c0005b7          	lui	a1,0xc000
    800015d2:	0c000537          	lui	a0,0xc000
    800015d6:	00000097          	auipc	ra,0x0
    800015da:	f6c080e7          	jalr	-148(ra) # 80001542 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800015de:	00007497          	auipc	s1,0x7
    800015e2:	a2248493          	addi	s1,s1,-1502 # 80008000 <etext>
    800015e6:	46a9                	li	a3,10
    800015e8:	80007617          	auipc	a2,0x80007
    800015ec:	a1860613          	addi	a2,a2,-1512 # 8000 <_entry-0x7fff8000>
    800015f0:	4585                	li	a1,1
    800015f2:	05fe                	slli	a1,a1,0x1f
    800015f4:	852e                	mv	a0,a1
    800015f6:	00000097          	auipc	ra,0x0
    800015fa:	f4c080e7          	jalr	-180(ra) # 80001542 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800015fe:	4699                	li	a3,6
    80001600:	4645                	li	a2,17
    80001602:	066e                	slli	a2,a2,0x1b
    80001604:	8e05                	sub	a2,a2,s1
    80001606:	85a6                	mv	a1,s1
    80001608:	8526                	mv	a0,s1
    8000160a:	00000097          	auipc	ra,0x0
    8000160e:	f38080e7          	jalr	-200(ra) # 80001542 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001612:	46a9                	li	a3,10
    80001614:	6605                	lui	a2,0x1
    80001616:	00006597          	auipc	a1,0x6
    8000161a:	9ea58593          	addi	a1,a1,-1558 # 80007000 <_trampoline>
    8000161e:	04000537          	lui	a0,0x4000
    80001622:	157d                	addi	a0,a0,-1
    80001624:	0532                	slli	a0,a0,0xc
    80001626:	00000097          	auipc	ra,0x0
    8000162a:	f1c080e7          	jalr	-228(ra) # 80001542 <kvmmap>
}
    8000162e:	60e2                	ld	ra,24(sp)
    80001630:	6442                	ld	s0,16(sp)
    80001632:	64a2                	ld	s1,8(sp)
    80001634:	6105                	addi	sp,sp,32
    80001636:	8082                	ret

0000000080001638 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001638:	715d                	addi	sp,sp,-80
    8000163a:	e486                	sd	ra,72(sp)
    8000163c:	e0a2                	sd	s0,64(sp)
    8000163e:	fc26                	sd	s1,56(sp)
    80001640:	f84a                	sd	s2,48(sp)
    80001642:	f44e                	sd	s3,40(sp)
    80001644:	f052                	sd	s4,32(sp)
    80001646:	ec56                	sd	s5,24(sp)
    80001648:	e85a                	sd	s6,16(sp)
    8000164a:	e45e                	sd	s7,8(sp)
    8000164c:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000164e:	03459793          	slli	a5,a1,0x34
    80001652:	e795                	bnez	a5,8000167e <uvmunmap+0x46>
    80001654:	8a2a                	mv	s4,a0
    80001656:	892e                	mv	s2,a1
    80001658:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000165a:	0632                	slli	a2,a2,0xc
    8000165c:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001660:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001662:	6b05                	lui	s6,0x1
    80001664:	0735e263          	bltu	a1,s3,800016c8 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001668:	60a6                	ld	ra,72(sp)
    8000166a:	6406                	ld	s0,64(sp)
    8000166c:	74e2                	ld	s1,56(sp)
    8000166e:	7942                	ld	s2,48(sp)
    80001670:	79a2                	ld	s3,40(sp)
    80001672:	7a02                	ld	s4,32(sp)
    80001674:	6ae2                	ld	s5,24(sp)
    80001676:	6b42                	ld	s6,16(sp)
    80001678:	6ba2                	ld	s7,8(sp)
    8000167a:	6161                	addi	sp,sp,80
    8000167c:	8082                	ret
    panic("uvmunmap: not aligned");
    8000167e:	00007517          	auipc	a0,0x7
    80001682:	b0a50513          	addi	a0,a0,-1270 # 80008188 <digits+0x148>
    80001686:	fffff097          	auipc	ra,0xfffff
    8000168a:	ec4080e7          	jalr	-316(ra) # 8000054a <panic>
      panic("uvmunmap: walk");
    8000168e:	00007517          	auipc	a0,0x7
    80001692:	b1250513          	addi	a0,a0,-1262 # 800081a0 <digits+0x160>
    80001696:	fffff097          	auipc	ra,0xfffff
    8000169a:	eb4080e7          	jalr	-332(ra) # 8000054a <panic>
      panic("uvmunmap: not mapped");
    8000169e:	00007517          	auipc	a0,0x7
    800016a2:	b1250513          	addi	a0,a0,-1262 # 800081b0 <digits+0x170>
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	ea4080e7          	jalr	-348(ra) # 8000054a <panic>
      panic("uvmunmap: not a leaf");
    800016ae:	00007517          	auipc	a0,0x7
    800016b2:	b1a50513          	addi	a0,a0,-1254 # 800081c8 <digits+0x188>
    800016b6:	fffff097          	auipc	ra,0xfffff
    800016ba:	e94080e7          	jalr	-364(ra) # 8000054a <panic>
    *pte = 0;
    800016be:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800016c2:	995a                	add	s2,s2,s6
    800016c4:	fb3972e3          	bgeu	s2,s3,80001668 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800016c8:	4601                	li	a2,0
    800016ca:	85ca                	mv	a1,s2
    800016cc:	8552                	mv	a0,s4
    800016ce:	00000097          	auipc	ra,0x0
    800016d2:	cda080e7          	jalr	-806(ra) # 800013a8 <walk>
    800016d6:	84aa                	mv	s1,a0
    800016d8:	d95d                	beqz	a0,8000168e <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800016da:	6108                	ld	a0,0(a0)
    800016dc:	00157793          	andi	a5,a0,1
    800016e0:	dfdd                	beqz	a5,8000169e <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800016e2:	3ff57793          	andi	a5,a0,1023
    800016e6:	fd7784e3          	beq	a5,s7,800016ae <uvmunmap+0x76>
    if(do_free){
    800016ea:	fc0a8ae3          	beqz	s5,800016be <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800016ee:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800016f0:	0532                	slli	a0,a0,0xc
    800016f2:	fffff097          	auipc	ra,0xfffff
    800016f6:	328080e7          	jalr	808(ra) # 80000a1a <kfree>
    800016fa:	b7d1                	j	800016be <uvmunmap+0x86>

00000000800016fc <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800016fc:	1101                	addi	sp,sp,-32
    800016fe:	ec06                	sd	ra,24(sp)
    80001700:	e822                	sd	s0,16(sp)
    80001702:	e426                	sd	s1,8(sp)
    80001704:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001706:	fffff097          	auipc	ra,0xfffff
    8000170a:	47a080e7          	jalr	1146(ra) # 80000b80 <kalloc>
    8000170e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001710:	c519                	beqz	a0,8000171e <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001712:	6605                	lui	a2,0x1
    80001714:	4581                	li	a1,0
    80001716:	00000097          	auipc	ra,0x0
    8000171a:	9c6080e7          	jalr	-1594(ra) # 800010dc <memset>
  return pagetable;
}
    8000171e:	8526                	mv	a0,s1
    80001720:	60e2                	ld	ra,24(sp)
    80001722:	6442                	ld	s0,16(sp)
    80001724:	64a2                	ld	s1,8(sp)
    80001726:	6105                	addi	sp,sp,32
    80001728:	8082                	ret

000000008000172a <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000172a:	7179                	addi	sp,sp,-48
    8000172c:	f406                	sd	ra,40(sp)
    8000172e:	f022                	sd	s0,32(sp)
    80001730:	ec26                	sd	s1,24(sp)
    80001732:	e84a                	sd	s2,16(sp)
    80001734:	e44e                	sd	s3,8(sp)
    80001736:	e052                	sd	s4,0(sp)
    80001738:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000173a:	6785                	lui	a5,0x1
    8000173c:	04f67863          	bgeu	a2,a5,8000178c <uvminit+0x62>
    80001740:	8a2a                	mv	s4,a0
    80001742:	89ae                	mv	s3,a1
    80001744:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001746:	fffff097          	auipc	ra,0xfffff
    8000174a:	43a080e7          	jalr	1082(ra) # 80000b80 <kalloc>
    8000174e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001750:	6605                	lui	a2,0x1
    80001752:	4581                	li	a1,0
    80001754:	00000097          	auipc	ra,0x0
    80001758:	988080e7          	jalr	-1656(ra) # 800010dc <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000175c:	4779                	li	a4,30
    8000175e:	86ca                	mv	a3,s2
    80001760:	6605                	lui	a2,0x1
    80001762:	4581                	li	a1,0
    80001764:	8552                	mv	a0,s4
    80001766:	00000097          	auipc	ra,0x0
    8000176a:	d4e080e7          	jalr	-690(ra) # 800014b4 <mappages>
  memmove(mem, src, sz);
    8000176e:	8626                	mv	a2,s1
    80001770:	85ce                	mv	a1,s3
    80001772:	854a                	mv	a0,s2
    80001774:	00000097          	auipc	ra,0x0
    80001778:	9c4080e7          	jalr	-1596(ra) # 80001138 <memmove>
}
    8000177c:	70a2                	ld	ra,40(sp)
    8000177e:	7402                	ld	s0,32(sp)
    80001780:	64e2                	ld	s1,24(sp)
    80001782:	6942                	ld	s2,16(sp)
    80001784:	69a2                	ld	s3,8(sp)
    80001786:	6a02                	ld	s4,0(sp)
    80001788:	6145                	addi	sp,sp,48
    8000178a:	8082                	ret
    panic("inituvm: more than a page");
    8000178c:	00007517          	auipc	a0,0x7
    80001790:	a5450513          	addi	a0,a0,-1452 # 800081e0 <digits+0x1a0>
    80001794:	fffff097          	auipc	ra,0xfffff
    80001798:	db6080e7          	jalr	-586(ra) # 8000054a <panic>

000000008000179c <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000179c:	1101                	addi	sp,sp,-32
    8000179e:	ec06                	sd	ra,24(sp)
    800017a0:	e822                	sd	s0,16(sp)
    800017a2:	e426                	sd	s1,8(sp)
    800017a4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800017a6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800017a8:	00b67d63          	bgeu	a2,a1,800017c2 <uvmdealloc+0x26>
    800017ac:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800017ae:	6785                	lui	a5,0x1
    800017b0:	17fd                	addi	a5,a5,-1
    800017b2:	00f60733          	add	a4,a2,a5
    800017b6:	767d                	lui	a2,0xfffff
    800017b8:	8f71                	and	a4,a4,a2
    800017ba:	97ae                	add	a5,a5,a1
    800017bc:	8ff1                	and	a5,a5,a2
    800017be:	00f76863          	bltu	a4,a5,800017ce <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800017c2:	8526                	mv	a0,s1
    800017c4:	60e2                	ld	ra,24(sp)
    800017c6:	6442                	ld	s0,16(sp)
    800017c8:	64a2                	ld	s1,8(sp)
    800017ca:	6105                	addi	sp,sp,32
    800017cc:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800017ce:	8f99                	sub	a5,a5,a4
    800017d0:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800017d2:	4685                	li	a3,1
    800017d4:	0007861b          	sext.w	a2,a5
    800017d8:	85ba                	mv	a1,a4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	e5e080e7          	jalr	-418(ra) # 80001638 <uvmunmap>
    800017e2:	b7c5                	j	800017c2 <uvmdealloc+0x26>

00000000800017e4 <uvmalloc>:
  if(newsz < oldsz)
    800017e4:	0ab66163          	bltu	a2,a1,80001886 <uvmalloc+0xa2>
{
    800017e8:	7139                	addi	sp,sp,-64
    800017ea:	fc06                	sd	ra,56(sp)
    800017ec:	f822                	sd	s0,48(sp)
    800017ee:	f426                	sd	s1,40(sp)
    800017f0:	f04a                	sd	s2,32(sp)
    800017f2:	ec4e                	sd	s3,24(sp)
    800017f4:	e852                	sd	s4,16(sp)
    800017f6:	e456                	sd	s5,8(sp)
    800017f8:	0080                	addi	s0,sp,64
    800017fa:	8aaa                	mv	s5,a0
    800017fc:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800017fe:	6985                	lui	s3,0x1
    80001800:	19fd                	addi	s3,s3,-1
    80001802:	95ce                	add	a1,a1,s3
    80001804:	79fd                	lui	s3,0xfffff
    80001806:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000180a:	08c9f063          	bgeu	s3,a2,8000188a <uvmalloc+0xa6>
    8000180e:	894e                	mv	s2,s3
    mem = kalloc();
    80001810:	fffff097          	auipc	ra,0xfffff
    80001814:	370080e7          	jalr	880(ra) # 80000b80 <kalloc>
    80001818:	84aa                	mv	s1,a0
    if(mem == 0){
    8000181a:	c51d                	beqz	a0,80001848 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000181c:	6605                	lui	a2,0x1
    8000181e:	4581                	li	a1,0
    80001820:	00000097          	auipc	ra,0x0
    80001824:	8bc080e7          	jalr	-1860(ra) # 800010dc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001828:	4779                	li	a4,30
    8000182a:	86a6                	mv	a3,s1
    8000182c:	6605                	lui	a2,0x1
    8000182e:	85ca                	mv	a1,s2
    80001830:	8556                	mv	a0,s5
    80001832:	00000097          	auipc	ra,0x0
    80001836:	c82080e7          	jalr	-894(ra) # 800014b4 <mappages>
    8000183a:	e905                	bnez	a0,8000186a <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000183c:	6785                	lui	a5,0x1
    8000183e:	993e                	add	s2,s2,a5
    80001840:	fd4968e3          	bltu	s2,s4,80001810 <uvmalloc+0x2c>
  return newsz;
    80001844:	8552                	mv	a0,s4
    80001846:	a809                	j	80001858 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001848:	864e                	mv	a2,s3
    8000184a:	85ca                	mv	a1,s2
    8000184c:	8556                	mv	a0,s5
    8000184e:	00000097          	auipc	ra,0x0
    80001852:	f4e080e7          	jalr	-178(ra) # 8000179c <uvmdealloc>
      return 0;
    80001856:	4501                	li	a0,0
}
    80001858:	70e2                	ld	ra,56(sp)
    8000185a:	7442                	ld	s0,48(sp)
    8000185c:	74a2                	ld	s1,40(sp)
    8000185e:	7902                	ld	s2,32(sp)
    80001860:	69e2                	ld	s3,24(sp)
    80001862:	6a42                	ld	s4,16(sp)
    80001864:	6aa2                	ld	s5,8(sp)
    80001866:	6121                	addi	sp,sp,64
    80001868:	8082                	ret
      kfree(mem);
    8000186a:	8526                	mv	a0,s1
    8000186c:	fffff097          	auipc	ra,0xfffff
    80001870:	1ae080e7          	jalr	430(ra) # 80000a1a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001874:	864e                	mv	a2,s3
    80001876:	85ca                	mv	a1,s2
    80001878:	8556                	mv	a0,s5
    8000187a:	00000097          	auipc	ra,0x0
    8000187e:	f22080e7          	jalr	-222(ra) # 8000179c <uvmdealloc>
      return 0;
    80001882:	4501                	li	a0,0
    80001884:	bfd1                	j	80001858 <uvmalloc+0x74>
    return oldsz;
    80001886:	852e                	mv	a0,a1
}
    80001888:	8082                	ret
  return newsz;
    8000188a:	8532                	mv	a0,a2
    8000188c:	b7f1                	j	80001858 <uvmalloc+0x74>

000000008000188e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000188e:	7179                	addi	sp,sp,-48
    80001890:	f406                	sd	ra,40(sp)
    80001892:	f022                	sd	s0,32(sp)
    80001894:	ec26                	sd	s1,24(sp)
    80001896:	e84a                	sd	s2,16(sp)
    80001898:	e44e                	sd	s3,8(sp)
    8000189a:	e052                	sd	s4,0(sp)
    8000189c:	1800                	addi	s0,sp,48
    8000189e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800018a0:	84aa                	mv	s1,a0
    800018a2:	6905                	lui	s2,0x1
    800018a4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800018a6:	4985                	li	s3,1
    800018a8:	a821                	j	800018c0 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800018aa:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800018ac:	0532                	slli	a0,a0,0xc
    800018ae:	00000097          	auipc	ra,0x0
    800018b2:	fe0080e7          	jalr	-32(ra) # 8000188e <freewalk>
      pagetable[i] = 0;
    800018b6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800018ba:	04a1                	addi	s1,s1,8
    800018bc:	03248163          	beq	s1,s2,800018de <freewalk+0x50>
    pte_t pte = pagetable[i];
    800018c0:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800018c2:	00f57793          	andi	a5,a0,15
    800018c6:	ff3782e3          	beq	a5,s3,800018aa <freewalk+0x1c>
    } else if(pte & PTE_V){
    800018ca:	8905                	andi	a0,a0,1
    800018cc:	d57d                	beqz	a0,800018ba <freewalk+0x2c>
      panic("freewalk: leaf");
    800018ce:	00007517          	auipc	a0,0x7
    800018d2:	93250513          	addi	a0,a0,-1742 # 80008200 <digits+0x1c0>
    800018d6:	fffff097          	auipc	ra,0xfffff
    800018da:	c74080e7          	jalr	-908(ra) # 8000054a <panic>
    }
  }
  kfree((void*)pagetable);
    800018de:	8552                	mv	a0,s4
    800018e0:	fffff097          	auipc	ra,0xfffff
    800018e4:	13a080e7          	jalr	314(ra) # 80000a1a <kfree>
}
    800018e8:	70a2                	ld	ra,40(sp)
    800018ea:	7402                	ld	s0,32(sp)
    800018ec:	64e2                	ld	s1,24(sp)
    800018ee:	6942                	ld	s2,16(sp)
    800018f0:	69a2                	ld	s3,8(sp)
    800018f2:	6a02                	ld	s4,0(sp)
    800018f4:	6145                	addi	sp,sp,48
    800018f6:	8082                	ret

00000000800018f8 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800018f8:	1101                	addi	sp,sp,-32
    800018fa:	ec06                	sd	ra,24(sp)
    800018fc:	e822                	sd	s0,16(sp)
    800018fe:	e426                	sd	s1,8(sp)
    80001900:	1000                	addi	s0,sp,32
    80001902:	84aa                	mv	s1,a0
  if(sz > 0)
    80001904:	e999                	bnez	a1,8000191a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001906:	8526                	mv	a0,s1
    80001908:	00000097          	auipc	ra,0x0
    8000190c:	f86080e7          	jalr	-122(ra) # 8000188e <freewalk>
}
    80001910:	60e2                	ld	ra,24(sp)
    80001912:	6442                	ld	s0,16(sp)
    80001914:	64a2                	ld	s1,8(sp)
    80001916:	6105                	addi	sp,sp,32
    80001918:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000191a:	6605                	lui	a2,0x1
    8000191c:	167d                	addi	a2,a2,-1
    8000191e:	962e                	add	a2,a2,a1
    80001920:	4685                	li	a3,1
    80001922:	8231                	srli	a2,a2,0xc
    80001924:	4581                	li	a1,0
    80001926:	00000097          	auipc	ra,0x0
    8000192a:	d12080e7          	jalr	-750(ra) # 80001638 <uvmunmap>
    8000192e:	bfe1                	j	80001906 <uvmfree+0xe>

0000000080001930 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001930:	c679                	beqz	a2,800019fe <uvmcopy+0xce>
{
    80001932:	715d                	addi	sp,sp,-80
    80001934:	e486                	sd	ra,72(sp)
    80001936:	e0a2                	sd	s0,64(sp)
    80001938:	fc26                	sd	s1,56(sp)
    8000193a:	f84a                	sd	s2,48(sp)
    8000193c:	f44e                	sd	s3,40(sp)
    8000193e:	f052                	sd	s4,32(sp)
    80001940:	ec56                	sd	s5,24(sp)
    80001942:	e85a                	sd	s6,16(sp)
    80001944:	e45e                	sd	s7,8(sp)
    80001946:	0880                	addi	s0,sp,80
    80001948:	8b2a                	mv	s6,a0
    8000194a:	8aae                	mv	s5,a1
    8000194c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000194e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001950:	4601                	li	a2,0
    80001952:	85ce                	mv	a1,s3
    80001954:	855a                	mv	a0,s6
    80001956:	00000097          	auipc	ra,0x0
    8000195a:	a52080e7          	jalr	-1454(ra) # 800013a8 <walk>
    8000195e:	c531                	beqz	a0,800019aa <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001960:	6118                	ld	a4,0(a0)
    80001962:	00177793          	andi	a5,a4,1
    80001966:	cbb1                	beqz	a5,800019ba <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001968:	00a75593          	srli	a1,a4,0xa
    8000196c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001970:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001974:	fffff097          	auipc	ra,0xfffff
    80001978:	20c080e7          	jalr	524(ra) # 80000b80 <kalloc>
    8000197c:	892a                	mv	s2,a0
    8000197e:	c939                	beqz	a0,800019d4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001980:	6605                	lui	a2,0x1
    80001982:	85de                	mv	a1,s7
    80001984:	fffff097          	auipc	ra,0xfffff
    80001988:	7b4080e7          	jalr	1972(ra) # 80001138 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000198c:	8726                	mv	a4,s1
    8000198e:	86ca                	mv	a3,s2
    80001990:	6605                	lui	a2,0x1
    80001992:	85ce                	mv	a1,s3
    80001994:	8556                	mv	a0,s5
    80001996:	00000097          	auipc	ra,0x0
    8000199a:	b1e080e7          	jalr	-1250(ra) # 800014b4 <mappages>
    8000199e:	e515                	bnez	a0,800019ca <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800019a0:	6785                	lui	a5,0x1
    800019a2:	99be                	add	s3,s3,a5
    800019a4:	fb49e6e3          	bltu	s3,s4,80001950 <uvmcopy+0x20>
    800019a8:	a081                	j	800019e8 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800019aa:	00007517          	auipc	a0,0x7
    800019ae:	86650513          	addi	a0,a0,-1946 # 80008210 <digits+0x1d0>
    800019b2:	fffff097          	auipc	ra,0xfffff
    800019b6:	b98080e7          	jalr	-1128(ra) # 8000054a <panic>
      panic("uvmcopy: page not present");
    800019ba:	00007517          	auipc	a0,0x7
    800019be:	87650513          	addi	a0,a0,-1930 # 80008230 <digits+0x1f0>
    800019c2:	fffff097          	auipc	ra,0xfffff
    800019c6:	b88080e7          	jalr	-1144(ra) # 8000054a <panic>
      kfree(mem);
    800019ca:	854a                	mv	a0,s2
    800019cc:	fffff097          	auipc	ra,0xfffff
    800019d0:	04e080e7          	jalr	78(ra) # 80000a1a <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800019d4:	4685                	li	a3,1
    800019d6:	00c9d613          	srli	a2,s3,0xc
    800019da:	4581                	li	a1,0
    800019dc:	8556                	mv	a0,s5
    800019de:	00000097          	auipc	ra,0x0
    800019e2:	c5a080e7          	jalr	-934(ra) # 80001638 <uvmunmap>
  return -1;
    800019e6:	557d                	li	a0,-1
}
    800019e8:	60a6                	ld	ra,72(sp)
    800019ea:	6406                	ld	s0,64(sp)
    800019ec:	74e2                	ld	s1,56(sp)
    800019ee:	7942                	ld	s2,48(sp)
    800019f0:	79a2                	ld	s3,40(sp)
    800019f2:	7a02                	ld	s4,32(sp)
    800019f4:	6ae2                	ld	s5,24(sp)
    800019f6:	6b42                	ld	s6,16(sp)
    800019f8:	6ba2                	ld	s7,8(sp)
    800019fa:	6161                	addi	sp,sp,80
    800019fc:	8082                	ret
  return 0;
    800019fe:	4501                	li	a0,0
}
    80001a00:	8082                	ret

0000000080001a02 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001a02:	1141                	addi	sp,sp,-16
    80001a04:	e406                	sd	ra,8(sp)
    80001a06:	e022                	sd	s0,0(sp)
    80001a08:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001a0a:	4601                	li	a2,0
    80001a0c:	00000097          	auipc	ra,0x0
    80001a10:	99c080e7          	jalr	-1636(ra) # 800013a8 <walk>
  if(pte == 0)
    80001a14:	c901                	beqz	a0,80001a24 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001a16:	611c                	ld	a5,0(a0)
    80001a18:	9bbd                	andi	a5,a5,-17
    80001a1a:	e11c                	sd	a5,0(a0)
}
    80001a1c:	60a2                	ld	ra,8(sp)
    80001a1e:	6402                	ld	s0,0(sp)
    80001a20:	0141                	addi	sp,sp,16
    80001a22:	8082                	ret
    panic("uvmclear");
    80001a24:	00007517          	auipc	a0,0x7
    80001a28:	82c50513          	addi	a0,a0,-2004 # 80008250 <digits+0x210>
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	b1e080e7          	jalr	-1250(ra) # 8000054a <panic>

0000000080001a34 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001a34:	c6bd                	beqz	a3,80001aa2 <copyout+0x6e>
{
    80001a36:	715d                	addi	sp,sp,-80
    80001a38:	e486                	sd	ra,72(sp)
    80001a3a:	e0a2                	sd	s0,64(sp)
    80001a3c:	fc26                	sd	s1,56(sp)
    80001a3e:	f84a                	sd	s2,48(sp)
    80001a40:	f44e                	sd	s3,40(sp)
    80001a42:	f052                	sd	s4,32(sp)
    80001a44:	ec56                	sd	s5,24(sp)
    80001a46:	e85a                	sd	s6,16(sp)
    80001a48:	e45e                	sd	s7,8(sp)
    80001a4a:	e062                	sd	s8,0(sp)
    80001a4c:	0880                	addi	s0,sp,80
    80001a4e:	8b2a                	mv	s6,a0
    80001a50:	8c2e                	mv	s8,a1
    80001a52:	8a32                	mv	s4,a2
    80001a54:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001a56:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001a58:	6a85                	lui	s5,0x1
    80001a5a:	a015                	j	80001a7e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001a5c:	9562                	add	a0,a0,s8
    80001a5e:	0004861b          	sext.w	a2,s1
    80001a62:	85d2                	mv	a1,s4
    80001a64:	41250533          	sub	a0,a0,s2
    80001a68:	fffff097          	auipc	ra,0xfffff
    80001a6c:	6d0080e7          	jalr	1744(ra) # 80001138 <memmove>

    len -= n;
    80001a70:	409989b3          	sub	s3,s3,s1
    src += n;
    80001a74:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001a76:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001a7a:	02098263          	beqz	s3,80001a9e <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001a7e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001a82:	85ca                	mv	a1,s2
    80001a84:	855a                	mv	a0,s6
    80001a86:	00000097          	auipc	ra,0x0
    80001a8a:	9ec080e7          	jalr	-1556(ra) # 80001472 <walkaddr>
    if(pa0 == 0)
    80001a8e:	cd01                	beqz	a0,80001aa6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001a90:	418904b3          	sub	s1,s2,s8
    80001a94:	94d6                	add	s1,s1,s5
    if(n > len)
    80001a96:	fc99f3e3          	bgeu	s3,s1,80001a5c <copyout+0x28>
    80001a9a:	84ce                	mv	s1,s3
    80001a9c:	b7c1                	j	80001a5c <copyout+0x28>
  }
  return 0;
    80001a9e:	4501                	li	a0,0
    80001aa0:	a021                	j	80001aa8 <copyout+0x74>
    80001aa2:	4501                	li	a0,0
}
    80001aa4:	8082                	ret
      return -1;
    80001aa6:	557d                	li	a0,-1
}
    80001aa8:	60a6                	ld	ra,72(sp)
    80001aaa:	6406                	ld	s0,64(sp)
    80001aac:	74e2                	ld	s1,56(sp)
    80001aae:	7942                	ld	s2,48(sp)
    80001ab0:	79a2                	ld	s3,40(sp)
    80001ab2:	7a02                	ld	s4,32(sp)
    80001ab4:	6ae2                	ld	s5,24(sp)
    80001ab6:	6b42                	ld	s6,16(sp)
    80001ab8:	6ba2                	ld	s7,8(sp)
    80001aba:	6c02                	ld	s8,0(sp)
    80001abc:	6161                	addi	sp,sp,80
    80001abe:	8082                	ret

0000000080001ac0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001ac0:	caa5                	beqz	a3,80001b30 <copyin+0x70>
{
    80001ac2:	715d                	addi	sp,sp,-80
    80001ac4:	e486                	sd	ra,72(sp)
    80001ac6:	e0a2                	sd	s0,64(sp)
    80001ac8:	fc26                	sd	s1,56(sp)
    80001aca:	f84a                	sd	s2,48(sp)
    80001acc:	f44e                	sd	s3,40(sp)
    80001ace:	f052                	sd	s4,32(sp)
    80001ad0:	ec56                	sd	s5,24(sp)
    80001ad2:	e85a                	sd	s6,16(sp)
    80001ad4:	e45e                	sd	s7,8(sp)
    80001ad6:	e062                	sd	s8,0(sp)
    80001ad8:	0880                	addi	s0,sp,80
    80001ada:	8b2a                	mv	s6,a0
    80001adc:	8a2e                	mv	s4,a1
    80001ade:	8c32                	mv	s8,a2
    80001ae0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001ae2:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001ae4:	6a85                	lui	s5,0x1
    80001ae6:	a01d                	j	80001b0c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001ae8:	018505b3          	add	a1,a0,s8
    80001aec:	0004861b          	sext.w	a2,s1
    80001af0:	412585b3          	sub	a1,a1,s2
    80001af4:	8552                	mv	a0,s4
    80001af6:	fffff097          	auipc	ra,0xfffff
    80001afa:	642080e7          	jalr	1602(ra) # 80001138 <memmove>

    len -= n;
    80001afe:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001b02:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001b04:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001b08:	02098263          	beqz	s3,80001b2c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001b0c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001b10:	85ca                	mv	a1,s2
    80001b12:	855a                	mv	a0,s6
    80001b14:	00000097          	auipc	ra,0x0
    80001b18:	95e080e7          	jalr	-1698(ra) # 80001472 <walkaddr>
    if(pa0 == 0)
    80001b1c:	cd01                	beqz	a0,80001b34 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001b1e:	418904b3          	sub	s1,s2,s8
    80001b22:	94d6                	add	s1,s1,s5
    if(n > len)
    80001b24:	fc99f2e3          	bgeu	s3,s1,80001ae8 <copyin+0x28>
    80001b28:	84ce                	mv	s1,s3
    80001b2a:	bf7d                	j	80001ae8 <copyin+0x28>
  }
  return 0;
    80001b2c:	4501                	li	a0,0
    80001b2e:	a021                	j	80001b36 <copyin+0x76>
    80001b30:	4501                	li	a0,0
}
    80001b32:	8082                	ret
      return -1;
    80001b34:	557d                	li	a0,-1
}
    80001b36:	60a6                	ld	ra,72(sp)
    80001b38:	6406                	ld	s0,64(sp)
    80001b3a:	74e2                	ld	s1,56(sp)
    80001b3c:	7942                	ld	s2,48(sp)
    80001b3e:	79a2                	ld	s3,40(sp)
    80001b40:	7a02                	ld	s4,32(sp)
    80001b42:	6ae2                	ld	s5,24(sp)
    80001b44:	6b42                	ld	s6,16(sp)
    80001b46:	6ba2                	ld	s7,8(sp)
    80001b48:	6c02                	ld	s8,0(sp)
    80001b4a:	6161                	addi	sp,sp,80
    80001b4c:	8082                	ret

0000000080001b4e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001b4e:	c6c5                	beqz	a3,80001bf6 <copyinstr+0xa8>
{
    80001b50:	715d                	addi	sp,sp,-80
    80001b52:	e486                	sd	ra,72(sp)
    80001b54:	e0a2                	sd	s0,64(sp)
    80001b56:	fc26                	sd	s1,56(sp)
    80001b58:	f84a                	sd	s2,48(sp)
    80001b5a:	f44e                	sd	s3,40(sp)
    80001b5c:	f052                	sd	s4,32(sp)
    80001b5e:	ec56                	sd	s5,24(sp)
    80001b60:	e85a                	sd	s6,16(sp)
    80001b62:	e45e                	sd	s7,8(sp)
    80001b64:	0880                	addi	s0,sp,80
    80001b66:	8a2a                	mv	s4,a0
    80001b68:	8b2e                	mv	s6,a1
    80001b6a:	8bb2                	mv	s7,a2
    80001b6c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001b6e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001b70:	6985                	lui	s3,0x1
    80001b72:	a035                	j	80001b9e <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001b74:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001b78:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001b7a:	0017b793          	seqz	a5,a5
    80001b7e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001b82:	60a6                	ld	ra,72(sp)
    80001b84:	6406                	ld	s0,64(sp)
    80001b86:	74e2                	ld	s1,56(sp)
    80001b88:	7942                	ld	s2,48(sp)
    80001b8a:	79a2                	ld	s3,40(sp)
    80001b8c:	7a02                	ld	s4,32(sp)
    80001b8e:	6ae2                	ld	s5,24(sp)
    80001b90:	6b42                	ld	s6,16(sp)
    80001b92:	6ba2                	ld	s7,8(sp)
    80001b94:	6161                	addi	sp,sp,80
    80001b96:	8082                	ret
    srcva = va0 + PGSIZE;
    80001b98:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001b9c:	c8a9                	beqz	s1,80001bee <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001b9e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001ba2:	85ca                	mv	a1,s2
    80001ba4:	8552                	mv	a0,s4
    80001ba6:	00000097          	auipc	ra,0x0
    80001baa:	8cc080e7          	jalr	-1844(ra) # 80001472 <walkaddr>
    if(pa0 == 0)
    80001bae:	c131                	beqz	a0,80001bf2 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001bb0:	41790833          	sub	a6,s2,s7
    80001bb4:	984e                	add	a6,a6,s3
    if(n > max)
    80001bb6:	0104f363          	bgeu	s1,a6,80001bbc <copyinstr+0x6e>
    80001bba:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001bbc:	955e                	add	a0,a0,s7
    80001bbe:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001bc2:	fc080be3          	beqz	a6,80001b98 <copyinstr+0x4a>
    80001bc6:	985a                	add	a6,a6,s6
    80001bc8:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001bca:	41650633          	sub	a2,a0,s6
    80001bce:	14fd                	addi	s1,s1,-1
    80001bd0:	9b26                	add	s6,s6,s1
    80001bd2:	00f60733          	add	a4,a2,a5
    80001bd6:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd2fd8>
    80001bda:	df49                	beqz	a4,80001b74 <copyinstr+0x26>
        *dst = *p;
    80001bdc:	00e78023          	sb	a4,0(a5)
      --max;
    80001be0:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001be4:	0785                	addi	a5,a5,1
    while(n > 0){
    80001be6:	ff0796e3          	bne	a5,a6,80001bd2 <copyinstr+0x84>
      dst++;
    80001bea:	8b42                	mv	s6,a6
    80001bec:	b775                	j	80001b98 <copyinstr+0x4a>
    80001bee:	4781                	li	a5,0
    80001bf0:	b769                	j	80001b7a <copyinstr+0x2c>
      return -1;
    80001bf2:	557d                	li	a0,-1
    80001bf4:	b779                	j	80001b82 <copyinstr+0x34>
  int got_null = 0;
    80001bf6:	4781                	li	a5,0
  if(got_null){
    80001bf8:	0017b793          	seqz	a5,a5
    80001bfc:	40f00533          	neg	a0,a5
}
    80001c00:	8082                	ret

0000000080001c02 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001c02:	1101                	addi	sp,sp,-32
    80001c04:	ec06                	sd	ra,24(sp)
    80001c06:	e822                	sd	s0,16(sp)
    80001c08:	e426                	sd	s1,8(sp)
    80001c0a:	1000                	addi	s0,sp,32
    80001c0c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001c0e:	fffff097          	auipc	ra,0xfffff
    80001c12:	074080e7          	jalr	116(ra) # 80000c82 <holding>
    80001c16:	c909                	beqz	a0,80001c28 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001c18:	789c                	ld	a5,48(s1)
    80001c1a:	00978f63          	beq	a5,s1,80001c38 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001c1e:	60e2                	ld	ra,24(sp)
    80001c20:	6442                	ld	s0,16(sp)
    80001c22:	64a2                	ld	s1,8(sp)
    80001c24:	6105                	addi	sp,sp,32
    80001c26:	8082                	ret
    panic("wakeup1");
    80001c28:	00006517          	auipc	a0,0x6
    80001c2c:	63850513          	addi	a0,a0,1592 # 80008260 <digits+0x220>
    80001c30:	fffff097          	auipc	ra,0xfffff
    80001c34:	91a080e7          	jalr	-1766(ra) # 8000054a <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001c38:	5098                	lw	a4,32(s1)
    80001c3a:	4785                	li	a5,1
    80001c3c:	fef711e3          	bne	a4,a5,80001c1e <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001c40:	4789                	li	a5,2
    80001c42:	d09c                	sw	a5,32(s1)
}
    80001c44:	bfe9                	j	80001c1e <wakeup1+0x1c>

0000000080001c46 <procinit>:
{
    80001c46:	715d                	addi	sp,sp,-80
    80001c48:	e486                	sd	ra,72(sp)
    80001c4a:	e0a2                	sd	s0,64(sp)
    80001c4c:	fc26                	sd	s1,56(sp)
    80001c4e:	f84a                	sd	s2,48(sp)
    80001c50:	f44e                	sd	s3,40(sp)
    80001c52:	f052                	sd	s4,32(sp)
    80001c54:	ec56                	sd	s5,24(sp)
    80001c56:	e85a                	sd	s6,16(sp)
    80001c58:	e45e                	sd	s7,8(sp)
    80001c5a:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001c5c:	00006597          	auipc	a1,0x6
    80001c60:	60c58593          	addi	a1,a1,1548 # 80008268 <digits+0x228>
    80001c64:	00010517          	auipc	a0,0x10
    80001c68:	76450513          	addi	a0,a0,1892 # 800123c8 <pid_lock>
    80001c6c:	fffff097          	auipc	ra,0xfffff
    80001c70:	20c080e7          	jalr	524(ra) # 80000e78 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c74:	00011917          	auipc	s2,0x11
    80001c78:	b7490913          	addi	s2,s2,-1164 # 800127e8 <proc>
      initlock(&p->lock, "proc");
    80001c7c:	00006b97          	auipc	s7,0x6
    80001c80:	5f4b8b93          	addi	s7,s7,1524 # 80008270 <digits+0x230>
      uint64 va = KSTACK((int) (p - proc));
    80001c84:	8b4a                	mv	s6,s2
    80001c86:	00006a97          	auipc	s5,0x6
    80001c8a:	37aa8a93          	addi	s5,s5,890 # 80008000 <etext>
    80001c8e:	040009b7          	lui	s3,0x4000
    80001c92:	19fd                	addi	s3,s3,-1
    80001c94:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c96:	00016a17          	auipc	s4,0x16
    80001c9a:	752a0a13          	addi	s4,s4,1874 # 800183e8 <tickslock>
      initlock(&p->lock, "proc");
    80001c9e:	85de                	mv	a1,s7
    80001ca0:	854a                	mv	a0,s2
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	1d6080e7          	jalr	470(ra) # 80000e78 <initlock>
      char *pa = kalloc();
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	ed6080e7          	jalr	-298(ra) # 80000b80 <kalloc>
    80001cb2:	85aa                	mv	a1,a0
      if(pa == 0)
    80001cb4:	c929                	beqz	a0,80001d06 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001cb6:	416904b3          	sub	s1,s2,s6
    80001cba:	8491                	srai	s1,s1,0x4
    80001cbc:	000ab783          	ld	a5,0(s5)
    80001cc0:	02f484b3          	mul	s1,s1,a5
    80001cc4:	2485                	addiw	s1,s1,1
    80001cc6:	00d4949b          	slliw	s1,s1,0xd
    80001cca:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001cce:	4699                	li	a3,6
    80001cd0:	6605                	lui	a2,0x1
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	00000097          	auipc	ra,0x0
    80001cd8:	86e080e7          	jalr	-1938(ra) # 80001542 <kvmmap>
      p->kstack = va;
    80001cdc:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ce0:	17090913          	addi	s2,s2,368
    80001ce4:	fb491de3          	bne	s2,s4,80001c9e <procinit+0x58>
  kvminithart();
    80001ce8:	fffff097          	auipc	ra,0xfffff
    80001cec:	766080e7          	jalr	1894(ra) # 8000144e <kvminithart>
}
    80001cf0:	60a6                	ld	ra,72(sp)
    80001cf2:	6406                	ld	s0,64(sp)
    80001cf4:	74e2                	ld	s1,56(sp)
    80001cf6:	7942                	ld	s2,48(sp)
    80001cf8:	79a2                	ld	s3,40(sp)
    80001cfa:	7a02                	ld	s4,32(sp)
    80001cfc:	6ae2                	ld	s5,24(sp)
    80001cfe:	6b42                	ld	s6,16(sp)
    80001d00:	6ba2                	ld	s7,8(sp)
    80001d02:	6161                	addi	sp,sp,80
    80001d04:	8082                	ret
        panic("kalloc");
    80001d06:	00006517          	auipc	a0,0x6
    80001d0a:	57250513          	addi	a0,a0,1394 # 80008278 <digits+0x238>
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	83c080e7          	jalr	-1988(ra) # 8000054a <panic>

0000000080001d16 <cpuid>:
{
    80001d16:	1141                	addi	sp,sp,-16
    80001d18:	e422                	sd	s0,8(sp)
    80001d1a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d1c:	8512                	mv	a0,tp
}
    80001d1e:	2501                	sext.w	a0,a0
    80001d20:	6422                	ld	s0,8(sp)
    80001d22:	0141                	addi	sp,sp,16
    80001d24:	8082                	ret

0000000080001d26 <mycpu>:
mycpu(void) {
    80001d26:	1141                	addi	sp,sp,-16
    80001d28:	e422                	sd	s0,8(sp)
    80001d2a:	0800                	addi	s0,sp,16
    80001d2c:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001d2e:	2781                	sext.w	a5,a5
    80001d30:	079e                	slli	a5,a5,0x7
}
    80001d32:	00010517          	auipc	a0,0x10
    80001d36:	6b650513          	addi	a0,a0,1718 # 800123e8 <cpus>
    80001d3a:	953e                	add	a0,a0,a5
    80001d3c:	6422                	ld	s0,8(sp)
    80001d3e:	0141                	addi	sp,sp,16
    80001d40:	8082                	ret

0000000080001d42 <myproc>:
myproc(void) {
    80001d42:	1101                	addi	sp,sp,-32
    80001d44:	ec06                	sd	ra,24(sp)
    80001d46:	e822                	sd	s0,16(sp)
    80001d48:	e426                	sd	s1,8(sp)
    80001d4a:	1000                	addi	s0,sp,32
  push_off();
    80001d4c:	fffff097          	auipc	ra,0xfffff
    80001d50:	f64080e7          	jalr	-156(ra) # 80000cb0 <push_off>
    80001d54:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001d56:	2781                	sext.w	a5,a5
    80001d58:	079e                	slli	a5,a5,0x7
    80001d5a:	00010717          	auipc	a4,0x10
    80001d5e:	66e70713          	addi	a4,a4,1646 # 800123c8 <pid_lock>
    80001d62:	97ba                	add	a5,a5,a4
    80001d64:	7384                	ld	s1,32(a5)
  pop_off();
    80001d66:	fffff097          	auipc	ra,0xfffff
    80001d6a:	006080e7          	jalr	6(ra) # 80000d6c <pop_off>
}
    80001d6e:	8526                	mv	a0,s1
    80001d70:	60e2                	ld	ra,24(sp)
    80001d72:	6442                	ld	s0,16(sp)
    80001d74:	64a2                	ld	s1,8(sp)
    80001d76:	6105                	addi	sp,sp,32
    80001d78:	8082                	ret

0000000080001d7a <forkret>:
{
    80001d7a:	1141                	addi	sp,sp,-16
    80001d7c:	e406                	sd	ra,8(sp)
    80001d7e:	e022                	sd	s0,0(sp)
    80001d80:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001d82:	00000097          	auipc	ra,0x0
    80001d86:	fc0080e7          	jalr	-64(ra) # 80001d42 <myproc>
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	042080e7          	jalr	66(ra) # 80000dcc <release>
  if (first) {
    80001d92:	00007797          	auipc	a5,0x7
    80001d96:	b2e7a783          	lw	a5,-1234(a5) # 800088c0 <first.1>
    80001d9a:	eb89                	bnez	a5,80001dac <forkret+0x32>
  usertrapret();
    80001d9c:	00001097          	auipc	ra,0x1
    80001da0:	c18080e7          	jalr	-1000(ra) # 800029b4 <usertrapret>
}
    80001da4:	60a2                	ld	ra,8(sp)
    80001da6:	6402                	ld	s0,0(sp)
    80001da8:	0141                	addi	sp,sp,16
    80001daa:	8082                	ret
    first = 0;
    80001dac:	00007797          	auipc	a5,0x7
    80001db0:	b007aa23          	sw	zero,-1260(a5) # 800088c0 <first.1>
    fsinit(ROOTDEV);
    80001db4:	4505                	li	a0,1
    80001db6:	00002097          	auipc	ra,0x2
    80001dba:	bfe080e7          	jalr	-1026(ra) # 800039b4 <fsinit>
    80001dbe:	bff9                	j	80001d9c <forkret+0x22>

0000000080001dc0 <allocpid>:
allocpid() {
    80001dc0:	1101                	addi	sp,sp,-32
    80001dc2:	ec06                	sd	ra,24(sp)
    80001dc4:	e822                	sd	s0,16(sp)
    80001dc6:	e426                	sd	s1,8(sp)
    80001dc8:	e04a                	sd	s2,0(sp)
    80001dca:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001dcc:	00010917          	auipc	s2,0x10
    80001dd0:	5fc90913          	addi	s2,s2,1532 # 800123c8 <pid_lock>
    80001dd4:	854a                	mv	a0,s2
    80001dd6:	fffff097          	auipc	ra,0xfffff
    80001dda:	f26080e7          	jalr	-218(ra) # 80000cfc <acquire>
  pid = nextpid;
    80001dde:	00007797          	auipc	a5,0x7
    80001de2:	ae678793          	addi	a5,a5,-1306 # 800088c4 <nextpid>
    80001de6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001de8:	0014871b          	addiw	a4,s1,1
    80001dec:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001dee:	854a                	mv	a0,s2
    80001df0:	fffff097          	auipc	ra,0xfffff
    80001df4:	fdc080e7          	jalr	-36(ra) # 80000dcc <release>
}
    80001df8:	8526                	mv	a0,s1
    80001dfa:	60e2                	ld	ra,24(sp)
    80001dfc:	6442                	ld	s0,16(sp)
    80001dfe:	64a2                	ld	s1,8(sp)
    80001e00:	6902                	ld	s2,0(sp)
    80001e02:	6105                	addi	sp,sp,32
    80001e04:	8082                	ret

0000000080001e06 <proc_pagetable>:
{
    80001e06:	1101                	addi	sp,sp,-32
    80001e08:	ec06                	sd	ra,24(sp)
    80001e0a:	e822                	sd	s0,16(sp)
    80001e0c:	e426                	sd	s1,8(sp)
    80001e0e:	e04a                	sd	s2,0(sp)
    80001e10:	1000                	addi	s0,sp,32
    80001e12:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	8e8080e7          	jalr	-1816(ra) # 800016fc <uvmcreate>
    80001e1c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001e1e:	c121                	beqz	a0,80001e5e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e20:	4729                	li	a4,10
    80001e22:	00005697          	auipc	a3,0x5
    80001e26:	1de68693          	addi	a3,a3,478 # 80007000 <_trampoline>
    80001e2a:	6605                	lui	a2,0x1
    80001e2c:	040005b7          	lui	a1,0x4000
    80001e30:	15fd                	addi	a1,a1,-1
    80001e32:	05b2                	slli	a1,a1,0xc
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	680080e7          	jalr	1664(ra) # 800014b4 <mappages>
    80001e3c:	02054863          	bltz	a0,80001e6c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001e40:	4719                	li	a4,6
    80001e42:	06093683          	ld	a3,96(s2)
    80001e46:	6605                	lui	a2,0x1
    80001e48:	020005b7          	lui	a1,0x2000
    80001e4c:	15fd                	addi	a1,a1,-1
    80001e4e:	05b6                	slli	a1,a1,0xd
    80001e50:	8526                	mv	a0,s1
    80001e52:	fffff097          	auipc	ra,0xfffff
    80001e56:	662080e7          	jalr	1634(ra) # 800014b4 <mappages>
    80001e5a:	02054163          	bltz	a0,80001e7c <proc_pagetable+0x76>
}
    80001e5e:	8526                	mv	a0,s1
    80001e60:	60e2                	ld	ra,24(sp)
    80001e62:	6442                	ld	s0,16(sp)
    80001e64:	64a2                	ld	s1,8(sp)
    80001e66:	6902                	ld	s2,0(sp)
    80001e68:	6105                	addi	sp,sp,32
    80001e6a:	8082                	ret
    uvmfree(pagetable, 0);
    80001e6c:	4581                	li	a1,0
    80001e6e:	8526                	mv	a0,s1
    80001e70:	00000097          	auipc	ra,0x0
    80001e74:	a88080e7          	jalr	-1400(ra) # 800018f8 <uvmfree>
    return 0;
    80001e78:	4481                	li	s1,0
    80001e7a:	b7d5                	j	80001e5e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e7c:	4681                	li	a3,0
    80001e7e:	4605                	li	a2,1
    80001e80:	040005b7          	lui	a1,0x4000
    80001e84:	15fd                	addi	a1,a1,-1
    80001e86:	05b2                	slli	a1,a1,0xc
    80001e88:	8526                	mv	a0,s1
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	7ae080e7          	jalr	1966(ra) # 80001638 <uvmunmap>
    uvmfree(pagetable, 0);
    80001e92:	4581                	li	a1,0
    80001e94:	8526                	mv	a0,s1
    80001e96:	00000097          	auipc	ra,0x0
    80001e9a:	a62080e7          	jalr	-1438(ra) # 800018f8 <uvmfree>
    return 0;
    80001e9e:	4481                	li	s1,0
    80001ea0:	bf7d                	j	80001e5e <proc_pagetable+0x58>

0000000080001ea2 <proc_freepagetable>:
{
    80001ea2:	1101                	addi	sp,sp,-32
    80001ea4:	ec06                	sd	ra,24(sp)
    80001ea6:	e822                	sd	s0,16(sp)
    80001ea8:	e426                	sd	s1,8(sp)
    80001eaa:	e04a                	sd	s2,0(sp)
    80001eac:	1000                	addi	s0,sp,32
    80001eae:	84aa                	mv	s1,a0
    80001eb0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001eb2:	4681                	li	a3,0
    80001eb4:	4605                	li	a2,1
    80001eb6:	040005b7          	lui	a1,0x4000
    80001eba:	15fd                	addi	a1,a1,-1
    80001ebc:	05b2                	slli	a1,a1,0xc
    80001ebe:	fffff097          	auipc	ra,0xfffff
    80001ec2:	77a080e7          	jalr	1914(ra) # 80001638 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ec6:	4681                	li	a3,0
    80001ec8:	4605                	li	a2,1
    80001eca:	020005b7          	lui	a1,0x2000
    80001ece:	15fd                	addi	a1,a1,-1
    80001ed0:	05b6                	slli	a1,a1,0xd
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	fffff097          	auipc	ra,0xfffff
    80001ed8:	764080e7          	jalr	1892(ra) # 80001638 <uvmunmap>
  uvmfree(pagetable, sz);
    80001edc:	85ca                	mv	a1,s2
    80001ede:	8526                	mv	a0,s1
    80001ee0:	00000097          	auipc	ra,0x0
    80001ee4:	a18080e7          	jalr	-1512(ra) # 800018f8 <uvmfree>
}
    80001ee8:	60e2                	ld	ra,24(sp)
    80001eea:	6442                	ld	s0,16(sp)
    80001eec:	64a2                	ld	s1,8(sp)
    80001eee:	6902                	ld	s2,0(sp)
    80001ef0:	6105                	addi	sp,sp,32
    80001ef2:	8082                	ret

0000000080001ef4 <freeproc>:
{
    80001ef4:	1101                	addi	sp,sp,-32
    80001ef6:	ec06                	sd	ra,24(sp)
    80001ef8:	e822                	sd	s0,16(sp)
    80001efa:	e426                	sd	s1,8(sp)
    80001efc:	1000                	addi	s0,sp,32
    80001efe:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001f00:	7128                	ld	a0,96(a0)
    80001f02:	c509                	beqz	a0,80001f0c <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	b16080e7          	jalr	-1258(ra) # 80000a1a <kfree>
  p->trapframe = 0;
    80001f0c:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001f10:	6ca8                	ld	a0,88(s1)
    80001f12:	c511                	beqz	a0,80001f1e <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001f14:	68ac                	ld	a1,80(s1)
    80001f16:	00000097          	auipc	ra,0x0
    80001f1a:	f8c080e7          	jalr	-116(ra) # 80001ea2 <proc_freepagetable>
  p->pagetable = 0;
    80001f1e:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001f22:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001f26:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001f2a:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001f2e:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001f32:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001f36:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001f3a:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001f3e:	0204a023          	sw	zero,32(s1)
}
    80001f42:	60e2                	ld	ra,24(sp)
    80001f44:	6442                	ld	s0,16(sp)
    80001f46:	64a2                	ld	s1,8(sp)
    80001f48:	6105                	addi	sp,sp,32
    80001f4a:	8082                	ret

0000000080001f4c <allocproc>:
{
    80001f4c:	1101                	addi	sp,sp,-32
    80001f4e:	ec06                	sd	ra,24(sp)
    80001f50:	e822                	sd	s0,16(sp)
    80001f52:	e426                	sd	s1,8(sp)
    80001f54:	e04a                	sd	s2,0(sp)
    80001f56:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f58:	00011497          	auipc	s1,0x11
    80001f5c:	89048493          	addi	s1,s1,-1904 # 800127e8 <proc>
    80001f60:	00016917          	auipc	s2,0x16
    80001f64:	48890913          	addi	s2,s2,1160 # 800183e8 <tickslock>
    acquire(&p->lock);
    80001f68:	8526                	mv	a0,s1
    80001f6a:	fffff097          	auipc	ra,0xfffff
    80001f6e:	d92080e7          	jalr	-622(ra) # 80000cfc <acquire>
    if(p->state == UNUSED) {
    80001f72:	509c                	lw	a5,32(s1)
    80001f74:	cf81                	beqz	a5,80001f8c <allocproc+0x40>
      release(&p->lock);
    80001f76:	8526                	mv	a0,s1
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	e54080e7          	jalr	-428(ra) # 80000dcc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f80:	17048493          	addi	s1,s1,368
    80001f84:	ff2492e3          	bne	s1,s2,80001f68 <allocproc+0x1c>
  return 0;
    80001f88:	4481                	li	s1,0
    80001f8a:	a0b9                	j	80001fd8 <allocproc+0x8c>
  p->pid = allocpid();
    80001f8c:	00000097          	auipc	ra,0x0
    80001f90:	e34080e7          	jalr	-460(ra) # 80001dc0 <allocpid>
    80001f94:	c0a8                	sw	a0,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	bea080e7          	jalr	-1046(ra) # 80000b80 <kalloc>
    80001f9e:	892a                	mv	s2,a0
    80001fa0:	f0a8                	sd	a0,96(s1)
    80001fa2:	c131                	beqz	a0,80001fe6 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	00000097          	auipc	ra,0x0
    80001faa:	e60080e7          	jalr	-416(ra) # 80001e06 <proc_pagetable>
    80001fae:	892a                	mv	s2,a0
    80001fb0:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001fb2:	c129                	beqz	a0,80001ff4 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001fb4:	07000613          	li	a2,112
    80001fb8:	4581                	li	a1,0
    80001fba:	06848513          	addi	a0,s1,104
    80001fbe:	fffff097          	auipc	ra,0xfffff
    80001fc2:	11e080e7          	jalr	286(ra) # 800010dc <memset>
  p->context.ra = (uint64)forkret;
    80001fc6:	00000797          	auipc	a5,0x0
    80001fca:	db478793          	addi	a5,a5,-588 # 80001d7a <forkret>
    80001fce:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001fd0:	64bc                	ld	a5,72(s1)
    80001fd2:	6705                	lui	a4,0x1
    80001fd4:	97ba                	add	a5,a5,a4
    80001fd6:	f8bc                	sd	a5,112(s1)
}
    80001fd8:	8526                	mv	a0,s1
    80001fda:	60e2                	ld	ra,24(sp)
    80001fdc:	6442                	ld	s0,16(sp)
    80001fde:	64a2                	ld	s1,8(sp)
    80001fe0:	6902                	ld	s2,0(sp)
    80001fe2:	6105                	addi	sp,sp,32
    80001fe4:	8082                	ret
    release(&p->lock);
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	fffff097          	auipc	ra,0xfffff
    80001fec:	de4080e7          	jalr	-540(ra) # 80000dcc <release>
    return 0;
    80001ff0:	84ca                	mv	s1,s2
    80001ff2:	b7dd                	j	80001fd8 <allocproc+0x8c>
    freeproc(p);
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	00000097          	auipc	ra,0x0
    80001ffa:	efe080e7          	jalr	-258(ra) # 80001ef4 <freeproc>
    release(&p->lock);
    80001ffe:	8526                	mv	a0,s1
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	dcc080e7          	jalr	-564(ra) # 80000dcc <release>
    return 0;
    80002008:	84ca                	mv	s1,s2
    8000200a:	b7f9                	j	80001fd8 <allocproc+0x8c>

000000008000200c <userinit>:
{
    8000200c:	1101                	addi	sp,sp,-32
    8000200e:	ec06                	sd	ra,24(sp)
    80002010:	e822                	sd	s0,16(sp)
    80002012:	e426                	sd	s1,8(sp)
    80002014:	1000                	addi	s0,sp,32
  p = allocproc();
    80002016:	00000097          	auipc	ra,0x0
    8000201a:	f36080e7          	jalr	-202(ra) # 80001f4c <allocproc>
    8000201e:	84aa                	mv	s1,a0
  initproc = p;
    80002020:	00007797          	auipc	a5,0x7
    80002024:	fea7bc23          	sd	a0,-8(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80002028:	03400613          	li	a2,52
    8000202c:	00007597          	auipc	a1,0x7
    80002030:	8a458593          	addi	a1,a1,-1884 # 800088d0 <initcode>
    80002034:	6d28                	ld	a0,88(a0)
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	6f4080e7          	jalr	1780(ra) # 8000172a <uvminit>
  p->sz = PGSIZE;
    8000203e:	6785                	lui	a5,0x1
    80002040:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80002042:	70b8                	ld	a4,96(s1)
    80002044:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80002048:	70b8                	ld	a4,96(s1)
    8000204a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    8000204c:	4641                	li	a2,16
    8000204e:	00006597          	auipc	a1,0x6
    80002052:	23258593          	addi	a1,a1,562 # 80008280 <digits+0x240>
    80002056:	16048513          	addi	a0,s1,352
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	1d4080e7          	jalr	468(ra) # 8000122e <safestrcpy>
  p->cwd = namei("/");
    80002062:	00006517          	auipc	a0,0x6
    80002066:	22e50513          	addi	a0,a0,558 # 80008290 <digits+0x250>
    8000206a:	00002097          	auipc	ra,0x2
    8000206e:	376080e7          	jalr	886(ra) # 800043e0 <namei>
    80002072:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80002076:	4789                	li	a5,2
    80002078:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    8000207a:	8526                	mv	a0,s1
    8000207c:	fffff097          	auipc	ra,0xfffff
    80002080:	d50080e7          	jalr	-688(ra) # 80000dcc <release>
}
    80002084:	60e2                	ld	ra,24(sp)
    80002086:	6442                	ld	s0,16(sp)
    80002088:	64a2                	ld	s1,8(sp)
    8000208a:	6105                	addi	sp,sp,32
    8000208c:	8082                	ret

000000008000208e <growproc>:
{
    8000208e:	1101                	addi	sp,sp,-32
    80002090:	ec06                	sd	ra,24(sp)
    80002092:	e822                	sd	s0,16(sp)
    80002094:	e426                	sd	s1,8(sp)
    80002096:	e04a                	sd	s2,0(sp)
    80002098:	1000                	addi	s0,sp,32
    8000209a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000209c:	00000097          	auipc	ra,0x0
    800020a0:	ca6080e7          	jalr	-858(ra) # 80001d42 <myproc>
    800020a4:	892a                	mv	s2,a0
  sz = p->sz;
    800020a6:	692c                	ld	a1,80(a0)
    800020a8:	0005861b          	sext.w	a2,a1
  if(n > 0){
    800020ac:	00904f63          	bgtz	s1,800020ca <growproc+0x3c>
  } else if(n < 0){
    800020b0:	0204cc63          	bltz	s1,800020e8 <growproc+0x5a>
  p->sz = sz;
    800020b4:	1602                	slli	a2,a2,0x20
    800020b6:	9201                	srli	a2,a2,0x20
    800020b8:	04c93823          	sd	a2,80(s2)
  return 0;
    800020bc:	4501                	li	a0,0
}
    800020be:	60e2                	ld	ra,24(sp)
    800020c0:	6442                	ld	s0,16(sp)
    800020c2:	64a2                	ld	s1,8(sp)
    800020c4:	6902                	ld	s2,0(sp)
    800020c6:	6105                	addi	sp,sp,32
    800020c8:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    800020ca:	9e25                	addw	a2,a2,s1
    800020cc:	1602                	slli	a2,a2,0x20
    800020ce:	9201                	srli	a2,a2,0x20
    800020d0:	1582                	slli	a1,a1,0x20
    800020d2:	9181                	srli	a1,a1,0x20
    800020d4:	6d28                	ld	a0,88(a0)
    800020d6:	fffff097          	auipc	ra,0xfffff
    800020da:	70e080e7          	jalr	1806(ra) # 800017e4 <uvmalloc>
    800020de:	0005061b          	sext.w	a2,a0
    800020e2:	fa69                	bnez	a2,800020b4 <growproc+0x26>
      return -1;
    800020e4:	557d                	li	a0,-1
    800020e6:	bfe1                	j	800020be <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800020e8:	9e25                	addw	a2,a2,s1
    800020ea:	1602                	slli	a2,a2,0x20
    800020ec:	9201                	srli	a2,a2,0x20
    800020ee:	1582                	slli	a1,a1,0x20
    800020f0:	9181                	srli	a1,a1,0x20
    800020f2:	6d28                	ld	a0,88(a0)
    800020f4:	fffff097          	auipc	ra,0xfffff
    800020f8:	6a8080e7          	jalr	1704(ra) # 8000179c <uvmdealloc>
    800020fc:	0005061b          	sext.w	a2,a0
    80002100:	bf55                	j	800020b4 <growproc+0x26>

0000000080002102 <fork>:
{
    80002102:	7139                	addi	sp,sp,-64
    80002104:	fc06                	sd	ra,56(sp)
    80002106:	f822                	sd	s0,48(sp)
    80002108:	f426                	sd	s1,40(sp)
    8000210a:	f04a                	sd	s2,32(sp)
    8000210c:	ec4e                	sd	s3,24(sp)
    8000210e:	e852                	sd	s4,16(sp)
    80002110:	e456                	sd	s5,8(sp)
    80002112:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002114:	00000097          	auipc	ra,0x0
    80002118:	c2e080e7          	jalr	-978(ra) # 80001d42 <myproc>
    8000211c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000211e:	00000097          	auipc	ra,0x0
    80002122:	e2e080e7          	jalr	-466(ra) # 80001f4c <allocproc>
    80002126:	c17d                	beqz	a0,8000220c <fork+0x10a>
    80002128:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000212a:	050ab603          	ld	a2,80(s5)
    8000212e:	6d2c                	ld	a1,88(a0)
    80002130:	058ab503          	ld	a0,88(s5)
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	7fc080e7          	jalr	2044(ra) # 80001930 <uvmcopy>
    8000213c:	04054a63          	bltz	a0,80002190 <fork+0x8e>
  np->sz = p->sz;
    80002140:	050ab783          	ld	a5,80(s5)
    80002144:	04fa3823          	sd	a5,80(s4)
  np->parent = p;
    80002148:	035a3423          	sd	s5,40(s4)
  *(np->trapframe) = *(p->trapframe);
    8000214c:	060ab683          	ld	a3,96(s5)
    80002150:	87b6                	mv	a5,a3
    80002152:	060a3703          	ld	a4,96(s4)
    80002156:	12068693          	addi	a3,a3,288
    8000215a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000215e:	6788                	ld	a0,8(a5)
    80002160:	6b8c                	ld	a1,16(a5)
    80002162:	6f90                	ld	a2,24(a5)
    80002164:	01073023          	sd	a6,0(a4)
    80002168:	e708                	sd	a0,8(a4)
    8000216a:	eb0c                	sd	a1,16(a4)
    8000216c:	ef10                	sd	a2,24(a4)
    8000216e:	02078793          	addi	a5,a5,32
    80002172:	02070713          	addi	a4,a4,32
    80002176:	fed792e3          	bne	a5,a3,8000215a <fork+0x58>
  np->trapframe->a0 = 0;
    8000217a:	060a3783          	ld	a5,96(s4)
    8000217e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002182:	0d8a8493          	addi	s1,s5,216
    80002186:	0d8a0913          	addi	s2,s4,216
    8000218a:	158a8993          	addi	s3,s5,344
    8000218e:	a00d                	j	800021b0 <fork+0xae>
    freeproc(np);
    80002190:	8552                	mv	a0,s4
    80002192:	00000097          	auipc	ra,0x0
    80002196:	d62080e7          	jalr	-670(ra) # 80001ef4 <freeproc>
    release(&np->lock);
    8000219a:	8552                	mv	a0,s4
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	c30080e7          	jalr	-976(ra) # 80000dcc <release>
    return -1;
    800021a4:	54fd                	li	s1,-1
    800021a6:	a889                	j	800021f8 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    800021a8:	04a1                	addi	s1,s1,8
    800021aa:	0921                	addi	s2,s2,8
    800021ac:	01348b63          	beq	s1,s3,800021c2 <fork+0xc0>
    if(p->ofile[i])
    800021b0:	6088                	ld	a0,0(s1)
    800021b2:	d97d                	beqz	a0,800021a8 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    800021b4:	00003097          	auipc	ra,0x3
    800021b8:	8ca080e7          	jalr	-1846(ra) # 80004a7e <filedup>
    800021bc:	00a93023          	sd	a0,0(s2)
    800021c0:	b7e5                	j	800021a8 <fork+0xa6>
  np->cwd = idup(p->cwd);
    800021c2:	158ab503          	ld	a0,344(s5)
    800021c6:	00002097          	auipc	ra,0x2
    800021ca:	a28080e7          	jalr	-1496(ra) # 80003bee <idup>
    800021ce:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800021d2:	4641                	li	a2,16
    800021d4:	160a8593          	addi	a1,s5,352
    800021d8:	160a0513          	addi	a0,s4,352
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	052080e7          	jalr	82(ra) # 8000122e <safestrcpy>
  pid = np->pid;
    800021e4:	040a2483          	lw	s1,64(s4)
  np->state = RUNNABLE;
    800021e8:	4789                	li	a5,2
    800021ea:	02fa2023          	sw	a5,32(s4)
  release(&np->lock);
    800021ee:	8552                	mv	a0,s4
    800021f0:	fffff097          	auipc	ra,0xfffff
    800021f4:	bdc080e7          	jalr	-1060(ra) # 80000dcc <release>
}
    800021f8:	8526                	mv	a0,s1
    800021fa:	70e2                	ld	ra,56(sp)
    800021fc:	7442                	ld	s0,48(sp)
    800021fe:	74a2                	ld	s1,40(sp)
    80002200:	7902                	ld	s2,32(sp)
    80002202:	69e2                	ld	s3,24(sp)
    80002204:	6a42                	ld	s4,16(sp)
    80002206:	6aa2                	ld	s5,8(sp)
    80002208:	6121                	addi	sp,sp,64
    8000220a:	8082                	ret
    return -1;
    8000220c:	54fd                	li	s1,-1
    8000220e:	b7ed                	j	800021f8 <fork+0xf6>

0000000080002210 <reparent>:
{
    80002210:	7179                	addi	sp,sp,-48
    80002212:	f406                	sd	ra,40(sp)
    80002214:	f022                	sd	s0,32(sp)
    80002216:	ec26                	sd	s1,24(sp)
    80002218:	e84a                	sd	s2,16(sp)
    8000221a:	e44e                	sd	s3,8(sp)
    8000221c:	e052                	sd	s4,0(sp)
    8000221e:	1800                	addi	s0,sp,48
    80002220:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002222:	00010497          	auipc	s1,0x10
    80002226:	5c648493          	addi	s1,s1,1478 # 800127e8 <proc>
      pp->parent = initproc;
    8000222a:	00007a17          	auipc	s4,0x7
    8000222e:	deea0a13          	addi	s4,s4,-530 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002232:	00016997          	auipc	s3,0x16
    80002236:	1b698993          	addi	s3,s3,438 # 800183e8 <tickslock>
    8000223a:	a029                	j	80002244 <reparent+0x34>
    8000223c:	17048493          	addi	s1,s1,368
    80002240:	03348363          	beq	s1,s3,80002266 <reparent+0x56>
    if(pp->parent == p){
    80002244:	749c                	ld	a5,40(s1)
    80002246:	ff279be3          	bne	a5,s2,8000223c <reparent+0x2c>
      acquire(&pp->lock);
    8000224a:	8526                	mv	a0,s1
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	ab0080e7          	jalr	-1360(ra) # 80000cfc <acquire>
      pp->parent = initproc;
    80002254:	000a3783          	ld	a5,0(s4)
    80002258:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    8000225a:	8526                	mv	a0,s1
    8000225c:	fffff097          	auipc	ra,0xfffff
    80002260:	b70080e7          	jalr	-1168(ra) # 80000dcc <release>
    80002264:	bfe1                	j	8000223c <reparent+0x2c>
}
    80002266:	70a2                	ld	ra,40(sp)
    80002268:	7402                	ld	s0,32(sp)
    8000226a:	64e2                	ld	s1,24(sp)
    8000226c:	6942                	ld	s2,16(sp)
    8000226e:	69a2                	ld	s3,8(sp)
    80002270:	6a02                	ld	s4,0(sp)
    80002272:	6145                	addi	sp,sp,48
    80002274:	8082                	ret

0000000080002276 <scheduler>:
{
    80002276:	711d                	addi	sp,sp,-96
    80002278:	ec86                	sd	ra,88(sp)
    8000227a:	e8a2                	sd	s0,80(sp)
    8000227c:	e4a6                	sd	s1,72(sp)
    8000227e:	e0ca                	sd	s2,64(sp)
    80002280:	fc4e                	sd	s3,56(sp)
    80002282:	f852                	sd	s4,48(sp)
    80002284:	f456                	sd	s5,40(sp)
    80002286:	f05a                	sd	s6,32(sp)
    80002288:	ec5e                	sd	s7,24(sp)
    8000228a:	e862                	sd	s8,16(sp)
    8000228c:	e466                	sd	s9,8(sp)
    8000228e:	1080                	addi	s0,sp,96
    80002290:	8792                	mv	a5,tp
  int id = r_tp();
    80002292:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002294:	00779c13          	slli	s8,a5,0x7
    80002298:	00010717          	auipc	a4,0x10
    8000229c:	13070713          	addi	a4,a4,304 # 800123c8 <pid_lock>
    800022a0:	9762                	add	a4,a4,s8
    800022a2:	02073023          	sd	zero,32(a4)
        swtch(&c->context, &p->context);
    800022a6:	00010717          	auipc	a4,0x10
    800022aa:	14a70713          	addi	a4,a4,330 # 800123f0 <cpus+0x8>
    800022ae:	9c3a                	add	s8,s8,a4
    int nproc = 0;
    800022b0:	4c81                	li	s9,0
      if(p->state == RUNNABLE) {
    800022b2:	4a89                	li	s5,2
        c->proc = p;
    800022b4:	079e                	slli	a5,a5,0x7
    800022b6:	00010b17          	auipc	s6,0x10
    800022ba:	112b0b13          	addi	s6,s6,274 # 800123c8 <pid_lock>
    800022be:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800022c0:	00016a17          	auipc	s4,0x16
    800022c4:	128a0a13          	addi	s4,s4,296 # 800183e8 <tickslock>
    800022c8:	a8a1                	j	80002320 <scheduler+0xaa>
      release(&p->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	b00080e7          	jalr	-1280(ra) # 80000dcc <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800022d4:	17048493          	addi	s1,s1,368
    800022d8:	03448a63          	beq	s1,s4,8000230c <scheduler+0x96>
      acquire(&p->lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	a1e080e7          	jalr	-1506(ra) # 80000cfc <acquire>
      if(p->state != UNUSED) {
    800022e6:	509c                	lw	a5,32(s1)
    800022e8:	d3ed                	beqz	a5,800022ca <scheduler+0x54>
        nproc++;
    800022ea:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    800022ec:	fd579fe3          	bne	a5,s5,800022ca <scheduler+0x54>
        p->state = RUNNING;
    800022f0:	0374a023          	sw	s7,32(s1)
        c->proc = p;
    800022f4:	029b3023          	sd	s1,32(s6)
        swtch(&c->context, &p->context);
    800022f8:	06848593          	addi	a1,s1,104
    800022fc:	8562                	mv	a0,s8
    800022fe:	00000097          	auipc	ra,0x0
    80002302:	60c080e7          	jalr	1548(ra) # 8000290a <swtch>
        c->proc = 0;
    80002306:	020b3023          	sd	zero,32(s6)
    8000230a:	b7c1                	j	800022ca <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    8000230c:	013aca63          	blt	s5,s3,80002320 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002310:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002314:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002318:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000231c:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002320:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002324:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002328:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    8000232c:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    8000232e:	00010497          	auipc	s1,0x10
    80002332:	4ba48493          	addi	s1,s1,1210 # 800127e8 <proc>
        p->state = RUNNING;
    80002336:	4b8d                	li	s7,3
    80002338:	b755                	j	800022dc <scheduler+0x66>

000000008000233a <sched>:
{
    8000233a:	7179                	addi	sp,sp,-48
    8000233c:	f406                	sd	ra,40(sp)
    8000233e:	f022                	sd	s0,32(sp)
    80002340:	ec26                	sd	s1,24(sp)
    80002342:	e84a                	sd	s2,16(sp)
    80002344:	e44e                	sd	s3,8(sp)
    80002346:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002348:	00000097          	auipc	ra,0x0
    8000234c:	9fa080e7          	jalr	-1542(ra) # 80001d42 <myproc>
    80002350:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	930080e7          	jalr	-1744(ra) # 80000c82 <holding>
    8000235a:	c93d                	beqz	a0,800023d0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000235c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000235e:	2781                	sext.w	a5,a5
    80002360:	079e                	slli	a5,a5,0x7
    80002362:	00010717          	auipc	a4,0x10
    80002366:	06670713          	addi	a4,a4,102 # 800123c8 <pid_lock>
    8000236a:	97ba                	add	a5,a5,a4
    8000236c:	0987a703          	lw	a4,152(a5)
    80002370:	4785                	li	a5,1
    80002372:	06f71763          	bne	a4,a5,800023e0 <sched+0xa6>
  if(p->state == RUNNING)
    80002376:	5098                	lw	a4,32(s1)
    80002378:	478d                	li	a5,3
    8000237a:	06f70b63          	beq	a4,a5,800023f0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000237e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002382:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002384:	efb5                	bnez	a5,80002400 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002386:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002388:	00010917          	auipc	s2,0x10
    8000238c:	04090913          	addi	s2,s2,64 # 800123c8 <pid_lock>
    80002390:	2781                	sext.w	a5,a5
    80002392:	079e                	slli	a5,a5,0x7
    80002394:	97ca                	add	a5,a5,s2
    80002396:	09c7a983          	lw	s3,156(a5)
    8000239a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000239c:	2781                	sext.w	a5,a5
    8000239e:	079e                	slli	a5,a5,0x7
    800023a0:	00010597          	auipc	a1,0x10
    800023a4:	05058593          	addi	a1,a1,80 # 800123f0 <cpus+0x8>
    800023a8:	95be                	add	a1,a1,a5
    800023aa:	06848513          	addi	a0,s1,104
    800023ae:	00000097          	auipc	ra,0x0
    800023b2:	55c080e7          	jalr	1372(ra) # 8000290a <swtch>
    800023b6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023b8:	2781                	sext.w	a5,a5
    800023ba:	079e                	slli	a5,a5,0x7
    800023bc:	97ca                	add	a5,a5,s2
    800023be:	0937ae23          	sw	s3,156(a5)
}
    800023c2:	70a2                	ld	ra,40(sp)
    800023c4:	7402                	ld	s0,32(sp)
    800023c6:	64e2                	ld	s1,24(sp)
    800023c8:	6942                	ld	s2,16(sp)
    800023ca:	69a2                	ld	s3,8(sp)
    800023cc:	6145                	addi	sp,sp,48
    800023ce:	8082                	ret
    panic("sched p->lock");
    800023d0:	00006517          	auipc	a0,0x6
    800023d4:	ec850513          	addi	a0,a0,-312 # 80008298 <digits+0x258>
    800023d8:	ffffe097          	auipc	ra,0xffffe
    800023dc:	172080e7          	jalr	370(ra) # 8000054a <panic>
    panic("sched locks");
    800023e0:	00006517          	auipc	a0,0x6
    800023e4:	ec850513          	addi	a0,a0,-312 # 800082a8 <digits+0x268>
    800023e8:	ffffe097          	auipc	ra,0xffffe
    800023ec:	162080e7          	jalr	354(ra) # 8000054a <panic>
    panic("sched running");
    800023f0:	00006517          	auipc	a0,0x6
    800023f4:	ec850513          	addi	a0,a0,-312 # 800082b8 <digits+0x278>
    800023f8:	ffffe097          	auipc	ra,0xffffe
    800023fc:	152080e7          	jalr	338(ra) # 8000054a <panic>
    panic("sched interruptible");
    80002400:	00006517          	auipc	a0,0x6
    80002404:	ec850513          	addi	a0,a0,-312 # 800082c8 <digits+0x288>
    80002408:	ffffe097          	auipc	ra,0xffffe
    8000240c:	142080e7          	jalr	322(ra) # 8000054a <panic>

0000000080002410 <exit>:
{
    80002410:	7179                	addi	sp,sp,-48
    80002412:	f406                	sd	ra,40(sp)
    80002414:	f022                	sd	s0,32(sp)
    80002416:	ec26                	sd	s1,24(sp)
    80002418:	e84a                	sd	s2,16(sp)
    8000241a:	e44e                	sd	s3,8(sp)
    8000241c:	e052                	sd	s4,0(sp)
    8000241e:	1800                	addi	s0,sp,48
    80002420:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002422:	00000097          	auipc	ra,0x0
    80002426:	920080e7          	jalr	-1760(ra) # 80001d42 <myproc>
    8000242a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000242c:	00007797          	auipc	a5,0x7
    80002430:	bec7b783          	ld	a5,-1044(a5) # 80009018 <initproc>
    80002434:	0d850493          	addi	s1,a0,216
    80002438:	15850913          	addi	s2,a0,344
    8000243c:	02a79363          	bne	a5,a0,80002462 <exit+0x52>
    panic("init exiting");
    80002440:	00006517          	auipc	a0,0x6
    80002444:	ea050513          	addi	a0,a0,-352 # 800082e0 <digits+0x2a0>
    80002448:	ffffe097          	auipc	ra,0xffffe
    8000244c:	102080e7          	jalr	258(ra) # 8000054a <panic>
      fileclose(f);
    80002450:	00002097          	auipc	ra,0x2
    80002454:	680080e7          	jalr	1664(ra) # 80004ad0 <fileclose>
      p->ofile[fd] = 0;
    80002458:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000245c:	04a1                	addi	s1,s1,8
    8000245e:	01248563          	beq	s1,s2,80002468 <exit+0x58>
    if(p->ofile[fd]){
    80002462:	6088                	ld	a0,0(s1)
    80002464:	f575                	bnez	a0,80002450 <exit+0x40>
    80002466:	bfdd                	j	8000245c <exit+0x4c>
  begin_op();
    80002468:	00002097          	auipc	ra,0x2
    8000246c:	194080e7          	jalr	404(ra) # 800045fc <begin_op>
  iput(p->cwd);
    80002470:	1589b503          	ld	a0,344(s3)
    80002474:	00002097          	auipc	ra,0x2
    80002478:	972080e7          	jalr	-1678(ra) # 80003de6 <iput>
  end_op();
    8000247c:	00002097          	auipc	ra,0x2
    80002480:	200080e7          	jalr	512(ra) # 8000467c <end_op>
  p->cwd = 0;
    80002484:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    80002488:	00007497          	auipc	s1,0x7
    8000248c:	b9048493          	addi	s1,s1,-1136 # 80009018 <initproc>
    80002490:	6088                	ld	a0,0(s1)
    80002492:	fffff097          	auipc	ra,0xfffff
    80002496:	86a080e7          	jalr	-1942(ra) # 80000cfc <acquire>
  wakeup1(initproc);
    8000249a:	6088                	ld	a0,0(s1)
    8000249c:	fffff097          	auipc	ra,0xfffff
    800024a0:	766080e7          	jalr	1894(ra) # 80001c02 <wakeup1>
  release(&initproc->lock);
    800024a4:	6088                	ld	a0,0(s1)
    800024a6:	fffff097          	auipc	ra,0xfffff
    800024aa:	926080e7          	jalr	-1754(ra) # 80000dcc <release>
  acquire(&p->lock);
    800024ae:	854e                	mv	a0,s3
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	84c080e7          	jalr	-1972(ra) # 80000cfc <acquire>
  struct proc *original_parent = p->parent;
    800024b8:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800024bc:	854e                	mv	a0,s3
    800024be:	fffff097          	auipc	ra,0xfffff
    800024c2:	90e080e7          	jalr	-1778(ra) # 80000dcc <release>
  acquire(&original_parent->lock);
    800024c6:	8526                	mv	a0,s1
    800024c8:	fffff097          	auipc	ra,0xfffff
    800024cc:	834080e7          	jalr	-1996(ra) # 80000cfc <acquire>
  acquire(&p->lock);
    800024d0:	854e                	mv	a0,s3
    800024d2:	fffff097          	auipc	ra,0xfffff
    800024d6:	82a080e7          	jalr	-2006(ra) # 80000cfc <acquire>
  reparent(p);
    800024da:	854e                	mv	a0,s3
    800024dc:	00000097          	auipc	ra,0x0
    800024e0:	d34080e7          	jalr	-716(ra) # 80002210 <reparent>
  wakeup1(original_parent);
    800024e4:	8526                	mv	a0,s1
    800024e6:	fffff097          	auipc	ra,0xfffff
    800024ea:	71c080e7          	jalr	1820(ra) # 80001c02 <wakeup1>
  p->xstate = status;
    800024ee:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800024f2:	4791                	li	a5,4
    800024f4:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800024f8:	8526                	mv	a0,s1
    800024fa:	fffff097          	auipc	ra,0xfffff
    800024fe:	8d2080e7          	jalr	-1838(ra) # 80000dcc <release>
  sched();
    80002502:	00000097          	auipc	ra,0x0
    80002506:	e38080e7          	jalr	-456(ra) # 8000233a <sched>
  panic("zombie exit");
    8000250a:	00006517          	auipc	a0,0x6
    8000250e:	de650513          	addi	a0,a0,-538 # 800082f0 <digits+0x2b0>
    80002512:	ffffe097          	auipc	ra,0xffffe
    80002516:	038080e7          	jalr	56(ra) # 8000054a <panic>

000000008000251a <yield>:
{
    8000251a:	1101                	addi	sp,sp,-32
    8000251c:	ec06                	sd	ra,24(sp)
    8000251e:	e822                	sd	s0,16(sp)
    80002520:	e426                	sd	s1,8(sp)
    80002522:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002524:	00000097          	auipc	ra,0x0
    80002528:	81e080e7          	jalr	-2018(ra) # 80001d42 <myproc>
    8000252c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000252e:	ffffe097          	auipc	ra,0xffffe
    80002532:	7ce080e7          	jalr	1998(ra) # 80000cfc <acquire>
  p->state = RUNNABLE;
    80002536:	4789                	li	a5,2
    80002538:	d09c                	sw	a5,32(s1)
  sched();
    8000253a:	00000097          	auipc	ra,0x0
    8000253e:	e00080e7          	jalr	-512(ra) # 8000233a <sched>
  release(&p->lock);
    80002542:	8526                	mv	a0,s1
    80002544:	fffff097          	auipc	ra,0xfffff
    80002548:	888080e7          	jalr	-1912(ra) # 80000dcc <release>
}
    8000254c:	60e2                	ld	ra,24(sp)
    8000254e:	6442                	ld	s0,16(sp)
    80002550:	64a2                	ld	s1,8(sp)
    80002552:	6105                	addi	sp,sp,32
    80002554:	8082                	ret

0000000080002556 <sleep>:
{
    80002556:	7179                	addi	sp,sp,-48
    80002558:	f406                	sd	ra,40(sp)
    8000255a:	f022                	sd	s0,32(sp)
    8000255c:	ec26                	sd	s1,24(sp)
    8000255e:	e84a                	sd	s2,16(sp)
    80002560:	e44e                	sd	s3,8(sp)
    80002562:	1800                	addi	s0,sp,48
    80002564:	89aa                	mv	s3,a0
    80002566:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002568:	fffff097          	auipc	ra,0xfffff
    8000256c:	7da080e7          	jalr	2010(ra) # 80001d42 <myproc>
    80002570:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002572:	05250663          	beq	a0,s2,800025be <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002576:	ffffe097          	auipc	ra,0xffffe
    8000257a:	786080e7          	jalr	1926(ra) # 80000cfc <acquire>
    release(lk);
    8000257e:	854a                	mv	a0,s2
    80002580:	fffff097          	auipc	ra,0xfffff
    80002584:	84c080e7          	jalr	-1972(ra) # 80000dcc <release>
  p->chan = chan;
    80002588:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000258c:	4785                	li	a5,1
    8000258e:	d09c                	sw	a5,32(s1)
  sched();
    80002590:	00000097          	auipc	ra,0x0
    80002594:	daa080e7          	jalr	-598(ra) # 8000233a <sched>
  p->chan = 0;
    80002598:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    8000259c:	8526                	mv	a0,s1
    8000259e:	fffff097          	auipc	ra,0xfffff
    800025a2:	82e080e7          	jalr	-2002(ra) # 80000dcc <release>
    acquire(lk);
    800025a6:	854a                	mv	a0,s2
    800025a8:	ffffe097          	auipc	ra,0xffffe
    800025ac:	754080e7          	jalr	1876(ra) # 80000cfc <acquire>
}
    800025b0:	70a2                	ld	ra,40(sp)
    800025b2:	7402                	ld	s0,32(sp)
    800025b4:	64e2                	ld	s1,24(sp)
    800025b6:	6942                	ld	s2,16(sp)
    800025b8:	69a2                	ld	s3,8(sp)
    800025ba:	6145                	addi	sp,sp,48
    800025bc:	8082                	ret
  p->chan = chan;
    800025be:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800025c2:	4785                	li	a5,1
    800025c4:	d11c                	sw	a5,32(a0)
  sched();
    800025c6:	00000097          	auipc	ra,0x0
    800025ca:	d74080e7          	jalr	-652(ra) # 8000233a <sched>
  p->chan = 0;
    800025ce:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800025d2:	bff9                	j	800025b0 <sleep+0x5a>

00000000800025d4 <wait>:
{
    800025d4:	715d                	addi	sp,sp,-80
    800025d6:	e486                	sd	ra,72(sp)
    800025d8:	e0a2                	sd	s0,64(sp)
    800025da:	fc26                	sd	s1,56(sp)
    800025dc:	f84a                	sd	s2,48(sp)
    800025de:	f44e                	sd	s3,40(sp)
    800025e0:	f052                	sd	s4,32(sp)
    800025e2:	ec56                	sd	s5,24(sp)
    800025e4:	e85a                	sd	s6,16(sp)
    800025e6:	e45e                	sd	s7,8(sp)
    800025e8:	0880                	addi	s0,sp,80
    800025ea:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800025ec:	fffff097          	auipc	ra,0xfffff
    800025f0:	756080e7          	jalr	1878(ra) # 80001d42 <myproc>
    800025f4:	892a                	mv	s2,a0
  acquire(&p->lock);
    800025f6:	ffffe097          	auipc	ra,0xffffe
    800025fa:	706080e7          	jalr	1798(ra) # 80000cfc <acquire>
    havekids = 0;
    800025fe:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002600:	4a11                	li	s4,4
        havekids = 1;
    80002602:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002604:	00016997          	auipc	s3,0x16
    80002608:	de498993          	addi	s3,s3,-540 # 800183e8 <tickslock>
    havekids = 0;
    8000260c:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000260e:	00010497          	auipc	s1,0x10
    80002612:	1da48493          	addi	s1,s1,474 # 800127e8 <proc>
    80002616:	a08d                	j	80002678 <wait+0xa4>
          pid = np->pid;
    80002618:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000261c:	000b0e63          	beqz	s6,80002638 <wait+0x64>
    80002620:	4691                	li	a3,4
    80002622:	03c48613          	addi	a2,s1,60
    80002626:	85da                	mv	a1,s6
    80002628:	05893503          	ld	a0,88(s2)
    8000262c:	fffff097          	auipc	ra,0xfffff
    80002630:	408080e7          	jalr	1032(ra) # 80001a34 <copyout>
    80002634:	02054263          	bltz	a0,80002658 <wait+0x84>
          freeproc(np);
    80002638:	8526                	mv	a0,s1
    8000263a:	00000097          	auipc	ra,0x0
    8000263e:	8ba080e7          	jalr	-1862(ra) # 80001ef4 <freeproc>
          release(&np->lock);
    80002642:	8526                	mv	a0,s1
    80002644:	ffffe097          	auipc	ra,0xffffe
    80002648:	788080e7          	jalr	1928(ra) # 80000dcc <release>
          release(&p->lock);
    8000264c:	854a                	mv	a0,s2
    8000264e:	ffffe097          	auipc	ra,0xffffe
    80002652:	77e080e7          	jalr	1918(ra) # 80000dcc <release>
          return pid;
    80002656:	a8a9                	j	800026b0 <wait+0xdc>
            release(&np->lock);
    80002658:	8526                	mv	a0,s1
    8000265a:	ffffe097          	auipc	ra,0xffffe
    8000265e:	772080e7          	jalr	1906(ra) # 80000dcc <release>
            release(&p->lock);
    80002662:	854a                	mv	a0,s2
    80002664:	ffffe097          	auipc	ra,0xffffe
    80002668:	768080e7          	jalr	1896(ra) # 80000dcc <release>
            return -1;
    8000266c:	59fd                	li	s3,-1
    8000266e:	a089                	j	800026b0 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002670:	17048493          	addi	s1,s1,368
    80002674:	03348463          	beq	s1,s3,8000269c <wait+0xc8>
      if(np->parent == p){
    80002678:	749c                	ld	a5,40(s1)
    8000267a:	ff279be3          	bne	a5,s2,80002670 <wait+0x9c>
        acquire(&np->lock);
    8000267e:	8526                	mv	a0,s1
    80002680:	ffffe097          	auipc	ra,0xffffe
    80002684:	67c080e7          	jalr	1660(ra) # 80000cfc <acquire>
        if(np->state == ZOMBIE){
    80002688:	509c                	lw	a5,32(s1)
    8000268a:	f94787e3          	beq	a5,s4,80002618 <wait+0x44>
        release(&np->lock);
    8000268e:	8526                	mv	a0,s1
    80002690:	ffffe097          	auipc	ra,0xffffe
    80002694:	73c080e7          	jalr	1852(ra) # 80000dcc <release>
        havekids = 1;
    80002698:	8756                	mv	a4,s5
    8000269a:	bfd9                	j	80002670 <wait+0x9c>
    if(!havekids || p->killed){
    8000269c:	c701                	beqz	a4,800026a4 <wait+0xd0>
    8000269e:	03892783          	lw	a5,56(s2)
    800026a2:	c39d                	beqz	a5,800026c8 <wait+0xf4>
      release(&p->lock);
    800026a4:	854a                	mv	a0,s2
    800026a6:	ffffe097          	auipc	ra,0xffffe
    800026aa:	726080e7          	jalr	1830(ra) # 80000dcc <release>
      return -1;
    800026ae:	59fd                	li	s3,-1
}
    800026b0:	854e                	mv	a0,s3
    800026b2:	60a6                	ld	ra,72(sp)
    800026b4:	6406                	ld	s0,64(sp)
    800026b6:	74e2                	ld	s1,56(sp)
    800026b8:	7942                	ld	s2,48(sp)
    800026ba:	79a2                	ld	s3,40(sp)
    800026bc:	7a02                	ld	s4,32(sp)
    800026be:	6ae2                	ld	s5,24(sp)
    800026c0:	6b42                	ld	s6,16(sp)
    800026c2:	6ba2                	ld	s7,8(sp)
    800026c4:	6161                	addi	sp,sp,80
    800026c6:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800026c8:	85ca                	mv	a1,s2
    800026ca:	854a                	mv	a0,s2
    800026cc:	00000097          	auipc	ra,0x0
    800026d0:	e8a080e7          	jalr	-374(ra) # 80002556 <sleep>
    havekids = 0;
    800026d4:	bf25                	j	8000260c <wait+0x38>

00000000800026d6 <wakeup>:
{
    800026d6:	7139                	addi	sp,sp,-64
    800026d8:	fc06                	sd	ra,56(sp)
    800026da:	f822                	sd	s0,48(sp)
    800026dc:	f426                	sd	s1,40(sp)
    800026de:	f04a                	sd	s2,32(sp)
    800026e0:	ec4e                	sd	s3,24(sp)
    800026e2:	e852                	sd	s4,16(sp)
    800026e4:	e456                	sd	s5,8(sp)
    800026e6:	0080                	addi	s0,sp,64
    800026e8:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800026ea:	00010497          	auipc	s1,0x10
    800026ee:	0fe48493          	addi	s1,s1,254 # 800127e8 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800026f2:	4985                	li	s3,1
      p->state = RUNNABLE;
    800026f4:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800026f6:	00016917          	auipc	s2,0x16
    800026fa:	cf290913          	addi	s2,s2,-782 # 800183e8 <tickslock>
    800026fe:	a811                	j	80002712 <wakeup+0x3c>
    release(&p->lock);
    80002700:	8526                	mv	a0,s1
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	6ca080e7          	jalr	1738(ra) # 80000dcc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000270a:	17048493          	addi	s1,s1,368
    8000270e:	03248063          	beq	s1,s2,8000272e <wakeup+0x58>
    acquire(&p->lock);
    80002712:	8526                	mv	a0,s1
    80002714:	ffffe097          	auipc	ra,0xffffe
    80002718:	5e8080e7          	jalr	1512(ra) # 80000cfc <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000271c:	509c                	lw	a5,32(s1)
    8000271e:	ff3791e3          	bne	a5,s3,80002700 <wakeup+0x2a>
    80002722:	789c                	ld	a5,48(s1)
    80002724:	fd479ee3          	bne	a5,s4,80002700 <wakeup+0x2a>
      p->state = RUNNABLE;
    80002728:	0354a023          	sw	s5,32(s1)
    8000272c:	bfd1                	j	80002700 <wakeup+0x2a>
}
    8000272e:	70e2                	ld	ra,56(sp)
    80002730:	7442                	ld	s0,48(sp)
    80002732:	74a2                	ld	s1,40(sp)
    80002734:	7902                	ld	s2,32(sp)
    80002736:	69e2                	ld	s3,24(sp)
    80002738:	6a42                	ld	s4,16(sp)
    8000273a:	6aa2                	ld	s5,8(sp)
    8000273c:	6121                	addi	sp,sp,64
    8000273e:	8082                	ret

0000000080002740 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002740:	7179                	addi	sp,sp,-48
    80002742:	f406                	sd	ra,40(sp)
    80002744:	f022                	sd	s0,32(sp)
    80002746:	ec26                	sd	s1,24(sp)
    80002748:	e84a                	sd	s2,16(sp)
    8000274a:	e44e                	sd	s3,8(sp)
    8000274c:	1800                	addi	s0,sp,48
    8000274e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002750:	00010497          	auipc	s1,0x10
    80002754:	09848493          	addi	s1,s1,152 # 800127e8 <proc>
    80002758:	00016997          	auipc	s3,0x16
    8000275c:	c9098993          	addi	s3,s3,-880 # 800183e8 <tickslock>
    acquire(&p->lock);
    80002760:	8526                	mv	a0,s1
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	59a080e7          	jalr	1434(ra) # 80000cfc <acquire>
    if(p->pid == pid){
    8000276a:	40bc                	lw	a5,64(s1)
    8000276c:	01278d63          	beq	a5,s2,80002786 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002770:	8526                	mv	a0,s1
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	65a080e7          	jalr	1626(ra) # 80000dcc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000277a:	17048493          	addi	s1,s1,368
    8000277e:	ff3491e3          	bne	s1,s3,80002760 <kill+0x20>
  }
  return -1;
    80002782:	557d                	li	a0,-1
    80002784:	a821                	j	8000279c <kill+0x5c>
      p->killed = 1;
    80002786:	4785                	li	a5,1
    80002788:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    8000278a:	5098                	lw	a4,32(s1)
    8000278c:	00f70f63          	beq	a4,a5,800027aa <kill+0x6a>
      release(&p->lock);
    80002790:	8526                	mv	a0,s1
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	63a080e7          	jalr	1594(ra) # 80000dcc <release>
      return 0;
    8000279a:	4501                	li	a0,0
}
    8000279c:	70a2                	ld	ra,40(sp)
    8000279e:	7402                	ld	s0,32(sp)
    800027a0:	64e2                	ld	s1,24(sp)
    800027a2:	6942                	ld	s2,16(sp)
    800027a4:	69a2                	ld	s3,8(sp)
    800027a6:	6145                	addi	sp,sp,48
    800027a8:	8082                	ret
        p->state = RUNNABLE;
    800027aa:	4789                	li	a5,2
    800027ac:	d09c                	sw	a5,32(s1)
    800027ae:	b7cd                	j	80002790 <kill+0x50>

00000000800027b0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027b0:	7179                	addi	sp,sp,-48
    800027b2:	f406                	sd	ra,40(sp)
    800027b4:	f022                	sd	s0,32(sp)
    800027b6:	ec26                	sd	s1,24(sp)
    800027b8:	e84a                	sd	s2,16(sp)
    800027ba:	e44e                	sd	s3,8(sp)
    800027bc:	e052                	sd	s4,0(sp)
    800027be:	1800                	addi	s0,sp,48
    800027c0:	84aa                	mv	s1,a0
    800027c2:	892e                	mv	s2,a1
    800027c4:	89b2                	mv	s3,a2
    800027c6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027c8:	fffff097          	auipc	ra,0xfffff
    800027cc:	57a080e7          	jalr	1402(ra) # 80001d42 <myproc>
  if(user_dst){
    800027d0:	c08d                	beqz	s1,800027f2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800027d2:	86d2                	mv	a3,s4
    800027d4:	864e                	mv	a2,s3
    800027d6:	85ca                	mv	a1,s2
    800027d8:	6d28                	ld	a0,88(a0)
    800027da:	fffff097          	auipc	ra,0xfffff
    800027de:	25a080e7          	jalr	602(ra) # 80001a34 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027e2:	70a2                	ld	ra,40(sp)
    800027e4:	7402                	ld	s0,32(sp)
    800027e6:	64e2                	ld	s1,24(sp)
    800027e8:	6942                	ld	s2,16(sp)
    800027ea:	69a2                	ld	s3,8(sp)
    800027ec:	6a02                	ld	s4,0(sp)
    800027ee:	6145                	addi	sp,sp,48
    800027f0:	8082                	ret
    memmove((char *)dst, src, len);
    800027f2:	000a061b          	sext.w	a2,s4
    800027f6:	85ce                	mv	a1,s3
    800027f8:	854a                	mv	a0,s2
    800027fa:	fffff097          	auipc	ra,0xfffff
    800027fe:	93e080e7          	jalr	-1730(ra) # 80001138 <memmove>
    return 0;
    80002802:	8526                	mv	a0,s1
    80002804:	bff9                	j	800027e2 <either_copyout+0x32>

0000000080002806 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002806:	7179                	addi	sp,sp,-48
    80002808:	f406                	sd	ra,40(sp)
    8000280a:	f022                	sd	s0,32(sp)
    8000280c:	ec26                	sd	s1,24(sp)
    8000280e:	e84a                	sd	s2,16(sp)
    80002810:	e44e                	sd	s3,8(sp)
    80002812:	e052                	sd	s4,0(sp)
    80002814:	1800                	addi	s0,sp,48
    80002816:	892a                	mv	s2,a0
    80002818:	84ae                	mv	s1,a1
    8000281a:	89b2                	mv	s3,a2
    8000281c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000281e:	fffff097          	auipc	ra,0xfffff
    80002822:	524080e7          	jalr	1316(ra) # 80001d42 <myproc>
  if(user_src){
    80002826:	c08d                	beqz	s1,80002848 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002828:	86d2                	mv	a3,s4
    8000282a:	864e                	mv	a2,s3
    8000282c:	85ca                	mv	a1,s2
    8000282e:	6d28                	ld	a0,88(a0)
    80002830:	fffff097          	auipc	ra,0xfffff
    80002834:	290080e7          	jalr	656(ra) # 80001ac0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002838:	70a2                	ld	ra,40(sp)
    8000283a:	7402                	ld	s0,32(sp)
    8000283c:	64e2                	ld	s1,24(sp)
    8000283e:	6942                	ld	s2,16(sp)
    80002840:	69a2                	ld	s3,8(sp)
    80002842:	6a02                	ld	s4,0(sp)
    80002844:	6145                	addi	sp,sp,48
    80002846:	8082                	ret
    memmove(dst, (char*)src, len);
    80002848:	000a061b          	sext.w	a2,s4
    8000284c:	85ce                	mv	a1,s3
    8000284e:	854a                	mv	a0,s2
    80002850:	fffff097          	auipc	ra,0xfffff
    80002854:	8e8080e7          	jalr	-1816(ra) # 80001138 <memmove>
    return 0;
    80002858:	8526                	mv	a0,s1
    8000285a:	bff9                	j	80002838 <either_copyin+0x32>

000000008000285c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000285c:	715d                	addi	sp,sp,-80
    8000285e:	e486                	sd	ra,72(sp)
    80002860:	e0a2                	sd	s0,64(sp)
    80002862:	fc26                	sd	s1,56(sp)
    80002864:	f84a                	sd	s2,48(sp)
    80002866:	f44e                	sd	s3,40(sp)
    80002868:	f052                	sd	s4,32(sp)
    8000286a:	ec56                	sd	s5,24(sp)
    8000286c:	e85a                	sd	s6,16(sp)
    8000286e:	e45e                	sd	s7,8(sp)
    80002870:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002872:	00006517          	auipc	a0,0x6
    80002876:	8f650513          	addi	a0,a0,-1802 # 80008168 <digits+0x128>
    8000287a:	ffffe097          	auipc	ra,0xffffe
    8000287e:	d1a080e7          	jalr	-742(ra) # 80000594 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002882:	00010497          	auipc	s1,0x10
    80002886:	0c648493          	addi	s1,s1,198 # 80012948 <proc+0x160>
    8000288a:	00016917          	auipc	s2,0x16
    8000288e:	cbe90913          	addi	s2,s2,-834 # 80018548 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002892:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002894:	00006997          	auipc	s3,0x6
    80002898:	a6c98993          	addi	s3,s3,-1428 # 80008300 <digits+0x2c0>
    printf("%d %s %s", p->pid, state, p->name);
    8000289c:	00006a97          	auipc	s5,0x6
    800028a0:	a6ca8a93          	addi	s5,s5,-1428 # 80008308 <digits+0x2c8>
    printf("\n");
    800028a4:	00006a17          	auipc	s4,0x6
    800028a8:	8c4a0a13          	addi	s4,s4,-1852 # 80008168 <digits+0x128>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028ac:	00006b97          	auipc	s7,0x6
    800028b0:	a94b8b93          	addi	s7,s7,-1388 # 80008340 <states.0>
    800028b4:	a00d                	j	800028d6 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800028b6:	ee06a583          	lw	a1,-288(a3)
    800028ba:	8556                	mv	a0,s5
    800028bc:	ffffe097          	auipc	ra,0xffffe
    800028c0:	cd8080e7          	jalr	-808(ra) # 80000594 <printf>
    printf("\n");
    800028c4:	8552                	mv	a0,s4
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	cce080e7          	jalr	-818(ra) # 80000594 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028ce:	17048493          	addi	s1,s1,368
    800028d2:	03248163          	beq	s1,s2,800028f4 <procdump+0x98>
    if(p->state == UNUSED)
    800028d6:	86a6                	mv	a3,s1
    800028d8:	ec04a783          	lw	a5,-320(s1)
    800028dc:	dbed                	beqz	a5,800028ce <procdump+0x72>
      state = "???";
    800028de:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028e0:	fcfb6be3          	bltu	s6,a5,800028b6 <procdump+0x5a>
    800028e4:	1782                	slli	a5,a5,0x20
    800028e6:	9381                	srli	a5,a5,0x20
    800028e8:	078e                	slli	a5,a5,0x3
    800028ea:	97de                	add	a5,a5,s7
    800028ec:	6390                	ld	a2,0(a5)
    800028ee:	f661                	bnez	a2,800028b6 <procdump+0x5a>
      state = "???";
    800028f0:	864e                	mv	a2,s3
    800028f2:	b7d1                	j	800028b6 <procdump+0x5a>
  }
}
    800028f4:	60a6                	ld	ra,72(sp)
    800028f6:	6406                	ld	s0,64(sp)
    800028f8:	74e2                	ld	s1,56(sp)
    800028fa:	7942                	ld	s2,48(sp)
    800028fc:	79a2                	ld	s3,40(sp)
    800028fe:	7a02                	ld	s4,32(sp)
    80002900:	6ae2                	ld	s5,24(sp)
    80002902:	6b42                	ld	s6,16(sp)
    80002904:	6ba2                	ld	s7,8(sp)
    80002906:	6161                	addi	sp,sp,80
    80002908:	8082                	ret

000000008000290a <swtch>:
    8000290a:	00153023          	sd	ra,0(a0)
    8000290e:	00253423          	sd	sp,8(a0)
    80002912:	e900                	sd	s0,16(a0)
    80002914:	ed04                	sd	s1,24(a0)
    80002916:	03253023          	sd	s2,32(a0)
    8000291a:	03353423          	sd	s3,40(a0)
    8000291e:	03453823          	sd	s4,48(a0)
    80002922:	03553c23          	sd	s5,56(a0)
    80002926:	05653023          	sd	s6,64(a0)
    8000292a:	05753423          	sd	s7,72(a0)
    8000292e:	05853823          	sd	s8,80(a0)
    80002932:	05953c23          	sd	s9,88(a0)
    80002936:	07a53023          	sd	s10,96(a0)
    8000293a:	07b53423          	sd	s11,104(a0)
    8000293e:	0005b083          	ld	ra,0(a1)
    80002942:	0085b103          	ld	sp,8(a1)
    80002946:	6980                	ld	s0,16(a1)
    80002948:	6d84                	ld	s1,24(a1)
    8000294a:	0205b903          	ld	s2,32(a1)
    8000294e:	0285b983          	ld	s3,40(a1)
    80002952:	0305ba03          	ld	s4,48(a1)
    80002956:	0385ba83          	ld	s5,56(a1)
    8000295a:	0405bb03          	ld	s6,64(a1)
    8000295e:	0485bb83          	ld	s7,72(a1)
    80002962:	0505bc03          	ld	s8,80(a1)
    80002966:	0585bc83          	ld	s9,88(a1)
    8000296a:	0605bd03          	ld	s10,96(a1)
    8000296e:	0685bd83          	ld	s11,104(a1)
    80002972:	8082                	ret

0000000080002974 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002974:	1141                	addi	sp,sp,-16
    80002976:	e406                	sd	ra,8(sp)
    80002978:	e022                	sd	s0,0(sp)
    8000297a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000297c:	00006597          	auipc	a1,0x6
    80002980:	9ec58593          	addi	a1,a1,-1556 # 80008368 <states.0+0x28>
    80002984:	00016517          	auipc	a0,0x16
    80002988:	a6450513          	addi	a0,a0,-1436 # 800183e8 <tickslock>
    8000298c:	ffffe097          	auipc	ra,0xffffe
    80002990:	4ec080e7          	jalr	1260(ra) # 80000e78 <initlock>
}
    80002994:	60a2                	ld	ra,8(sp)
    80002996:	6402                	ld	s0,0(sp)
    80002998:	0141                	addi	sp,sp,16
    8000299a:	8082                	ret

000000008000299c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000299c:	1141                	addi	sp,sp,-16
    8000299e:	e422                	sd	s0,8(sp)
    800029a0:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029a2:	00003797          	auipc	a5,0x3
    800029a6:	78e78793          	addi	a5,a5,1934 # 80006130 <kernelvec>
    800029aa:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029ae:	6422                	ld	s0,8(sp)
    800029b0:	0141                	addi	sp,sp,16
    800029b2:	8082                	ret

00000000800029b4 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800029b4:	1141                	addi	sp,sp,-16
    800029b6:	e406                	sd	ra,8(sp)
    800029b8:	e022                	sd	s0,0(sp)
    800029ba:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029bc:	fffff097          	auipc	ra,0xfffff
    800029c0:	386080e7          	jalr	902(ra) # 80001d42 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029c8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ca:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800029ce:	00004617          	auipc	a2,0x4
    800029d2:	63260613          	addi	a2,a2,1586 # 80007000 <_trampoline>
    800029d6:	00004697          	auipc	a3,0x4
    800029da:	62a68693          	addi	a3,a3,1578 # 80007000 <_trampoline>
    800029de:	8e91                	sub	a3,a3,a2
    800029e0:	040007b7          	lui	a5,0x4000
    800029e4:	17fd                	addi	a5,a5,-1
    800029e6:	07b2                	slli	a5,a5,0xc
    800029e8:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029ea:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029ee:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029f0:	180026f3          	csrr	a3,satp
    800029f4:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029f6:	7138                	ld	a4,96(a0)
    800029f8:	6534                	ld	a3,72(a0)
    800029fa:	6585                	lui	a1,0x1
    800029fc:	96ae                	add	a3,a3,a1
    800029fe:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a00:	7138                	ld	a4,96(a0)
    80002a02:	00000697          	auipc	a3,0x0
    80002a06:	13868693          	addi	a3,a3,312 # 80002b3a <usertrap>
    80002a0a:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a0c:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a0e:	8692                	mv	a3,tp
    80002a10:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a12:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a16:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a1a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a1e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a22:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a24:	6f18                	ld	a4,24(a4)
    80002a26:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a2a:	6d2c                	ld	a1,88(a0)
    80002a2c:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002a2e:	00004717          	auipc	a4,0x4
    80002a32:	66270713          	addi	a4,a4,1634 # 80007090 <userret>
    80002a36:	8f11                	sub	a4,a4,a2
    80002a38:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002a3a:	577d                	li	a4,-1
    80002a3c:	177e                	slli	a4,a4,0x3f
    80002a3e:	8dd9                	or	a1,a1,a4
    80002a40:	02000537          	lui	a0,0x2000
    80002a44:	157d                	addi	a0,a0,-1
    80002a46:	0536                	slli	a0,a0,0xd
    80002a48:	9782                	jalr	a5
}
    80002a4a:	60a2                	ld	ra,8(sp)
    80002a4c:	6402                	ld	s0,0(sp)
    80002a4e:	0141                	addi	sp,sp,16
    80002a50:	8082                	ret

0000000080002a52 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a52:	1101                	addi	sp,sp,-32
    80002a54:	ec06                	sd	ra,24(sp)
    80002a56:	e822                	sd	s0,16(sp)
    80002a58:	e426                	sd	s1,8(sp)
    80002a5a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a5c:	00016497          	auipc	s1,0x16
    80002a60:	98c48493          	addi	s1,s1,-1652 # 800183e8 <tickslock>
    80002a64:	8526                	mv	a0,s1
    80002a66:	ffffe097          	auipc	ra,0xffffe
    80002a6a:	296080e7          	jalr	662(ra) # 80000cfc <acquire>
  ticks++;
    80002a6e:	00006517          	auipc	a0,0x6
    80002a72:	5b250513          	addi	a0,a0,1458 # 80009020 <ticks>
    80002a76:	411c                	lw	a5,0(a0)
    80002a78:	2785                	addiw	a5,a5,1
    80002a7a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a7c:	00000097          	auipc	ra,0x0
    80002a80:	c5a080e7          	jalr	-934(ra) # 800026d6 <wakeup>
  release(&tickslock);
    80002a84:	8526                	mv	a0,s1
    80002a86:	ffffe097          	auipc	ra,0xffffe
    80002a8a:	346080e7          	jalr	838(ra) # 80000dcc <release>
}
    80002a8e:	60e2                	ld	ra,24(sp)
    80002a90:	6442                	ld	s0,16(sp)
    80002a92:	64a2                	ld	s1,8(sp)
    80002a94:	6105                	addi	sp,sp,32
    80002a96:	8082                	ret

0000000080002a98 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a98:	1101                	addi	sp,sp,-32
    80002a9a:	ec06                	sd	ra,24(sp)
    80002a9c:	e822                	sd	s0,16(sp)
    80002a9e:	e426                	sd	s1,8(sp)
    80002aa0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aa2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002aa6:	00074d63          	bltz	a4,80002ac0 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002aaa:	57fd                	li	a5,-1
    80002aac:	17fe                	slli	a5,a5,0x3f
    80002aae:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ab0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ab2:	06f70363          	beq	a4,a5,80002b18 <devintr+0x80>
  }
}
    80002ab6:	60e2                	ld	ra,24(sp)
    80002ab8:	6442                	ld	s0,16(sp)
    80002aba:	64a2                	ld	s1,8(sp)
    80002abc:	6105                	addi	sp,sp,32
    80002abe:	8082                	ret
     (scause & 0xff) == 9){
    80002ac0:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002ac4:	46a5                	li	a3,9
    80002ac6:	fed792e3          	bne	a5,a3,80002aaa <devintr+0x12>
    int irq = plic_claim();
    80002aca:	00003097          	auipc	ra,0x3
    80002ace:	76e080e7          	jalr	1902(ra) # 80006238 <plic_claim>
    80002ad2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002ad4:	47a9                	li	a5,10
    80002ad6:	02f50763          	beq	a0,a5,80002b04 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002ada:	4785                	li	a5,1
    80002adc:	02f50963          	beq	a0,a5,80002b0e <devintr+0x76>
    return 1;
    80002ae0:	4505                	li	a0,1
    } else if(irq){
    80002ae2:	d8f1                	beqz	s1,80002ab6 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ae4:	85a6                	mv	a1,s1
    80002ae6:	00006517          	auipc	a0,0x6
    80002aea:	88a50513          	addi	a0,a0,-1910 # 80008370 <states.0+0x30>
    80002aee:	ffffe097          	auipc	ra,0xffffe
    80002af2:	aa6080e7          	jalr	-1370(ra) # 80000594 <printf>
      plic_complete(irq);
    80002af6:	8526                	mv	a0,s1
    80002af8:	00003097          	auipc	ra,0x3
    80002afc:	764080e7          	jalr	1892(ra) # 8000625c <plic_complete>
    return 1;
    80002b00:	4505                	li	a0,1
    80002b02:	bf55                	j	80002ab6 <devintr+0x1e>
      uartintr();
    80002b04:	ffffe097          	auipc	ra,0xffffe
    80002b08:	ec6080e7          	jalr	-314(ra) # 800009ca <uartintr>
    80002b0c:	b7ed                	j	80002af6 <devintr+0x5e>
      virtio_disk_intr();
    80002b0e:	00004097          	auipc	ra,0x4
    80002b12:	be0080e7          	jalr	-1056(ra) # 800066ee <virtio_disk_intr>
    80002b16:	b7c5                	j	80002af6 <devintr+0x5e>
    if(cpuid() == 0){
    80002b18:	fffff097          	auipc	ra,0xfffff
    80002b1c:	1fe080e7          	jalr	510(ra) # 80001d16 <cpuid>
    80002b20:	c901                	beqz	a0,80002b30 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b22:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b26:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b28:	14479073          	csrw	sip,a5
    return 2;
    80002b2c:	4509                	li	a0,2
    80002b2e:	b761                	j	80002ab6 <devintr+0x1e>
      clockintr();
    80002b30:	00000097          	auipc	ra,0x0
    80002b34:	f22080e7          	jalr	-222(ra) # 80002a52 <clockintr>
    80002b38:	b7ed                	j	80002b22 <devintr+0x8a>

0000000080002b3a <usertrap>:
{
    80002b3a:	1101                	addi	sp,sp,-32
    80002b3c:	ec06                	sd	ra,24(sp)
    80002b3e:	e822                	sd	s0,16(sp)
    80002b40:	e426                	sd	s1,8(sp)
    80002b42:	e04a                	sd	s2,0(sp)
    80002b44:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b46:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b4a:	1007f793          	andi	a5,a5,256
    80002b4e:	e3ad                	bnez	a5,80002bb0 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b50:	00003797          	auipc	a5,0x3
    80002b54:	5e078793          	addi	a5,a5,1504 # 80006130 <kernelvec>
    80002b58:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b5c:	fffff097          	auipc	ra,0xfffff
    80002b60:	1e6080e7          	jalr	486(ra) # 80001d42 <myproc>
    80002b64:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b66:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b68:	14102773          	csrr	a4,sepc
    80002b6c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b6e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b72:	47a1                	li	a5,8
    80002b74:	04f71c63          	bne	a4,a5,80002bcc <usertrap+0x92>
    if(p->killed)
    80002b78:	5d1c                	lw	a5,56(a0)
    80002b7a:	e3b9                	bnez	a5,80002bc0 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002b7c:	70b8                	ld	a4,96(s1)
    80002b7e:	6f1c                	ld	a5,24(a4)
    80002b80:	0791                	addi	a5,a5,4
    80002b82:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b88:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b8c:	10079073          	csrw	sstatus,a5
    syscall();
    80002b90:	00000097          	auipc	ra,0x0
    80002b94:	2e0080e7          	jalr	736(ra) # 80002e70 <syscall>
  if(p->killed)
    80002b98:	5c9c                	lw	a5,56(s1)
    80002b9a:	ebc1                	bnez	a5,80002c2a <usertrap+0xf0>
  usertrapret();
    80002b9c:	00000097          	auipc	ra,0x0
    80002ba0:	e18080e7          	jalr	-488(ra) # 800029b4 <usertrapret>
}
    80002ba4:	60e2                	ld	ra,24(sp)
    80002ba6:	6442                	ld	s0,16(sp)
    80002ba8:	64a2                	ld	s1,8(sp)
    80002baa:	6902                	ld	s2,0(sp)
    80002bac:	6105                	addi	sp,sp,32
    80002bae:	8082                	ret
    panic("usertrap: not from user mode");
    80002bb0:	00005517          	auipc	a0,0x5
    80002bb4:	7e050513          	addi	a0,a0,2016 # 80008390 <states.0+0x50>
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	992080e7          	jalr	-1646(ra) # 8000054a <panic>
      exit(-1);
    80002bc0:	557d                	li	a0,-1
    80002bc2:	00000097          	auipc	ra,0x0
    80002bc6:	84e080e7          	jalr	-1970(ra) # 80002410 <exit>
    80002bca:	bf4d                	j	80002b7c <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002bcc:	00000097          	auipc	ra,0x0
    80002bd0:	ecc080e7          	jalr	-308(ra) # 80002a98 <devintr>
    80002bd4:	892a                	mv	s2,a0
    80002bd6:	c501                	beqz	a0,80002bde <usertrap+0xa4>
  if(p->killed)
    80002bd8:	5c9c                	lw	a5,56(s1)
    80002bda:	c3a1                	beqz	a5,80002c1a <usertrap+0xe0>
    80002bdc:	a815                	j	80002c10 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bde:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002be2:	40b0                	lw	a2,64(s1)
    80002be4:	00005517          	auipc	a0,0x5
    80002be8:	7cc50513          	addi	a0,a0,1996 # 800083b0 <states.0+0x70>
    80002bec:	ffffe097          	auipc	ra,0xffffe
    80002bf0:	9a8080e7          	jalr	-1624(ra) # 80000594 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bf4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bf8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bfc:	00005517          	auipc	a0,0x5
    80002c00:	7e450513          	addi	a0,a0,2020 # 800083e0 <states.0+0xa0>
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	990080e7          	jalr	-1648(ra) # 80000594 <printf>
    p->killed = 1;
    80002c0c:	4785                	li	a5,1
    80002c0e:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002c10:	557d                	li	a0,-1
    80002c12:	fffff097          	auipc	ra,0xfffff
    80002c16:	7fe080e7          	jalr	2046(ra) # 80002410 <exit>
  if(which_dev == 2)
    80002c1a:	4789                	li	a5,2
    80002c1c:	f8f910e3          	bne	s2,a5,80002b9c <usertrap+0x62>
    yield();
    80002c20:	00000097          	auipc	ra,0x0
    80002c24:	8fa080e7          	jalr	-1798(ra) # 8000251a <yield>
    80002c28:	bf95                	j	80002b9c <usertrap+0x62>
  int which_dev = 0;
    80002c2a:	4901                	li	s2,0
    80002c2c:	b7d5                	j	80002c10 <usertrap+0xd6>

0000000080002c2e <kerneltrap>:
{
    80002c2e:	7179                	addi	sp,sp,-48
    80002c30:	f406                	sd	ra,40(sp)
    80002c32:	f022                	sd	s0,32(sp)
    80002c34:	ec26                	sd	s1,24(sp)
    80002c36:	e84a                	sd	s2,16(sp)
    80002c38:	e44e                	sd	s3,8(sp)
    80002c3a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c3c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c40:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c44:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c48:	1004f793          	andi	a5,s1,256
    80002c4c:	cb85                	beqz	a5,80002c7c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c52:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c54:	ef85                	bnez	a5,80002c8c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	e42080e7          	jalr	-446(ra) # 80002a98 <devintr>
    80002c5e:	cd1d                	beqz	a0,80002c9c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c60:	4789                	li	a5,2
    80002c62:	06f50a63          	beq	a0,a5,80002cd6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c66:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c6a:	10049073          	csrw	sstatus,s1
}
    80002c6e:	70a2                	ld	ra,40(sp)
    80002c70:	7402                	ld	s0,32(sp)
    80002c72:	64e2                	ld	s1,24(sp)
    80002c74:	6942                	ld	s2,16(sp)
    80002c76:	69a2                	ld	s3,8(sp)
    80002c78:	6145                	addi	sp,sp,48
    80002c7a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c7c:	00005517          	auipc	a0,0x5
    80002c80:	78450513          	addi	a0,a0,1924 # 80008400 <states.0+0xc0>
    80002c84:	ffffe097          	auipc	ra,0xffffe
    80002c88:	8c6080e7          	jalr	-1850(ra) # 8000054a <panic>
    panic("kerneltrap: interrupts enabled");
    80002c8c:	00005517          	auipc	a0,0x5
    80002c90:	79c50513          	addi	a0,a0,1948 # 80008428 <states.0+0xe8>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	8b6080e7          	jalr	-1866(ra) # 8000054a <panic>
    printf("scause %p\n", scause);
    80002c9c:	85ce                	mv	a1,s3
    80002c9e:	00005517          	auipc	a0,0x5
    80002ca2:	7aa50513          	addi	a0,a0,1962 # 80008448 <states.0+0x108>
    80002ca6:	ffffe097          	auipc	ra,0xffffe
    80002caa:	8ee080e7          	jalr	-1810(ra) # 80000594 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cb2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cb6:	00005517          	auipc	a0,0x5
    80002cba:	7a250513          	addi	a0,a0,1954 # 80008458 <states.0+0x118>
    80002cbe:	ffffe097          	auipc	ra,0xffffe
    80002cc2:	8d6080e7          	jalr	-1834(ra) # 80000594 <printf>
    panic("kerneltrap");
    80002cc6:	00005517          	auipc	a0,0x5
    80002cca:	7aa50513          	addi	a0,a0,1962 # 80008470 <states.0+0x130>
    80002cce:	ffffe097          	auipc	ra,0xffffe
    80002cd2:	87c080e7          	jalr	-1924(ra) # 8000054a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	06c080e7          	jalr	108(ra) # 80001d42 <myproc>
    80002cde:	d541                	beqz	a0,80002c66 <kerneltrap+0x38>
    80002ce0:	fffff097          	auipc	ra,0xfffff
    80002ce4:	062080e7          	jalr	98(ra) # 80001d42 <myproc>
    80002ce8:	5118                	lw	a4,32(a0)
    80002cea:	478d                	li	a5,3
    80002cec:	f6f71de3          	bne	a4,a5,80002c66 <kerneltrap+0x38>
    yield();
    80002cf0:	00000097          	auipc	ra,0x0
    80002cf4:	82a080e7          	jalr	-2006(ra) # 8000251a <yield>
    80002cf8:	b7bd                	j	80002c66 <kerneltrap+0x38>

0000000080002cfa <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cfa:	1101                	addi	sp,sp,-32
    80002cfc:	ec06                	sd	ra,24(sp)
    80002cfe:	e822                	sd	s0,16(sp)
    80002d00:	e426                	sd	s1,8(sp)
    80002d02:	1000                	addi	s0,sp,32
    80002d04:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d06:	fffff097          	auipc	ra,0xfffff
    80002d0a:	03c080e7          	jalr	60(ra) # 80001d42 <myproc>
  switch (n) {
    80002d0e:	4795                	li	a5,5
    80002d10:	0497e163          	bltu	a5,s1,80002d52 <argraw+0x58>
    80002d14:	048a                	slli	s1,s1,0x2
    80002d16:	00005717          	auipc	a4,0x5
    80002d1a:	79270713          	addi	a4,a4,1938 # 800084a8 <states.0+0x168>
    80002d1e:	94ba                	add	s1,s1,a4
    80002d20:	409c                	lw	a5,0(s1)
    80002d22:	97ba                	add	a5,a5,a4
    80002d24:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d26:	713c                	ld	a5,96(a0)
    80002d28:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d2a:	60e2                	ld	ra,24(sp)
    80002d2c:	6442                	ld	s0,16(sp)
    80002d2e:	64a2                	ld	s1,8(sp)
    80002d30:	6105                	addi	sp,sp,32
    80002d32:	8082                	ret
    return p->trapframe->a1;
    80002d34:	713c                	ld	a5,96(a0)
    80002d36:	7fa8                	ld	a0,120(a5)
    80002d38:	bfcd                	j	80002d2a <argraw+0x30>
    return p->trapframe->a2;
    80002d3a:	713c                	ld	a5,96(a0)
    80002d3c:	63c8                	ld	a0,128(a5)
    80002d3e:	b7f5                	j	80002d2a <argraw+0x30>
    return p->trapframe->a3;
    80002d40:	713c                	ld	a5,96(a0)
    80002d42:	67c8                	ld	a0,136(a5)
    80002d44:	b7dd                	j	80002d2a <argraw+0x30>
    return p->trapframe->a4;
    80002d46:	713c                	ld	a5,96(a0)
    80002d48:	6bc8                	ld	a0,144(a5)
    80002d4a:	b7c5                	j	80002d2a <argraw+0x30>
    return p->trapframe->a5;
    80002d4c:	713c                	ld	a5,96(a0)
    80002d4e:	6fc8                	ld	a0,152(a5)
    80002d50:	bfe9                	j	80002d2a <argraw+0x30>
  panic("argraw");
    80002d52:	00005517          	auipc	a0,0x5
    80002d56:	72e50513          	addi	a0,a0,1838 # 80008480 <states.0+0x140>
    80002d5a:	ffffd097          	auipc	ra,0xffffd
    80002d5e:	7f0080e7          	jalr	2032(ra) # 8000054a <panic>

0000000080002d62 <fetchaddr>:
{
    80002d62:	1101                	addi	sp,sp,-32
    80002d64:	ec06                	sd	ra,24(sp)
    80002d66:	e822                	sd	s0,16(sp)
    80002d68:	e426                	sd	s1,8(sp)
    80002d6a:	e04a                	sd	s2,0(sp)
    80002d6c:	1000                	addi	s0,sp,32
    80002d6e:	84aa                	mv	s1,a0
    80002d70:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d72:	fffff097          	auipc	ra,0xfffff
    80002d76:	fd0080e7          	jalr	-48(ra) # 80001d42 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d7a:	693c                	ld	a5,80(a0)
    80002d7c:	02f4f863          	bgeu	s1,a5,80002dac <fetchaddr+0x4a>
    80002d80:	00848713          	addi	a4,s1,8
    80002d84:	02e7e663          	bltu	a5,a4,80002db0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d88:	46a1                	li	a3,8
    80002d8a:	8626                	mv	a2,s1
    80002d8c:	85ca                	mv	a1,s2
    80002d8e:	6d28                	ld	a0,88(a0)
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	d30080e7          	jalr	-720(ra) # 80001ac0 <copyin>
    80002d98:	00a03533          	snez	a0,a0
    80002d9c:	40a00533          	neg	a0,a0
}
    80002da0:	60e2                	ld	ra,24(sp)
    80002da2:	6442                	ld	s0,16(sp)
    80002da4:	64a2                	ld	s1,8(sp)
    80002da6:	6902                	ld	s2,0(sp)
    80002da8:	6105                	addi	sp,sp,32
    80002daa:	8082                	ret
    return -1;
    80002dac:	557d                	li	a0,-1
    80002dae:	bfcd                	j	80002da0 <fetchaddr+0x3e>
    80002db0:	557d                	li	a0,-1
    80002db2:	b7fd                	j	80002da0 <fetchaddr+0x3e>

0000000080002db4 <fetchstr>:
{
    80002db4:	7179                	addi	sp,sp,-48
    80002db6:	f406                	sd	ra,40(sp)
    80002db8:	f022                	sd	s0,32(sp)
    80002dba:	ec26                	sd	s1,24(sp)
    80002dbc:	e84a                	sd	s2,16(sp)
    80002dbe:	e44e                	sd	s3,8(sp)
    80002dc0:	1800                	addi	s0,sp,48
    80002dc2:	892a                	mv	s2,a0
    80002dc4:	84ae                	mv	s1,a1
    80002dc6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002dc8:	fffff097          	auipc	ra,0xfffff
    80002dcc:	f7a080e7          	jalr	-134(ra) # 80001d42 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002dd0:	86ce                	mv	a3,s3
    80002dd2:	864a                	mv	a2,s2
    80002dd4:	85a6                	mv	a1,s1
    80002dd6:	6d28                	ld	a0,88(a0)
    80002dd8:	fffff097          	auipc	ra,0xfffff
    80002ddc:	d76080e7          	jalr	-650(ra) # 80001b4e <copyinstr>
  if(err < 0)
    80002de0:	00054763          	bltz	a0,80002dee <fetchstr+0x3a>
  return strlen(buf);
    80002de4:	8526                	mv	a0,s1
    80002de6:	ffffe097          	auipc	ra,0xffffe
    80002dea:	47a080e7          	jalr	1146(ra) # 80001260 <strlen>
}
    80002dee:	70a2                	ld	ra,40(sp)
    80002df0:	7402                	ld	s0,32(sp)
    80002df2:	64e2                	ld	s1,24(sp)
    80002df4:	6942                	ld	s2,16(sp)
    80002df6:	69a2                	ld	s3,8(sp)
    80002df8:	6145                	addi	sp,sp,48
    80002dfa:	8082                	ret

0000000080002dfc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002dfc:	1101                	addi	sp,sp,-32
    80002dfe:	ec06                	sd	ra,24(sp)
    80002e00:	e822                	sd	s0,16(sp)
    80002e02:	e426                	sd	s1,8(sp)
    80002e04:	1000                	addi	s0,sp,32
    80002e06:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e08:	00000097          	auipc	ra,0x0
    80002e0c:	ef2080e7          	jalr	-270(ra) # 80002cfa <argraw>
    80002e10:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e12:	4501                	li	a0,0
    80002e14:	60e2                	ld	ra,24(sp)
    80002e16:	6442                	ld	s0,16(sp)
    80002e18:	64a2                	ld	s1,8(sp)
    80002e1a:	6105                	addi	sp,sp,32
    80002e1c:	8082                	ret

0000000080002e1e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e1e:	1101                	addi	sp,sp,-32
    80002e20:	ec06                	sd	ra,24(sp)
    80002e22:	e822                	sd	s0,16(sp)
    80002e24:	e426                	sd	s1,8(sp)
    80002e26:	1000                	addi	s0,sp,32
    80002e28:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e2a:	00000097          	auipc	ra,0x0
    80002e2e:	ed0080e7          	jalr	-304(ra) # 80002cfa <argraw>
    80002e32:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e34:	4501                	li	a0,0
    80002e36:	60e2                	ld	ra,24(sp)
    80002e38:	6442                	ld	s0,16(sp)
    80002e3a:	64a2                	ld	s1,8(sp)
    80002e3c:	6105                	addi	sp,sp,32
    80002e3e:	8082                	ret

0000000080002e40 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e40:	1101                	addi	sp,sp,-32
    80002e42:	ec06                	sd	ra,24(sp)
    80002e44:	e822                	sd	s0,16(sp)
    80002e46:	e426                	sd	s1,8(sp)
    80002e48:	e04a                	sd	s2,0(sp)
    80002e4a:	1000                	addi	s0,sp,32
    80002e4c:	84ae                	mv	s1,a1
    80002e4e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e50:	00000097          	auipc	ra,0x0
    80002e54:	eaa080e7          	jalr	-342(ra) # 80002cfa <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e58:	864a                	mv	a2,s2
    80002e5a:	85a6                	mv	a1,s1
    80002e5c:	00000097          	auipc	ra,0x0
    80002e60:	f58080e7          	jalr	-168(ra) # 80002db4 <fetchstr>
}
    80002e64:	60e2                	ld	ra,24(sp)
    80002e66:	6442                	ld	s0,16(sp)
    80002e68:	64a2                	ld	s1,8(sp)
    80002e6a:	6902                	ld	s2,0(sp)
    80002e6c:	6105                	addi	sp,sp,32
    80002e6e:	8082                	ret

0000000080002e70 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002e70:	1101                	addi	sp,sp,-32
    80002e72:	ec06                	sd	ra,24(sp)
    80002e74:	e822                	sd	s0,16(sp)
    80002e76:	e426                	sd	s1,8(sp)
    80002e78:	e04a                	sd	s2,0(sp)
    80002e7a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e7c:	fffff097          	auipc	ra,0xfffff
    80002e80:	ec6080e7          	jalr	-314(ra) # 80001d42 <myproc>
    80002e84:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e86:	06053903          	ld	s2,96(a0)
    80002e8a:	0a893783          	ld	a5,168(s2)
    80002e8e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e92:	37fd                	addiw	a5,a5,-1
    80002e94:	4751                	li	a4,20
    80002e96:	00f76f63          	bltu	a4,a5,80002eb4 <syscall+0x44>
    80002e9a:	00369713          	slli	a4,a3,0x3
    80002e9e:	00005797          	auipc	a5,0x5
    80002ea2:	62278793          	addi	a5,a5,1570 # 800084c0 <syscalls>
    80002ea6:	97ba                	add	a5,a5,a4
    80002ea8:	639c                	ld	a5,0(a5)
    80002eaa:	c789                	beqz	a5,80002eb4 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002eac:	9782                	jalr	a5
    80002eae:	06a93823          	sd	a0,112(s2)
    80002eb2:	a839                	j	80002ed0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002eb4:	16048613          	addi	a2,s1,352
    80002eb8:	40ac                	lw	a1,64(s1)
    80002eba:	00005517          	auipc	a0,0x5
    80002ebe:	5ce50513          	addi	a0,a0,1486 # 80008488 <states.0+0x148>
    80002ec2:	ffffd097          	auipc	ra,0xffffd
    80002ec6:	6d2080e7          	jalr	1746(ra) # 80000594 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002eca:	70bc                	ld	a5,96(s1)
    80002ecc:	577d                	li	a4,-1
    80002ece:	fbb8                	sd	a4,112(a5)
  }
}
    80002ed0:	60e2                	ld	ra,24(sp)
    80002ed2:	6442                	ld	s0,16(sp)
    80002ed4:	64a2                	ld	s1,8(sp)
    80002ed6:	6902                	ld	s2,0(sp)
    80002ed8:	6105                	addi	sp,sp,32
    80002eda:	8082                	ret

0000000080002edc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002edc:	1101                	addi	sp,sp,-32
    80002ede:	ec06                	sd	ra,24(sp)
    80002ee0:	e822                	sd	s0,16(sp)
    80002ee2:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002ee4:	fec40593          	addi	a1,s0,-20
    80002ee8:	4501                	li	a0,0
    80002eea:	00000097          	auipc	ra,0x0
    80002eee:	f12080e7          	jalr	-238(ra) # 80002dfc <argint>
    return -1;
    80002ef2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ef4:	00054963          	bltz	a0,80002f06 <sys_exit+0x2a>
  exit(n);
    80002ef8:	fec42503          	lw	a0,-20(s0)
    80002efc:	fffff097          	auipc	ra,0xfffff
    80002f00:	514080e7          	jalr	1300(ra) # 80002410 <exit>
  return 0;  // not reached
    80002f04:	4781                	li	a5,0
}
    80002f06:	853e                	mv	a0,a5
    80002f08:	60e2                	ld	ra,24(sp)
    80002f0a:	6442                	ld	s0,16(sp)
    80002f0c:	6105                	addi	sp,sp,32
    80002f0e:	8082                	ret

0000000080002f10 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f10:	1141                	addi	sp,sp,-16
    80002f12:	e406                	sd	ra,8(sp)
    80002f14:	e022                	sd	s0,0(sp)
    80002f16:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f18:	fffff097          	auipc	ra,0xfffff
    80002f1c:	e2a080e7          	jalr	-470(ra) # 80001d42 <myproc>
}
    80002f20:	4128                	lw	a0,64(a0)
    80002f22:	60a2                	ld	ra,8(sp)
    80002f24:	6402                	ld	s0,0(sp)
    80002f26:	0141                	addi	sp,sp,16
    80002f28:	8082                	ret

0000000080002f2a <sys_fork>:

uint64
sys_fork(void)
{
    80002f2a:	1141                	addi	sp,sp,-16
    80002f2c:	e406                	sd	ra,8(sp)
    80002f2e:	e022                	sd	s0,0(sp)
    80002f30:	0800                	addi	s0,sp,16
  return fork();
    80002f32:	fffff097          	auipc	ra,0xfffff
    80002f36:	1d0080e7          	jalr	464(ra) # 80002102 <fork>
}
    80002f3a:	60a2                	ld	ra,8(sp)
    80002f3c:	6402                	ld	s0,0(sp)
    80002f3e:	0141                	addi	sp,sp,16
    80002f40:	8082                	ret

0000000080002f42 <sys_wait>:

uint64
sys_wait(void)
{
    80002f42:	1101                	addi	sp,sp,-32
    80002f44:	ec06                	sd	ra,24(sp)
    80002f46:	e822                	sd	s0,16(sp)
    80002f48:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002f4a:	fe840593          	addi	a1,s0,-24
    80002f4e:	4501                	li	a0,0
    80002f50:	00000097          	auipc	ra,0x0
    80002f54:	ece080e7          	jalr	-306(ra) # 80002e1e <argaddr>
    80002f58:	87aa                	mv	a5,a0
    return -1;
    80002f5a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f5c:	0007c863          	bltz	a5,80002f6c <sys_wait+0x2a>
  return wait(p);
    80002f60:	fe843503          	ld	a0,-24(s0)
    80002f64:	fffff097          	auipc	ra,0xfffff
    80002f68:	670080e7          	jalr	1648(ra) # 800025d4 <wait>
}
    80002f6c:	60e2                	ld	ra,24(sp)
    80002f6e:	6442                	ld	s0,16(sp)
    80002f70:	6105                	addi	sp,sp,32
    80002f72:	8082                	ret

0000000080002f74 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f74:	7179                	addi	sp,sp,-48
    80002f76:	f406                	sd	ra,40(sp)
    80002f78:	f022                	sd	s0,32(sp)
    80002f7a:	ec26                	sd	s1,24(sp)
    80002f7c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f7e:	fdc40593          	addi	a1,s0,-36
    80002f82:	4501                	li	a0,0
    80002f84:	00000097          	auipc	ra,0x0
    80002f88:	e78080e7          	jalr	-392(ra) # 80002dfc <argint>
    return -1;
    80002f8c:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002f8e:	00054f63          	bltz	a0,80002fac <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002f92:	fffff097          	auipc	ra,0xfffff
    80002f96:	db0080e7          	jalr	-592(ra) # 80001d42 <myproc>
    80002f9a:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002f9c:	fdc42503          	lw	a0,-36(s0)
    80002fa0:	fffff097          	auipc	ra,0xfffff
    80002fa4:	0ee080e7          	jalr	238(ra) # 8000208e <growproc>
    80002fa8:	00054863          	bltz	a0,80002fb8 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002fac:	8526                	mv	a0,s1
    80002fae:	70a2                	ld	ra,40(sp)
    80002fb0:	7402                	ld	s0,32(sp)
    80002fb2:	64e2                	ld	s1,24(sp)
    80002fb4:	6145                	addi	sp,sp,48
    80002fb6:	8082                	ret
    return -1;
    80002fb8:	54fd                	li	s1,-1
    80002fba:	bfcd                	j	80002fac <sys_sbrk+0x38>

0000000080002fbc <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fbc:	7139                	addi	sp,sp,-64
    80002fbe:	fc06                	sd	ra,56(sp)
    80002fc0:	f822                	sd	s0,48(sp)
    80002fc2:	f426                	sd	s1,40(sp)
    80002fc4:	f04a                	sd	s2,32(sp)
    80002fc6:	ec4e                	sd	s3,24(sp)
    80002fc8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002fca:	fcc40593          	addi	a1,s0,-52
    80002fce:	4501                	li	a0,0
    80002fd0:	00000097          	auipc	ra,0x0
    80002fd4:	e2c080e7          	jalr	-468(ra) # 80002dfc <argint>
    return -1;
    80002fd8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002fda:	06054563          	bltz	a0,80003044 <sys_sleep+0x88>
  acquire(&tickslock);
    80002fde:	00015517          	auipc	a0,0x15
    80002fe2:	40a50513          	addi	a0,a0,1034 # 800183e8 <tickslock>
    80002fe6:	ffffe097          	auipc	ra,0xffffe
    80002fea:	d16080e7          	jalr	-746(ra) # 80000cfc <acquire>
  ticks0 = ticks;
    80002fee:	00006917          	auipc	s2,0x6
    80002ff2:	03292903          	lw	s2,50(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002ff6:	fcc42783          	lw	a5,-52(s0)
    80002ffa:	cf85                	beqz	a5,80003032 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ffc:	00015997          	auipc	s3,0x15
    80003000:	3ec98993          	addi	s3,s3,1004 # 800183e8 <tickslock>
    80003004:	00006497          	auipc	s1,0x6
    80003008:	01c48493          	addi	s1,s1,28 # 80009020 <ticks>
    if(myproc()->killed){
    8000300c:	fffff097          	auipc	ra,0xfffff
    80003010:	d36080e7          	jalr	-714(ra) # 80001d42 <myproc>
    80003014:	5d1c                	lw	a5,56(a0)
    80003016:	ef9d                	bnez	a5,80003054 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003018:	85ce                	mv	a1,s3
    8000301a:	8526                	mv	a0,s1
    8000301c:	fffff097          	auipc	ra,0xfffff
    80003020:	53a080e7          	jalr	1338(ra) # 80002556 <sleep>
  while(ticks - ticks0 < n){
    80003024:	409c                	lw	a5,0(s1)
    80003026:	412787bb          	subw	a5,a5,s2
    8000302a:	fcc42703          	lw	a4,-52(s0)
    8000302e:	fce7efe3          	bltu	a5,a4,8000300c <sys_sleep+0x50>
  }
  release(&tickslock);
    80003032:	00015517          	auipc	a0,0x15
    80003036:	3b650513          	addi	a0,a0,950 # 800183e8 <tickslock>
    8000303a:	ffffe097          	auipc	ra,0xffffe
    8000303e:	d92080e7          	jalr	-622(ra) # 80000dcc <release>
  return 0;
    80003042:	4781                	li	a5,0
}
    80003044:	853e                	mv	a0,a5
    80003046:	70e2                	ld	ra,56(sp)
    80003048:	7442                	ld	s0,48(sp)
    8000304a:	74a2                	ld	s1,40(sp)
    8000304c:	7902                	ld	s2,32(sp)
    8000304e:	69e2                	ld	s3,24(sp)
    80003050:	6121                	addi	sp,sp,64
    80003052:	8082                	ret
      release(&tickslock);
    80003054:	00015517          	auipc	a0,0x15
    80003058:	39450513          	addi	a0,a0,916 # 800183e8 <tickslock>
    8000305c:	ffffe097          	auipc	ra,0xffffe
    80003060:	d70080e7          	jalr	-656(ra) # 80000dcc <release>
      return -1;
    80003064:	57fd                	li	a5,-1
    80003066:	bff9                	j	80003044 <sys_sleep+0x88>

0000000080003068 <sys_kill>:

uint64
sys_kill(void)
{
    80003068:	1101                	addi	sp,sp,-32
    8000306a:	ec06                	sd	ra,24(sp)
    8000306c:	e822                	sd	s0,16(sp)
    8000306e:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003070:	fec40593          	addi	a1,s0,-20
    80003074:	4501                	li	a0,0
    80003076:	00000097          	auipc	ra,0x0
    8000307a:	d86080e7          	jalr	-634(ra) # 80002dfc <argint>
    8000307e:	87aa                	mv	a5,a0
    return -1;
    80003080:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003082:	0007c863          	bltz	a5,80003092 <sys_kill+0x2a>
  return kill(pid);
    80003086:	fec42503          	lw	a0,-20(s0)
    8000308a:	fffff097          	auipc	ra,0xfffff
    8000308e:	6b6080e7          	jalr	1718(ra) # 80002740 <kill>
}
    80003092:	60e2                	ld	ra,24(sp)
    80003094:	6442                	ld	s0,16(sp)
    80003096:	6105                	addi	sp,sp,32
    80003098:	8082                	ret

000000008000309a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000309a:	1101                	addi	sp,sp,-32
    8000309c:	ec06                	sd	ra,24(sp)
    8000309e:	e822                	sd	s0,16(sp)
    800030a0:	e426                	sd	s1,8(sp)
    800030a2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030a4:	00015517          	auipc	a0,0x15
    800030a8:	34450513          	addi	a0,a0,836 # 800183e8 <tickslock>
    800030ac:	ffffe097          	auipc	ra,0xffffe
    800030b0:	c50080e7          	jalr	-944(ra) # 80000cfc <acquire>
  xticks = ticks;
    800030b4:	00006497          	auipc	s1,0x6
    800030b8:	f6c4a483          	lw	s1,-148(s1) # 80009020 <ticks>
  release(&tickslock);
    800030bc:	00015517          	auipc	a0,0x15
    800030c0:	32c50513          	addi	a0,a0,812 # 800183e8 <tickslock>
    800030c4:	ffffe097          	auipc	ra,0xffffe
    800030c8:	d08080e7          	jalr	-760(ra) # 80000dcc <release>
  return xticks;
}
    800030cc:	02049513          	slli	a0,s1,0x20
    800030d0:	9101                	srli	a0,a0,0x20
    800030d2:	60e2                	ld	ra,24(sp)
    800030d4:	6442                	ld	s0,16(sp)
    800030d6:	64a2                	ld	s1,8(sp)
    800030d8:	6105                	addi	sp,sp,32
    800030da:	8082                	ret

00000000800030dc <hash>:
} bcache;


int
hash(uint blockno)
{
    800030dc:	1141                	addi	sp,sp,-16
    800030de:	e422                	sd	s0,8(sp)
    800030e0:	0800                	addi	s0,sp,16
  return blockno % NBUCKET;
}
    800030e2:	47b5                	li	a5,13
    800030e4:	02f5753b          	remuw	a0,a0,a5
    800030e8:	6422                	ld	s0,8(sp)
    800030ea:	0141                	addi	sp,sp,16
    800030ec:	8082                	ret

00000000800030ee <binit>:

void
binit(void)
{
    800030ee:	711d                	addi	sp,sp,-96
    800030f0:	ec86                	sd	ra,88(sp)
    800030f2:	e8a2                	sd	s0,80(sp)
    800030f4:	e4a6                	sd	s1,72(sp)
    800030f6:	e0ca                	sd	s2,64(sp)
    800030f8:	fc4e                	sd	s3,56(sp)
    800030fa:	f852                	sd	s4,48(sp)
    800030fc:	f456                	sd	s5,40(sp)
    800030fe:	f05a                	sd	s6,32(sp)
    80003100:	ec5e                	sd	s7,24(sp)
    80003102:	e862                	sd	s8,16(sp)
    80003104:	e466                	sd	s9,8(sp)
    80003106:	1080                	addi	s0,sp,96
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003108:	00005597          	auipc	a1,0x5
    8000310c:	ff858593          	addi	a1,a1,-8 # 80008100 <digits+0xc0>
    80003110:	00015517          	auipc	a0,0x15
    80003114:	2f850513          	addi	a0,a0,760 # 80018408 <bcache>
    80003118:	ffffe097          	auipc	ra,0xffffe
    8000311c:	d60080e7          	jalr	-672(ra) # 80000e78 <initlock>
  for(int i = 0; i < NBUCKET; i++) {
    80003120:	00021497          	auipc	s1,0x21
    80003124:	4e848493          	addi	s1,s1,1256 # 80024608 <bcache+0xc200>
    80003128:	00021997          	auipc	s3,0x21
    8000312c:	68098993          	addi	s3,s3,1664 # 800247a8 <sb>
    initlock(&bcache.bucket_lock[i], "bcache.bucket");
    80003130:	00005917          	auipc	s2,0x5
    80003134:	44090913          	addi	s2,s2,1088 # 80008570 <syscalls+0xb0>
    80003138:	85ca                	mv	a1,s2
    8000313a:	8526                	mv	a0,s1
    8000313c:	ffffe097          	auipc	ra,0xffffe
    80003140:	d3c080e7          	jalr	-708(ra) # 80000e78 <initlock>
  for(int i = 0; i < NBUCKET; i++) {
    80003144:	02048493          	addi	s1,s1,32
    80003148:	ff3498e3          	bne	s1,s3,80003138 <binit+0x4a>
    8000314c:	0001e797          	auipc	a5,0x1e
    80003150:	b7478793          	addi	a5,a5,-1164 # 80020cc0 <bcache+0x88b8>
    80003154:	00015717          	auipc	a4,0x15
    80003158:	2b470713          	addi	a4,a4,692 # 80018408 <bcache>
    8000315c:	66b1                	lui	a3,0xc
    8000315e:	20068693          	addi	a3,a3,512 # c200 <_entry-0x7fff3e00>
    80003162:	9736                	add	a4,a4,a3
  }

  for(int i = 0; i < NBUCKET; i++) {
    bcache.bucket[i].next = &bcache.bucket[i];
    80003164:	efbc                	sd	a5,88(a5)
    bcache.bucket[i].prev = &bcache.bucket[i];
    80003166:	ebbc                	sd	a5,80(a5)
  for(int i = 0; i < NBUCKET; i++) {
    80003168:	46878793          	addi	a5,a5,1128
    8000316c:	fee79ce3          	bne	a5,a4,80003164 <binit+0x76>
  }
  
  // Create hash table of buffers
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003170:	00015497          	auipc	s1,0x15
    80003174:	2b848493          	addi	s1,s1,696 # 80018428 <bcache+0x20>
  return blockno % NBUCKET;
    80003178:	4cb5                	li	s9,13
    int i = hash(b->blockno);
    b->next = bcache.bucket[i].next;
    8000317a:	00015917          	auipc	s2,0x15
    8000317e:	28e90913          	addi	s2,s2,654 # 80018408 <bcache>
    80003182:	46800c13          	li	s8,1128
    80003186:	69a5                	lui	s3,0x9
    b->prev = &bcache.bucket[i];
    80003188:	8b898b93          	addi	s7,s3,-1864 # 88b8 <_entry-0x7fff7748>

    bcache.bucket[i].next->prev = b;
    bcache.bucket[i].next = b;
    b->ticks = ticks;
    8000318c:	00006b17          	auipc	s6,0x6
    80003190:	e94b0b13          	addi	s6,s6,-364 # 80009020 <ticks>
    initsleeplock(&b->lock, "buffer");
    80003194:	00005a97          	auipc	s5,0x5
    80003198:	3eca8a93          	addi	s5,s5,1004 # 80008580 <syscalls+0xc0>
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000319c:	0001da17          	auipc	s4,0x1d
    800031a0:	6bca0a13          	addi	s4,s4,1724 # 80020858 <bcache+0x8450>
  return blockno % NBUCKET;
    800031a4:	44dc                	lw	a5,12(s1)
    800031a6:	0397f7bb          	remuw	a5,a5,s9
    b->next = bcache.bucket[i].next;
    800031aa:	038787b3          	mul	a5,a5,s8
    800031ae:	00f90733          	add	a4,s2,a5
    800031b2:	974e                	add	a4,a4,s3
    800031b4:	91073683          	ld	a3,-1776(a4)
    800031b8:	ecb4                	sd	a3,88(s1)
    b->prev = &bcache.bucket[i];
    800031ba:	97de                	add	a5,a5,s7
    800031bc:	97ca                	add	a5,a5,s2
    800031be:	e8bc                	sd	a5,80(s1)
    bcache.bucket[i].next->prev = b;
    800031c0:	91073783          	ld	a5,-1776(a4)
    800031c4:	eba4                	sd	s1,80(a5)
    bcache.bucket[i].next = b;
    800031c6:	90973823          	sd	s1,-1776(a4)
    b->ticks = ticks;
    800031ca:	000b2783          	lw	a5,0(s6)
    800031ce:	46f4a023          	sw	a5,1120(s1)
    initsleeplock(&b->lock, "buffer");
    800031d2:	85d6                	mv	a1,s5
    800031d4:	01048513          	addi	a0,s1,16
    800031d8:	00001097          	auipc	ra,0x1
    800031dc:	6ea080e7          	jalr	1770(ra) # 800048c2 <initsleeplock>
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031e0:	46848493          	addi	s1,s1,1128
    800031e4:	fd4490e3          	bne	s1,s4,800031a4 <binit+0xb6>
  }
}
    800031e8:	60e6                	ld	ra,88(sp)
    800031ea:	6446                	ld	s0,80(sp)
    800031ec:	64a6                	ld	s1,72(sp)
    800031ee:	6906                	ld	s2,64(sp)
    800031f0:	79e2                	ld	s3,56(sp)
    800031f2:	7a42                	ld	s4,48(sp)
    800031f4:	7aa2                	ld	s5,40(sp)
    800031f6:	7b02                	ld	s6,32(sp)
    800031f8:	6be2                	ld	s7,24(sp)
    800031fa:	6c42                	ld	s8,16(sp)
    800031fc:	6ca2                	ld	s9,8(sp)
    800031fe:	6125                	addi	sp,sp,96
    80003200:	8082                	ret

0000000080003202 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003202:	7175                	addi	sp,sp,-144
    80003204:	e506                	sd	ra,136(sp)
    80003206:	e122                	sd	s0,128(sp)
    80003208:	fca6                	sd	s1,120(sp)
    8000320a:	f8ca                	sd	s2,112(sp)
    8000320c:	f4ce                	sd	s3,104(sp)
    8000320e:	f0d2                	sd	s4,96(sp)
    80003210:	ecd6                	sd	s5,88(sp)
    80003212:	e8da                	sd	s6,80(sp)
    80003214:	e4de                	sd	s7,72(sp)
    80003216:	e0e2                	sd	s8,64(sp)
    80003218:	fc66                	sd	s9,56(sp)
    8000321a:	f86a                	sd	s10,48(sp)
    8000321c:	f46e                	sd	s11,40(sp)
    8000321e:	0900                	addi	s0,sp,144
    80003220:	8caa                	mv	s9,a0
    80003222:	8d2e                	mv	s10,a1
  return blockno % NBUCKET;
    80003224:	47b5                	li	a5,13
    80003226:	02f5f7bb          	remuw	a5,a1,a5
    8000322a:	0007849b          	sext.w	s1,a5
    8000322e:	f6943c23          	sd	s1,-136(s0)
  acquire(&bcache.bucket_lock[hi]);
    80003232:	6107879b          	addiw	a5,a5,1552
    80003236:	0796                	slli	a5,a5,0x5
    80003238:	00015b97          	auipc	s7,0x15
    8000323c:	1d0b8b93          	addi	s7,s7,464 # 80018408 <bcache>
    80003240:	97de                	add	a5,a5,s7
    80003242:	f8f43023          	sd	a5,-128(s0)
    80003246:	853e                	mv	a0,a5
    80003248:	ffffe097          	auipc	ra,0xffffe
    8000324c:	ab4080e7          	jalr	-1356(ra) # 80000cfc <acquire>
  for(b = bcache.bucket[hi].next; b != &bcache.bucket[hi]; b = b->next) {
    80003250:	46800793          	li	a5,1128
    80003254:	02f487b3          	mul	a5,s1,a5
    80003258:	00fb86b3          	add	a3,s7,a5
    8000325c:	6725                	lui	a4,0x9
    8000325e:	96ba                	add	a3,a3,a4
    80003260:	9106b903          	ld	s2,-1776(a3)
    80003264:	8b870713          	addi	a4,a4,-1864 # 88b8 <_entry-0x7fff7748>
    80003268:	97ba                	add	a5,a5,a4
    8000326a:	9bbe                	add	s7,s7,a5
    8000326c:	07791e63          	bne	s2,s7,800032e8 <bread+0xe6>
  release(&bcache.bucket_lock[hi]);
    80003270:	f8043483          	ld	s1,-128(s0)
    80003274:	8526                	mv	a0,s1
    80003276:	ffffe097          	auipc	ra,0xffffe
    8000327a:	b56080e7          	jalr	-1194(ra) # 80000dcc <release>
  acquire(&bcache.lock);
    8000327e:	00015517          	auipc	a0,0x15
    80003282:	18a50513          	addi	a0,a0,394 # 80018408 <bcache>
    80003286:	ffffe097          	auipc	ra,0xffffe
    8000328a:	a76080e7          	jalr	-1418(ra) # 80000cfc <acquire>
  acquire(&bcache.bucket_lock[hi]);
    8000328e:	8526                	mv	a0,s1
    80003290:	ffffe097          	auipc	ra,0xffffe
    80003294:	a6c080e7          	jalr	-1428(ra) # 80000cfc <acquire>
  for(b = bcache.bucket[hi].next; b != &bcache.bucket[hi]; b = b->next) {
    80003298:	46800713          	li	a4,1128
    8000329c:	f7843783          	ld	a5,-136(s0)
    800032a0:	02e78733          	mul	a4,a5,a4
    800032a4:	00015797          	auipc	a5,0x15
    800032a8:	16478793          	addi	a5,a5,356 # 80018408 <bcache>
    800032ac:	973e                	add	a4,a4,a5
    800032ae:	67a5                	lui	a5,0x9
    800032b0:	97ba                	add	a5,a5,a4
    800032b2:	9107b903          	ld	s2,-1776(a5) # 8910 <_entry-0x7fff76f0>
    800032b6:	07791763          	bne	s2,s7,80003324 <bread+0x122>
  release(&bcache.bucket_lock[hi]);
    800032ba:	f8043503          	ld	a0,-128(s0)
    800032be:	ffffe097          	auipc	ra,0xffffe
    800032c2:	b0e080e7          	jalr	-1266(ra) # 80000dcc <release>
  for(int i = 0; i < NBUCKET; i++) {
    800032c6:	00021c17          	auipc	s8,0x21
    800032ca:	342c0c13          	addi	s8,s8,834 # 80024608 <bcache+0xc200>
    800032ce:	0001ea97          	auipc	s5,0x1e
    800032d2:	9f2a8a93          	addi	s5,s5,-1550 # 80020cc0 <bcache+0x88b8>
  uint min_ticks = ~0;
    800032d6:	5a7d                	li	s4,-1
  struct buf *minb = 0;
    800032d8:	4901                	li	s2,0
  for(int i = 0; i < NBUCKET; i++) {
    800032da:	4b01                	li	s6,0
  return blockno % NBUCKET;
    800032dc:	4db5                	li	s11,13
    800032de:	a0d5                	j	800033c2 <bread+0x1c0>
  for(b = bcache.bucket[hi].next; b != &bcache.bucket[hi]; b = b->next) {
    800032e0:	05893903          	ld	s2,88(s2)
    800032e4:	f97906e3          	beq	s2,s7,80003270 <bread+0x6e>
    if(b->dev == dev && b->blockno == blockno) {
    800032e8:	00892783          	lw	a5,8(s2)
    800032ec:	ff979ae3          	bne	a5,s9,800032e0 <bread+0xde>
    800032f0:	00c92783          	lw	a5,12(s2)
    800032f4:	ffa796e3          	bne	a5,s10,800032e0 <bread+0xde>
      b->refcnt++;
    800032f8:	04892783          	lw	a5,72(s2)
    800032fc:	2785                	addiw	a5,a5,1
    800032fe:	04f92423          	sw	a5,72(s2)
      release(&bcache.bucket_lock[hi]);
    80003302:	f8043503          	ld	a0,-128(s0)
    80003306:	ffffe097          	auipc	ra,0xffffe
    8000330a:	ac6080e7          	jalr	-1338(ra) # 80000dcc <release>
      acquiresleep(&b->lock);
    8000330e:	01090513          	addi	a0,s2,16
    80003312:	00001097          	auipc	ra,0x1
    80003316:	5ea080e7          	jalr	1514(ra) # 800048fc <acquiresleep>
      return b;
    8000331a:	a259                	j	800034a0 <bread+0x29e>
  for(b = bcache.bucket[hi].next; b != &bcache.bucket[hi]; b = b->next) {
    8000331c:	05893903          	ld	s2,88(s2)
    80003320:	f9790de3          	beq	s2,s7,800032ba <bread+0xb8>
    if(b->dev == dev && b->blockno == blockno) {
    80003324:	00892783          	lw	a5,8(s2)
    80003328:	ff979ae3          	bne	a5,s9,8000331c <bread+0x11a>
    8000332c:	00c92783          	lw	a5,12(s2)
    80003330:	ffa796e3          	bne	a5,s10,8000331c <bread+0x11a>
      b->refcnt++;
    80003334:	04892783          	lw	a5,72(s2)
    80003338:	2785                	addiw	a5,a5,1
    8000333a:	04f92423          	sw	a5,72(s2)
      release(&bcache.bucket_lock[hi]);
    8000333e:	f8043503          	ld	a0,-128(s0)
    80003342:	ffffe097          	auipc	ra,0xffffe
    80003346:	a8a080e7          	jalr	-1398(ra) # 80000dcc <release>
      release(&bcache.lock);
    8000334a:	00015517          	auipc	a0,0x15
    8000334e:	0be50513          	addi	a0,a0,190 # 80018408 <bcache>
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	a7a080e7          	jalr	-1414(ra) # 80000dcc <release>
      acquiresleep(&b->lock);
    8000335a:	01090513          	addi	a0,s2,16
    8000335e:	00001097          	auipc	ra,0x1
    80003362:	59e080e7          	jalr	1438(ra) # 800048fc <acquiresleep>
      return b;
    80003366:	aa2d                	j	800034a0 <bread+0x29e>
        min_ticks = b->ticks;
    80003368:	4604aa03          	lw	s4,1120(s1)
    8000336c:	8926                	mv	s2,s1
        find = 1;
    8000336e:	4705                	li	a4,1
    for(b = bcache.bucket[i].next; b != &bcache.bucket[i]; b = b->next) {
    80003370:	6ca4                	ld	s1,88(s1)
    80003372:	03348f63          	beq	s1,s3,800033b0 <bread+0x1ae>
      if(b->refcnt == 0 && b->ticks < min_ticks) {
    80003376:	44bc                	lw	a5,72(s1)
    80003378:	ffe5                	bnez	a5,80003370 <bread+0x16e>
    8000337a:	4604a783          	lw	a5,1120(s1)
    8000337e:	ff47f9e3          	bgeu	a5,s4,80003370 <bread+0x16e>
        if(minb != 0) {
    80003382:	fe0903e3          	beqz	s2,80003368 <bread+0x166>
  return blockno % NBUCKET;
    80003386:	00c92503          	lw	a0,12(s2)
    8000338a:	03b5753b          	remuw	a0,a0,s11
    8000338e:	0005079b          	sext.w	a5,a0
          if(last != i)
    80003392:	fd678be3          	beq	a5,s6,80003368 <bread+0x166>
            release(&bcache.bucket_lock[last]);
    80003396:	6105051b          	addiw	a0,a0,1552
    8000339a:	0516                	slli	a0,a0,0x5
    8000339c:	00015797          	auipc	a5,0x15
    800033a0:	06c78793          	addi	a5,a5,108 # 80018408 <bcache>
    800033a4:	953e                	add	a0,a0,a5
    800033a6:	ffffe097          	auipc	ra,0xffffe
    800033aa:	a26080e7          	jalr	-1498(ra) # 80000dcc <release>
    800033ae:	bf6d                	j	80003368 <bread+0x166>
    if(!find)
    800033b0:	c71d                	beqz	a4,800033de <bread+0x1dc>
  for(int i = 0; i < NBUCKET; i++) {
    800033b2:	2b05                	addiw	s6,s6,1
    800033b4:	020c0c13          	addi	s8,s8,32
    800033b8:	468a8a93          	addi	s5,s5,1128
    800033bc:	47b5                	li	a5,13
    800033be:	02fb0763          	beq	s6,a5,800033ec <bread+0x1ea>
    acquire(&bcache.bucket_lock[i]);
    800033c2:	f9843423          	sd	s8,-120(s0)
    800033c6:	8562                	mv	a0,s8
    800033c8:	ffffe097          	auipc	ra,0xffffe
    800033cc:	934080e7          	jalr	-1740(ra) # 80000cfc <acquire>
    for(b = bcache.bucket[i].next; b != &bcache.bucket[i]; b = b->next) {
    800033d0:	89d6                	mv	s3,s5
    800033d2:	058ab483          	ld	s1,88(s5)
    800033d6:	01548463          	beq	s1,s5,800033de <bread+0x1dc>
    int find = 0;
    800033da:	4701                	li	a4,0
    800033dc:	bf69                	j	80003376 <bread+0x174>
      release(&bcache.bucket_lock[i]);
    800033de:	f8843503          	ld	a0,-120(s0)
    800033e2:	ffffe097          	auipc	ra,0xffffe
    800033e6:	9ea080e7          	jalr	-1558(ra) # 80000dcc <release>
    800033ea:	b7e1                	j	800033b2 <bread+0x1b0>
  if(minb == 0)
    800033ec:	0c090d63          	beqz	s2,800034c6 <bread+0x2c4>
  return blockno % NBUCKET;
    800033f0:	00c92783          	lw	a5,12(s2)
    800033f4:	4735                	li	a4,13
    800033f6:	02e7f7bb          	remuw	a5,a5,a4
    800033fa:	0007871b          	sext.w	a4,a5
  minb->dev = dev;
    800033fe:	01992423          	sw	s9,8(s2)
  minb->blockno = blockno;
    80003402:	01a92623          	sw	s10,12(s2)
  minb->valid = 0;
    80003406:	00092023          	sw	zero,0(s2)
  minb->refcnt = 1;
    8000340a:	4685                	li	a3,1
    8000340c:	04d92423          	sw	a3,72(s2)
  if (minb_i != hi) {
    80003410:	f7843983          	ld	s3,-136(s0)
    80003414:	0ce98b63          	beq	s3,a4,800034ea <bread+0x2e8>
    minb->prev->next = minb->next;
    80003418:	05093703          	ld	a4,80(s2)
    8000341c:	05893683          	ld	a3,88(s2)
    80003420:	ef34                	sd	a3,88(a4)
    minb->next->prev = minb->prev;
    80003422:	05893703          	ld	a4,88(s2)
    80003426:	05093683          	ld	a3,80(s2)
    8000342a:	eb34                	sd	a3,80(a4)
  release(&bcache.bucket_lock[minb_i]);
    8000342c:	6107879b          	addiw	a5,a5,1552
    80003430:	00579513          	slli	a0,a5,0x5
    80003434:	00015497          	auipc	s1,0x15
    80003438:	fd448493          	addi	s1,s1,-44 # 80018408 <bcache>
    8000343c:	9526                	add	a0,a0,s1
    8000343e:	ffffe097          	auipc	ra,0xffffe
    80003442:	98e080e7          	jalr	-1650(ra) # 80000dcc <release>
    acquire(&bcache.bucket_lock[hi]);
    80003446:	f8043a03          	ld	s4,-128(s0)
    8000344a:	8552                	mv	a0,s4
    8000344c:	ffffe097          	auipc	ra,0xffffe
    80003450:	8b0080e7          	jalr	-1872(ra) # 80000cfc <acquire>
    minb->next = bcache.bucket[hi].next;
    80003454:	46800793          	li	a5,1128
    80003458:	02f987b3          	mul	a5,s3,a5
    8000345c:	94be                	add	s1,s1,a5
    8000345e:	67a5                	lui	a5,0x9
    80003460:	97a6                	add	a5,a5,s1
    80003462:	9107b703          	ld	a4,-1776(a5) # 8910 <_entry-0x7fff76f0>
    80003466:	04e93c23          	sd	a4,88(s2)
    minb->prev = &bcache.bucket[hi];
    8000346a:	05793823          	sd	s7,80(s2)
    bcache.bucket[hi].next->prev = minb;
    8000346e:	9107b703          	ld	a4,-1776(a5)
    80003472:	05273823          	sd	s2,80(a4)
    bcache.bucket[hi].next = minb;
    80003476:	9127b823          	sd	s2,-1776(a5)
    release(&bcache.bucket_lock[hi]);
    8000347a:	8552                	mv	a0,s4
    8000347c:	ffffe097          	auipc	ra,0xffffe
    80003480:	950080e7          	jalr	-1712(ra) # 80000dcc <release>
  release(&bcache.lock);
    80003484:	00015517          	auipc	a0,0x15
    80003488:	f8450513          	addi	a0,a0,-124 # 80018408 <bcache>
    8000348c:	ffffe097          	auipc	ra,0xffffe
    80003490:	940080e7          	jalr	-1728(ra) # 80000dcc <release>
  acquiresleep(&minb->lock);
    80003494:	01090513          	addi	a0,s2,16
    80003498:	00001097          	auipc	ra,0x1
    8000349c:	464080e7          	jalr	1124(ra) # 800048fc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034a0:	00092783          	lw	a5,0(s2)
    800034a4:	cb8d                	beqz	a5,800034d6 <bread+0x2d4>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034a6:	854a                	mv	a0,s2
    800034a8:	60aa                	ld	ra,136(sp)
    800034aa:	640a                	ld	s0,128(sp)
    800034ac:	74e6                	ld	s1,120(sp)
    800034ae:	7946                	ld	s2,112(sp)
    800034b0:	79a6                	ld	s3,104(sp)
    800034b2:	7a06                	ld	s4,96(sp)
    800034b4:	6ae6                	ld	s5,88(sp)
    800034b6:	6b46                	ld	s6,80(sp)
    800034b8:	6ba6                	ld	s7,72(sp)
    800034ba:	6c06                	ld	s8,64(sp)
    800034bc:	7ce2                	ld	s9,56(sp)
    800034be:	7d42                	ld	s10,48(sp)
    800034c0:	7da2                	ld	s11,40(sp)
    800034c2:	6149                	addi	sp,sp,144
    800034c4:	8082                	ret
    panic("bget: no buffers");
    800034c6:	00005517          	auipc	a0,0x5
    800034ca:	0c250513          	addi	a0,a0,194 # 80008588 <syscalls+0xc8>
    800034ce:	ffffd097          	auipc	ra,0xffffd
    800034d2:	07c080e7          	jalr	124(ra) # 8000054a <panic>
    virtio_disk_rw(b, 0);
    800034d6:	4581                	li	a1,0
    800034d8:	854a                	mv	a0,s2
    800034da:	00003097          	auipc	ra,0x3
    800034de:	f8c080e7          	jalr	-116(ra) # 80006466 <virtio_disk_rw>
    b->valid = 1;
    800034e2:	4785                	li	a5,1
    800034e4:	00f92023          	sw	a5,0(s2)
  return b;
    800034e8:	bf7d                	j	800034a6 <bread+0x2a4>
  release(&bcache.bucket_lock[minb_i]);
    800034ea:	6107879b          	addiw	a5,a5,1552
    800034ee:	0796                	slli	a5,a5,0x5
    800034f0:	00015517          	auipc	a0,0x15
    800034f4:	f1850513          	addi	a0,a0,-232 # 80018408 <bcache>
    800034f8:	953e                	add	a0,a0,a5
    800034fa:	ffffe097          	auipc	ra,0xffffe
    800034fe:	8d2080e7          	jalr	-1838(ra) # 80000dcc <release>
  if(minb_i != hi) {
    80003502:	b749                	j	80003484 <bread+0x282>

0000000080003504 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003504:	1101                	addi	sp,sp,-32
    80003506:	ec06                	sd	ra,24(sp)
    80003508:	e822                	sd	s0,16(sp)
    8000350a:	e426                	sd	s1,8(sp)
    8000350c:	1000                	addi	s0,sp,32
    8000350e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003510:	0541                	addi	a0,a0,16
    80003512:	00001097          	auipc	ra,0x1
    80003516:	484080e7          	jalr	1156(ra) # 80004996 <holdingsleep>
    8000351a:	cd01                	beqz	a0,80003532 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000351c:	4585                	li	a1,1
    8000351e:	8526                	mv	a0,s1
    80003520:	00003097          	auipc	ra,0x3
    80003524:	f46080e7          	jalr	-186(ra) # 80006466 <virtio_disk_rw>
}
    80003528:	60e2                	ld	ra,24(sp)
    8000352a:	6442                	ld	s0,16(sp)
    8000352c:	64a2                	ld	s1,8(sp)
    8000352e:	6105                	addi	sp,sp,32
    80003530:	8082                	ret
    panic("bwrite");
    80003532:	00005517          	auipc	a0,0x5
    80003536:	06e50513          	addi	a0,a0,110 # 800085a0 <syscalls+0xe0>
    8000353a:	ffffd097          	auipc	ra,0xffffd
    8000353e:	010080e7          	jalr	16(ra) # 8000054a <panic>

0000000080003542 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003542:	1101                	addi	sp,sp,-32
    80003544:	ec06                	sd	ra,24(sp)
    80003546:	e822                	sd	s0,16(sp)
    80003548:	e426                	sd	s1,8(sp)
    8000354a:	e04a                	sd	s2,0(sp)
    8000354c:	1000                	addi	s0,sp,32
    8000354e:	892a                	mv	s2,a0
  if(!holdingsleep(&b->lock))
    80003550:	01050493          	addi	s1,a0,16
    80003554:	8526                	mv	a0,s1
    80003556:	00001097          	auipc	ra,0x1
    8000355a:	440080e7          	jalr	1088(ra) # 80004996 <holdingsleep>
    8000355e:	c12d                	beqz	a0,800035c0 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80003560:	8526                	mv	a0,s1
    80003562:	00001097          	auipc	ra,0x1
    80003566:	3f0080e7          	jalr	1008(ra) # 80004952 <releasesleep>
  return blockno % NBUCKET;
    8000356a:	00c92483          	lw	s1,12(s2)
    8000356e:	47b5                	li	a5,13
    80003570:	02f4f4bb          	remuw	s1,s1,a5

  int hi = hash(b->blockno);
  acquire(&bcache.bucket_lock[hi]);
    80003574:	6104849b          	addiw	s1,s1,1552
    80003578:	0496                	slli	s1,s1,0x5
    8000357a:	00015797          	auipc	a5,0x15
    8000357e:	e8e78793          	addi	a5,a5,-370 # 80018408 <bcache>
    80003582:	94be                	add	s1,s1,a5
    80003584:	8526                	mv	a0,s1
    80003586:	ffffd097          	auipc	ra,0xffffd
    8000358a:	776080e7          	jalr	1910(ra) # 80000cfc <acquire>
  b->refcnt--;
    8000358e:	04892783          	lw	a5,72(s2)
    80003592:	37fd                	addiw	a5,a5,-1
    80003594:	0007871b          	sext.w	a4,a5
    80003598:	04f92423          	sw	a5,72(s2)
  if (b->refcnt == 0) {
    8000359c:	e719                	bnez	a4,800035aa <brelse+0x68>
    b->ticks = ticks;
    8000359e:	00006797          	auipc	a5,0x6
    800035a2:	a827a783          	lw	a5,-1406(a5) # 80009020 <ticks>
    800035a6:	46f92023          	sw	a5,1120(s2)
  }
  release(&bcache.bucket_lock[hi]);
    800035aa:	8526                	mv	a0,s1
    800035ac:	ffffe097          	auipc	ra,0xffffe
    800035b0:	820080e7          	jalr	-2016(ra) # 80000dcc <release>
}
    800035b4:	60e2                	ld	ra,24(sp)
    800035b6:	6442                	ld	s0,16(sp)
    800035b8:	64a2                	ld	s1,8(sp)
    800035ba:	6902                	ld	s2,0(sp)
    800035bc:	6105                	addi	sp,sp,32
    800035be:	8082                	ret
    panic("brelse");
    800035c0:	00005517          	auipc	a0,0x5
    800035c4:	fe850513          	addi	a0,a0,-24 # 800085a8 <syscalls+0xe8>
    800035c8:	ffffd097          	auipc	ra,0xffffd
    800035cc:	f82080e7          	jalr	-126(ra) # 8000054a <panic>

00000000800035d0 <bpin>:

void
bpin(struct buf *b) {
    800035d0:	1101                	addi	sp,sp,-32
    800035d2:	ec06                	sd	ra,24(sp)
    800035d4:	e822                	sd	s0,16(sp)
    800035d6:	e426                	sd	s1,8(sp)
    800035d8:	e04a                	sd	s2,0(sp)
    800035da:	1000                	addi	s0,sp,32
    800035dc:	892a                	mv	s2,a0
  return blockno % NBUCKET;
    800035de:	4544                	lw	s1,12(a0)
    800035e0:	47b5                	li	a5,13
    800035e2:	02f4f4bb          	remuw	s1,s1,a5
  int hi = hash(b->blockno);
  acquire(&bcache.bucket_lock[hi]);
    800035e6:	6104849b          	addiw	s1,s1,1552
    800035ea:	0496                	slli	s1,s1,0x5
    800035ec:	00015797          	auipc	a5,0x15
    800035f0:	e1c78793          	addi	a5,a5,-484 # 80018408 <bcache>
    800035f4:	94be                	add	s1,s1,a5
    800035f6:	8526                	mv	a0,s1
    800035f8:	ffffd097          	auipc	ra,0xffffd
    800035fc:	704080e7          	jalr	1796(ra) # 80000cfc <acquire>
  b->refcnt++;
    80003600:	04892783          	lw	a5,72(s2)
    80003604:	2785                	addiw	a5,a5,1
    80003606:	04f92423          	sw	a5,72(s2)
  release(&bcache.bucket_lock[hi]);
    8000360a:	8526                	mv	a0,s1
    8000360c:	ffffd097          	auipc	ra,0xffffd
    80003610:	7c0080e7          	jalr	1984(ra) # 80000dcc <release>
}
    80003614:	60e2                	ld	ra,24(sp)
    80003616:	6442                	ld	s0,16(sp)
    80003618:	64a2                	ld	s1,8(sp)
    8000361a:	6902                	ld	s2,0(sp)
    8000361c:	6105                	addi	sp,sp,32
    8000361e:	8082                	ret

0000000080003620 <bunpin>:

void
bunpin(struct buf *b) {
    80003620:	1101                	addi	sp,sp,-32
    80003622:	ec06                	sd	ra,24(sp)
    80003624:	e822                	sd	s0,16(sp)
    80003626:	e426                	sd	s1,8(sp)
    80003628:	e04a                	sd	s2,0(sp)
    8000362a:	1000                	addi	s0,sp,32
    8000362c:	892a                	mv	s2,a0
  return blockno % NBUCKET;
    8000362e:	4544                	lw	s1,12(a0)
    80003630:	47b5                	li	a5,13
    80003632:	02f4f4bb          	remuw	s1,s1,a5
  int hi = hash(b->blockno);
  acquire(&bcache.bucket_lock[hi]);
    80003636:	6104849b          	addiw	s1,s1,1552
    8000363a:	0496                	slli	s1,s1,0x5
    8000363c:	00015797          	auipc	a5,0x15
    80003640:	dcc78793          	addi	a5,a5,-564 # 80018408 <bcache>
    80003644:	94be                	add	s1,s1,a5
    80003646:	8526                	mv	a0,s1
    80003648:	ffffd097          	auipc	ra,0xffffd
    8000364c:	6b4080e7          	jalr	1716(ra) # 80000cfc <acquire>
  b->refcnt--;
    80003650:	04892783          	lw	a5,72(s2)
    80003654:	37fd                	addiw	a5,a5,-1
    80003656:	04f92423          	sw	a5,72(s2)
  release(&bcache.bucket_lock[hi]);
    8000365a:	8526                	mv	a0,s1
    8000365c:	ffffd097          	auipc	ra,0xffffd
    80003660:	770080e7          	jalr	1904(ra) # 80000dcc <release>
}
    80003664:	60e2                	ld	ra,24(sp)
    80003666:	6442                	ld	s0,16(sp)
    80003668:	64a2                	ld	s1,8(sp)
    8000366a:	6902                	ld	s2,0(sp)
    8000366c:	6105                	addi	sp,sp,32
    8000366e:	8082                	ret

0000000080003670 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003670:	1101                	addi	sp,sp,-32
    80003672:	ec06                	sd	ra,24(sp)
    80003674:	e822                	sd	s0,16(sp)
    80003676:	e426                	sd	s1,8(sp)
    80003678:	e04a                	sd	s2,0(sp)
    8000367a:	1000                	addi	s0,sp,32
    8000367c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000367e:	00d5d59b          	srliw	a1,a1,0xd
    80003682:	00021797          	auipc	a5,0x21
    80003686:	1427a783          	lw	a5,322(a5) # 800247c4 <sb+0x1c>
    8000368a:	9dbd                	addw	a1,a1,a5
    8000368c:	00000097          	auipc	ra,0x0
    80003690:	b76080e7          	jalr	-1162(ra) # 80003202 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003694:	0074f713          	andi	a4,s1,7
    80003698:	4785                	li	a5,1
    8000369a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000369e:	14ce                	slli	s1,s1,0x33
    800036a0:	90d9                	srli	s1,s1,0x36
    800036a2:	00950733          	add	a4,a0,s1
    800036a6:	06074703          	lbu	a4,96(a4)
    800036aa:	00e7f6b3          	and	a3,a5,a4
    800036ae:	c69d                	beqz	a3,800036dc <bfree+0x6c>
    800036b0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036b2:	94aa                	add	s1,s1,a0
    800036b4:	fff7c793          	not	a5,a5
    800036b8:	8ff9                	and	a5,a5,a4
    800036ba:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    800036be:	00001097          	auipc	ra,0x1
    800036c2:	116080e7          	jalr	278(ra) # 800047d4 <log_write>
  brelse(bp);
    800036c6:	854a                	mv	a0,s2
    800036c8:	00000097          	auipc	ra,0x0
    800036cc:	e7a080e7          	jalr	-390(ra) # 80003542 <brelse>
}
    800036d0:	60e2                	ld	ra,24(sp)
    800036d2:	6442                	ld	s0,16(sp)
    800036d4:	64a2                	ld	s1,8(sp)
    800036d6:	6902                	ld	s2,0(sp)
    800036d8:	6105                	addi	sp,sp,32
    800036da:	8082                	ret
    panic("freeing free block");
    800036dc:	00005517          	auipc	a0,0x5
    800036e0:	ed450513          	addi	a0,a0,-300 # 800085b0 <syscalls+0xf0>
    800036e4:	ffffd097          	auipc	ra,0xffffd
    800036e8:	e66080e7          	jalr	-410(ra) # 8000054a <panic>

00000000800036ec <balloc>:
{
    800036ec:	711d                	addi	sp,sp,-96
    800036ee:	ec86                	sd	ra,88(sp)
    800036f0:	e8a2                	sd	s0,80(sp)
    800036f2:	e4a6                	sd	s1,72(sp)
    800036f4:	e0ca                	sd	s2,64(sp)
    800036f6:	fc4e                	sd	s3,56(sp)
    800036f8:	f852                	sd	s4,48(sp)
    800036fa:	f456                	sd	s5,40(sp)
    800036fc:	f05a                	sd	s6,32(sp)
    800036fe:	ec5e                	sd	s7,24(sp)
    80003700:	e862                	sd	s8,16(sp)
    80003702:	e466                	sd	s9,8(sp)
    80003704:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003706:	00021797          	auipc	a5,0x21
    8000370a:	0a67a783          	lw	a5,166(a5) # 800247ac <sb+0x4>
    8000370e:	cbd1                	beqz	a5,800037a2 <balloc+0xb6>
    80003710:	8baa                	mv	s7,a0
    80003712:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003714:	00021b17          	auipc	s6,0x21
    80003718:	094b0b13          	addi	s6,s6,148 # 800247a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000371c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000371e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003720:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003722:	6c89                	lui	s9,0x2
    80003724:	a831                	j	80003740 <balloc+0x54>
    brelse(bp);
    80003726:	854a                	mv	a0,s2
    80003728:	00000097          	auipc	ra,0x0
    8000372c:	e1a080e7          	jalr	-486(ra) # 80003542 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003730:	015c87bb          	addw	a5,s9,s5
    80003734:	00078a9b          	sext.w	s5,a5
    80003738:	004b2703          	lw	a4,4(s6)
    8000373c:	06eaf363          	bgeu	s5,a4,800037a2 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003740:	41fad79b          	sraiw	a5,s5,0x1f
    80003744:	0137d79b          	srliw	a5,a5,0x13
    80003748:	015787bb          	addw	a5,a5,s5
    8000374c:	40d7d79b          	sraiw	a5,a5,0xd
    80003750:	01cb2583          	lw	a1,28(s6)
    80003754:	9dbd                	addw	a1,a1,a5
    80003756:	855e                	mv	a0,s7
    80003758:	00000097          	auipc	ra,0x0
    8000375c:	aaa080e7          	jalr	-1366(ra) # 80003202 <bread>
    80003760:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003762:	004b2503          	lw	a0,4(s6)
    80003766:	000a849b          	sext.w	s1,s5
    8000376a:	8662                	mv	a2,s8
    8000376c:	faa4fde3          	bgeu	s1,a0,80003726 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003770:	41f6579b          	sraiw	a5,a2,0x1f
    80003774:	01d7d69b          	srliw	a3,a5,0x1d
    80003778:	00c6873b          	addw	a4,a3,a2
    8000377c:	00777793          	andi	a5,a4,7
    80003780:	9f95                	subw	a5,a5,a3
    80003782:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003786:	4037571b          	sraiw	a4,a4,0x3
    8000378a:	00e906b3          	add	a3,s2,a4
    8000378e:	0606c683          	lbu	a3,96(a3)
    80003792:	00d7f5b3          	and	a1,a5,a3
    80003796:	cd91                	beqz	a1,800037b2 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003798:	2605                	addiw	a2,a2,1
    8000379a:	2485                	addiw	s1,s1,1
    8000379c:	fd4618e3          	bne	a2,s4,8000376c <balloc+0x80>
    800037a0:	b759                	j	80003726 <balloc+0x3a>
  panic("balloc: out of blocks");
    800037a2:	00005517          	auipc	a0,0x5
    800037a6:	e2650513          	addi	a0,a0,-474 # 800085c8 <syscalls+0x108>
    800037aa:	ffffd097          	auipc	ra,0xffffd
    800037ae:	da0080e7          	jalr	-608(ra) # 8000054a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800037b2:	974a                	add	a4,a4,s2
    800037b4:	8fd5                	or	a5,a5,a3
    800037b6:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    800037ba:	854a                	mv	a0,s2
    800037bc:	00001097          	auipc	ra,0x1
    800037c0:	018080e7          	jalr	24(ra) # 800047d4 <log_write>
        brelse(bp);
    800037c4:	854a                	mv	a0,s2
    800037c6:	00000097          	auipc	ra,0x0
    800037ca:	d7c080e7          	jalr	-644(ra) # 80003542 <brelse>
  bp = bread(dev, bno);
    800037ce:	85a6                	mv	a1,s1
    800037d0:	855e                	mv	a0,s7
    800037d2:	00000097          	auipc	ra,0x0
    800037d6:	a30080e7          	jalr	-1488(ra) # 80003202 <bread>
    800037da:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800037dc:	40000613          	li	a2,1024
    800037e0:	4581                	li	a1,0
    800037e2:	06050513          	addi	a0,a0,96
    800037e6:	ffffe097          	auipc	ra,0xffffe
    800037ea:	8f6080e7          	jalr	-1802(ra) # 800010dc <memset>
  log_write(bp);
    800037ee:	854a                	mv	a0,s2
    800037f0:	00001097          	auipc	ra,0x1
    800037f4:	fe4080e7          	jalr	-28(ra) # 800047d4 <log_write>
  brelse(bp);
    800037f8:	854a                	mv	a0,s2
    800037fa:	00000097          	auipc	ra,0x0
    800037fe:	d48080e7          	jalr	-696(ra) # 80003542 <brelse>
}
    80003802:	8526                	mv	a0,s1
    80003804:	60e6                	ld	ra,88(sp)
    80003806:	6446                	ld	s0,80(sp)
    80003808:	64a6                	ld	s1,72(sp)
    8000380a:	6906                	ld	s2,64(sp)
    8000380c:	79e2                	ld	s3,56(sp)
    8000380e:	7a42                	ld	s4,48(sp)
    80003810:	7aa2                	ld	s5,40(sp)
    80003812:	7b02                	ld	s6,32(sp)
    80003814:	6be2                	ld	s7,24(sp)
    80003816:	6c42                	ld	s8,16(sp)
    80003818:	6ca2                	ld	s9,8(sp)
    8000381a:	6125                	addi	sp,sp,96
    8000381c:	8082                	ret

000000008000381e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000381e:	7179                	addi	sp,sp,-48
    80003820:	f406                	sd	ra,40(sp)
    80003822:	f022                	sd	s0,32(sp)
    80003824:	ec26                	sd	s1,24(sp)
    80003826:	e84a                	sd	s2,16(sp)
    80003828:	e44e                	sd	s3,8(sp)
    8000382a:	e052                	sd	s4,0(sp)
    8000382c:	1800                	addi	s0,sp,48
    8000382e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003830:	47ad                	li	a5,11
    80003832:	04b7fe63          	bgeu	a5,a1,8000388e <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003836:	ff45849b          	addiw	s1,a1,-12
    8000383a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000383e:	0ff00793          	li	a5,255
    80003842:	0ae7e363          	bltu	a5,a4,800038e8 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003846:	08852583          	lw	a1,136(a0)
    8000384a:	c5ad                	beqz	a1,800038b4 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000384c:	00092503          	lw	a0,0(s2)
    80003850:	00000097          	auipc	ra,0x0
    80003854:	9b2080e7          	jalr	-1614(ra) # 80003202 <bread>
    80003858:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000385a:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    8000385e:	02049593          	slli	a1,s1,0x20
    80003862:	9181                	srli	a1,a1,0x20
    80003864:	058a                	slli	a1,a1,0x2
    80003866:	00b784b3          	add	s1,a5,a1
    8000386a:	0004a983          	lw	s3,0(s1)
    8000386e:	04098d63          	beqz	s3,800038c8 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003872:	8552                	mv	a0,s4
    80003874:	00000097          	auipc	ra,0x0
    80003878:	cce080e7          	jalr	-818(ra) # 80003542 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000387c:	854e                	mv	a0,s3
    8000387e:	70a2                	ld	ra,40(sp)
    80003880:	7402                	ld	s0,32(sp)
    80003882:	64e2                	ld	s1,24(sp)
    80003884:	6942                	ld	s2,16(sp)
    80003886:	69a2                	ld	s3,8(sp)
    80003888:	6a02                	ld	s4,0(sp)
    8000388a:	6145                	addi	sp,sp,48
    8000388c:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000388e:	02059493          	slli	s1,a1,0x20
    80003892:	9081                	srli	s1,s1,0x20
    80003894:	048a                	slli	s1,s1,0x2
    80003896:	94aa                	add	s1,s1,a0
    80003898:	0584a983          	lw	s3,88(s1)
    8000389c:	fe0990e3          	bnez	s3,8000387c <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800038a0:	4108                	lw	a0,0(a0)
    800038a2:	00000097          	auipc	ra,0x0
    800038a6:	e4a080e7          	jalr	-438(ra) # 800036ec <balloc>
    800038aa:	0005099b          	sext.w	s3,a0
    800038ae:	0534ac23          	sw	s3,88(s1)
    800038b2:	b7e9                	j	8000387c <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800038b4:	4108                	lw	a0,0(a0)
    800038b6:	00000097          	auipc	ra,0x0
    800038ba:	e36080e7          	jalr	-458(ra) # 800036ec <balloc>
    800038be:	0005059b          	sext.w	a1,a0
    800038c2:	08b92423          	sw	a1,136(s2)
    800038c6:	b759                	j	8000384c <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800038c8:	00092503          	lw	a0,0(s2)
    800038cc:	00000097          	auipc	ra,0x0
    800038d0:	e20080e7          	jalr	-480(ra) # 800036ec <balloc>
    800038d4:	0005099b          	sext.w	s3,a0
    800038d8:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800038dc:	8552                	mv	a0,s4
    800038de:	00001097          	auipc	ra,0x1
    800038e2:	ef6080e7          	jalr	-266(ra) # 800047d4 <log_write>
    800038e6:	b771                	j	80003872 <bmap+0x54>
  panic("bmap: out of range");
    800038e8:	00005517          	auipc	a0,0x5
    800038ec:	cf850513          	addi	a0,a0,-776 # 800085e0 <syscalls+0x120>
    800038f0:	ffffd097          	auipc	ra,0xffffd
    800038f4:	c5a080e7          	jalr	-934(ra) # 8000054a <panic>

00000000800038f8 <iget>:
{
    800038f8:	7179                	addi	sp,sp,-48
    800038fa:	f406                	sd	ra,40(sp)
    800038fc:	f022                	sd	s0,32(sp)
    800038fe:	ec26                	sd	s1,24(sp)
    80003900:	e84a                	sd	s2,16(sp)
    80003902:	e44e                	sd	s3,8(sp)
    80003904:	e052                	sd	s4,0(sp)
    80003906:	1800                	addi	s0,sp,48
    80003908:	89aa                	mv	s3,a0
    8000390a:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000390c:	00021517          	auipc	a0,0x21
    80003910:	ebc50513          	addi	a0,a0,-324 # 800247c8 <icache>
    80003914:	ffffd097          	auipc	ra,0xffffd
    80003918:	3e8080e7          	jalr	1000(ra) # 80000cfc <acquire>
  empty = 0;
    8000391c:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000391e:	00021497          	auipc	s1,0x21
    80003922:	eca48493          	addi	s1,s1,-310 # 800247e8 <icache+0x20>
    80003926:	00023697          	auipc	a3,0x23
    8000392a:	ae268693          	addi	a3,a3,-1310 # 80026408 <log>
    8000392e:	a039                	j	8000393c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003930:	02090b63          	beqz	s2,80003966 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003934:	09048493          	addi	s1,s1,144
    80003938:	02d48a63          	beq	s1,a3,8000396c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000393c:	449c                	lw	a5,8(s1)
    8000393e:	fef059e3          	blez	a5,80003930 <iget+0x38>
    80003942:	4098                	lw	a4,0(s1)
    80003944:	ff3716e3          	bne	a4,s3,80003930 <iget+0x38>
    80003948:	40d8                	lw	a4,4(s1)
    8000394a:	ff4713e3          	bne	a4,s4,80003930 <iget+0x38>
      ip->ref++;
    8000394e:	2785                	addiw	a5,a5,1
    80003950:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003952:	00021517          	auipc	a0,0x21
    80003956:	e7650513          	addi	a0,a0,-394 # 800247c8 <icache>
    8000395a:	ffffd097          	auipc	ra,0xffffd
    8000395e:	472080e7          	jalr	1138(ra) # 80000dcc <release>
      return ip;
    80003962:	8926                	mv	s2,s1
    80003964:	a03d                	j	80003992 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003966:	f7f9                	bnez	a5,80003934 <iget+0x3c>
    80003968:	8926                	mv	s2,s1
    8000396a:	b7e9                	j	80003934 <iget+0x3c>
  if(empty == 0)
    8000396c:	02090c63          	beqz	s2,800039a4 <iget+0xac>
  ip->dev = dev;
    80003970:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003974:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003978:	4785                	li	a5,1
    8000397a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000397e:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    80003982:	00021517          	auipc	a0,0x21
    80003986:	e4650513          	addi	a0,a0,-442 # 800247c8 <icache>
    8000398a:	ffffd097          	auipc	ra,0xffffd
    8000398e:	442080e7          	jalr	1090(ra) # 80000dcc <release>
}
    80003992:	854a                	mv	a0,s2
    80003994:	70a2                	ld	ra,40(sp)
    80003996:	7402                	ld	s0,32(sp)
    80003998:	64e2                	ld	s1,24(sp)
    8000399a:	6942                	ld	s2,16(sp)
    8000399c:	69a2                	ld	s3,8(sp)
    8000399e:	6a02                	ld	s4,0(sp)
    800039a0:	6145                	addi	sp,sp,48
    800039a2:	8082                	ret
    panic("iget: no inodes");
    800039a4:	00005517          	auipc	a0,0x5
    800039a8:	c5450513          	addi	a0,a0,-940 # 800085f8 <syscalls+0x138>
    800039ac:	ffffd097          	auipc	ra,0xffffd
    800039b0:	b9e080e7          	jalr	-1122(ra) # 8000054a <panic>

00000000800039b4 <fsinit>:
fsinit(int dev) {
    800039b4:	7179                	addi	sp,sp,-48
    800039b6:	f406                	sd	ra,40(sp)
    800039b8:	f022                	sd	s0,32(sp)
    800039ba:	ec26                	sd	s1,24(sp)
    800039bc:	e84a                	sd	s2,16(sp)
    800039be:	e44e                	sd	s3,8(sp)
    800039c0:	1800                	addi	s0,sp,48
    800039c2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800039c4:	4585                	li	a1,1
    800039c6:	00000097          	auipc	ra,0x0
    800039ca:	83c080e7          	jalr	-1988(ra) # 80003202 <bread>
    800039ce:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039d0:	00021997          	auipc	s3,0x21
    800039d4:	dd898993          	addi	s3,s3,-552 # 800247a8 <sb>
    800039d8:	02000613          	li	a2,32
    800039dc:	06050593          	addi	a1,a0,96
    800039e0:	854e                	mv	a0,s3
    800039e2:	ffffd097          	auipc	ra,0xffffd
    800039e6:	756080e7          	jalr	1878(ra) # 80001138 <memmove>
  brelse(bp);
    800039ea:	8526                	mv	a0,s1
    800039ec:	00000097          	auipc	ra,0x0
    800039f0:	b56080e7          	jalr	-1194(ra) # 80003542 <brelse>
  if(sb.magic != FSMAGIC)
    800039f4:	0009a703          	lw	a4,0(s3)
    800039f8:	102037b7          	lui	a5,0x10203
    800039fc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a00:	02f71263          	bne	a4,a5,80003a24 <fsinit+0x70>
  initlog(dev, &sb);
    80003a04:	00021597          	auipc	a1,0x21
    80003a08:	da458593          	addi	a1,a1,-604 # 800247a8 <sb>
    80003a0c:	854a                	mv	a0,s2
    80003a0e:	00001097          	auipc	ra,0x1
    80003a12:	b4a080e7          	jalr	-1206(ra) # 80004558 <initlog>
}
    80003a16:	70a2                	ld	ra,40(sp)
    80003a18:	7402                	ld	s0,32(sp)
    80003a1a:	64e2                	ld	s1,24(sp)
    80003a1c:	6942                	ld	s2,16(sp)
    80003a1e:	69a2                	ld	s3,8(sp)
    80003a20:	6145                	addi	sp,sp,48
    80003a22:	8082                	ret
    panic("invalid file system");
    80003a24:	00005517          	auipc	a0,0x5
    80003a28:	be450513          	addi	a0,a0,-1052 # 80008608 <syscalls+0x148>
    80003a2c:	ffffd097          	auipc	ra,0xffffd
    80003a30:	b1e080e7          	jalr	-1250(ra) # 8000054a <panic>

0000000080003a34 <iinit>:
{
    80003a34:	7179                	addi	sp,sp,-48
    80003a36:	f406                	sd	ra,40(sp)
    80003a38:	f022                	sd	s0,32(sp)
    80003a3a:	ec26                	sd	s1,24(sp)
    80003a3c:	e84a                	sd	s2,16(sp)
    80003a3e:	e44e                	sd	s3,8(sp)
    80003a40:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003a42:	00005597          	auipc	a1,0x5
    80003a46:	bde58593          	addi	a1,a1,-1058 # 80008620 <syscalls+0x160>
    80003a4a:	00021517          	auipc	a0,0x21
    80003a4e:	d7e50513          	addi	a0,a0,-642 # 800247c8 <icache>
    80003a52:	ffffd097          	auipc	ra,0xffffd
    80003a56:	426080e7          	jalr	1062(ra) # 80000e78 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a5a:	00021497          	auipc	s1,0x21
    80003a5e:	d9e48493          	addi	s1,s1,-610 # 800247f8 <icache+0x30>
    80003a62:	00023997          	auipc	s3,0x23
    80003a66:	9b698993          	addi	s3,s3,-1610 # 80026418 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003a6a:	00005917          	auipc	s2,0x5
    80003a6e:	bbe90913          	addi	s2,s2,-1090 # 80008628 <syscalls+0x168>
    80003a72:	85ca                	mv	a1,s2
    80003a74:	8526                	mv	a0,s1
    80003a76:	00001097          	auipc	ra,0x1
    80003a7a:	e4c080e7          	jalr	-436(ra) # 800048c2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a7e:	09048493          	addi	s1,s1,144
    80003a82:	ff3498e3          	bne	s1,s3,80003a72 <iinit+0x3e>
}
    80003a86:	70a2                	ld	ra,40(sp)
    80003a88:	7402                	ld	s0,32(sp)
    80003a8a:	64e2                	ld	s1,24(sp)
    80003a8c:	6942                	ld	s2,16(sp)
    80003a8e:	69a2                	ld	s3,8(sp)
    80003a90:	6145                	addi	sp,sp,48
    80003a92:	8082                	ret

0000000080003a94 <ialloc>:
{
    80003a94:	715d                	addi	sp,sp,-80
    80003a96:	e486                	sd	ra,72(sp)
    80003a98:	e0a2                	sd	s0,64(sp)
    80003a9a:	fc26                	sd	s1,56(sp)
    80003a9c:	f84a                	sd	s2,48(sp)
    80003a9e:	f44e                	sd	s3,40(sp)
    80003aa0:	f052                	sd	s4,32(sp)
    80003aa2:	ec56                	sd	s5,24(sp)
    80003aa4:	e85a                	sd	s6,16(sp)
    80003aa6:	e45e                	sd	s7,8(sp)
    80003aa8:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003aaa:	00021717          	auipc	a4,0x21
    80003aae:	d0a72703          	lw	a4,-758(a4) # 800247b4 <sb+0xc>
    80003ab2:	4785                	li	a5,1
    80003ab4:	04e7fa63          	bgeu	a5,a4,80003b08 <ialloc+0x74>
    80003ab8:	8aaa                	mv	s5,a0
    80003aba:	8bae                	mv	s7,a1
    80003abc:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003abe:	00021a17          	auipc	s4,0x21
    80003ac2:	ceaa0a13          	addi	s4,s4,-790 # 800247a8 <sb>
    80003ac6:	00048b1b          	sext.w	s6,s1
    80003aca:	0044d793          	srli	a5,s1,0x4
    80003ace:	018a2583          	lw	a1,24(s4)
    80003ad2:	9dbd                	addw	a1,a1,a5
    80003ad4:	8556                	mv	a0,s5
    80003ad6:	fffff097          	auipc	ra,0xfffff
    80003ada:	72c080e7          	jalr	1836(ra) # 80003202 <bread>
    80003ade:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ae0:	06050993          	addi	s3,a0,96
    80003ae4:	00f4f793          	andi	a5,s1,15
    80003ae8:	079a                	slli	a5,a5,0x6
    80003aea:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003aec:	00099783          	lh	a5,0(s3)
    80003af0:	c785                	beqz	a5,80003b18 <ialloc+0x84>
    brelse(bp);
    80003af2:	00000097          	auipc	ra,0x0
    80003af6:	a50080e7          	jalr	-1456(ra) # 80003542 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003afa:	0485                	addi	s1,s1,1
    80003afc:	00ca2703          	lw	a4,12(s4)
    80003b00:	0004879b          	sext.w	a5,s1
    80003b04:	fce7e1e3          	bltu	a5,a4,80003ac6 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003b08:	00005517          	auipc	a0,0x5
    80003b0c:	b2850513          	addi	a0,a0,-1240 # 80008630 <syscalls+0x170>
    80003b10:	ffffd097          	auipc	ra,0xffffd
    80003b14:	a3a080e7          	jalr	-1478(ra) # 8000054a <panic>
      memset(dip, 0, sizeof(*dip));
    80003b18:	04000613          	li	a2,64
    80003b1c:	4581                	li	a1,0
    80003b1e:	854e                	mv	a0,s3
    80003b20:	ffffd097          	auipc	ra,0xffffd
    80003b24:	5bc080e7          	jalr	1468(ra) # 800010dc <memset>
      dip->type = type;
    80003b28:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b2c:	854a                	mv	a0,s2
    80003b2e:	00001097          	auipc	ra,0x1
    80003b32:	ca6080e7          	jalr	-858(ra) # 800047d4 <log_write>
      brelse(bp);
    80003b36:	854a                	mv	a0,s2
    80003b38:	00000097          	auipc	ra,0x0
    80003b3c:	a0a080e7          	jalr	-1526(ra) # 80003542 <brelse>
      return iget(dev, inum);
    80003b40:	85da                	mv	a1,s6
    80003b42:	8556                	mv	a0,s5
    80003b44:	00000097          	auipc	ra,0x0
    80003b48:	db4080e7          	jalr	-588(ra) # 800038f8 <iget>
}
    80003b4c:	60a6                	ld	ra,72(sp)
    80003b4e:	6406                	ld	s0,64(sp)
    80003b50:	74e2                	ld	s1,56(sp)
    80003b52:	7942                	ld	s2,48(sp)
    80003b54:	79a2                	ld	s3,40(sp)
    80003b56:	7a02                	ld	s4,32(sp)
    80003b58:	6ae2                	ld	s5,24(sp)
    80003b5a:	6b42                	ld	s6,16(sp)
    80003b5c:	6ba2                	ld	s7,8(sp)
    80003b5e:	6161                	addi	sp,sp,80
    80003b60:	8082                	ret

0000000080003b62 <iupdate>:
{
    80003b62:	1101                	addi	sp,sp,-32
    80003b64:	ec06                	sd	ra,24(sp)
    80003b66:	e822                	sd	s0,16(sp)
    80003b68:	e426                	sd	s1,8(sp)
    80003b6a:	e04a                	sd	s2,0(sp)
    80003b6c:	1000                	addi	s0,sp,32
    80003b6e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b70:	415c                	lw	a5,4(a0)
    80003b72:	0047d79b          	srliw	a5,a5,0x4
    80003b76:	00021597          	auipc	a1,0x21
    80003b7a:	c4a5a583          	lw	a1,-950(a1) # 800247c0 <sb+0x18>
    80003b7e:	9dbd                	addw	a1,a1,a5
    80003b80:	4108                	lw	a0,0(a0)
    80003b82:	fffff097          	auipc	ra,0xfffff
    80003b86:	680080e7          	jalr	1664(ra) # 80003202 <bread>
    80003b8a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b8c:	06050793          	addi	a5,a0,96
    80003b90:	40c8                	lw	a0,4(s1)
    80003b92:	893d                	andi	a0,a0,15
    80003b94:	051a                	slli	a0,a0,0x6
    80003b96:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003b98:	04c49703          	lh	a4,76(s1)
    80003b9c:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003ba0:	04e49703          	lh	a4,78(s1)
    80003ba4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003ba8:	05049703          	lh	a4,80(s1)
    80003bac:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003bb0:	05249703          	lh	a4,82(s1)
    80003bb4:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003bb8:	48f8                	lw	a4,84(s1)
    80003bba:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003bbc:	03400613          	li	a2,52
    80003bc0:	05848593          	addi	a1,s1,88
    80003bc4:	0531                	addi	a0,a0,12
    80003bc6:	ffffd097          	auipc	ra,0xffffd
    80003bca:	572080e7          	jalr	1394(ra) # 80001138 <memmove>
  log_write(bp);
    80003bce:	854a                	mv	a0,s2
    80003bd0:	00001097          	auipc	ra,0x1
    80003bd4:	c04080e7          	jalr	-1020(ra) # 800047d4 <log_write>
  brelse(bp);
    80003bd8:	854a                	mv	a0,s2
    80003bda:	00000097          	auipc	ra,0x0
    80003bde:	968080e7          	jalr	-1688(ra) # 80003542 <brelse>
}
    80003be2:	60e2                	ld	ra,24(sp)
    80003be4:	6442                	ld	s0,16(sp)
    80003be6:	64a2                	ld	s1,8(sp)
    80003be8:	6902                	ld	s2,0(sp)
    80003bea:	6105                	addi	sp,sp,32
    80003bec:	8082                	ret

0000000080003bee <idup>:
{
    80003bee:	1101                	addi	sp,sp,-32
    80003bf0:	ec06                	sd	ra,24(sp)
    80003bf2:	e822                	sd	s0,16(sp)
    80003bf4:	e426                	sd	s1,8(sp)
    80003bf6:	1000                	addi	s0,sp,32
    80003bf8:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003bfa:	00021517          	auipc	a0,0x21
    80003bfe:	bce50513          	addi	a0,a0,-1074 # 800247c8 <icache>
    80003c02:	ffffd097          	auipc	ra,0xffffd
    80003c06:	0fa080e7          	jalr	250(ra) # 80000cfc <acquire>
  ip->ref++;
    80003c0a:	449c                	lw	a5,8(s1)
    80003c0c:	2785                	addiw	a5,a5,1
    80003c0e:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003c10:	00021517          	auipc	a0,0x21
    80003c14:	bb850513          	addi	a0,a0,-1096 # 800247c8 <icache>
    80003c18:	ffffd097          	auipc	ra,0xffffd
    80003c1c:	1b4080e7          	jalr	436(ra) # 80000dcc <release>
}
    80003c20:	8526                	mv	a0,s1
    80003c22:	60e2                	ld	ra,24(sp)
    80003c24:	6442                	ld	s0,16(sp)
    80003c26:	64a2                	ld	s1,8(sp)
    80003c28:	6105                	addi	sp,sp,32
    80003c2a:	8082                	ret

0000000080003c2c <ilock>:
{
    80003c2c:	1101                	addi	sp,sp,-32
    80003c2e:	ec06                	sd	ra,24(sp)
    80003c30:	e822                	sd	s0,16(sp)
    80003c32:	e426                	sd	s1,8(sp)
    80003c34:	e04a                	sd	s2,0(sp)
    80003c36:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c38:	c115                	beqz	a0,80003c5c <ilock+0x30>
    80003c3a:	84aa                	mv	s1,a0
    80003c3c:	451c                	lw	a5,8(a0)
    80003c3e:	00f05f63          	blez	a5,80003c5c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c42:	0541                	addi	a0,a0,16
    80003c44:	00001097          	auipc	ra,0x1
    80003c48:	cb8080e7          	jalr	-840(ra) # 800048fc <acquiresleep>
  if(ip->valid == 0){
    80003c4c:	44bc                	lw	a5,72(s1)
    80003c4e:	cf99                	beqz	a5,80003c6c <ilock+0x40>
}
    80003c50:	60e2                	ld	ra,24(sp)
    80003c52:	6442                	ld	s0,16(sp)
    80003c54:	64a2                	ld	s1,8(sp)
    80003c56:	6902                	ld	s2,0(sp)
    80003c58:	6105                	addi	sp,sp,32
    80003c5a:	8082                	ret
    panic("ilock");
    80003c5c:	00005517          	auipc	a0,0x5
    80003c60:	9ec50513          	addi	a0,a0,-1556 # 80008648 <syscalls+0x188>
    80003c64:	ffffd097          	auipc	ra,0xffffd
    80003c68:	8e6080e7          	jalr	-1818(ra) # 8000054a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c6c:	40dc                	lw	a5,4(s1)
    80003c6e:	0047d79b          	srliw	a5,a5,0x4
    80003c72:	00021597          	auipc	a1,0x21
    80003c76:	b4e5a583          	lw	a1,-1202(a1) # 800247c0 <sb+0x18>
    80003c7a:	9dbd                	addw	a1,a1,a5
    80003c7c:	4088                	lw	a0,0(s1)
    80003c7e:	fffff097          	auipc	ra,0xfffff
    80003c82:	584080e7          	jalr	1412(ra) # 80003202 <bread>
    80003c86:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c88:	06050593          	addi	a1,a0,96
    80003c8c:	40dc                	lw	a5,4(s1)
    80003c8e:	8bbd                	andi	a5,a5,15
    80003c90:	079a                	slli	a5,a5,0x6
    80003c92:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c94:	00059783          	lh	a5,0(a1)
    80003c98:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003c9c:	00259783          	lh	a5,2(a1)
    80003ca0:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003ca4:	00459783          	lh	a5,4(a1)
    80003ca8:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003cac:	00659783          	lh	a5,6(a1)
    80003cb0:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003cb4:	459c                	lw	a5,8(a1)
    80003cb6:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003cb8:	03400613          	li	a2,52
    80003cbc:	05b1                	addi	a1,a1,12
    80003cbe:	05848513          	addi	a0,s1,88
    80003cc2:	ffffd097          	auipc	ra,0xffffd
    80003cc6:	476080e7          	jalr	1142(ra) # 80001138 <memmove>
    brelse(bp);
    80003cca:	854a                	mv	a0,s2
    80003ccc:	00000097          	auipc	ra,0x0
    80003cd0:	876080e7          	jalr	-1930(ra) # 80003542 <brelse>
    ip->valid = 1;
    80003cd4:	4785                	li	a5,1
    80003cd6:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003cd8:	04c49783          	lh	a5,76(s1)
    80003cdc:	fbb5                	bnez	a5,80003c50 <ilock+0x24>
      panic("ilock: no type");
    80003cde:	00005517          	auipc	a0,0x5
    80003ce2:	97250513          	addi	a0,a0,-1678 # 80008650 <syscalls+0x190>
    80003ce6:	ffffd097          	auipc	ra,0xffffd
    80003cea:	864080e7          	jalr	-1948(ra) # 8000054a <panic>

0000000080003cee <iunlock>:
{
    80003cee:	1101                	addi	sp,sp,-32
    80003cf0:	ec06                	sd	ra,24(sp)
    80003cf2:	e822                	sd	s0,16(sp)
    80003cf4:	e426                	sd	s1,8(sp)
    80003cf6:	e04a                	sd	s2,0(sp)
    80003cf8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003cfa:	c905                	beqz	a0,80003d2a <iunlock+0x3c>
    80003cfc:	84aa                	mv	s1,a0
    80003cfe:	01050913          	addi	s2,a0,16
    80003d02:	854a                	mv	a0,s2
    80003d04:	00001097          	auipc	ra,0x1
    80003d08:	c92080e7          	jalr	-878(ra) # 80004996 <holdingsleep>
    80003d0c:	cd19                	beqz	a0,80003d2a <iunlock+0x3c>
    80003d0e:	449c                	lw	a5,8(s1)
    80003d10:	00f05d63          	blez	a5,80003d2a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d14:	854a                	mv	a0,s2
    80003d16:	00001097          	auipc	ra,0x1
    80003d1a:	c3c080e7          	jalr	-964(ra) # 80004952 <releasesleep>
}
    80003d1e:	60e2                	ld	ra,24(sp)
    80003d20:	6442                	ld	s0,16(sp)
    80003d22:	64a2                	ld	s1,8(sp)
    80003d24:	6902                	ld	s2,0(sp)
    80003d26:	6105                	addi	sp,sp,32
    80003d28:	8082                	ret
    panic("iunlock");
    80003d2a:	00005517          	auipc	a0,0x5
    80003d2e:	93650513          	addi	a0,a0,-1738 # 80008660 <syscalls+0x1a0>
    80003d32:	ffffd097          	auipc	ra,0xffffd
    80003d36:	818080e7          	jalr	-2024(ra) # 8000054a <panic>

0000000080003d3a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d3a:	7179                	addi	sp,sp,-48
    80003d3c:	f406                	sd	ra,40(sp)
    80003d3e:	f022                	sd	s0,32(sp)
    80003d40:	ec26                	sd	s1,24(sp)
    80003d42:	e84a                	sd	s2,16(sp)
    80003d44:	e44e                	sd	s3,8(sp)
    80003d46:	e052                	sd	s4,0(sp)
    80003d48:	1800                	addi	s0,sp,48
    80003d4a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d4c:	05850493          	addi	s1,a0,88
    80003d50:	08850913          	addi	s2,a0,136
    80003d54:	a021                	j	80003d5c <itrunc+0x22>
    80003d56:	0491                	addi	s1,s1,4
    80003d58:	01248d63          	beq	s1,s2,80003d72 <itrunc+0x38>
    if(ip->addrs[i]){
    80003d5c:	408c                	lw	a1,0(s1)
    80003d5e:	dde5                	beqz	a1,80003d56 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d60:	0009a503          	lw	a0,0(s3)
    80003d64:	00000097          	auipc	ra,0x0
    80003d68:	90c080e7          	jalr	-1780(ra) # 80003670 <bfree>
      ip->addrs[i] = 0;
    80003d6c:	0004a023          	sw	zero,0(s1)
    80003d70:	b7dd                	j	80003d56 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d72:	0889a583          	lw	a1,136(s3)
    80003d76:	e185                	bnez	a1,80003d96 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d78:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80003d7c:	854e                	mv	a0,s3
    80003d7e:	00000097          	auipc	ra,0x0
    80003d82:	de4080e7          	jalr	-540(ra) # 80003b62 <iupdate>
}
    80003d86:	70a2                	ld	ra,40(sp)
    80003d88:	7402                	ld	s0,32(sp)
    80003d8a:	64e2                	ld	s1,24(sp)
    80003d8c:	6942                	ld	s2,16(sp)
    80003d8e:	69a2                	ld	s3,8(sp)
    80003d90:	6a02                	ld	s4,0(sp)
    80003d92:	6145                	addi	sp,sp,48
    80003d94:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d96:	0009a503          	lw	a0,0(s3)
    80003d9a:	fffff097          	auipc	ra,0xfffff
    80003d9e:	468080e7          	jalr	1128(ra) # 80003202 <bread>
    80003da2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003da4:	06050493          	addi	s1,a0,96
    80003da8:	46050913          	addi	s2,a0,1120
    80003dac:	a021                	j	80003db4 <itrunc+0x7a>
    80003dae:	0491                	addi	s1,s1,4
    80003db0:	01248b63          	beq	s1,s2,80003dc6 <itrunc+0x8c>
      if(a[j])
    80003db4:	408c                	lw	a1,0(s1)
    80003db6:	dde5                	beqz	a1,80003dae <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003db8:	0009a503          	lw	a0,0(s3)
    80003dbc:	00000097          	auipc	ra,0x0
    80003dc0:	8b4080e7          	jalr	-1868(ra) # 80003670 <bfree>
    80003dc4:	b7ed                	j	80003dae <itrunc+0x74>
    brelse(bp);
    80003dc6:	8552                	mv	a0,s4
    80003dc8:	fffff097          	auipc	ra,0xfffff
    80003dcc:	77a080e7          	jalr	1914(ra) # 80003542 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003dd0:	0889a583          	lw	a1,136(s3)
    80003dd4:	0009a503          	lw	a0,0(s3)
    80003dd8:	00000097          	auipc	ra,0x0
    80003ddc:	898080e7          	jalr	-1896(ra) # 80003670 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003de0:	0809a423          	sw	zero,136(s3)
    80003de4:	bf51                	j	80003d78 <itrunc+0x3e>

0000000080003de6 <iput>:
{
    80003de6:	1101                	addi	sp,sp,-32
    80003de8:	ec06                	sd	ra,24(sp)
    80003dea:	e822                	sd	s0,16(sp)
    80003dec:	e426                	sd	s1,8(sp)
    80003dee:	e04a                	sd	s2,0(sp)
    80003df0:	1000                	addi	s0,sp,32
    80003df2:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003df4:	00021517          	auipc	a0,0x21
    80003df8:	9d450513          	addi	a0,a0,-1580 # 800247c8 <icache>
    80003dfc:	ffffd097          	auipc	ra,0xffffd
    80003e00:	f00080e7          	jalr	-256(ra) # 80000cfc <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e04:	4498                	lw	a4,8(s1)
    80003e06:	4785                	li	a5,1
    80003e08:	02f70363          	beq	a4,a5,80003e2e <iput+0x48>
  ip->ref--;
    80003e0c:	449c                	lw	a5,8(s1)
    80003e0e:	37fd                	addiw	a5,a5,-1
    80003e10:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003e12:	00021517          	auipc	a0,0x21
    80003e16:	9b650513          	addi	a0,a0,-1610 # 800247c8 <icache>
    80003e1a:	ffffd097          	auipc	ra,0xffffd
    80003e1e:	fb2080e7          	jalr	-78(ra) # 80000dcc <release>
}
    80003e22:	60e2                	ld	ra,24(sp)
    80003e24:	6442                	ld	s0,16(sp)
    80003e26:	64a2                	ld	s1,8(sp)
    80003e28:	6902                	ld	s2,0(sp)
    80003e2a:	6105                	addi	sp,sp,32
    80003e2c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e2e:	44bc                	lw	a5,72(s1)
    80003e30:	dff1                	beqz	a5,80003e0c <iput+0x26>
    80003e32:	05249783          	lh	a5,82(s1)
    80003e36:	fbf9                	bnez	a5,80003e0c <iput+0x26>
    acquiresleep(&ip->lock);
    80003e38:	01048913          	addi	s2,s1,16
    80003e3c:	854a                	mv	a0,s2
    80003e3e:	00001097          	auipc	ra,0x1
    80003e42:	abe080e7          	jalr	-1346(ra) # 800048fc <acquiresleep>
    release(&icache.lock);
    80003e46:	00021517          	auipc	a0,0x21
    80003e4a:	98250513          	addi	a0,a0,-1662 # 800247c8 <icache>
    80003e4e:	ffffd097          	auipc	ra,0xffffd
    80003e52:	f7e080e7          	jalr	-130(ra) # 80000dcc <release>
    itrunc(ip);
    80003e56:	8526                	mv	a0,s1
    80003e58:	00000097          	auipc	ra,0x0
    80003e5c:	ee2080e7          	jalr	-286(ra) # 80003d3a <itrunc>
    ip->type = 0;
    80003e60:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003e64:	8526                	mv	a0,s1
    80003e66:	00000097          	auipc	ra,0x0
    80003e6a:	cfc080e7          	jalr	-772(ra) # 80003b62 <iupdate>
    ip->valid = 0;
    80003e6e:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003e72:	854a                	mv	a0,s2
    80003e74:	00001097          	auipc	ra,0x1
    80003e78:	ade080e7          	jalr	-1314(ra) # 80004952 <releasesleep>
    acquire(&icache.lock);
    80003e7c:	00021517          	auipc	a0,0x21
    80003e80:	94c50513          	addi	a0,a0,-1716 # 800247c8 <icache>
    80003e84:	ffffd097          	auipc	ra,0xffffd
    80003e88:	e78080e7          	jalr	-392(ra) # 80000cfc <acquire>
    80003e8c:	b741                	j	80003e0c <iput+0x26>

0000000080003e8e <iunlockput>:
{
    80003e8e:	1101                	addi	sp,sp,-32
    80003e90:	ec06                	sd	ra,24(sp)
    80003e92:	e822                	sd	s0,16(sp)
    80003e94:	e426                	sd	s1,8(sp)
    80003e96:	1000                	addi	s0,sp,32
    80003e98:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e9a:	00000097          	auipc	ra,0x0
    80003e9e:	e54080e7          	jalr	-428(ra) # 80003cee <iunlock>
  iput(ip);
    80003ea2:	8526                	mv	a0,s1
    80003ea4:	00000097          	auipc	ra,0x0
    80003ea8:	f42080e7          	jalr	-190(ra) # 80003de6 <iput>
}
    80003eac:	60e2                	ld	ra,24(sp)
    80003eae:	6442                	ld	s0,16(sp)
    80003eb0:	64a2                	ld	s1,8(sp)
    80003eb2:	6105                	addi	sp,sp,32
    80003eb4:	8082                	ret

0000000080003eb6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003eb6:	1141                	addi	sp,sp,-16
    80003eb8:	e422                	sd	s0,8(sp)
    80003eba:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ebc:	411c                	lw	a5,0(a0)
    80003ebe:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ec0:	415c                	lw	a5,4(a0)
    80003ec2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ec4:	04c51783          	lh	a5,76(a0)
    80003ec8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ecc:	05251783          	lh	a5,82(a0)
    80003ed0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ed4:	05456783          	lwu	a5,84(a0)
    80003ed8:	e99c                	sd	a5,16(a1)
}
    80003eda:	6422                	ld	s0,8(sp)
    80003edc:	0141                	addi	sp,sp,16
    80003ede:	8082                	ret

0000000080003ee0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ee0:	497c                	lw	a5,84(a0)
    80003ee2:	0ed7e963          	bltu	a5,a3,80003fd4 <readi+0xf4>
{
    80003ee6:	7159                	addi	sp,sp,-112
    80003ee8:	f486                	sd	ra,104(sp)
    80003eea:	f0a2                	sd	s0,96(sp)
    80003eec:	eca6                	sd	s1,88(sp)
    80003eee:	e8ca                	sd	s2,80(sp)
    80003ef0:	e4ce                	sd	s3,72(sp)
    80003ef2:	e0d2                	sd	s4,64(sp)
    80003ef4:	fc56                	sd	s5,56(sp)
    80003ef6:	f85a                	sd	s6,48(sp)
    80003ef8:	f45e                	sd	s7,40(sp)
    80003efa:	f062                	sd	s8,32(sp)
    80003efc:	ec66                	sd	s9,24(sp)
    80003efe:	e86a                	sd	s10,16(sp)
    80003f00:	e46e                	sd	s11,8(sp)
    80003f02:	1880                	addi	s0,sp,112
    80003f04:	8baa                	mv	s7,a0
    80003f06:	8c2e                	mv	s8,a1
    80003f08:	8ab2                	mv	s5,a2
    80003f0a:	84b6                	mv	s1,a3
    80003f0c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f0e:	9f35                	addw	a4,a4,a3
    return 0;
    80003f10:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f12:	0ad76063          	bltu	a4,a3,80003fb2 <readi+0xd2>
  if(off + n > ip->size)
    80003f16:	00e7f463          	bgeu	a5,a4,80003f1e <readi+0x3e>
    n = ip->size - off;
    80003f1a:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f1e:	0a0b0963          	beqz	s6,80003fd0 <readi+0xf0>
    80003f22:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f24:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f28:	5cfd                	li	s9,-1
    80003f2a:	a82d                	j	80003f64 <readi+0x84>
    80003f2c:	020a1d93          	slli	s11,s4,0x20
    80003f30:	020ddd93          	srli	s11,s11,0x20
    80003f34:	06090793          	addi	a5,s2,96
    80003f38:	86ee                	mv	a3,s11
    80003f3a:	963e                	add	a2,a2,a5
    80003f3c:	85d6                	mv	a1,s5
    80003f3e:	8562                	mv	a0,s8
    80003f40:	fffff097          	auipc	ra,0xfffff
    80003f44:	870080e7          	jalr	-1936(ra) # 800027b0 <either_copyout>
    80003f48:	05950d63          	beq	a0,s9,80003fa2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f4c:	854a                	mv	a0,s2
    80003f4e:	fffff097          	auipc	ra,0xfffff
    80003f52:	5f4080e7          	jalr	1524(ra) # 80003542 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f56:	013a09bb          	addw	s3,s4,s3
    80003f5a:	009a04bb          	addw	s1,s4,s1
    80003f5e:	9aee                	add	s5,s5,s11
    80003f60:	0569f763          	bgeu	s3,s6,80003fae <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003f64:	000ba903          	lw	s2,0(s7)
    80003f68:	00a4d59b          	srliw	a1,s1,0xa
    80003f6c:	855e                	mv	a0,s7
    80003f6e:	00000097          	auipc	ra,0x0
    80003f72:	8b0080e7          	jalr	-1872(ra) # 8000381e <bmap>
    80003f76:	0005059b          	sext.w	a1,a0
    80003f7a:	854a                	mv	a0,s2
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	286080e7          	jalr	646(ra) # 80003202 <bread>
    80003f84:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f86:	3ff4f613          	andi	a2,s1,1023
    80003f8a:	40cd07bb          	subw	a5,s10,a2
    80003f8e:	413b073b          	subw	a4,s6,s3
    80003f92:	8a3e                	mv	s4,a5
    80003f94:	2781                	sext.w	a5,a5
    80003f96:	0007069b          	sext.w	a3,a4
    80003f9a:	f8f6f9e3          	bgeu	a3,a5,80003f2c <readi+0x4c>
    80003f9e:	8a3a                	mv	s4,a4
    80003fa0:	b771                	j	80003f2c <readi+0x4c>
      brelse(bp);
    80003fa2:	854a                	mv	a0,s2
    80003fa4:	fffff097          	auipc	ra,0xfffff
    80003fa8:	59e080e7          	jalr	1438(ra) # 80003542 <brelse>
      tot = -1;
    80003fac:	59fd                	li	s3,-1
  }
  return tot;
    80003fae:	0009851b          	sext.w	a0,s3
}
    80003fb2:	70a6                	ld	ra,104(sp)
    80003fb4:	7406                	ld	s0,96(sp)
    80003fb6:	64e6                	ld	s1,88(sp)
    80003fb8:	6946                	ld	s2,80(sp)
    80003fba:	69a6                	ld	s3,72(sp)
    80003fbc:	6a06                	ld	s4,64(sp)
    80003fbe:	7ae2                	ld	s5,56(sp)
    80003fc0:	7b42                	ld	s6,48(sp)
    80003fc2:	7ba2                	ld	s7,40(sp)
    80003fc4:	7c02                	ld	s8,32(sp)
    80003fc6:	6ce2                	ld	s9,24(sp)
    80003fc8:	6d42                	ld	s10,16(sp)
    80003fca:	6da2                	ld	s11,8(sp)
    80003fcc:	6165                	addi	sp,sp,112
    80003fce:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fd0:	89da                	mv	s3,s6
    80003fd2:	bff1                	j	80003fae <readi+0xce>
    return 0;
    80003fd4:	4501                	li	a0,0
}
    80003fd6:	8082                	ret

0000000080003fd8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fd8:	497c                	lw	a5,84(a0)
    80003fda:	10d7e763          	bltu	a5,a3,800040e8 <writei+0x110>
{
    80003fde:	7159                	addi	sp,sp,-112
    80003fe0:	f486                	sd	ra,104(sp)
    80003fe2:	f0a2                	sd	s0,96(sp)
    80003fe4:	eca6                	sd	s1,88(sp)
    80003fe6:	e8ca                	sd	s2,80(sp)
    80003fe8:	e4ce                	sd	s3,72(sp)
    80003fea:	e0d2                	sd	s4,64(sp)
    80003fec:	fc56                	sd	s5,56(sp)
    80003fee:	f85a                	sd	s6,48(sp)
    80003ff0:	f45e                	sd	s7,40(sp)
    80003ff2:	f062                	sd	s8,32(sp)
    80003ff4:	ec66                	sd	s9,24(sp)
    80003ff6:	e86a                	sd	s10,16(sp)
    80003ff8:	e46e                	sd	s11,8(sp)
    80003ffa:	1880                	addi	s0,sp,112
    80003ffc:	8baa                	mv	s7,a0
    80003ffe:	8c2e                	mv	s8,a1
    80004000:	8ab2                	mv	s5,a2
    80004002:	8936                	mv	s2,a3
    80004004:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004006:	00e687bb          	addw	a5,a3,a4
    8000400a:	0ed7e163          	bltu	a5,a3,800040ec <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000400e:	00043737          	lui	a4,0x43
    80004012:	0cf76f63          	bltu	a4,a5,800040f0 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004016:	0a0b0863          	beqz	s6,800040c6 <writei+0xee>
    8000401a:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000401c:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004020:	5cfd                	li	s9,-1
    80004022:	a091                	j	80004066 <writei+0x8e>
    80004024:	02099d93          	slli	s11,s3,0x20
    80004028:	020ddd93          	srli	s11,s11,0x20
    8000402c:	06048793          	addi	a5,s1,96
    80004030:	86ee                	mv	a3,s11
    80004032:	8656                	mv	a2,s5
    80004034:	85e2                	mv	a1,s8
    80004036:	953e                	add	a0,a0,a5
    80004038:	ffffe097          	auipc	ra,0xffffe
    8000403c:	7ce080e7          	jalr	1998(ra) # 80002806 <either_copyin>
    80004040:	07950263          	beq	a0,s9,800040a4 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80004044:	8526                	mv	a0,s1
    80004046:	00000097          	auipc	ra,0x0
    8000404a:	78e080e7          	jalr	1934(ra) # 800047d4 <log_write>
    brelse(bp);
    8000404e:	8526                	mv	a0,s1
    80004050:	fffff097          	auipc	ra,0xfffff
    80004054:	4f2080e7          	jalr	1266(ra) # 80003542 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004058:	01498a3b          	addw	s4,s3,s4
    8000405c:	0129893b          	addw	s2,s3,s2
    80004060:	9aee                	add	s5,s5,s11
    80004062:	056a7763          	bgeu	s4,s6,800040b0 <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004066:	000ba483          	lw	s1,0(s7)
    8000406a:	00a9559b          	srliw	a1,s2,0xa
    8000406e:	855e                	mv	a0,s7
    80004070:	fffff097          	auipc	ra,0xfffff
    80004074:	7ae080e7          	jalr	1966(ra) # 8000381e <bmap>
    80004078:	0005059b          	sext.w	a1,a0
    8000407c:	8526                	mv	a0,s1
    8000407e:	fffff097          	auipc	ra,0xfffff
    80004082:	184080e7          	jalr	388(ra) # 80003202 <bread>
    80004086:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004088:	3ff97513          	andi	a0,s2,1023
    8000408c:	40ad07bb          	subw	a5,s10,a0
    80004090:	414b073b          	subw	a4,s6,s4
    80004094:	89be                	mv	s3,a5
    80004096:	2781                	sext.w	a5,a5
    80004098:	0007069b          	sext.w	a3,a4
    8000409c:	f8f6f4e3          	bgeu	a3,a5,80004024 <writei+0x4c>
    800040a0:	89ba                	mv	s3,a4
    800040a2:	b749                	j	80004024 <writei+0x4c>
      brelse(bp);
    800040a4:	8526                	mv	a0,s1
    800040a6:	fffff097          	auipc	ra,0xfffff
    800040aa:	49c080e7          	jalr	1180(ra) # 80003542 <brelse>
      n = -1;
    800040ae:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    800040b0:	054ba783          	lw	a5,84(s7)
    800040b4:	0127f463          	bgeu	a5,s2,800040bc <writei+0xe4>
      ip->size = off;
    800040b8:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    800040bc:	855e                	mv	a0,s7
    800040be:	00000097          	auipc	ra,0x0
    800040c2:	aa4080e7          	jalr	-1372(ra) # 80003b62 <iupdate>
  }

  return n;
    800040c6:	000b051b          	sext.w	a0,s6
}
    800040ca:	70a6                	ld	ra,104(sp)
    800040cc:	7406                	ld	s0,96(sp)
    800040ce:	64e6                	ld	s1,88(sp)
    800040d0:	6946                	ld	s2,80(sp)
    800040d2:	69a6                	ld	s3,72(sp)
    800040d4:	6a06                	ld	s4,64(sp)
    800040d6:	7ae2                	ld	s5,56(sp)
    800040d8:	7b42                	ld	s6,48(sp)
    800040da:	7ba2                	ld	s7,40(sp)
    800040dc:	7c02                	ld	s8,32(sp)
    800040de:	6ce2                	ld	s9,24(sp)
    800040e0:	6d42                	ld	s10,16(sp)
    800040e2:	6da2                	ld	s11,8(sp)
    800040e4:	6165                	addi	sp,sp,112
    800040e6:	8082                	ret
    return -1;
    800040e8:	557d                	li	a0,-1
}
    800040ea:	8082                	ret
    return -1;
    800040ec:	557d                	li	a0,-1
    800040ee:	bff1                	j	800040ca <writei+0xf2>
    return -1;
    800040f0:	557d                	li	a0,-1
    800040f2:	bfe1                	j	800040ca <writei+0xf2>

00000000800040f4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040f4:	1141                	addi	sp,sp,-16
    800040f6:	e406                	sd	ra,8(sp)
    800040f8:	e022                	sd	s0,0(sp)
    800040fa:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040fc:	4639                	li	a2,14
    800040fe:	ffffd097          	auipc	ra,0xffffd
    80004102:	0b6080e7          	jalr	182(ra) # 800011b4 <strncmp>
}
    80004106:	60a2                	ld	ra,8(sp)
    80004108:	6402                	ld	s0,0(sp)
    8000410a:	0141                	addi	sp,sp,16
    8000410c:	8082                	ret

000000008000410e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000410e:	7139                	addi	sp,sp,-64
    80004110:	fc06                	sd	ra,56(sp)
    80004112:	f822                	sd	s0,48(sp)
    80004114:	f426                	sd	s1,40(sp)
    80004116:	f04a                	sd	s2,32(sp)
    80004118:	ec4e                	sd	s3,24(sp)
    8000411a:	e852                	sd	s4,16(sp)
    8000411c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000411e:	04c51703          	lh	a4,76(a0)
    80004122:	4785                	li	a5,1
    80004124:	00f71a63          	bne	a4,a5,80004138 <dirlookup+0x2a>
    80004128:	892a                	mv	s2,a0
    8000412a:	89ae                	mv	s3,a1
    8000412c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000412e:	497c                	lw	a5,84(a0)
    80004130:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004132:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004134:	e79d                	bnez	a5,80004162 <dirlookup+0x54>
    80004136:	a8a5                	j	800041ae <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004138:	00004517          	auipc	a0,0x4
    8000413c:	53050513          	addi	a0,a0,1328 # 80008668 <syscalls+0x1a8>
    80004140:	ffffc097          	auipc	ra,0xffffc
    80004144:	40a080e7          	jalr	1034(ra) # 8000054a <panic>
      panic("dirlookup read");
    80004148:	00004517          	auipc	a0,0x4
    8000414c:	53850513          	addi	a0,a0,1336 # 80008680 <syscalls+0x1c0>
    80004150:	ffffc097          	auipc	ra,0xffffc
    80004154:	3fa080e7          	jalr	1018(ra) # 8000054a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004158:	24c1                	addiw	s1,s1,16
    8000415a:	05492783          	lw	a5,84(s2)
    8000415e:	04f4f763          	bgeu	s1,a5,800041ac <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004162:	4741                	li	a4,16
    80004164:	86a6                	mv	a3,s1
    80004166:	fc040613          	addi	a2,s0,-64
    8000416a:	4581                	li	a1,0
    8000416c:	854a                	mv	a0,s2
    8000416e:	00000097          	auipc	ra,0x0
    80004172:	d72080e7          	jalr	-654(ra) # 80003ee0 <readi>
    80004176:	47c1                	li	a5,16
    80004178:	fcf518e3          	bne	a0,a5,80004148 <dirlookup+0x3a>
    if(de.inum == 0)
    8000417c:	fc045783          	lhu	a5,-64(s0)
    80004180:	dfe1                	beqz	a5,80004158 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004182:	fc240593          	addi	a1,s0,-62
    80004186:	854e                	mv	a0,s3
    80004188:	00000097          	auipc	ra,0x0
    8000418c:	f6c080e7          	jalr	-148(ra) # 800040f4 <namecmp>
    80004190:	f561                	bnez	a0,80004158 <dirlookup+0x4a>
      if(poff)
    80004192:	000a0463          	beqz	s4,8000419a <dirlookup+0x8c>
        *poff = off;
    80004196:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000419a:	fc045583          	lhu	a1,-64(s0)
    8000419e:	00092503          	lw	a0,0(s2)
    800041a2:	fffff097          	auipc	ra,0xfffff
    800041a6:	756080e7          	jalr	1878(ra) # 800038f8 <iget>
    800041aa:	a011                	j	800041ae <dirlookup+0xa0>
  return 0;
    800041ac:	4501                	li	a0,0
}
    800041ae:	70e2                	ld	ra,56(sp)
    800041b0:	7442                	ld	s0,48(sp)
    800041b2:	74a2                	ld	s1,40(sp)
    800041b4:	7902                	ld	s2,32(sp)
    800041b6:	69e2                	ld	s3,24(sp)
    800041b8:	6a42                	ld	s4,16(sp)
    800041ba:	6121                	addi	sp,sp,64
    800041bc:	8082                	ret

00000000800041be <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800041be:	711d                	addi	sp,sp,-96
    800041c0:	ec86                	sd	ra,88(sp)
    800041c2:	e8a2                	sd	s0,80(sp)
    800041c4:	e4a6                	sd	s1,72(sp)
    800041c6:	e0ca                	sd	s2,64(sp)
    800041c8:	fc4e                	sd	s3,56(sp)
    800041ca:	f852                	sd	s4,48(sp)
    800041cc:	f456                	sd	s5,40(sp)
    800041ce:	f05a                	sd	s6,32(sp)
    800041d0:	ec5e                	sd	s7,24(sp)
    800041d2:	e862                	sd	s8,16(sp)
    800041d4:	e466                	sd	s9,8(sp)
    800041d6:	1080                	addi	s0,sp,96
    800041d8:	84aa                	mv	s1,a0
    800041da:	8aae                	mv	s5,a1
    800041dc:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041de:	00054703          	lbu	a4,0(a0)
    800041e2:	02f00793          	li	a5,47
    800041e6:	02f70363          	beq	a4,a5,8000420c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800041ea:	ffffe097          	auipc	ra,0xffffe
    800041ee:	b58080e7          	jalr	-1192(ra) # 80001d42 <myproc>
    800041f2:	15853503          	ld	a0,344(a0)
    800041f6:	00000097          	auipc	ra,0x0
    800041fa:	9f8080e7          	jalr	-1544(ra) # 80003bee <idup>
    800041fe:	89aa                	mv	s3,a0
  while(*path == '/')
    80004200:	02f00913          	li	s2,47
  len = path - s;
    80004204:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004206:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004208:	4b85                	li	s7,1
    8000420a:	a865                	j	800042c2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000420c:	4585                	li	a1,1
    8000420e:	4505                	li	a0,1
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	6e8080e7          	jalr	1768(ra) # 800038f8 <iget>
    80004218:	89aa                	mv	s3,a0
    8000421a:	b7dd                	j	80004200 <namex+0x42>
      iunlockput(ip);
    8000421c:	854e                	mv	a0,s3
    8000421e:	00000097          	auipc	ra,0x0
    80004222:	c70080e7          	jalr	-912(ra) # 80003e8e <iunlockput>
      return 0;
    80004226:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004228:	854e                	mv	a0,s3
    8000422a:	60e6                	ld	ra,88(sp)
    8000422c:	6446                	ld	s0,80(sp)
    8000422e:	64a6                	ld	s1,72(sp)
    80004230:	6906                	ld	s2,64(sp)
    80004232:	79e2                	ld	s3,56(sp)
    80004234:	7a42                	ld	s4,48(sp)
    80004236:	7aa2                	ld	s5,40(sp)
    80004238:	7b02                	ld	s6,32(sp)
    8000423a:	6be2                	ld	s7,24(sp)
    8000423c:	6c42                	ld	s8,16(sp)
    8000423e:	6ca2                	ld	s9,8(sp)
    80004240:	6125                	addi	sp,sp,96
    80004242:	8082                	ret
      iunlock(ip);
    80004244:	854e                	mv	a0,s3
    80004246:	00000097          	auipc	ra,0x0
    8000424a:	aa8080e7          	jalr	-1368(ra) # 80003cee <iunlock>
      return ip;
    8000424e:	bfe9                	j	80004228 <namex+0x6a>
      iunlockput(ip);
    80004250:	854e                	mv	a0,s3
    80004252:	00000097          	auipc	ra,0x0
    80004256:	c3c080e7          	jalr	-964(ra) # 80003e8e <iunlockput>
      return 0;
    8000425a:	89e6                	mv	s3,s9
    8000425c:	b7f1                	j	80004228 <namex+0x6a>
  len = path - s;
    8000425e:	40b48633          	sub	a2,s1,a1
    80004262:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004266:	099c5463          	bge	s8,s9,800042ee <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000426a:	4639                	li	a2,14
    8000426c:	8552                	mv	a0,s4
    8000426e:	ffffd097          	auipc	ra,0xffffd
    80004272:	eca080e7          	jalr	-310(ra) # 80001138 <memmove>
  while(*path == '/')
    80004276:	0004c783          	lbu	a5,0(s1)
    8000427a:	01279763          	bne	a5,s2,80004288 <namex+0xca>
    path++;
    8000427e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004280:	0004c783          	lbu	a5,0(s1)
    80004284:	ff278de3          	beq	a5,s2,8000427e <namex+0xc0>
    ilock(ip);
    80004288:	854e                	mv	a0,s3
    8000428a:	00000097          	auipc	ra,0x0
    8000428e:	9a2080e7          	jalr	-1630(ra) # 80003c2c <ilock>
    if(ip->type != T_DIR){
    80004292:	04c99783          	lh	a5,76(s3)
    80004296:	f97793e3          	bne	a5,s7,8000421c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000429a:	000a8563          	beqz	s5,800042a4 <namex+0xe6>
    8000429e:	0004c783          	lbu	a5,0(s1)
    800042a2:	d3cd                	beqz	a5,80004244 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800042a4:	865a                	mv	a2,s6
    800042a6:	85d2                	mv	a1,s4
    800042a8:	854e                	mv	a0,s3
    800042aa:	00000097          	auipc	ra,0x0
    800042ae:	e64080e7          	jalr	-412(ra) # 8000410e <dirlookup>
    800042b2:	8caa                	mv	s9,a0
    800042b4:	dd51                	beqz	a0,80004250 <namex+0x92>
    iunlockput(ip);
    800042b6:	854e                	mv	a0,s3
    800042b8:	00000097          	auipc	ra,0x0
    800042bc:	bd6080e7          	jalr	-1066(ra) # 80003e8e <iunlockput>
    ip = next;
    800042c0:	89e6                	mv	s3,s9
  while(*path == '/')
    800042c2:	0004c783          	lbu	a5,0(s1)
    800042c6:	05279763          	bne	a5,s2,80004314 <namex+0x156>
    path++;
    800042ca:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042cc:	0004c783          	lbu	a5,0(s1)
    800042d0:	ff278de3          	beq	a5,s2,800042ca <namex+0x10c>
  if(*path == 0)
    800042d4:	c79d                	beqz	a5,80004302 <namex+0x144>
    path++;
    800042d6:	85a6                	mv	a1,s1
  len = path - s;
    800042d8:	8cda                	mv	s9,s6
    800042da:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800042dc:	01278963          	beq	a5,s2,800042ee <namex+0x130>
    800042e0:	dfbd                	beqz	a5,8000425e <namex+0xa0>
    path++;
    800042e2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800042e4:	0004c783          	lbu	a5,0(s1)
    800042e8:	ff279ce3          	bne	a5,s2,800042e0 <namex+0x122>
    800042ec:	bf8d                	j	8000425e <namex+0xa0>
    memmove(name, s, len);
    800042ee:	2601                	sext.w	a2,a2
    800042f0:	8552                	mv	a0,s4
    800042f2:	ffffd097          	auipc	ra,0xffffd
    800042f6:	e46080e7          	jalr	-442(ra) # 80001138 <memmove>
    name[len] = 0;
    800042fa:	9cd2                	add	s9,s9,s4
    800042fc:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004300:	bf9d                	j	80004276 <namex+0xb8>
  if(nameiparent){
    80004302:	f20a83e3          	beqz	s5,80004228 <namex+0x6a>
    iput(ip);
    80004306:	854e                	mv	a0,s3
    80004308:	00000097          	auipc	ra,0x0
    8000430c:	ade080e7          	jalr	-1314(ra) # 80003de6 <iput>
    return 0;
    80004310:	4981                	li	s3,0
    80004312:	bf19                	j	80004228 <namex+0x6a>
  if(*path == 0)
    80004314:	d7fd                	beqz	a5,80004302 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004316:	0004c783          	lbu	a5,0(s1)
    8000431a:	85a6                	mv	a1,s1
    8000431c:	b7d1                	j	800042e0 <namex+0x122>

000000008000431e <dirlink>:
{
    8000431e:	7139                	addi	sp,sp,-64
    80004320:	fc06                	sd	ra,56(sp)
    80004322:	f822                	sd	s0,48(sp)
    80004324:	f426                	sd	s1,40(sp)
    80004326:	f04a                	sd	s2,32(sp)
    80004328:	ec4e                	sd	s3,24(sp)
    8000432a:	e852                	sd	s4,16(sp)
    8000432c:	0080                	addi	s0,sp,64
    8000432e:	892a                	mv	s2,a0
    80004330:	8a2e                	mv	s4,a1
    80004332:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004334:	4601                	li	a2,0
    80004336:	00000097          	auipc	ra,0x0
    8000433a:	dd8080e7          	jalr	-552(ra) # 8000410e <dirlookup>
    8000433e:	e93d                	bnez	a0,800043b4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004340:	05492483          	lw	s1,84(s2)
    80004344:	c49d                	beqz	s1,80004372 <dirlink+0x54>
    80004346:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004348:	4741                	li	a4,16
    8000434a:	86a6                	mv	a3,s1
    8000434c:	fc040613          	addi	a2,s0,-64
    80004350:	4581                	li	a1,0
    80004352:	854a                	mv	a0,s2
    80004354:	00000097          	auipc	ra,0x0
    80004358:	b8c080e7          	jalr	-1140(ra) # 80003ee0 <readi>
    8000435c:	47c1                	li	a5,16
    8000435e:	06f51163          	bne	a0,a5,800043c0 <dirlink+0xa2>
    if(de.inum == 0)
    80004362:	fc045783          	lhu	a5,-64(s0)
    80004366:	c791                	beqz	a5,80004372 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004368:	24c1                	addiw	s1,s1,16
    8000436a:	05492783          	lw	a5,84(s2)
    8000436e:	fcf4ede3          	bltu	s1,a5,80004348 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004372:	4639                	li	a2,14
    80004374:	85d2                	mv	a1,s4
    80004376:	fc240513          	addi	a0,s0,-62
    8000437a:	ffffd097          	auipc	ra,0xffffd
    8000437e:	e76080e7          	jalr	-394(ra) # 800011f0 <strncpy>
  de.inum = inum;
    80004382:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004386:	4741                	li	a4,16
    80004388:	86a6                	mv	a3,s1
    8000438a:	fc040613          	addi	a2,s0,-64
    8000438e:	4581                	li	a1,0
    80004390:	854a                	mv	a0,s2
    80004392:	00000097          	auipc	ra,0x0
    80004396:	c46080e7          	jalr	-954(ra) # 80003fd8 <writei>
    8000439a:	872a                	mv	a4,a0
    8000439c:	47c1                	li	a5,16
  return 0;
    8000439e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043a0:	02f71863          	bne	a4,a5,800043d0 <dirlink+0xb2>
}
    800043a4:	70e2                	ld	ra,56(sp)
    800043a6:	7442                	ld	s0,48(sp)
    800043a8:	74a2                	ld	s1,40(sp)
    800043aa:	7902                	ld	s2,32(sp)
    800043ac:	69e2                	ld	s3,24(sp)
    800043ae:	6a42                	ld	s4,16(sp)
    800043b0:	6121                	addi	sp,sp,64
    800043b2:	8082                	ret
    iput(ip);
    800043b4:	00000097          	auipc	ra,0x0
    800043b8:	a32080e7          	jalr	-1486(ra) # 80003de6 <iput>
    return -1;
    800043bc:	557d                	li	a0,-1
    800043be:	b7dd                	j	800043a4 <dirlink+0x86>
      panic("dirlink read");
    800043c0:	00004517          	auipc	a0,0x4
    800043c4:	2d050513          	addi	a0,a0,720 # 80008690 <syscalls+0x1d0>
    800043c8:	ffffc097          	auipc	ra,0xffffc
    800043cc:	182080e7          	jalr	386(ra) # 8000054a <panic>
    panic("dirlink");
    800043d0:	00004517          	auipc	a0,0x4
    800043d4:	3e050513          	addi	a0,a0,992 # 800087b0 <syscalls+0x2f0>
    800043d8:	ffffc097          	auipc	ra,0xffffc
    800043dc:	172080e7          	jalr	370(ra) # 8000054a <panic>

00000000800043e0 <namei>:

struct inode*
namei(char *path)
{
    800043e0:	1101                	addi	sp,sp,-32
    800043e2:	ec06                	sd	ra,24(sp)
    800043e4:	e822                	sd	s0,16(sp)
    800043e6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043e8:	fe040613          	addi	a2,s0,-32
    800043ec:	4581                	li	a1,0
    800043ee:	00000097          	auipc	ra,0x0
    800043f2:	dd0080e7          	jalr	-560(ra) # 800041be <namex>
}
    800043f6:	60e2                	ld	ra,24(sp)
    800043f8:	6442                	ld	s0,16(sp)
    800043fa:	6105                	addi	sp,sp,32
    800043fc:	8082                	ret

00000000800043fe <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043fe:	1141                	addi	sp,sp,-16
    80004400:	e406                	sd	ra,8(sp)
    80004402:	e022                	sd	s0,0(sp)
    80004404:	0800                	addi	s0,sp,16
    80004406:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004408:	4585                	li	a1,1
    8000440a:	00000097          	auipc	ra,0x0
    8000440e:	db4080e7          	jalr	-588(ra) # 800041be <namex>
}
    80004412:	60a2                	ld	ra,8(sp)
    80004414:	6402                	ld	s0,0(sp)
    80004416:	0141                	addi	sp,sp,16
    80004418:	8082                	ret

000000008000441a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000441a:	1101                	addi	sp,sp,-32
    8000441c:	ec06                	sd	ra,24(sp)
    8000441e:	e822                	sd	s0,16(sp)
    80004420:	e426                	sd	s1,8(sp)
    80004422:	e04a                	sd	s2,0(sp)
    80004424:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004426:	00022917          	auipc	s2,0x22
    8000442a:	fe290913          	addi	s2,s2,-30 # 80026408 <log>
    8000442e:	02092583          	lw	a1,32(s2)
    80004432:	03092503          	lw	a0,48(s2)
    80004436:	fffff097          	auipc	ra,0xfffff
    8000443a:	dcc080e7          	jalr	-564(ra) # 80003202 <bread>
    8000443e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004440:	03492683          	lw	a3,52(s2)
    80004444:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004446:	02d05763          	blez	a3,80004474 <write_head+0x5a>
    8000444a:	00022797          	auipc	a5,0x22
    8000444e:	ff678793          	addi	a5,a5,-10 # 80026440 <log+0x38>
    80004452:	06450713          	addi	a4,a0,100
    80004456:	36fd                	addiw	a3,a3,-1
    80004458:	1682                	slli	a3,a3,0x20
    8000445a:	9281                	srli	a3,a3,0x20
    8000445c:	068a                	slli	a3,a3,0x2
    8000445e:	00022617          	auipc	a2,0x22
    80004462:	fe660613          	addi	a2,a2,-26 # 80026444 <log+0x3c>
    80004466:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004468:	4390                	lw	a2,0(a5)
    8000446a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000446c:	0791                	addi	a5,a5,4
    8000446e:	0711                	addi	a4,a4,4
    80004470:	fed79ce3          	bne	a5,a3,80004468 <write_head+0x4e>
  }
  bwrite(buf);
    80004474:	8526                	mv	a0,s1
    80004476:	fffff097          	auipc	ra,0xfffff
    8000447a:	08e080e7          	jalr	142(ra) # 80003504 <bwrite>
  brelse(buf);
    8000447e:	8526                	mv	a0,s1
    80004480:	fffff097          	auipc	ra,0xfffff
    80004484:	0c2080e7          	jalr	194(ra) # 80003542 <brelse>
}
    80004488:	60e2                	ld	ra,24(sp)
    8000448a:	6442                	ld	s0,16(sp)
    8000448c:	64a2                	ld	s1,8(sp)
    8000448e:	6902                	ld	s2,0(sp)
    80004490:	6105                	addi	sp,sp,32
    80004492:	8082                	ret

0000000080004494 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004494:	00022797          	auipc	a5,0x22
    80004498:	fa87a783          	lw	a5,-88(a5) # 8002643c <log+0x34>
    8000449c:	0af05d63          	blez	a5,80004556 <install_trans+0xc2>
{
    800044a0:	7139                	addi	sp,sp,-64
    800044a2:	fc06                	sd	ra,56(sp)
    800044a4:	f822                	sd	s0,48(sp)
    800044a6:	f426                	sd	s1,40(sp)
    800044a8:	f04a                	sd	s2,32(sp)
    800044aa:	ec4e                	sd	s3,24(sp)
    800044ac:	e852                	sd	s4,16(sp)
    800044ae:	e456                	sd	s5,8(sp)
    800044b0:	e05a                	sd	s6,0(sp)
    800044b2:	0080                	addi	s0,sp,64
    800044b4:	8b2a                	mv	s6,a0
    800044b6:	00022a97          	auipc	s5,0x22
    800044ba:	f8aa8a93          	addi	s5,s5,-118 # 80026440 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044be:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044c0:	00022997          	auipc	s3,0x22
    800044c4:	f4898993          	addi	s3,s3,-184 # 80026408 <log>
    800044c8:	a00d                	j	800044ea <install_trans+0x56>
    brelse(lbuf);
    800044ca:	854a                	mv	a0,s2
    800044cc:	fffff097          	auipc	ra,0xfffff
    800044d0:	076080e7          	jalr	118(ra) # 80003542 <brelse>
    brelse(dbuf);
    800044d4:	8526                	mv	a0,s1
    800044d6:	fffff097          	auipc	ra,0xfffff
    800044da:	06c080e7          	jalr	108(ra) # 80003542 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044de:	2a05                	addiw	s4,s4,1
    800044e0:	0a91                	addi	s5,s5,4
    800044e2:	0349a783          	lw	a5,52(s3)
    800044e6:	04fa5e63          	bge	s4,a5,80004542 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044ea:	0209a583          	lw	a1,32(s3)
    800044ee:	014585bb          	addw	a1,a1,s4
    800044f2:	2585                	addiw	a1,a1,1
    800044f4:	0309a503          	lw	a0,48(s3)
    800044f8:	fffff097          	auipc	ra,0xfffff
    800044fc:	d0a080e7          	jalr	-758(ra) # 80003202 <bread>
    80004500:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004502:	000aa583          	lw	a1,0(s5)
    80004506:	0309a503          	lw	a0,48(s3)
    8000450a:	fffff097          	auipc	ra,0xfffff
    8000450e:	cf8080e7          	jalr	-776(ra) # 80003202 <bread>
    80004512:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004514:	40000613          	li	a2,1024
    80004518:	06090593          	addi	a1,s2,96
    8000451c:	06050513          	addi	a0,a0,96
    80004520:	ffffd097          	auipc	ra,0xffffd
    80004524:	c18080e7          	jalr	-1000(ra) # 80001138 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004528:	8526                	mv	a0,s1
    8000452a:	fffff097          	auipc	ra,0xfffff
    8000452e:	fda080e7          	jalr	-38(ra) # 80003504 <bwrite>
    if(recovering == 0)
    80004532:	f80b1ce3          	bnez	s6,800044ca <install_trans+0x36>
      bunpin(dbuf);
    80004536:	8526                	mv	a0,s1
    80004538:	fffff097          	auipc	ra,0xfffff
    8000453c:	0e8080e7          	jalr	232(ra) # 80003620 <bunpin>
    80004540:	b769                	j	800044ca <install_trans+0x36>
}
    80004542:	70e2                	ld	ra,56(sp)
    80004544:	7442                	ld	s0,48(sp)
    80004546:	74a2                	ld	s1,40(sp)
    80004548:	7902                	ld	s2,32(sp)
    8000454a:	69e2                	ld	s3,24(sp)
    8000454c:	6a42                	ld	s4,16(sp)
    8000454e:	6aa2                	ld	s5,8(sp)
    80004550:	6b02                	ld	s6,0(sp)
    80004552:	6121                	addi	sp,sp,64
    80004554:	8082                	ret
    80004556:	8082                	ret

0000000080004558 <initlog>:
{
    80004558:	7179                	addi	sp,sp,-48
    8000455a:	f406                	sd	ra,40(sp)
    8000455c:	f022                	sd	s0,32(sp)
    8000455e:	ec26                	sd	s1,24(sp)
    80004560:	e84a                	sd	s2,16(sp)
    80004562:	e44e                	sd	s3,8(sp)
    80004564:	1800                	addi	s0,sp,48
    80004566:	892a                	mv	s2,a0
    80004568:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000456a:	00022497          	auipc	s1,0x22
    8000456e:	e9e48493          	addi	s1,s1,-354 # 80026408 <log>
    80004572:	00004597          	auipc	a1,0x4
    80004576:	12e58593          	addi	a1,a1,302 # 800086a0 <syscalls+0x1e0>
    8000457a:	8526                	mv	a0,s1
    8000457c:	ffffd097          	auipc	ra,0xffffd
    80004580:	8fc080e7          	jalr	-1796(ra) # 80000e78 <initlock>
  log.start = sb->logstart;
    80004584:	0149a583          	lw	a1,20(s3)
    80004588:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    8000458a:	0109a783          	lw	a5,16(s3)
    8000458e:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    80004590:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004594:	854a                	mv	a0,s2
    80004596:	fffff097          	auipc	ra,0xfffff
    8000459a:	c6c080e7          	jalr	-916(ra) # 80003202 <bread>
  log.lh.n = lh->n;
    8000459e:	5134                	lw	a3,96(a0)
    800045a0:	d8d4                	sw	a3,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045a2:	02d05563          	blez	a3,800045cc <initlog+0x74>
    800045a6:	06450793          	addi	a5,a0,100
    800045aa:	00022717          	auipc	a4,0x22
    800045ae:	e9670713          	addi	a4,a4,-362 # 80026440 <log+0x38>
    800045b2:	36fd                	addiw	a3,a3,-1
    800045b4:	1682                	slli	a3,a3,0x20
    800045b6:	9281                	srli	a3,a3,0x20
    800045b8:	068a                	slli	a3,a3,0x2
    800045ba:	06850613          	addi	a2,a0,104
    800045be:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800045c0:	4390                	lw	a2,0(a5)
    800045c2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045c4:	0791                	addi	a5,a5,4
    800045c6:	0711                	addi	a4,a4,4
    800045c8:	fed79ce3          	bne	a5,a3,800045c0 <initlog+0x68>
  brelse(buf);
    800045cc:	fffff097          	auipc	ra,0xfffff
    800045d0:	f76080e7          	jalr	-138(ra) # 80003542 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045d4:	4505                	li	a0,1
    800045d6:	00000097          	auipc	ra,0x0
    800045da:	ebe080e7          	jalr	-322(ra) # 80004494 <install_trans>
  log.lh.n = 0;
    800045de:	00022797          	auipc	a5,0x22
    800045e2:	e407af23          	sw	zero,-418(a5) # 8002643c <log+0x34>
  write_head(); // clear the log
    800045e6:	00000097          	auipc	ra,0x0
    800045ea:	e34080e7          	jalr	-460(ra) # 8000441a <write_head>
}
    800045ee:	70a2                	ld	ra,40(sp)
    800045f0:	7402                	ld	s0,32(sp)
    800045f2:	64e2                	ld	s1,24(sp)
    800045f4:	6942                	ld	s2,16(sp)
    800045f6:	69a2                	ld	s3,8(sp)
    800045f8:	6145                	addi	sp,sp,48
    800045fa:	8082                	ret

00000000800045fc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045fc:	1101                	addi	sp,sp,-32
    800045fe:	ec06                	sd	ra,24(sp)
    80004600:	e822                	sd	s0,16(sp)
    80004602:	e426                	sd	s1,8(sp)
    80004604:	e04a                	sd	s2,0(sp)
    80004606:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004608:	00022517          	auipc	a0,0x22
    8000460c:	e0050513          	addi	a0,a0,-512 # 80026408 <log>
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	6ec080e7          	jalr	1772(ra) # 80000cfc <acquire>
  while(1){
    if(log.committing){
    80004618:	00022497          	auipc	s1,0x22
    8000461c:	df048493          	addi	s1,s1,-528 # 80026408 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004620:	4979                	li	s2,30
    80004622:	a039                	j	80004630 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004624:	85a6                	mv	a1,s1
    80004626:	8526                	mv	a0,s1
    80004628:	ffffe097          	auipc	ra,0xffffe
    8000462c:	f2e080e7          	jalr	-210(ra) # 80002556 <sleep>
    if(log.committing){
    80004630:	54dc                	lw	a5,44(s1)
    80004632:	fbed                	bnez	a5,80004624 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004634:	549c                	lw	a5,40(s1)
    80004636:	0017871b          	addiw	a4,a5,1
    8000463a:	0007069b          	sext.w	a3,a4
    8000463e:	0027179b          	slliw	a5,a4,0x2
    80004642:	9fb9                	addw	a5,a5,a4
    80004644:	0017979b          	slliw	a5,a5,0x1
    80004648:	58d8                	lw	a4,52(s1)
    8000464a:	9fb9                	addw	a5,a5,a4
    8000464c:	00f95963          	bge	s2,a5,8000465e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004650:	85a6                	mv	a1,s1
    80004652:	8526                	mv	a0,s1
    80004654:	ffffe097          	auipc	ra,0xffffe
    80004658:	f02080e7          	jalr	-254(ra) # 80002556 <sleep>
    8000465c:	bfd1                	j	80004630 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000465e:	00022517          	auipc	a0,0x22
    80004662:	daa50513          	addi	a0,a0,-598 # 80026408 <log>
    80004666:	d514                	sw	a3,40(a0)
      release(&log.lock);
    80004668:	ffffc097          	auipc	ra,0xffffc
    8000466c:	764080e7          	jalr	1892(ra) # 80000dcc <release>
      break;
    }
  }
}
    80004670:	60e2                	ld	ra,24(sp)
    80004672:	6442                	ld	s0,16(sp)
    80004674:	64a2                	ld	s1,8(sp)
    80004676:	6902                	ld	s2,0(sp)
    80004678:	6105                	addi	sp,sp,32
    8000467a:	8082                	ret

000000008000467c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000467c:	7139                	addi	sp,sp,-64
    8000467e:	fc06                	sd	ra,56(sp)
    80004680:	f822                	sd	s0,48(sp)
    80004682:	f426                	sd	s1,40(sp)
    80004684:	f04a                	sd	s2,32(sp)
    80004686:	ec4e                	sd	s3,24(sp)
    80004688:	e852                	sd	s4,16(sp)
    8000468a:	e456                	sd	s5,8(sp)
    8000468c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000468e:	00022497          	auipc	s1,0x22
    80004692:	d7a48493          	addi	s1,s1,-646 # 80026408 <log>
    80004696:	8526                	mv	a0,s1
    80004698:	ffffc097          	auipc	ra,0xffffc
    8000469c:	664080e7          	jalr	1636(ra) # 80000cfc <acquire>
  log.outstanding -= 1;
    800046a0:	549c                	lw	a5,40(s1)
    800046a2:	37fd                	addiw	a5,a5,-1
    800046a4:	0007891b          	sext.w	s2,a5
    800046a8:	d49c                	sw	a5,40(s1)
  if(log.committing)
    800046aa:	54dc                	lw	a5,44(s1)
    800046ac:	e7b9                	bnez	a5,800046fa <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800046ae:	04091e63          	bnez	s2,8000470a <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800046b2:	00022497          	auipc	s1,0x22
    800046b6:	d5648493          	addi	s1,s1,-682 # 80026408 <log>
    800046ba:	4785                	li	a5,1
    800046bc:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800046be:	8526                	mv	a0,s1
    800046c0:	ffffc097          	auipc	ra,0xffffc
    800046c4:	70c080e7          	jalr	1804(ra) # 80000dcc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800046c8:	58dc                	lw	a5,52(s1)
    800046ca:	06f04763          	bgtz	a5,80004738 <end_op+0xbc>
    acquire(&log.lock);
    800046ce:	00022497          	auipc	s1,0x22
    800046d2:	d3a48493          	addi	s1,s1,-710 # 80026408 <log>
    800046d6:	8526                	mv	a0,s1
    800046d8:	ffffc097          	auipc	ra,0xffffc
    800046dc:	624080e7          	jalr	1572(ra) # 80000cfc <acquire>
    log.committing = 0;
    800046e0:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    800046e4:	8526                	mv	a0,s1
    800046e6:	ffffe097          	auipc	ra,0xffffe
    800046ea:	ff0080e7          	jalr	-16(ra) # 800026d6 <wakeup>
    release(&log.lock);
    800046ee:	8526                	mv	a0,s1
    800046f0:	ffffc097          	auipc	ra,0xffffc
    800046f4:	6dc080e7          	jalr	1756(ra) # 80000dcc <release>
}
    800046f8:	a03d                	j	80004726 <end_op+0xaa>
    panic("log.committing");
    800046fa:	00004517          	auipc	a0,0x4
    800046fe:	fae50513          	addi	a0,a0,-82 # 800086a8 <syscalls+0x1e8>
    80004702:	ffffc097          	auipc	ra,0xffffc
    80004706:	e48080e7          	jalr	-440(ra) # 8000054a <panic>
    wakeup(&log);
    8000470a:	00022497          	auipc	s1,0x22
    8000470e:	cfe48493          	addi	s1,s1,-770 # 80026408 <log>
    80004712:	8526                	mv	a0,s1
    80004714:	ffffe097          	auipc	ra,0xffffe
    80004718:	fc2080e7          	jalr	-62(ra) # 800026d6 <wakeup>
  release(&log.lock);
    8000471c:	8526                	mv	a0,s1
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	6ae080e7          	jalr	1710(ra) # 80000dcc <release>
}
    80004726:	70e2                	ld	ra,56(sp)
    80004728:	7442                	ld	s0,48(sp)
    8000472a:	74a2                	ld	s1,40(sp)
    8000472c:	7902                	ld	s2,32(sp)
    8000472e:	69e2                	ld	s3,24(sp)
    80004730:	6a42                	ld	s4,16(sp)
    80004732:	6aa2                	ld	s5,8(sp)
    80004734:	6121                	addi	sp,sp,64
    80004736:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004738:	00022a97          	auipc	s5,0x22
    8000473c:	d08a8a93          	addi	s5,s5,-760 # 80026440 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004740:	00022a17          	auipc	s4,0x22
    80004744:	cc8a0a13          	addi	s4,s4,-824 # 80026408 <log>
    80004748:	020a2583          	lw	a1,32(s4)
    8000474c:	012585bb          	addw	a1,a1,s2
    80004750:	2585                	addiw	a1,a1,1
    80004752:	030a2503          	lw	a0,48(s4)
    80004756:	fffff097          	auipc	ra,0xfffff
    8000475a:	aac080e7          	jalr	-1364(ra) # 80003202 <bread>
    8000475e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004760:	000aa583          	lw	a1,0(s5)
    80004764:	030a2503          	lw	a0,48(s4)
    80004768:	fffff097          	auipc	ra,0xfffff
    8000476c:	a9a080e7          	jalr	-1382(ra) # 80003202 <bread>
    80004770:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004772:	40000613          	li	a2,1024
    80004776:	06050593          	addi	a1,a0,96
    8000477a:	06048513          	addi	a0,s1,96
    8000477e:	ffffd097          	auipc	ra,0xffffd
    80004782:	9ba080e7          	jalr	-1606(ra) # 80001138 <memmove>
    bwrite(to);  // write the log
    80004786:	8526                	mv	a0,s1
    80004788:	fffff097          	auipc	ra,0xfffff
    8000478c:	d7c080e7          	jalr	-644(ra) # 80003504 <bwrite>
    brelse(from);
    80004790:	854e                	mv	a0,s3
    80004792:	fffff097          	auipc	ra,0xfffff
    80004796:	db0080e7          	jalr	-592(ra) # 80003542 <brelse>
    brelse(to);
    8000479a:	8526                	mv	a0,s1
    8000479c:	fffff097          	auipc	ra,0xfffff
    800047a0:	da6080e7          	jalr	-602(ra) # 80003542 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047a4:	2905                	addiw	s2,s2,1
    800047a6:	0a91                	addi	s5,s5,4
    800047a8:	034a2783          	lw	a5,52(s4)
    800047ac:	f8f94ee3          	blt	s2,a5,80004748 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800047b0:	00000097          	auipc	ra,0x0
    800047b4:	c6a080e7          	jalr	-918(ra) # 8000441a <write_head>
    install_trans(0); // Now install writes to home locations
    800047b8:	4501                	li	a0,0
    800047ba:	00000097          	auipc	ra,0x0
    800047be:	cda080e7          	jalr	-806(ra) # 80004494 <install_trans>
    log.lh.n = 0;
    800047c2:	00022797          	auipc	a5,0x22
    800047c6:	c607ad23          	sw	zero,-902(a5) # 8002643c <log+0x34>
    write_head();    // Erase the transaction from the log
    800047ca:	00000097          	auipc	ra,0x0
    800047ce:	c50080e7          	jalr	-944(ra) # 8000441a <write_head>
    800047d2:	bdf5                	j	800046ce <end_op+0x52>

00000000800047d4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800047d4:	1101                	addi	sp,sp,-32
    800047d6:	ec06                	sd	ra,24(sp)
    800047d8:	e822                	sd	s0,16(sp)
    800047da:	e426                	sd	s1,8(sp)
    800047dc:	e04a                	sd	s2,0(sp)
    800047de:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047e0:	00022717          	auipc	a4,0x22
    800047e4:	c5c72703          	lw	a4,-932(a4) # 8002643c <log+0x34>
    800047e8:	47f5                	li	a5,29
    800047ea:	08e7c063          	blt	a5,a4,8000486a <log_write+0x96>
    800047ee:	84aa                	mv	s1,a0
    800047f0:	00022797          	auipc	a5,0x22
    800047f4:	c3c7a783          	lw	a5,-964(a5) # 8002642c <log+0x24>
    800047f8:	37fd                	addiw	a5,a5,-1
    800047fa:	06f75863          	bge	a4,a5,8000486a <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047fe:	00022797          	auipc	a5,0x22
    80004802:	c327a783          	lw	a5,-974(a5) # 80026430 <log+0x28>
    80004806:	06f05a63          	blez	a5,8000487a <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    8000480a:	00022917          	auipc	s2,0x22
    8000480e:	bfe90913          	addi	s2,s2,-1026 # 80026408 <log>
    80004812:	854a                	mv	a0,s2
    80004814:	ffffc097          	auipc	ra,0xffffc
    80004818:	4e8080e7          	jalr	1256(ra) # 80000cfc <acquire>
  for (i = 0; i < log.lh.n; i++) {
    8000481c:	03492603          	lw	a2,52(s2)
    80004820:	06c05563          	blez	a2,8000488a <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004824:	44cc                	lw	a1,12(s1)
    80004826:	00022717          	auipc	a4,0x22
    8000482a:	c1a70713          	addi	a4,a4,-998 # 80026440 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    8000482e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004830:	4314                	lw	a3,0(a4)
    80004832:	04b68d63          	beq	a3,a1,8000488c <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004836:	2785                	addiw	a5,a5,1
    80004838:	0711                	addi	a4,a4,4
    8000483a:	fec79be3          	bne	a5,a2,80004830 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000483e:	0631                	addi	a2,a2,12
    80004840:	060a                	slli	a2,a2,0x2
    80004842:	00022797          	auipc	a5,0x22
    80004846:	bc678793          	addi	a5,a5,-1082 # 80026408 <log>
    8000484a:	963e                	add	a2,a2,a5
    8000484c:	44dc                	lw	a5,12(s1)
    8000484e:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004850:	8526                	mv	a0,s1
    80004852:	fffff097          	auipc	ra,0xfffff
    80004856:	d7e080e7          	jalr	-642(ra) # 800035d0 <bpin>
    log.lh.n++;
    8000485a:	00022717          	auipc	a4,0x22
    8000485e:	bae70713          	addi	a4,a4,-1106 # 80026408 <log>
    80004862:	5b5c                	lw	a5,52(a4)
    80004864:	2785                	addiw	a5,a5,1
    80004866:	db5c                	sw	a5,52(a4)
    80004868:	a83d                	j	800048a6 <log_write+0xd2>
    panic("too big a transaction");
    8000486a:	00004517          	auipc	a0,0x4
    8000486e:	e4e50513          	addi	a0,a0,-434 # 800086b8 <syscalls+0x1f8>
    80004872:	ffffc097          	auipc	ra,0xffffc
    80004876:	cd8080e7          	jalr	-808(ra) # 8000054a <panic>
    panic("log_write outside of trans");
    8000487a:	00004517          	auipc	a0,0x4
    8000487e:	e5650513          	addi	a0,a0,-426 # 800086d0 <syscalls+0x210>
    80004882:	ffffc097          	auipc	ra,0xffffc
    80004886:	cc8080e7          	jalr	-824(ra) # 8000054a <panic>
  for (i = 0; i < log.lh.n; i++) {
    8000488a:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    8000488c:	00c78713          	addi	a4,a5,12
    80004890:	00271693          	slli	a3,a4,0x2
    80004894:	00022717          	auipc	a4,0x22
    80004898:	b7470713          	addi	a4,a4,-1164 # 80026408 <log>
    8000489c:	9736                	add	a4,a4,a3
    8000489e:	44d4                	lw	a3,12(s1)
    800048a0:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800048a2:	faf607e3          	beq	a2,a5,80004850 <log_write+0x7c>
  }
  release(&log.lock);
    800048a6:	00022517          	auipc	a0,0x22
    800048aa:	b6250513          	addi	a0,a0,-1182 # 80026408 <log>
    800048ae:	ffffc097          	auipc	ra,0xffffc
    800048b2:	51e080e7          	jalr	1310(ra) # 80000dcc <release>
}
    800048b6:	60e2                	ld	ra,24(sp)
    800048b8:	6442                	ld	s0,16(sp)
    800048ba:	64a2                	ld	s1,8(sp)
    800048bc:	6902                	ld	s2,0(sp)
    800048be:	6105                	addi	sp,sp,32
    800048c0:	8082                	ret

00000000800048c2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800048c2:	1101                	addi	sp,sp,-32
    800048c4:	ec06                	sd	ra,24(sp)
    800048c6:	e822                	sd	s0,16(sp)
    800048c8:	e426                	sd	s1,8(sp)
    800048ca:	e04a                	sd	s2,0(sp)
    800048cc:	1000                	addi	s0,sp,32
    800048ce:	84aa                	mv	s1,a0
    800048d0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048d2:	00004597          	auipc	a1,0x4
    800048d6:	e1e58593          	addi	a1,a1,-482 # 800086f0 <syscalls+0x230>
    800048da:	0521                	addi	a0,a0,8
    800048dc:	ffffc097          	auipc	ra,0xffffc
    800048e0:	59c080e7          	jalr	1436(ra) # 80000e78 <initlock>
  lk->name = name;
    800048e4:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    800048e8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048ec:	0204a823          	sw	zero,48(s1)
}
    800048f0:	60e2                	ld	ra,24(sp)
    800048f2:	6442                	ld	s0,16(sp)
    800048f4:	64a2                	ld	s1,8(sp)
    800048f6:	6902                	ld	s2,0(sp)
    800048f8:	6105                	addi	sp,sp,32
    800048fa:	8082                	ret

00000000800048fc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048fc:	1101                	addi	sp,sp,-32
    800048fe:	ec06                	sd	ra,24(sp)
    80004900:	e822                	sd	s0,16(sp)
    80004902:	e426                	sd	s1,8(sp)
    80004904:	e04a                	sd	s2,0(sp)
    80004906:	1000                	addi	s0,sp,32
    80004908:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000490a:	00850913          	addi	s2,a0,8
    8000490e:	854a                	mv	a0,s2
    80004910:	ffffc097          	auipc	ra,0xffffc
    80004914:	3ec080e7          	jalr	1004(ra) # 80000cfc <acquire>
  while (lk->locked) {
    80004918:	409c                	lw	a5,0(s1)
    8000491a:	cb89                	beqz	a5,8000492c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000491c:	85ca                	mv	a1,s2
    8000491e:	8526                	mv	a0,s1
    80004920:	ffffe097          	auipc	ra,0xffffe
    80004924:	c36080e7          	jalr	-970(ra) # 80002556 <sleep>
  while (lk->locked) {
    80004928:	409c                	lw	a5,0(s1)
    8000492a:	fbed                	bnez	a5,8000491c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000492c:	4785                	li	a5,1
    8000492e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004930:	ffffd097          	auipc	ra,0xffffd
    80004934:	412080e7          	jalr	1042(ra) # 80001d42 <myproc>
    80004938:	413c                	lw	a5,64(a0)
    8000493a:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    8000493c:	854a                	mv	a0,s2
    8000493e:	ffffc097          	auipc	ra,0xffffc
    80004942:	48e080e7          	jalr	1166(ra) # 80000dcc <release>
}
    80004946:	60e2                	ld	ra,24(sp)
    80004948:	6442                	ld	s0,16(sp)
    8000494a:	64a2                	ld	s1,8(sp)
    8000494c:	6902                	ld	s2,0(sp)
    8000494e:	6105                	addi	sp,sp,32
    80004950:	8082                	ret

0000000080004952 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004952:	1101                	addi	sp,sp,-32
    80004954:	ec06                	sd	ra,24(sp)
    80004956:	e822                	sd	s0,16(sp)
    80004958:	e426                	sd	s1,8(sp)
    8000495a:	e04a                	sd	s2,0(sp)
    8000495c:	1000                	addi	s0,sp,32
    8000495e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004960:	00850913          	addi	s2,a0,8
    80004964:	854a                	mv	a0,s2
    80004966:	ffffc097          	auipc	ra,0xffffc
    8000496a:	396080e7          	jalr	918(ra) # 80000cfc <acquire>
  lk->locked = 0;
    8000496e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004972:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    80004976:	8526                	mv	a0,s1
    80004978:	ffffe097          	auipc	ra,0xffffe
    8000497c:	d5e080e7          	jalr	-674(ra) # 800026d6 <wakeup>
  release(&lk->lk);
    80004980:	854a                	mv	a0,s2
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	44a080e7          	jalr	1098(ra) # 80000dcc <release>
}
    8000498a:	60e2                	ld	ra,24(sp)
    8000498c:	6442                	ld	s0,16(sp)
    8000498e:	64a2                	ld	s1,8(sp)
    80004990:	6902                	ld	s2,0(sp)
    80004992:	6105                	addi	sp,sp,32
    80004994:	8082                	ret

0000000080004996 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004996:	7179                	addi	sp,sp,-48
    80004998:	f406                	sd	ra,40(sp)
    8000499a:	f022                	sd	s0,32(sp)
    8000499c:	ec26                	sd	s1,24(sp)
    8000499e:	e84a                	sd	s2,16(sp)
    800049a0:	e44e                	sd	s3,8(sp)
    800049a2:	1800                	addi	s0,sp,48
    800049a4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049a6:	00850913          	addi	s2,a0,8
    800049aa:	854a                	mv	a0,s2
    800049ac:	ffffc097          	auipc	ra,0xffffc
    800049b0:	350080e7          	jalr	848(ra) # 80000cfc <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049b4:	409c                	lw	a5,0(s1)
    800049b6:	ef99                	bnez	a5,800049d4 <holdingsleep+0x3e>
    800049b8:	4481                	li	s1,0
  release(&lk->lk);
    800049ba:	854a                	mv	a0,s2
    800049bc:	ffffc097          	auipc	ra,0xffffc
    800049c0:	410080e7          	jalr	1040(ra) # 80000dcc <release>
  return r;
}
    800049c4:	8526                	mv	a0,s1
    800049c6:	70a2                	ld	ra,40(sp)
    800049c8:	7402                	ld	s0,32(sp)
    800049ca:	64e2                	ld	s1,24(sp)
    800049cc:	6942                	ld	s2,16(sp)
    800049ce:	69a2                	ld	s3,8(sp)
    800049d0:	6145                	addi	sp,sp,48
    800049d2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800049d4:	0304a983          	lw	s3,48(s1)
    800049d8:	ffffd097          	auipc	ra,0xffffd
    800049dc:	36a080e7          	jalr	874(ra) # 80001d42 <myproc>
    800049e0:	4124                	lw	s1,64(a0)
    800049e2:	413484b3          	sub	s1,s1,s3
    800049e6:	0014b493          	seqz	s1,s1
    800049ea:	bfc1                	j	800049ba <holdingsleep+0x24>

00000000800049ec <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800049ec:	1141                	addi	sp,sp,-16
    800049ee:	e406                	sd	ra,8(sp)
    800049f0:	e022                	sd	s0,0(sp)
    800049f2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049f4:	00004597          	auipc	a1,0x4
    800049f8:	d0c58593          	addi	a1,a1,-756 # 80008700 <syscalls+0x240>
    800049fc:	00022517          	auipc	a0,0x22
    80004a00:	b5c50513          	addi	a0,a0,-1188 # 80026558 <ftable>
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	474080e7          	jalr	1140(ra) # 80000e78 <initlock>
}
    80004a0c:	60a2                	ld	ra,8(sp)
    80004a0e:	6402                	ld	s0,0(sp)
    80004a10:	0141                	addi	sp,sp,16
    80004a12:	8082                	ret

0000000080004a14 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a14:	1101                	addi	sp,sp,-32
    80004a16:	ec06                	sd	ra,24(sp)
    80004a18:	e822                	sd	s0,16(sp)
    80004a1a:	e426                	sd	s1,8(sp)
    80004a1c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a1e:	00022517          	auipc	a0,0x22
    80004a22:	b3a50513          	addi	a0,a0,-1222 # 80026558 <ftable>
    80004a26:	ffffc097          	auipc	ra,0xffffc
    80004a2a:	2d6080e7          	jalr	726(ra) # 80000cfc <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a2e:	00022497          	auipc	s1,0x22
    80004a32:	b4a48493          	addi	s1,s1,-1206 # 80026578 <ftable+0x20>
    80004a36:	00023717          	auipc	a4,0x23
    80004a3a:	ae270713          	addi	a4,a4,-1310 # 80027518 <ftable+0xfc0>
    if(f->ref == 0){
    80004a3e:	40dc                	lw	a5,4(s1)
    80004a40:	cf99                	beqz	a5,80004a5e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a42:	02848493          	addi	s1,s1,40
    80004a46:	fee49ce3          	bne	s1,a4,80004a3e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a4a:	00022517          	auipc	a0,0x22
    80004a4e:	b0e50513          	addi	a0,a0,-1266 # 80026558 <ftable>
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	37a080e7          	jalr	890(ra) # 80000dcc <release>
  return 0;
    80004a5a:	4481                	li	s1,0
    80004a5c:	a819                	j	80004a72 <filealloc+0x5e>
      f->ref = 1;
    80004a5e:	4785                	li	a5,1
    80004a60:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a62:	00022517          	auipc	a0,0x22
    80004a66:	af650513          	addi	a0,a0,-1290 # 80026558 <ftable>
    80004a6a:	ffffc097          	auipc	ra,0xffffc
    80004a6e:	362080e7          	jalr	866(ra) # 80000dcc <release>
}
    80004a72:	8526                	mv	a0,s1
    80004a74:	60e2                	ld	ra,24(sp)
    80004a76:	6442                	ld	s0,16(sp)
    80004a78:	64a2                	ld	s1,8(sp)
    80004a7a:	6105                	addi	sp,sp,32
    80004a7c:	8082                	ret

0000000080004a7e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a7e:	1101                	addi	sp,sp,-32
    80004a80:	ec06                	sd	ra,24(sp)
    80004a82:	e822                	sd	s0,16(sp)
    80004a84:	e426                	sd	s1,8(sp)
    80004a86:	1000                	addi	s0,sp,32
    80004a88:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a8a:	00022517          	auipc	a0,0x22
    80004a8e:	ace50513          	addi	a0,a0,-1330 # 80026558 <ftable>
    80004a92:	ffffc097          	auipc	ra,0xffffc
    80004a96:	26a080e7          	jalr	618(ra) # 80000cfc <acquire>
  if(f->ref < 1)
    80004a9a:	40dc                	lw	a5,4(s1)
    80004a9c:	02f05263          	blez	a5,80004ac0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004aa0:	2785                	addiw	a5,a5,1
    80004aa2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004aa4:	00022517          	auipc	a0,0x22
    80004aa8:	ab450513          	addi	a0,a0,-1356 # 80026558 <ftable>
    80004aac:	ffffc097          	auipc	ra,0xffffc
    80004ab0:	320080e7          	jalr	800(ra) # 80000dcc <release>
  return f;
}
    80004ab4:	8526                	mv	a0,s1
    80004ab6:	60e2                	ld	ra,24(sp)
    80004ab8:	6442                	ld	s0,16(sp)
    80004aba:	64a2                	ld	s1,8(sp)
    80004abc:	6105                	addi	sp,sp,32
    80004abe:	8082                	ret
    panic("filedup");
    80004ac0:	00004517          	auipc	a0,0x4
    80004ac4:	c4850513          	addi	a0,a0,-952 # 80008708 <syscalls+0x248>
    80004ac8:	ffffc097          	auipc	ra,0xffffc
    80004acc:	a82080e7          	jalr	-1406(ra) # 8000054a <panic>

0000000080004ad0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004ad0:	7139                	addi	sp,sp,-64
    80004ad2:	fc06                	sd	ra,56(sp)
    80004ad4:	f822                	sd	s0,48(sp)
    80004ad6:	f426                	sd	s1,40(sp)
    80004ad8:	f04a                	sd	s2,32(sp)
    80004ada:	ec4e                	sd	s3,24(sp)
    80004adc:	e852                	sd	s4,16(sp)
    80004ade:	e456                	sd	s5,8(sp)
    80004ae0:	0080                	addi	s0,sp,64
    80004ae2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ae4:	00022517          	auipc	a0,0x22
    80004ae8:	a7450513          	addi	a0,a0,-1420 # 80026558 <ftable>
    80004aec:	ffffc097          	auipc	ra,0xffffc
    80004af0:	210080e7          	jalr	528(ra) # 80000cfc <acquire>
  if(f->ref < 1)
    80004af4:	40dc                	lw	a5,4(s1)
    80004af6:	06f05163          	blez	a5,80004b58 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004afa:	37fd                	addiw	a5,a5,-1
    80004afc:	0007871b          	sext.w	a4,a5
    80004b00:	c0dc                	sw	a5,4(s1)
    80004b02:	06e04363          	bgtz	a4,80004b68 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b06:	0004a903          	lw	s2,0(s1)
    80004b0a:	0094ca83          	lbu	s5,9(s1)
    80004b0e:	0104ba03          	ld	s4,16(s1)
    80004b12:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b16:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b1a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b1e:	00022517          	auipc	a0,0x22
    80004b22:	a3a50513          	addi	a0,a0,-1478 # 80026558 <ftable>
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	2a6080e7          	jalr	678(ra) # 80000dcc <release>

  if(ff.type == FD_PIPE){
    80004b2e:	4785                	li	a5,1
    80004b30:	04f90d63          	beq	s2,a5,80004b8a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b34:	3979                	addiw	s2,s2,-2
    80004b36:	4785                	li	a5,1
    80004b38:	0527e063          	bltu	a5,s2,80004b78 <fileclose+0xa8>
    begin_op();
    80004b3c:	00000097          	auipc	ra,0x0
    80004b40:	ac0080e7          	jalr	-1344(ra) # 800045fc <begin_op>
    iput(ff.ip);
    80004b44:	854e                	mv	a0,s3
    80004b46:	fffff097          	auipc	ra,0xfffff
    80004b4a:	2a0080e7          	jalr	672(ra) # 80003de6 <iput>
    end_op();
    80004b4e:	00000097          	auipc	ra,0x0
    80004b52:	b2e080e7          	jalr	-1234(ra) # 8000467c <end_op>
    80004b56:	a00d                	j	80004b78 <fileclose+0xa8>
    panic("fileclose");
    80004b58:	00004517          	auipc	a0,0x4
    80004b5c:	bb850513          	addi	a0,a0,-1096 # 80008710 <syscalls+0x250>
    80004b60:	ffffc097          	auipc	ra,0xffffc
    80004b64:	9ea080e7          	jalr	-1558(ra) # 8000054a <panic>
    release(&ftable.lock);
    80004b68:	00022517          	auipc	a0,0x22
    80004b6c:	9f050513          	addi	a0,a0,-1552 # 80026558 <ftable>
    80004b70:	ffffc097          	auipc	ra,0xffffc
    80004b74:	25c080e7          	jalr	604(ra) # 80000dcc <release>
  }
}
    80004b78:	70e2                	ld	ra,56(sp)
    80004b7a:	7442                	ld	s0,48(sp)
    80004b7c:	74a2                	ld	s1,40(sp)
    80004b7e:	7902                	ld	s2,32(sp)
    80004b80:	69e2                	ld	s3,24(sp)
    80004b82:	6a42                	ld	s4,16(sp)
    80004b84:	6aa2                	ld	s5,8(sp)
    80004b86:	6121                	addi	sp,sp,64
    80004b88:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b8a:	85d6                	mv	a1,s5
    80004b8c:	8552                	mv	a0,s4
    80004b8e:	00000097          	auipc	ra,0x0
    80004b92:	372080e7          	jalr	882(ra) # 80004f00 <pipeclose>
    80004b96:	b7cd                	j	80004b78 <fileclose+0xa8>

0000000080004b98 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b98:	715d                	addi	sp,sp,-80
    80004b9a:	e486                	sd	ra,72(sp)
    80004b9c:	e0a2                	sd	s0,64(sp)
    80004b9e:	fc26                	sd	s1,56(sp)
    80004ba0:	f84a                	sd	s2,48(sp)
    80004ba2:	f44e                	sd	s3,40(sp)
    80004ba4:	0880                	addi	s0,sp,80
    80004ba6:	84aa                	mv	s1,a0
    80004ba8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004baa:	ffffd097          	auipc	ra,0xffffd
    80004bae:	198080e7          	jalr	408(ra) # 80001d42 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004bb2:	409c                	lw	a5,0(s1)
    80004bb4:	37f9                	addiw	a5,a5,-2
    80004bb6:	4705                	li	a4,1
    80004bb8:	04f76763          	bltu	a4,a5,80004c06 <filestat+0x6e>
    80004bbc:	892a                	mv	s2,a0
    ilock(f->ip);
    80004bbe:	6c88                	ld	a0,24(s1)
    80004bc0:	fffff097          	auipc	ra,0xfffff
    80004bc4:	06c080e7          	jalr	108(ra) # 80003c2c <ilock>
    stati(f->ip, &st);
    80004bc8:	fb840593          	addi	a1,s0,-72
    80004bcc:	6c88                	ld	a0,24(s1)
    80004bce:	fffff097          	auipc	ra,0xfffff
    80004bd2:	2e8080e7          	jalr	744(ra) # 80003eb6 <stati>
    iunlock(f->ip);
    80004bd6:	6c88                	ld	a0,24(s1)
    80004bd8:	fffff097          	auipc	ra,0xfffff
    80004bdc:	116080e7          	jalr	278(ra) # 80003cee <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004be0:	46e1                	li	a3,24
    80004be2:	fb840613          	addi	a2,s0,-72
    80004be6:	85ce                	mv	a1,s3
    80004be8:	05893503          	ld	a0,88(s2)
    80004bec:	ffffd097          	auipc	ra,0xffffd
    80004bf0:	e48080e7          	jalr	-440(ra) # 80001a34 <copyout>
    80004bf4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004bf8:	60a6                	ld	ra,72(sp)
    80004bfa:	6406                	ld	s0,64(sp)
    80004bfc:	74e2                	ld	s1,56(sp)
    80004bfe:	7942                	ld	s2,48(sp)
    80004c00:	79a2                	ld	s3,40(sp)
    80004c02:	6161                	addi	sp,sp,80
    80004c04:	8082                	ret
  return -1;
    80004c06:	557d                	li	a0,-1
    80004c08:	bfc5                	j	80004bf8 <filestat+0x60>

0000000080004c0a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c0a:	7179                	addi	sp,sp,-48
    80004c0c:	f406                	sd	ra,40(sp)
    80004c0e:	f022                	sd	s0,32(sp)
    80004c10:	ec26                	sd	s1,24(sp)
    80004c12:	e84a                	sd	s2,16(sp)
    80004c14:	e44e                	sd	s3,8(sp)
    80004c16:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c18:	00854783          	lbu	a5,8(a0)
    80004c1c:	c3d5                	beqz	a5,80004cc0 <fileread+0xb6>
    80004c1e:	84aa                	mv	s1,a0
    80004c20:	89ae                	mv	s3,a1
    80004c22:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c24:	411c                	lw	a5,0(a0)
    80004c26:	4705                	li	a4,1
    80004c28:	04e78963          	beq	a5,a4,80004c7a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c2c:	470d                	li	a4,3
    80004c2e:	04e78d63          	beq	a5,a4,80004c88 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c32:	4709                	li	a4,2
    80004c34:	06e79e63          	bne	a5,a4,80004cb0 <fileread+0xa6>
    ilock(f->ip);
    80004c38:	6d08                	ld	a0,24(a0)
    80004c3a:	fffff097          	auipc	ra,0xfffff
    80004c3e:	ff2080e7          	jalr	-14(ra) # 80003c2c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c42:	874a                	mv	a4,s2
    80004c44:	5094                	lw	a3,32(s1)
    80004c46:	864e                	mv	a2,s3
    80004c48:	4585                	li	a1,1
    80004c4a:	6c88                	ld	a0,24(s1)
    80004c4c:	fffff097          	auipc	ra,0xfffff
    80004c50:	294080e7          	jalr	660(ra) # 80003ee0 <readi>
    80004c54:	892a                	mv	s2,a0
    80004c56:	00a05563          	blez	a0,80004c60 <fileread+0x56>
      f->off += r;
    80004c5a:	509c                	lw	a5,32(s1)
    80004c5c:	9fa9                	addw	a5,a5,a0
    80004c5e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c60:	6c88                	ld	a0,24(s1)
    80004c62:	fffff097          	auipc	ra,0xfffff
    80004c66:	08c080e7          	jalr	140(ra) # 80003cee <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c6a:	854a                	mv	a0,s2
    80004c6c:	70a2                	ld	ra,40(sp)
    80004c6e:	7402                	ld	s0,32(sp)
    80004c70:	64e2                	ld	s1,24(sp)
    80004c72:	6942                	ld	s2,16(sp)
    80004c74:	69a2                	ld	s3,8(sp)
    80004c76:	6145                	addi	sp,sp,48
    80004c78:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c7a:	6908                	ld	a0,16(a0)
    80004c7c:	00000097          	auipc	ra,0x0
    80004c80:	3fe080e7          	jalr	1022(ra) # 8000507a <piperead>
    80004c84:	892a                	mv	s2,a0
    80004c86:	b7d5                	j	80004c6a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c88:	02451783          	lh	a5,36(a0)
    80004c8c:	03079693          	slli	a3,a5,0x30
    80004c90:	92c1                	srli	a3,a3,0x30
    80004c92:	4725                	li	a4,9
    80004c94:	02d76863          	bltu	a4,a3,80004cc4 <fileread+0xba>
    80004c98:	0792                	slli	a5,a5,0x4
    80004c9a:	00022717          	auipc	a4,0x22
    80004c9e:	81e70713          	addi	a4,a4,-2018 # 800264b8 <devsw>
    80004ca2:	97ba                	add	a5,a5,a4
    80004ca4:	639c                	ld	a5,0(a5)
    80004ca6:	c38d                	beqz	a5,80004cc8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004ca8:	4505                	li	a0,1
    80004caa:	9782                	jalr	a5
    80004cac:	892a                	mv	s2,a0
    80004cae:	bf75                	j	80004c6a <fileread+0x60>
    panic("fileread");
    80004cb0:	00004517          	auipc	a0,0x4
    80004cb4:	a7050513          	addi	a0,a0,-1424 # 80008720 <syscalls+0x260>
    80004cb8:	ffffc097          	auipc	ra,0xffffc
    80004cbc:	892080e7          	jalr	-1902(ra) # 8000054a <panic>
    return -1;
    80004cc0:	597d                	li	s2,-1
    80004cc2:	b765                	j	80004c6a <fileread+0x60>
      return -1;
    80004cc4:	597d                	li	s2,-1
    80004cc6:	b755                	j	80004c6a <fileread+0x60>
    80004cc8:	597d                	li	s2,-1
    80004cca:	b745                	j	80004c6a <fileread+0x60>

0000000080004ccc <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004ccc:	00954783          	lbu	a5,9(a0)
    80004cd0:	14078563          	beqz	a5,80004e1a <filewrite+0x14e>
{
    80004cd4:	715d                	addi	sp,sp,-80
    80004cd6:	e486                	sd	ra,72(sp)
    80004cd8:	e0a2                	sd	s0,64(sp)
    80004cda:	fc26                	sd	s1,56(sp)
    80004cdc:	f84a                	sd	s2,48(sp)
    80004cde:	f44e                	sd	s3,40(sp)
    80004ce0:	f052                	sd	s4,32(sp)
    80004ce2:	ec56                	sd	s5,24(sp)
    80004ce4:	e85a                	sd	s6,16(sp)
    80004ce6:	e45e                	sd	s7,8(sp)
    80004ce8:	e062                	sd	s8,0(sp)
    80004cea:	0880                	addi	s0,sp,80
    80004cec:	892a                	mv	s2,a0
    80004cee:	8aae                	mv	s5,a1
    80004cf0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cf2:	411c                	lw	a5,0(a0)
    80004cf4:	4705                	li	a4,1
    80004cf6:	02e78263          	beq	a5,a4,80004d1a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cfa:	470d                	li	a4,3
    80004cfc:	02e78563          	beq	a5,a4,80004d26 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d00:	4709                	li	a4,2
    80004d02:	10e79463          	bne	a5,a4,80004e0a <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d06:	0ec05e63          	blez	a2,80004e02 <filewrite+0x136>
    int i = 0;
    80004d0a:	4981                	li	s3,0
    80004d0c:	6b05                	lui	s6,0x1
    80004d0e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d12:	6b85                	lui	s7,0x1
    80004d14:	c00b8b9b          	addiw	s7,s7,-1024
    80004d18:	a851                	j	80004dac <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004d1a:	6908                	ld	a0,16(a0)
    80004d1c:	00000097          	auipc	ra,0x0
    80004d20:	25e080e7          	jalr	606(ra) # 80004f7a <pipewrite>
    80004d24:	a85d                	j	80004dda <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d26:	02451783          	lh	a5,36(a0)
    80004d2a:	03079693          	slli	a3,a5,0x30
    80004d2e:	92c1                	srli	a3,a3,0x30
    80004d30:	4725                	li	a4,9
    80004d32:	0ed76663          	bltu	a4,a3,80004e1e <filewrite+0x152>
    80004d36:	0792                	slli	a5,a5,0x4
    80004d38:	00021717          	auipc	a4,0x21
    80004d3c:	78070713          	addi	a4,a4,1920 # 800264b8 <devsw>
    80004d40:	97ba                	add	a5,a5,a4
    80004d42:	679c                	ld	a5,8(a5)
    80004d44:	cff9                	beqz	a5,80004e22 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004d46:	4505                	li	a0,1
    80004d48:	9782                	jalr	a5
    80004d4a:	a841                	j	80004dda <filewrite+0x10e>
    80004d4c:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d50:	00000097          	auipc	ra,0x0
    80004d54:	8ac080e7          	jalr	-1876(ra) # 800045fc <begin_op>
      ilock(f->ip);
    80004d58:	01893503          	ld	a0,24(s2)
    80004d5c:	fffff097          	auipc	ra,0xfffff
    80004d60:	ed0080e7          	jalr	-304(ra) # 80003c2c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d64:	8762                	mv	a4,s8
    80004d66:	02092683          	lw	a3,32(s2)
    80004d6a:	01598633          	add	a2,s3,s5
    80004d6e:	4585                	li	a1,1
    80004d70:	01893503          	ld	a0,24(s2)
    80004d74:	fffff097          	auipc	ra,0xfffff
    80004d78:	264080e7          	jalr	612(ra) # 80003fd8 <writei>
    80004d7c:	84aa                	mv	s1,a0
    80004d7e:	02a05f63          	blez	a0,80004dbc <filewrite+0xf0>
        f->off += r;
    80004d82:	02092783          	lw	a5,32(s2)
    80004d86:	9fa9                	addw	a5,a5,a0
    80004d88:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d8c:	01893503          	ld	a0,24(s2)
    80004d90:	fffff097          	auipc	ra,0xfffff
    80004d94:	f5e080e7          	jalr	-162(ra) # 80003cee <iunlock>
      end_op();
    80004d98:	00000097          	auipc	ra,0x0
    80004d9c:	8e4080e7          	jalr	-1820(ra) # 8000467c <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004da0:	049c1963          	bne	s8,s1,80004df2 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004da4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004da8:	0349d663          	bge	s3,s4,80004dd4 <filewrite+0x108>
      int n1 = n - i;
    80004dac:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004db0:	84be                	mv	s1,a5
    80004db2:	2781                	sext.w	a5,a5
    80004db4:	f8fb5ce3          	bge	s6,a5,80004d4c <filewrite+0x80>
    80004db8:	84de                	mv	s1,s7
    80004dba:	bf49                	j	80004d4c <filewrite+0x80>
      iunlock(f->ip);
    80004dbc:	01893503          	ld	a0,24(s2)
    80004dc0:	fffff097          	auipc	ra,0xfffff
    80004dc4:	f2e080e7          	jalr	-210(ra) # 80003cee <iunlock>
      end_op();
    80004dc8:	00000097          	auipc	ra,0x0
    80004dcc:	8b4080e7          	jalr	-1868(ra) # 8000467c <end_op>
      if(r < 0)
    80004dd0:	fc04d8e3          	bgez	s1,80004da0 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004dd4:	8552                	mv	a0,s4
    80004dd6:	033a1863          	bne	s4,s3,80004e06 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004dda:	60a6                	ld	ra,72(sp)
    80004ddc:	6406                	ld	s0,64(sp)
    80004dde:	74e2                	ld	s1,56(sp)
    80004de0:	7942                	ld	s2,48(sp)
    80004de2:	79a2                	ld	s3,40(sp)
    80004de4:	7a02                	ld	s4,32(sp)
    80004de6:	6ae2                	ld	s5,24(sp)
    80004de8:	6b42                	ld	s6,16(sp)
    80004dea:	6ba2                	ld	s7,8(sp)
    80004dec:	6c02                	ld	s8,0(sp)
    80004dee:	6161                	addi	sp,sp,80
    80004df0:	8082                	ret
        panic("short filewrite");
    80004df2:	00004517          	auipc	a0,0x4
    80004df6:	93e50513          	addi	a0,a0,-1730 # 80008730 <syscalls+0x270>
    80004dfa:	ffffb097          	auipc	ra,0xffffb
    80004dfe:	750080e7          	jalr	1872(ra) # 8000054a <panic>
    int i = 0;
    80004e02:	4981                	li	s3,0
    80004e04:	bfc1                	j	80004dd4 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004e06:	557d                	li	a0,-1
    80004e08:	bfc9                	j	80004dda <filewrite+0x10e>
    panic("filewrite");
    80004e0a:	00004517          	auipc	a0,0x4
    80004e0e:	93650513          	addi	a0,a0,-1738 # 80008740 <syscalls+0x280>
    80004e12:	ffffb097          	auipc	ra,0xffffb
    80004e16:	738080e7          	jalr	1848(ra) # 8000054a <panic>
    return -1;
    80004e1a:	557d                	li	a0,-1
}
    80004e1c:	8082                	ret
      return -1;
    80004e1e:	557d                	li	a0,-1
    80004e20:	bf6d                	j	80004dda <filewrite+0x10e>
    80004e22:	557d                	li	a0,-1
    80004e24:	bf5d                	j	80004dda <filewrite+0x10e>

0000000080004e26 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e26:	7179                	addi	sp,sp,-48
    80004e28:	f406                	sd	ra,40(sp)
    80004e2a:	f022                	sd	s0,32(sp)
    80004e2c:	ec26                	sd	s1,24(sp)
    80004e2e:	e84a                	sd	s2,16(sp)
    80004e30:	e44e                	sd	s3,8(sp)
    80004e32:	e052                	sd	s4,0(sp)
    80004e34:	1800                	addi	s0,sp,48
    80004e36:	84aa                	mv	s1,a0
    80004e38:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e3a:	0005b023          	sd	zero,0(a1)
    80004e3e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e42:	00000097          	auipc	ra,0x0
    80004e46:	bd2080e7          	jalr	-1070(ra) # 80004a14 <filealloc>
    80004e4a:	e088                	sd	a0,0(s1)
    80004e4c:	c551                	beqz	a0,80004ed8 <pipealloc+0xb2>
    80004e4e:	00000097          	auipc	ra,0x0
    80004e52:	bc6080e7          	jalr	-1082(ra) # 80004a14 <filealloc>
    80004e56:	00aa3023          	sd	a0,0(s4)
    80004e5a:	c92d                	beqz	a0,80004ecc <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e5c:	ffffc097          	auipc	ra,0xffffc
    80004e60:	d24080e7          	jalr	-732(ra) # 80000b80 <kalloc>
    80004e64:	892a                	mv	s2,a0
    80004e66:	c125                	beqz	a0,80004ec6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e68:	4985                	li	s3,1
    80004e6a:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004e6e:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004e72:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004e76:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004e7a:	00004597          	auipc	a1,0x4
    80004e7e:	8d658593          	addi	a1,a1,-1834 # 80008750 <syscalls+0x290>
    80004e82:	ffffc097          	auipc	ra,0xffffc
    80004e86:	ff6080e7          	jalr	-10(ra) # 80000e78 <initlock>
  (*f0)->type = FD_PIPE;
    80004e8a:	609c                	ld	a5,0(s1)
    80004e8c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e90:	609c                	ld	a5,0(s1)
    80004e92:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e96:	609c                	ld	a5,0(s1)
    80004e98:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e9c:	609c                	ld	a5,0(s1)
    80004e9e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ea2:	000a3783          	ld	a5,0(s4)
    80004ea6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004eaa:	000a3783          	ld	a5,0(s4)
    80004eae:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004eb2:	000a3783          	ld	a5,0(s4)
    80004eb6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004eba:	000a3783          	ld	a5,0(s4)
    80004ebe:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ec2:	4501                	li	a0,0
    80004ec4:	a025                	j	80004eec <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ec6:	6088                	ld	a0,0(s1)
    80004ec8:	e501                	bnez	a0,80004ed0 <pipealloc+0xaa>
    80004eca:	a039                	j	80004ed8 <pipealloc+0xb2>
    80004ecc:	6088                	ld	a0,0(s1)
    80004ece:	c51d                	beqz	a0,80004efc <pipealloc+0xd6>
    fileclose(*f0);
    80004ed0:	00000097          	auipc	ra,0x0
    80004ed4:	c00080e7          	jalr	-1024(ra) # 80004ad0 <fileclose>
  if(*f1)
    80004ed8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004edc:	557d                	li	a0,-1
  if(*f1)
    80004ede:	c799                	beqz	a5,80004eec <pipealloc+0xc6>
    fileclose(*f1);
    80004ee0:	853e                	mv	a0,a5
    80004ee2:	00000097          	auipc	ra,0x0
    80004ee6:	bee080e7          	jalr	-1042(ra) # 80004ad0 <fileclose>
  return -1;
    80004eea:	557d                	li	a0,-1
}
    80004eec:	70a2                	ld	ra,40(sp)
    80004eee:	7402                	ld	s0,32(sp)
    80004ef0:	64e2                	ld	s1,24(sp)
    80004ef2:	6942                	ld	s2,16(sp)
    80004ef4:	69a2                	ld	s3,8(sp)
    80004ef6:	6a02                	ld	s4,0(sp)
    80004ef8:	6145                	addi	sp,sp,48
    80004efa:	8082                	ret
  return -1;
    80004efc:	557d                	li	a0,-1
    80004efe:	b7fd                	j	80004eec <pipealloc+0xc6>

0000000080004f00 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f00:	1101                	addi	sp,sp,-32
    80004f02:	ec06                	sd	ra,24(sp)
    80004f04:	e822                	sd	s0,16(sp)
    80004f06:	e426                	sd	s1,8(sp)
    80004f08:	e04a                	sd	s2,0(sp)
    80004f0a:	1000                	addi	s0,sp,32
    80004f0c:	84aa                	mv	s1,a0
    80004f0e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f10:	ffffc097          	auipc	ra,0xffffc
    80004f14:	dec080e7          	jalr	-532(ra) # 80000cfc <acquire>
  if(writable){
    80004f18:	04090263          	beqz	s2,80004f5c <pipeclose+0x5c>
    pi->writeopen = 0;
    80004f1c:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004f20:	22048513          	addi	a0,s1,544
    80004f24:	ffffd097          	auipc	ra,0xffffd
    80004f28:	7b2080e7          	jalr	1970(ra) # 800026d6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f2c:	2284b783          	ld	a5,552(s1)
    80004f30:	ef9d                	bnez	a5,80004f6e <pipeclose+0x6e>
    release(&pi->lock);
    80004f32:	8526                	mv	a0,s1
    80004f34:	ffffc097          	auipc	ra,0xffffc
    80004f38:	e98080e7          	jalr	-360(ra) # 80000dcc <release>
#ifdef LAB_LOCK
    freelock(&pi->lock);
    80004f3c:	8526                	mv	a0,s1
    80004f3e:	ffffc097          	auipc	ra,0xffffc
    80004f42:	ed6080e7          	jalr	-298(ra) # 80000e14 <freelock>
#endif    
    kfree((char*)pi);
    80004f46:	8526                	mv	a0,s1
    80004f48:	ffffc097          	auipc	ra,0xffffc
    80004f4c:	ad2080e7          	jalr	-1326(ra) # 80000a1a <kfree>
  } else
    release(&pi->lock);
}
    80004f50:	60e2                	ld	ra,24(sp)
    80004f52:	6442                	ld	s0,16(sp)
    80004f54:	64a2                	ld	s1,8(sp)
    80004f56:	6902                	ld	s2,0(sp)
    80004f58:	6105                	addi	sp,sp,32
    80004f5a:	8082                	ret
    pi->readopen = 0;
    80004f5c:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004f60:	22448513          	addi	a0,s1,548
    80004f64:	ffffd097          	auipc	ra,0xffffd
    80004f68:	772080e7          	jalr	1906(ra) # 800026d6 <wakeup>
    80004f6c:	b7c1                	j	80004f2c <pipeclose+0x2c>
    release(&pi->lock);
    80004f6e:	8526                	mv	a0,s1
    80004f70:	ffffc097          	auipc	ra,0xffffc
    80004f74:	e5c080e7          	jalr	-420(ra) # 80000dcc <release>
}
    80004f78:	bfe1                	j	80004f50 <pipeclose+0x50>

0000000080004f7a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f7a:	711d                	addi	sp,sp,-96
    80004f7c:	ec86                	sd	ra,88(sp)
    80004f7e:	e8a2                	sd	s0,80(sp)
    80004f80:	e4a6                	sd	s1,72(sp)
    80004f82:	e0ca                	sd	s2,64(sp)
    80004f84:	fc4e                	sd	s3,56(sp)
    80004f86:	f852                	sd	s4,48(sp)
    80004f88:	f456                	sd	s5,40(sp)
    80004f8a:	f05a                	sd	s6,32(sp)
    80004f8c:	ec5e                	sd	s7,24(sp)
    80004f8e:	e862                	sd	s8,16(sp)
    80004f90:	1080                	addi	s0,sp,96
    80004f92:	84aa                	mv	s1,a0
    80004f94:	8b2e                	mv	s6,a1
    80004f96:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004f98:	ffffd097          	auipc	ra,0xffffd
    80004f9c:	daa080e7          	jalr	-598(ra) # 80001d42 <myproc>
    80004fa0:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004fa2:	8526                	mv	a0,s1
    80004fa4:	ffffc097          	auipc	ra,0xffffc
    80004fa8:	d58080e7          	jalr	-680(ra) # 80000cfc <acquire>
  for(i = 0; i < n; i++){
    80004fac:	09505763          	blez	s5,8000503a <pipewrite+0xc0>
    80004fb0:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004fb2:	22048a13          	addi	s4,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004fb6:	22448993          	addi	s3,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fba:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004fbc:	2204a783          	lw	a5,544(s1)
    80004fc0:	2244a703          	lw	a4,548(s1)
    80004fc4:	2007879b          	addiw	a5,a5,512
    80004fc8:	02f71b63          	bne	a4,a5,80004ffe <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004fcc:	2284a783          	lw	a5,552(s1)
    80004fd0:	c3d1                	beqz	a5,80005054 <pipewrite+0xda>
    80004fd2:	03892783          	lw	a5,56(s2)
    80004fd6:	efbd                	bnez	a5,80005054 <pipewrite+0xda>
      wakeup(&pi->nread);
    80004fd8:	8552                	mv	a0,s4
    80004fda:	ffffd097          	auipc	ra,0xffffd
    80004fde:	6fc080e7          	jalr	1788(ra) # 800026d6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004fe2:	85a6                	mv	a1,s1
    80004fe4:	854e                	mv	a0,s3
    80004fe6:	ffffd097          	auipc	ra,0xffffd
    80004fea:	570080e7          	jalr	1392(ra) # 80002556 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004fee:	2204a783          	lw	a5,544(s1)
    80004ff2:	2244a703          	lw	a4,548(s1)
    80004ff6:	2007879b          	addiw	a5,a5,512
    80004ffa:	fcf709e3          	beq	a4,a5,80004fcc <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ffe:	4685                	li	a3,1
    80005000:	865a                	mv	a2,s6
    80005002:	faf40593          	addi	a1,s0,-81
    80005006:	05893503          	ld	a0,88(s2)
    8000500a:	ffffd097          	auipc	ra,0xffffd
    8000500e:	ab6080e7          	jalr	-1354(ra) # 80001ac0 <copyin>
    80005012:	03850563          	beq	a0,s8,8000503c <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005016:	2244a783          	lw	a5,548(s1)
    8000501a:	0017871b          	addiw	a4,a5,1
    8000501e:	22e4a223          	sw	a4,548(s1)
    80005022:	1ff7f793          	andi	a5,a5,511
    80005026:	97a6                	add	a5,a5,s1
    80005028:	faf44703          	lbu	a4,-81(s0)
    8000502c:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80005030:	2b85                	addiw	s7,s7,1
    80005032:	0b05                	addi	s6,s6,1
    80005034:	f97a94e3          	bne	s5,s7,80004fbc <pipewrite+0x42>
    80005038:	a011                	j	8000503c <pipewrite+0xc2>
    8000503a:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    8000503c:	22048513          	addi	a0,s1,544
    80005040:	ffffd097          	auipc	ra,0xffffd
    80005044:	696080e7          	jalr	1686(ra) # 800026d6 <wakeup>
  release(&pi->lock);
    80005048:	8526                	mv	a0,s1
    8000504a:	ffffc097          	auipc	ra,0xffffc
    8000504e:	d82080e7          	jalr	-638(ra) # 80000dcc <release>
  return i;
    80005052:	a039                	j	80005060 <pipewrite+0xe6>
        release(&pi->lock);
    80005054:	8526                	mv	a0,s1
    80005056:	ffffc097          	auipc	ra,0xffffc
    8000505a:	d76080e7          	jalr	-650(ra) # 80000dcc <release>
        return -1;
    8000505e:	5bfd                	li	s7,-1
}
    80005060:	855e                	mv	a0,s7
    80005062:	60e6                	ld	ra,88(sp)
    80005064:	6446                	ld	s0,80(sp)
    80005066:	64a6                	ld	s1,72(sp)
    80005068:	6906                	ld	s2,64(sp)
    8000506a:	79e2                	ld	s3,56(sp)
    8000506c:	7a42                	ld	s4,48(sp)
    8000506e:	7aa2                	ld	s5,40(sp)
    80005070:	7b02                	ld	s6,32(sp)
    80005072:	6be2                	ld	s7,24(sp)
    80005074:	6c42                	ld	s8,16(sp)
    80005076:	6125                	addi	sp,sp,96
    80005078:	8082                	ret

000000008000507a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000507a:	715d                	addi	sp,sp,-80
    8000507c:	e486                	sd	ra,72(sp)
    8000507e:	e0a2                	sd	s0,64(sp)
    80005080:	fc26                	sd	s1,56(sp)
    80005082:	f84a                	sd	s2,48(sp)
    80005084:	f44e                	sd	s3,40(sp)
    80005086:	f052                	sd	s4,32(sp)
    80005088:	ec56                	sd	s5,24(sp)
    8000508a:	e85a                	sd	s6,16(sp)
    8000508c:	0880                	addi	s0,sp,80
    8000508e:	84aa                	mv	s1,a0
    80005090:	892e                	mv	s2,a1
    80005092:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005094:	ffffd097          	auipc	ra,0xffffd
    80005098:	cae080e7          	jalr	-850(ra) # 80001d42 <myproc>
    8000509c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000509e:	8526                	mv	a0,s1
    800050a0:	ffffc097          	auipc	ra,0xffffc
    800050a4:	c5c080e7          	jalr	-932(ra) # 80000cfc <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050a8:	2204a703          	lw	a4,544(s1)
    800050ac:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050b0:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050b4:	02f71463          	bne	a4,a5,800050dc <piperead+0x62>
    800050b8:	22c4a783          	lw	a5,556(s1)
    800050bc:	c385                	beqz	a5,800050dc <piperead+0x62>
    if(pr->killed){
    800050be:	038a2783          	lw	a5,56(s4)
    800050c2:	ebc1                	bnez	a5,80005152 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050c4:	85a6                	mv	a1,s1
    800050c6:	854e                	mv	a0,s3
    800050c8:	ffffd097          	auipc	ra,0xffffd
    800050cc:	48e080e7          	jalr	1166(ra) # 80002556 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050d0:	2204a703          	lw	a4,544(s1)
    800050d4:	2244a783          	lw	a5,548(s1)
    800050d8:	fef700e3          	beq	a4,a5,800050b8 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050dc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050de:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050e0:	05505363          	blez	s5,80005126 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    800050e4:	2204a783          	lw	a5,544(s1)
    800050e8:	2244a703          	lw	a4,548(s1)
    800050ec:	02f70d63          	beq	a4,a5,80005126 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800050f0:	0017871b          	addiw	a4,a5,1
    800050f4:	22e4a023          	sw	a4,544(s1)
    800050f8:	1ff7f793          	andi	a5,a5,511
    800050fc:	97a6                	add	a5,a5,s1
    800050fe:	0207c783          	lbu	a5,32(a5)
    80005102:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005106:	4685                	li	a3,1
    80005108:	fbf40613          	addi	a2,s0,-65
    8000510c:	85ca                	mv	a1,s2
    8000510e:	058a3503          	ld	a0,88(s4)
    80005112:	ffffd097          	auipc	ra,0xffffd
    80005116:	922080e7          	jalr	-1758(ra) # 80001a34 <copyout>
    8000511a:	01650663          	beq	a0,s6,80005126 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000511e:	2985                	addiw	s3,s3,1
    80005120:	0905                	addi	s2,s2,1
    80005122:	fd3a91e3          	bne	s5,s3,800050e4 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005126:	22448513          	addi	a0,s1,548
    8000512a:	ffffd097          	auipc	ra,0xffffd
    8000512e:	5ac080e7          	jalr	1452(ra) # 800026d6 <wakeup>
  release(&pi->lock);
    80005132:	8526                	mv	a0,s1
    80005134:	ffffc097          	auipc	ra,0xffffc
    80005138:	c98080e7          	jalr	-872(ra) # 80000dcc <release>
  return i;
}
    8000513c:	854e                	mv	a0,s3
    8000513e:	60a6                	ld	ra,72(sp)
    80005140:	6406                	ld	s0,64(sp)
    80005142:	74e2                	ld	s1,56(sp)
    80005144:	7942                	ld	s2,48(sp)
    80005146:	79a2                	ld	s3,40(sp)
    80005148:	7a02                	ld	s4,32(sp)
    8000514a:	6ae2                	ld	s5,24(sp)
    8000514c:	6b42                	ld	s6,16(sp)
    8000514e:	6161                	addi	sp,sp,80
    80005150:	8082                	ret
      release(&pi->lock);
    80005152:	8526                	mv	a0,s1
    80005154:	ffffc097          	auipc	ra,0xffffc
    80005158:	c78080e7          	jalr	-904(ra) # 80000dcc <release>
      return -1;
    8000515c:	59fd                	li	s3,-1
    8000515e:	bff9                	j	8000513c <piperead+0xc2>

0000000080005160 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005160:	de010113          	addi	sp,sp,-544
    80005164:	20113c23          	sd	ra,536(sp)
    80005168:	20813823          	sd	s0,528(sp)
    8000516c:	20913423          	sd	s1,520(sp)
    80005170:	21213023          	sd	s2,512(sp)
    80005174:	ffce                	sd	s3,504(sp)
    80005176:	fbd2                	sd	s4,496(sp)
    80005178:	f7d6                	sd	s5,488(sp)
    8000517a:	f3da                	sd	s6,480(sp)
    8000517c:	efde                	sd	s7,472(sp)
    8000517e:	ebe2                	sd	s8,464(sp)
    80005180:	e7e6                	sd	s9,456(sp)
    80005182:	e3ea                	sd	s10,448(sp)
    80005184:	ff6e                	sd	s11,440(sp)
    80005186:	1400                	addi	s0,sp,544
    80005188:	892a                	mv	s2,a0
    8000518a:	dea43423          	sd	a0,-536(s0)
    8000518e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005192:	ffffd097          	auipc	ra,0xffffd
    80005196:	bb0080e7          	jalr	-1104(ra) # 80001d42 <myproc>
    8000519a:	84aa                	mv	s1,a0

  begin_op();
    8000519c:	fffff097          	auipc	ra,0xfffff
    800051a0:	460080e7          	jalr	1120(ra) # 800045fc <begin_op>

  if((ip = namei(path)) == 0){
    800051a4:	854a                	mv	a0,s2
    800051a6:	fffff097          	auipc	ra,0xfffff
    800051aa:	23a080e7          	jalr	570(ra) # 800043e0 <namei>
    800051ae:	c93d                	beqz	a0,80005224 <exec+0xc4>
    800051b0:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800051b2:	fffff097          	auipc	ra,0xfffff
    800051b6:	a7a080e7          	jalr	-1414(ra) # 80003c2c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800051ba:	04000713          	li	a4,64
    800051be:	4681                	li	a3,0
    800051c0:	e4840613          	addi	a2,s0,-440
    800051c4:	4581                	li	a1,0
    800051c6:	8556                	mv	a0,s5
    800051c8:	fffff097          	auipc	ra,0xfffff
    800051cc:	d18080e7          	jalr	-744(ra) # 80003ee0 <readi>
    800051d0:	04000793          	li	a5,64
    800051d4:	00f51a63          	bne	a0,a5,800051e8 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800051d8:	e4842703          	lw	a4,-440(s0)
    800051dc:	464c47b7          	lui	a5,0x464c4
    800051e0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051e4:	04f70663          	beq	a4,a5,80005230 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051e8:	8556                	mv	a0,s5
    800051ea:	fffff097          	auipc	ra,0xfffff
    800051ee:	ca4080e7          	jalr	-860(ra) # 80003e8e <iunlockput>
    end_op();
    800051f2:	fffff097          	auipc	ra,0xfffff
    800051f6:	48a080e7          	jalr	1162(ra) # 8000467c <end_op>
  }
  return -1;
    800051fa:	557d                	li	a0,-1
}
    800051fc:	21813083          	ld	ra,536(sp)
    80005200:	21013403          	ld	s0,528(sp)
    80005204:	20813483          	ld	s1,520(sp)
    80005208:	20013903          	ld	s2,512(sp)
    8000520c:	79fe                	ld	s3,504(sp)
    8000520e:	7a5e                	ld	s4,496(sp)
    80005210:	7abe                	ld	s5,488(sp)
    80005212:	7b1e                	ld	s6,480(sp)
    80005214:	6bfe                	ld	s7,472(sp)
    80005216:	6c5e                	ld	s8,464(sp)
    80005218:	6cbe                	ld	s9,456(sp)
    8000521a:	6d1e                	ld	s10,448(sp)
    8000521c:	7dfa                	ld	s11,440(sp)
    8000521e:	22010113          	addi	sp,sp,544
    80005222:	8082                	ret
    end_op();
    80005224:	fffff097          	auipc	ra,0xfffff
    80005228:	458080e7          	jalr	1112(ra) # 8000467c <end_op>
    return -1;
    8000522c:	557d                	li	a0,-1
    8000522e:	b7f9                	j	800051fc <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005230:	8526                	mv	a0,s1
    80005232:	ffffd097          	auipc	ra,0xffffd
    80005236:	bd4080e7          	jalr	-1068(ra) # 80001e06 <proc_pagetable>
    8000523a:	8b2a                	mv	s6,a0
    8000523c:	d555                	beqz	a0,800051e8 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000523e:	e6842783          	lw	a5,-408(s0)
    80005242:	e8045703          	lhu	a4,-384(s0)
    80005246:	c735                	beqz	a4,800052b2 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005248:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000524a:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000524e:	6a05                	lui	s4,0x1
    80005250:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005254:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005258:	6d85                	lui	s11,0x1
    8000525a:	7d7d                	lui	s10,0xfffff
    8000525c:	ac1d                	j	80005492 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000525e:	00003517          	auipc	a0,0x3
    80005262:	4fa50513          	addi	a0,a0,1274 # 80008758 <syscalls+0x298>
    80005266:	ffffb097          	auipc	ra,0xffffb
    8000526a:	2e4080e7          	jalr	740(ra) # 8000054a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000526e:	874a                	mv	a4,s2
    80005270:	009c86bb          	addw	a3,s9,s1
    80005274:	4581                	li	a1,0
    80005276:	8556                	mv	a0,s5
    80005278:	fffff097          	auipc	ra,0xfffff
    8000527c:	c68080e7          	jalr	-920(ra) # 80003ee0 <readi>
    80005280:	2501                	sext.w	a0,a0
    80005282:	1aa91863          	bne	s2,a0,80005432 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80005286:	009d84bb          	addw	s1,s11,s1
    8000528a:	013d09bb          	addw	s3,s10,s3
    8000528e:	1f74f263          	bgeu	s1,s7,80005472 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80005292:	02049593          	slli	a1,s1,0x20
    80005296:	9181                	srli	a1,a1,0x20
    80005298:	95e2                	add	a1,a1,s8
    8000529a:	855a                	mv	a0,s6
    8000529c:	ffffc097          	auipc	ra,0xffffc
    800052a0:	1d6080e7          	jalr	470(ra) # 80001472 <walkaddr>
    800052a4:	862a                	mv	a2,a0
    if(pa == 0)
    800052a6:	dd45                	beqz	a0,8000525e <exec+0xfe>
      n = PGSIZE;
    800052a8:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800052aa:	fd49f2e3          	bgeu	s3,s4,8000526e <exec+0x10e>
      n = sz - i;
    800052ae:	894e                	mv	s2,s3
    800052b0:	bf7d                	j	8000526e <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800052b2:	4481                	li	s1,0
  iunlockput(ip);
    800052b4:	8556                	mv	a0,s5
    800052b6:	fffff097          	auipc	ra,0xfffff
    800052ba:	bd8080e7          	jalr	-1064(ra) # 80003e8e <iunlockput>
  end_op();
    800052be:	fffff097          	auipc	ra,0xfffff
    800052c2:	3be080e7          	jalr	958(ra) # 8000467c <end_op>
  p = myproc();
    800052c6:	ffffd097          	auipc	ra,0xffffd
    800052ca:	a7c080e7          	jalr	-1412(ra) # 80001d42 <myproc>
    800052ce:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800052d0:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    800052d4:	6785                	lui	a5,0x1
    800052d6:	17fd                	addi	a5,a5,-1
    800052d8:	94be                	add	s1,s1,a5
    800052da:	77fd                	lui	a5,0xfffff
    800052dc:	8fe5                	and	a5,a5,s1
    800052de:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800052e2:	6609                	lui	a2,0x2
    800052e4:	963e                	add	a2,a2,a5
    800052e6:	85be                	mv	a1,a5
    800052e8:	855a                	mv	a0,s6
    800052ea:	ffffc097          	auipc	ra,0xffffc
    800052ee:	4fa080e7          	jalr	1274(ra) # 800017e4 <uvmalloc>
    800052f2:	8c2a                	mv	s8,a0
  ip = 0;
    800052f4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800052f6:	12050e63          	beqz	a0,80005432 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052fa:	75f9                	lui	a1,0xffffe
    800052fc:	95aa                	add	a1,a1,a0
    800052fe:	855a                	mv	a0,s6
    80005300:	ffffc097          	auipc	ra,0xffffc
    80005304:	702080e7          	jalr	1794(ra) # 80001a02 <uvmclear>
  stackbase = sp - PGSIZE;
    80005308:	7afd                	lui	s5,0xfffff
    8000530a:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000530c:	df043783          	ld	a5,-528(s0)
    80005310:	6388                	ld	a0,0(a5)
    80005312:	c925                	beqz	a0,80005382 <exec+0x222>
    80005314:	e8840993          	addi	s3,s0,-376
    80005318:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    8000531c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000531e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005320:	ffffc097          	auipc	ra,0xffffc
    80005324:	f40080e7          	jalr	-192(ra) # 80001260 <strlen>
    80005328:	0015079b          	addiw	a5,a0,1
    8000532c:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005330:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005334:	13596363          	bltu	s2,s5,8000545a <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005338:	df043d83          	ld	s11,-528(s0)
    8000533c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005340:	8552                	mv	a0,s4
    80005342:	ffffc097          	auipc	ra,0xffffc
    80005346:	f1e080e7          	jalr	-226(ra) # 80001260 <strlen>
    8000534a:	0015069b          	addiw	a3,a0,1
    8000534e:	8652                	mv	a2,s4
    80005350:	85ca                	mv	a1,s2
    80005352:	855a                	mv	a0,s6
    80005354:	ffffc097          	auipc	ra,0xffffc
    80005358:	6e0080e7          	jalr	1760(ra) # 80001a34 <copyout>
    8000535c:	10054363          	bltz	a0,80005462 <exec+0x302>
    ustack[argc] = sp;
    80005360:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005364:	0485                	addi	s1,s1,1
    80005366:	008d8793          	addi	a5,s11,8
    8000536a:	def43823          	sd	a5,-528(s0)
    8000536e:	008db503          	ld	a0,8(s11)
    80005372:	c911                	beqz	a0,80005386 <exec+0x226>
    if(argc >= MAXARG)
    80005374:	09a1                	addi	s3,s3,8
    80005376:	fb3c95e3          	bne	s9,s3,80005320 <exec+0x1c0>
  sz = sz1;
    8000537a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000537e:	4a81                	li	s5,0
    80005380:	a84d                	j	80005432 <exec+0x2d2>
  sp = sz;
    80005382:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005384:	4481                	li	s1,0
  ustack[argc] = 0;
    80005386:	00349793          	slli	a5,s1,0x3
    8000538a:	f9040713          	addi	a4,s0,-112
    8000538e:	97ba                	add	a5,a5,a4
    80005390:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd2ed0>
  sp -= (argc+1) * sizeof(uint64);
    80005394:	00148693          	addi	a3,s1,1
    80005398:	068e                	slli	a3,a3,0x3
    8000539a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000539e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800053a2:	01597663          	bgeu	s2,s5,800053ae <exec+0x24e>
  sz = sz1;
    800053a6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053aa:	4a81                	li	s5,0
    800053ac:	a059                	j	80005432 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800053ae:	e8840613          	addi	a2,s0,-376
    800053b2:	85ca                	mv	a1,s2
    800053b4:	855a                	mv	a0,s6
    800053b6:	ffffc097          	auipc	ra,0xffffc
    800053ba:	67e080e7          	jalr	1662(ra) # 80001a34 <copyout>
    800053be:	0a054663          	bltz	a0,8000546a <exec+0x30a>
  p->trapframe->a1 = sp;
    800053c2:	060bb783          	ld	a5,96(s7) # 1060 <_entry-0x7fffefa0>
    800053c6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800053ca:	de843783          	ld	a5,-536(s0)
    800053ce:	0007c703          	lbu	a4,0(a5)
    800053d2:	cf11                	beqz	a4,800053ee <exec+0x28e>
    800053d4:	0785                	addi	a5,a5,1
    if(*s == '/')
    800053d6:	02f00693          	li	a3,47
    800053da:	a039                	j	800053e8 <exec+0x288>
      last = s+1;
    800053dc:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800053e0:	0785                	addi	a5,a5,1
    800053e2:	fff7c703          	lbu	a4,-1(a5)
    800053e6:	c701                	beqz	a4,800053ee <exec+0x28e>
    if(*s == '/')
    800053e8:	fed71ce3          	bne	a4,a3,800053e0 <exec+0x280>
    800053ec:	bfc5                	j	800053dc <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    800053ee:	4641                	li	a2,16
    800053f0:	de843583          	ld	a1,-536(s0)
    800053f4:	160b8513          	addi	a0,s7,352
    800053f8:	ffffc097          	auipc	ra,0xffffc
    800053fc:	e36080e7          	jalr	-458(ra) # 8000122e <safestrcpy>
  oldpagetable = p->pagetable;
    80005400:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80005404:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    80005408:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000540c:	060bb783          	ld	a5,96(s7)
    80005410:	e6043703          	ld	a4,-416(s0)
    80005414:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005416:	060bb783          	ld	a5,96(s7)
    8000541a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000541e:	85ea                	mv	a1,s10
    80005420:	ffffd097          	auipc	ra,0xffffd
    80005424:	a82080e7          	jalr	-1406(ra) # 80001ea2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005428:	0004851b          	sext.w	a0,s1
    8000542c:	bbc1                	j	800051fc <exec+0x9c>
    8000542e:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005432:	df843583          	ld	a1,-520(s0)
    80005436:	855a                	mv	a0,s6
    80005438:	ffffd097          	auipc	ra,0xffffd
    8000543c:	a6a080e7          	jalr	-1430(ra) # 80001ea2 <proc_freepagetable>
  if(ip){
    80005440:	da0a94e3          	bnez	s5,800051e8 <exec+0x88>
  return -1;
    80005444:	557d                	li	a0,-1
    80005446:	bb5d                	j	800051fc <exec+0x9c>
    80005448:	de943c23          	sd	s1,-520(s0)
    8000544c:	b7dd                	j	80005432 <exec+0x2d2>
    8000544e:	de943c23          	sd	s1,-520(s0)
    80005452:	b7c5                	j	80005432 <exec+0x2d2>
    80005454:	de943c23          	sd	s1,-520(s0)
    80005458:	bfe9                	j	80005432 <exec+0x2d2>
  sz = sz1;
    8000545a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000545e:	4a81                	li	s5,0
    80005460:	bfc9                	j	80005432 <exec+0x2d2>
  sz = sz1;
    80005462:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005466:	4a81                	li	s5,0
    80005468:	b7e9                	j	80005432 <exec+0x2d2>
  sz = sz1;
    8000546a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000546e:	4a81                	li	s5,0
    80005470:	b7c9                	j	80005432 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005472:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005476:	e0843783          	ld	a5,-504(s0)
    8000547a:	0017869b          	addiw	a3,a5,1
    8000547e:	e0d43423          	sd	a3,-504(s0)
    80005482:	e0043783          	ld	a5,-512(s0)
    80005486:	0387879b          	addiw	a5,a5,56
    8000548a:	e8045703          	lhu	a4,-384(s0)
    8000548e:	e2e6d3e3          	bge	a3,a4,800052b4 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005492:	2781                	sext.w	a5,a5
    80005494:	e0f43023          	sd	a5,-512(s0)
    80005498:	03800713          	li	a4,56
    8000549c:	86be                	mv	a3,a5
    8000549e:	e1040613          	addi	a2,s0,-496
    800054a2:	4581                	li	a1,0
    800054a4:	8556                	mv	a0,s5
    800054a6:	fffff097          	auipc	ra,0xfffff
    800054aa:	a3a080e7          	jalr	-1478(ra) # 80003ee0 <readi>
    800054ae:	03800793          	li	a5,56
    800054b2:	f6f51ee3          	bne	a0,a5,8000542e <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800054b6:	e1042783          	lw	a5,-496(s0)
    800054ba:	4705                	li	a4,1
    800054bc:	fae79de3          	bne	a5,a4,80005476 <exec+0x316>
    if(ph.memsz < ph.filesz)
    800054c0:	e3843603          	ld	a2,-456(s0)
    800054c4:	e3043783          	ld	a5,-464(s0)
    800054c8:	f8f660e3          	bltu	a2,a5,80005448 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800054cc:	e2043783          	ld	a5,-480(s0)
    800054d0:	963e                	add	a2,a2,a5
    800054d2:	f6f66ee3          	bltu	a2,a5,8000544e <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800054d6:	85a6                	mv	a1,s1
    800054d8:	855a                	mv	a0,s6
    800054da:	ffffc097          	auipc	ra,0xffffc
    800054de:	30a080e7          	jalr	778(ra) # 800017e4 <uvmalloc>
    800054e2:	dea43c23          	sd	a0,-520(s0)
    800054e6:	d53d                	beqz	a0,80005454 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    800054e8:	e2043c03          	ld	s8,-480(s0)
    800054ec:	de043783          	ld	a5,-544(s0)
    800054f0:	00fc77b3          	and	a5,s8,a5
    800054f4:	ff9d                	bnez	a5,80005432 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054f6:	e1842c83          	lw	s9,-488(s0)
    800054fa:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054fe:	f60b8ae3          	beqz	s7,80005472 <exec+0x312>
    80005502:	89de                	mv	s3,s7
    80005504:	4481                	li	s1,0
    80005506:	b371                	j	80005292 <exec+0x132>

0000000080005508 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005508:	7179                	addi	sp,sp,-48
    8000550a:	f406                	sd	ra,40(sp)
    8000550c:	f022                	sd	s0,32(sp)
    8000550e:	ec26                	sd	s1,24(sp)
    80005510:	e84a                	sd	s2,16(sp)
    80005512:	1800                	addi	s0,sp,48
    80005514:	892e                	mv	s2,a1
    80005516:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005518:	fdc40593          	addi	a1,s0,-36
    8000551c:	ffffe097          	auipc	ra,0xffffe
    80005520:	8e0080e7          	jalr	-1824(ra) # 80002dfc <argint>
    80005524:	04054063          	bltz	a0,80005564 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005528:	fdc42703          	lw	a4,-36(s0)
    8000552c:	47bd                	li	a5,15
    8000552e:	02e7ed63          	bltu	a5,a4,80005568 <argfd+0x60>
    80005532:	ffffd097          	auipc	ra,0xffffd
    80005536:	810080e7          	jalr	-2032(ra) # 80001d42 <myproc>
    8000553a:	fdc42703          	lw	a4,-36(s0)
    8000553e:	01a70793          	addi	a5,a4,26
    80005542:	078e                	slli	a5,a5,0x3
    80005544:	953e                	add	a0,a0,a5
    80005546:	651c                	ld	a5,8(a0)
    80005548:	c395                	beqz	a5,8000556c <argfd+0x64>
    return -1;
  if(pfd)
    8000554a:	00090463          	beqz	s2,80005552 <argfd+0x4a>
    *pfd = fd;
    8000554e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005552:	4501                	li	a0,0
  if(pf)
    80005554:	c091                	beqz	s1,80005558 <argfd+0x50>
    *pf = f;
    80005556:	e09c                	sd	a5,0(s1)
}
    80005558:	70a2                	ld	ra,40(sp)
    8000555a:	7402                	ld	s0,32(sp)
    8000555c:	64e2                	ld	s1,24(sp)
    8000555e:	6942                	ld	s2,16(sp)
    80005560:	6145                	addi	sp,sp,48
    80005562:	8082                	ret
    return -1;
    80005564:	557d                	li	a0,-1
    80005566:	bfcd                	j	80005558 <argfd+0x50>
    return -1;
    80005568:	557d                	li	a0,-1
    8000556a:	b7fd                	j	80005558 <argfd+0x50>
    8000556c:	557d                	li	a0,-1
    8000556e:	b7ed                	j	80005558 <argfd+0x50>

0000000080005570 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005570:	1101                	addi	sp,sp,-32
    80005572:	ec06                	sd	ra,24(sp)
    80005574:	e822                	sd	s0,16(sp)
    80005576:	e426                	sd	s1,8(sp)
    80005578:	1000                	addi	s0,sp,32
    8000557a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000557c:	ffffc097          	auipc	ra,0xffffc
    80005580:	7c6080e7          	jalr	1990(ra) # 80001d42 <myproc>
    80005584:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005586:	0d850793          	addi	a5,a0,216
    8000558a:	4501                	li	a0,0
    8000558c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000558e:	6398                	ld	a4,0(a5)
    80005590:	cb19                	beqz	a4,800055a6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005592:	2505                	addiw	a0,a0,1
    80005594:	07a1                	addi	a5,a5,8
    80005596:	fed51ce3          	bne	a0,a3,8000558e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000559a:	557d                	li	a0,-1
}
    8000559c:	60e2                	ld	ra,24(sp)
    8000559e:	6442                	ld	s0,16(sp)
    800055a0:	64a2                	ld	s1,8(sp)
    800055a2:	6105                	addi	sp,sp,32
    800055a4:	8082                	ret
      p->ofile[fd] = f;
    800055a6:	01a50793          	addi	a5,a0,26
    800055aa:	078e                	slli	a5,a5,0x3
    800055ac:	963e                	add	a2,a2,a5
    800055ae:	e604                	sd	s1,8(a2)
      return fd;
    800055b0:	b7f5                	j	8000559c <fdalloc+0x2c>

00000000800055b2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055b2:	715d                	addi	sp,sp,-80
    800055b4:	e486                	sd	ra,72(sp)
    800055b6:	e0a2                	sd	s0,64(sp)
    800055b8:	fc26                	sd	s1,56(sp)
    800055ba:	f84a                	sd	s2,48(sp)
    800055bc:	f44e                	sd	s3,40(sp)
    800055be:	f052                	sd	s4,32(sp)
    800055c0:	ec56                	sd	s5,24(sp)
    800055c2:	0880                	addi	s0,sp,80
    800055c4:	89ae                	mv	s3,a1
    800055c6:	8ab2                	mv	s5,a2
    800055c8:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800055ca:	fb040593          	addi	a1,s0,-80
    800055ce:	fffff097          	auipc	ra,0xfffff
    800055d2:	e30080e7          	jalr	-464(ra) # 800043fe <nameiparent>
    800055d6:	892a                	mv	s2,a0
    800055d8:	12050e63          	beqz	a0,80005714 <create+0x162>
    return 0;

  ilock(dp);
    800055dc:	ffffe097          	auipc	ra,0xffffe
    800055e0:	650080e7          	jalr	1616(ra) # 80003c2c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055e4:	4601                	li	a2,0
    800055e6:	fb040593          	addi	a1,s0,-80
    800055ea:	854a                	mv	a0,s2
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	b22080e7          	jalr	-1246(ra) # 8000410e <dirlookup>
    800055f4:	84aa                	mv	s1,a0
    800055f6:	c921                	beqz	a0,80005646 <create+0x94>
    iunlockput(dp);
    800055f8:	854a                	mv	a0,s2
    800055fa:	fffff097          	auipc	ra,0xfffff
    800055fe:	894080e7          	jalr	-1900(ra) # 80003e8e <iunlockput>
    ilock(ip);
    80005602:	8526                	mv	a0,s1
    80005604:	ffffe097          	auipc	ra,0xffffe
    80005608:	628080e7          	jalr	1576(ra) # 80003c2c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000560c:	2981                	sext.w	s3,s3
    8000560e:	4789                	li	a5,2
    80005610:	02f99463          	bne	s3,a5,80005638 <create+0x86>
    80005614:	04c4d783          	lhu	a5,76(s1)
    80005618:	37f9                	addiw	a5,a5,-2
    8000561a:	17c2                	slli	a5,a5,0x30
    8000561c:	93c1                	srli	a5,a5,0x30
    8000561e:	4705                	li	a4,1
    80005620:	00f76c63          	bltu	a4,a5,80005638 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005624:	8526                	mv	a0,s1
    80005626:	60a6                	ld	ra,72(sp)
    80005628:	6406                	ld	s0,64(sp)
    8000562a:	74e2                	ld	s1,56(sp)
    8000562c:	7942                	ld	s2,48(sp)
    8000562e:	79a2                	ld	s3,40(sp)
    80005630:	7a02                	ld	s4,32(sp)
    80005632:	6ae2                	ld	s5,24(sp)
    80005634:	6161                	addi	sp,sp,80
    80005636:	8082                	ret
    iunlockput(ip);
    80005638:	8526                	mv	a0,s1
    8000563a:	fffff097          	auipc	ra,0xfffff
    8000563e:	854080e7          	jalr	-1964(ra) # 80003e8e <iunlockput>
    return 0;
    80005642:	4481                	li	s1,0
    80005644:	b7c5                	j	80005624 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005646:	85ce                	mv	a1,s3
    80005648:	00092503          	lw	a0,0(s2)
    8000564c:	ffffe097          	auipc	ra,0xffffe
    80005650:	448080e7          	jalr	1096(ra) # 80003a94 <ialloc>
    80005654:	84aa                	mv	s1,a0
    80005656:	c521                	beqz	a0,8000569e <create+0xec>
  ilock(ip);
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	5d4080e7          	jalr	1492(ra) # 80003c2c <ilock>
  ip->major = major;
    80005660:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    80005664:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    80005668:	4a05                	li	s4,1
    8000566a:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    8000566e:	8526                	mv	a0,s1
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	4f2080e7          	jalr	1266(ra) # 80003b62 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005678:	2981                	sext.w	s3,s3
    8000567a:	03498a63          	beq	s3,s4,800056ae <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000567e:	40d0                	lw	a2,4(s1)
    80005680:	fb040593          	addi	a1,s0,-80
    80005684:	854a                	mv	a0,s2
    80005686:	fffff097          	auipc	ra,0xfffff
    8000568a:	c98080e7          	jalr	-872(ra) # 8000431e <dirlink>
    8000568e:	06054b63          	bltz	a0,80005704 <create+0x152>
  iunlockput(dp);
    80005692:	854a                	mv	a0,s2
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	7fa080e7          	jalr	2042(ra) # 80003e8e <iunlockput>
  return ip;
    8000569c:	b761                	j	80005624 <create+0x72>
    panic("create: ialloc");
    8000569e:	00003517          	auipc	a0,0x3
    800056a2:	0da50513          	addi	a0,a0,218 # 80008778 <syscalls+0x2b8>
    800056a6:	ffffb097          	auipc	ra,0xffffb
    800056aa:	ea4080e7          	jalr	-348(ra) # 8000054a <panic>
    dp->nlink++;  // for ".."
    800056ae:	05295783          	lhu	a5,82(s2)
    800056b2:	2785                	addiw	a5,a5,1
    800056b4:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    800056b8:	854a                	mv	a0,s2
    800056ba:	ffffe097          	auipc	ra,0xffffe
    800056be:	4a8080e7          	jalr	1192(ra) # 80003b62 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056c2:	40d0                	lw	a2,4(s1)
    800056c4:	00003597          	auipc	a1,0x3
    800056c8:	0c458593          	addi	a1,a1,196 # 80008788 <syscalls+0x2c8>
    800056cc:	8526                	mv	a0,s1
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	c50080e7          	jalr	-944(ra) # 8000431e <dirlink>
    800056d6:	00054f63          	bltz	a0,800056f4 <create+0x142>
    800056da:	00492603          	lw	a2,4(s2)
    800056de:	00003597          	auipc	a1,0x3
    800056e2:	0b258593          	addi	a1,a1,178 # 80008790 <syscalls+0x2d0>
    800056e6:	8526                	mv	a0,s1
    800056e8:	fffff097          	auipc	ra,0xfffff
    800056ec:	c36080e7          	jalr	-970(ra) # 8000431e <dirlink>
    800056f0:	f80557e3          	bgez	a0,8000567e <create+0xcc>
      panic("create dots");
    800056f4:	00003517          	auipc	a0,0x3
    800056f8:	0a450513          	addi	a0,a0,164 # 80008798 <syscalls+0x2d8>
    800056fc:	ffffb097          	auipc	ra,0xffffb
    80005700:	e4e080e7          	jalr	-434(ra) # 8000054a <panic>
    panic("create: dirlink");
    80005704:	00003517          	auipc	a0,0x3
    80005708:	0a450513          	addi	a0,a0,164 # 800087a8 <syscalls+0x2e8>
    8000570c:	ffffb097          	auipc	ra,0xffffb
    80005710:	e3e080e7          	jalr	-450(ra) # 8000054a <panic>
    return 0;
    80005714:	84aa                	mv	s1,a0
    80005716:	b739                	j	80005624 <create+0x72>

0000000080005718 <sys_dup>:
{
    80005718:	7179                	addi	sp,sp,-48
    8000571a:	f406                	sd	ra,40(sp)
    8000571c:	f022                	sd	s0,32(sp)
    8000571e:	ec26                	sd	s1,24(sp)
    80005720:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005722:	fd840613          	addi	a2,s0,-40
    80005726:	4581                	li	a1,0
    80005728:	4501                	li	a0,0
    8000572a:	00000097          	auipc	ra,0x0
    8000572e:	dde080e7          	jalr	-546(ra) # 80005508 <argfd>
    return -1;
    80005732:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005734:	02054363          	bltz	a0,8000575a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005738:	fd843503          	ld	a0,-40(s0)
    8000573c:	00000097          	auipc	ra,0x0
    80005740:	e34080e7          	jalr	-460(ra) # 80005570 <fdalloc>
    80005744:	84aa                	mv	s1,a0
    return -1;
    80005746:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005748:	00054963          	bltz	a0,8000575a <sys_dup+0x42>
  filedup(f);
    8000574c:	fd843503          	ld	a0,-40(s0)
    80005750:	fffff097          	auipc	ra,0xfffff
    80005754:	32e080e7          	jalr	814(ra) # 80004a7e <filedup>
  return fd;
    80005758:	87a6                	mv	a5,s1
}
    8000575a:	853e                	mv	a0,a5
    8000575c:	70a2                	ld	ra,40(sp)
    8000575e:	7402                	ld	s0,32(sp)
    80005760:	64e2                	ld	s1,24(sp)
    80005762:	6145                	addi	sp,sp,48
    80005764:	8082                	ret

0000000080005766 <sys_read>:
{
    80005766:	7179                	addi	sp,sp,-48
    80005768:	f406                	sd	ra,40(sp)
    8000576a:	f022                	sd	s0,32(sp)
    8000576c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000576e:	fe840613          	addi	a2,s0,-24
    80005772:	4581                	li	a1,0
    80005774:	4501                	li	a0,0
    80005776:	00000097          	auipc	ra,0x0
    8000577a:	d92080e7          	jalr	-622(ra) # 80005508 <argfd>
    return -1;
    8000577e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005780:	04054163          	bltz	a0,800057c2 <sys_read+0x5c>
    80005784:	fe440593          	addi	a1,s0,-28
    80005788:	4509                	li	a0,2
    8000578a:	ffffd097          	auipc	ra,0xffffd
    8000578e:	672080e7          	jalr	1650(ra) # 80002dfc <argint>
    return -1;
    80005792:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005794:	02054763          	bltz	a0,800057c2 <sys_read+0x5c>
    80005798:	fd840593          	addi	a1,s0,-40
    8000579c:	4505                	li	a0,1
    8000579e:	ffffd097          	auipc	ra,0xffffd
    800057a2:	680080e7          	jalr	1664(ra) # 80002e1e <argaddr>
    return -1;
    800057a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057a8:	00054d63          	bltz	a0,800057c2 <sys_read+0x5c>
  return fileread(f, p, n);
    800057ac:	fe442603          	lw	a2,-28(s0)
    800057b0:	fd843583          	ld	a1,-40(s0)
    800057b4:	fe843503          	ld	a0,-24(s0)
    800057b8:	fffff097          	auipc	ra,0xfffff
    800057bc:	452080e7          	jalr	1106(ra) # 80004c0a <fileread>
    800057c0:	87aa                	mv	a5,a0
}
    800057c2:	853e                	mv	a0,a5
    800057c4:	70a2                	ld	ra,40(sp)
    800057c6:	7402                	ld	s0,32(sp)
    800057c8:	6145                	addi	sp,sp,48
    800057ca:	8082                	ret

00000000800057cc <sys_write>:
{
    800057cc:	7179                	addi	sp,sp,-48
    800057ce:	f406                	sd	ra,40(sp)
    800057d0:	f022                	sd	s0,32(sp)
    800057d2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057d4:	fe840613          	addi	a2,s0,-24
    800057d8:	4581                	li	a1,0
    800057da:	4501                	li	a0,0
    800057dc:	00000097          	auipc	ra,0x0
    800057e0:	d2c080e7          	jalr	-724(ra) # 80005508 <argfd>
    return -1;
    800057e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057e6:	04054163          	bltz	a0,80005828 <sys_write+0x5c>
    800057ea:	fe440593          	addi	a1,s0,-28
    800057ee:	4509                	li	a0,2
    800057f0:	ffffd097          	auipc	ra,0xffffd
    800057f4:	60c080e7          	jalr	1548(ra) # 80002dfc <argint>
    return -1;
    800057f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057fa:	02054763          	bltz	a0,80005828 <sys_write+0x5c>
    800057fe:	fd840593          	addi	a1,s0,-40
    80005802:	4505                	li	a0,1
    80005804:	ffffd097          	auipc	ra,0xffffd
    80005808:	61a080e7          	jalr	1562(ra) # 80002e1e <argaddr>
    return -1;
    8000580c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000580e:	00054d63          	bltz	a0,80005828 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005812:	fe442603          	lw	a2,-28(s0)
    80005816:	fd843583          	ld	a1,-40(s0)
    8000581a:	fe843503          	ld	a0,-24(s0)
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	4ae080e7          	jalr	1198(ra) # 80004ccc <filewrite>
    80005826:	87aa                	mv	a5,a0
}
    80005828:	853e                	mv	a0,a5
    8000582a:	70a2                	ld	ra,40(sp)
    8000582c:	7402                	ld	s0,32(sp)
    8000582e:	6145                	addi	sp,sp,48
    80005830:	8082                	ret

0000000080005832 <sys_close>:
{
    80005832:	1101                	addi	sp,sp,-32
    80005834:	ec06                	sd	ra,24(sp)
    80005836:	e822                	sd	s0,16(sp)
    80005838:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000583a:	fe040613          	addi	a2,s0,-32
    8000583e:	fec40593          	addi	a1,s0,-20
    80005842:	4501                	li	a0,0
    80005844:	00000097          	auipc	ra,0x0
    80005848:	cc4080e7          	jalr	-828(ra) # 80005508 <argfd>
    return -1;
    8000584c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000584e:	02054463          	bltz	a0,80005876 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005852:	ffffc097          	auipc	ra,0xffffc
    80005856:	4f0080e7          	jalr	1264(ra) # 80001d42 <myproc>
    8000585a:	fec42783          	lw	a5,-20(s0)
    8000585e:	07e9                	addi	a5,a5,26
    80005860:	078e                	slli	a5,a5,0x3
    80005862:	97aa                	add	a5,a5,a0
    80005864:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005868:	fe043503          	ld	a0,-32(s0)
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	264080e7          	jalr	612(ra) # 80004ad0 <fileclose>
  return 0;
    80005874:	4781                	li	a5,0
}
    80005876:	853e                	mv	a0,a5
    80005878:	60e2                	ld	ra,24(sp)
    8000587a:	6442                	ld	s0,16(sp)
    8000587c:	6105                	addi	sp,sp,32
    8000587e:	8082                	ret

0000000080005880 <sys_fstat>:
{
    80005880:	1101                	addi	sp,sp,-32
    80005882:	ec06                	sd	ra,24(sp)
    80005884:	e822                	sd	s0,16(sp)
    80005886:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005888:	fe840613          	addi	a2,s0,-24
    8000588c:	4581                	li	a1,0
    8000588e:	4501                	li	a0,0
    80005890:	00000097          	auipc	ra,0x0
    80005894:	c78080e7          	jalr	-904(ra) # 80005508 <argfd>
    return -1;
    80005898:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000589a:	02054563          	bltz	a0,800058c4 <sys_fstat+0x44>
    8000589e:	fe040593          	addi	a1,s0,-32
    800058a2:	4505                	li	a0,1
    800058a4:	ffffd097          	auipc	ra,0xffffd
    800058a8:	57a080e7          	jalr	1402(ra) # 80002e1e <argaddr>
    return -1;
    800058ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058ae:	00054b63          	bltz	a0,800058c4 <sys_fstat+0x44>
  return filestat(f, st);
    800058b2:	fe043583          	ld	a1,-32(s0)
    800058b6:	fe843503          	ld	a0,-24(s0)
    800058ba:	fffff097          	auipc	ra,0xfffff
    800058be:	2de080e7          	jalr	734(ra) # 80004b98 <filestat>
    800058c2:	87aa                	mv	a5,a0
}
    800058c4:	853e                	mv	a0,a5
    800058c6:	60e2                	ld	ra,24(sp)
    800058c8:	6442                	ld	s0,16(sp)
    800058ca:	6105                	addi	sp,sp,32
    800058cc:	8082                	ret

00000000800058ce <sys_link>:
{
    800058ce:	7169                	addi	sp,sp,-304
    800058d0:	f606                	sd	ra,296(sp)
    800058d2:	f222                	sd	s0,288(sp)
    800058d4:	ee26                	sd	s1,280(sp)
    800058d6:	ea4a                	sd	s2,272(sp)
    800058d8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058da:	08000613          	li	a2,128
    800058de:	ed040593          	addi	a1,s0,-304
    800058e2:	4501                	li	a0,0
    800058e4:	ffffd097          	auipc	ra,0xffffd
    800058e8:	55c080e7          	jalr	1372(ra) # 80002e40 <argstr>
    return -1;
    800058ec:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058ee:	10054e63          	bltz	a0,80005a0a <sys_link+0x13c>
    800058f2:	08000613          	li	a2,128
    800058f6:	f5040593          	addi	a1,s0,-176
    800058fa:	4505                	li	a0,1
    800058fc:	ffffd097          	auipc	ra,0xffffd
    80005900:	544080e7          	jalr	1348(ra) # 80002e40 <argstr>
    return -1;
    80005904:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005906:	10054263          	bltz	a0,80005a0a <sys_link+0x13c>
  begin_op();
    8000590a:	fffff097          	auipc	ra,0xfffff
    8000590e:	cf2080e7          	jalr	-782(ra) # 800045fc <begin_op>
  if((ip = namei(old)) == 0){
    80005912:	ed040513          	addi	a0,s0,-304
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	aca080e7          	jalr	-1334(ra) # 800043e0 <namei>
    8000591e:	84aa                	mv	s1,a0
    80005920:	c551                	beqz	a0,800059ac <sys_link+0xde>
  ilock(ip);
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	30a080e7          	jalr	778(ra) # 80003c2c <ilock>
  if(ip->type == T_DIR){
    8000592a:	04c49703          	lh	a4,76(s1)
    8000592e:	4785                	li	a5,1
    80005930:	08f70463          	beq	a4,a5,800059b8 <sys_link+0xea>
  ip->nlink++;
    80005934:	0524d783          	lhu	a5,82(s1)
    80005938:	2785                	addiw	a5,a5,1
    8000593a:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000593e:	8526                	mv	a0,s1
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	222080e7          	jalr	546(ra) # 80003b62 <iupdate>
  iunlock(ip);
    80005948:	8526                	mv	a0,s1
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	3a4080e7          	jalr	932(ra) # 80003cee <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005952:	fd040593          	addi	a1,s0,-48
    80005956:	f5040513          	addi	a0,s0,-176
    8000595a:	fffff097          	auipc	ra,0xfffff
    8000595e:	aa4080e7          	jalr	-1372(ra) # 800043fe <nameiparent>
    80005962:	892a                	mv	s2,a0
    80005964:	c935                	beqz	a0,800059d8 <sys_link+0x10a>
  ilock(dp);
    80005966:	ffffe097          	auipc	ra,0xffffe
    8000596a:	2c6080e7          	jalr	710(ra) # 80003c2c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000596e:	00092703          	lw	a4,0(s2)
    80005972:	409c                	lw	a5,0(s1)
    80005974:	04f71d63          	bne	a4,a5,800059ce <sys_link+0x100>
    80005978:	40d0                	lw	a2,4(s1)
    8000597a:	fd040593          	addi	a1,s0,-48
    8000597e:	854a                	mv	a0,s2
    80005980:	fffff097          	auipc	ra,0xfffff
    80005984:	99e080e7          	jalr	-1634(ra) # 8000431e <dirlink>
    80005988:	04054363          	bltz	a0,800059ce <sys_link+0x100>
  iunlockput(dp);
    8000598c:	854a                	mv	a0,s2
    8000598e:	ffffe097          	auipc	ra,0xffffe
    80005992:	500080e7          	jalr	1280(ra) # 80003e8e <iunlockput>
  iput(ip);
    80005996:	8526                	mv	a0,s1
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	44e080e7          	jalr	1102(ra) # 80003de6 <iput>
  end_op();
    800059a0:	fffff097          	auipc	ra,0xfffff
    800059a4:	cdc080e7          	jalr	-804(ra) # 8000467c <end_op>
  return 0;
    800059a8:	4781                	li	a5,0
    800059aa:	a085                	j	80005a0a <sys_link+0x13c>
    end_op();
    800059ac:	fffff097          	auipc	ra,0xfffff
    800059b0:	cd0080e7          	jalr	-816(ra) # 8000467c <end_op>
    return -1;
    800059b4:	57fd                	li	a5,-1
    800059b6:	a891                	j	80005a0a <sys_link+0x13c>
    iunlockput(ip);
    800059b8:	8526                	mv	a0,s1
    800059ba:	ffffe097          	auipc	ra,0xffffe
    800059be:	4d4080e7          	jalr	1236(ra) # 80003e8e <iunlockput>
    end_op();
    800059c2:	fffff097          	auipc	ra,0xfffff
    800059c6:	cba080e7          	jalr	-838(ra) # 8000467c <end_op>
    return -1;
    800059ca:	57fd                	li	a5,-1
    800059cc:	a83d                	j	80005a0a <sys_link+0x13c>
    iunlockput(dp);
    800059ce:	854a                	mv	a0,s2
    800059d0:	ffffe097          	auipc	ra,0xffffe
    800059d4:	4be080e7          	jalr	1214(ra) # 80003e8e <iunlockput>
  ilock(ip);
    800059d8:	8526                	mv	a0,s1
    800059da:	ffffe097          	auipc	ra,0xffffe
    800059de:	252080e7          	jalr	594(ra) # 80003c2c <ilock>
  ip->nlink--;
    800059e2:	0524d783          	lhu	a5,82(s1)
    800059e6:	37fd                	addiw	a5,a5,-1
    800059e8:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800059ec:	8526                	mv	a0,s1
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	174080e7          	jalr	372(ra) # 80003b62 <iupdate>
  iunlockput(ip);
    800059f6:	8526                	mv	a0,s1
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	496080e7          	jalr	1174(ra) # 80003e8e <iunlockput>
  end_op();
    80005a00:	fffff097          	auipc	ra,0xfffff
    80005a04:	c7c080e7          	jalr	-900(ra) # 8000467c <end_op>
  return -1;
    80005a08:	57fd                	li	a5,-1
}
    80005a0a:	853e                	mv	a0,a5
    80005a0c:	70b2                	ld	ra,296(sp)
    80005a0e:	7412                	ld	s0,288(sp)
    80005a10:	64f2                	ld	s1,280(sp)
    80005a12:	6952                	ld	s2,272(sp)
    80005a14:	6155                	addi	sp,sp,304
    80005a16:	8082                	ret

0000000080005a18 <sys_unlink>:
{
    80005a18:	7151                	addi	sp,sp,-240
    80005a1a:	f586                	sd	ra,232(sp)
    80005a1c:	f1a2                	sd	s0,224(sp)
    80005a1e:	eda6                	sd	s1,216(sp)
    80005a20:	e9ca                	sd	s2,208(sp)
    80005a22:	e5ce                	sd	s3,200(sp)
    80005a24:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a26:	08000613          	li	a2,128
    80005a2a:	f3040593          	addi	a1,s0,-208
    80005a2e:	4501                	li	a0,0
    80005a30:	ffffd097          	auipc	ra,0xffffd
    80005a34:	410080e7          	jalr	1040(ra) # 80002e40 <argstr>
    80005a38:	18054163          	bltz	a0,80005bba <sys_unlink+0x1a2>
  begin_op();
    80005a3c:	fffff097          	auipc	ra,0xfffff
    80005a40:	bc0080e7          	jalr	-1088(ra) # 800045fc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a44:	fb040593          	addi	a1,s0,-80
    80005a48:	f3040513          	addi	a0,s0,-208
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	9b2080e7          	jalr	-1614(ra) # 800043fe <nameiparent>
    80005a54:	84aa                	mv	s1,a0
    80005a56:	c979                	beqz	a0,80005b2c <sys_unlink+0x114>
  ilock(dp);
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	1d4080e7          	jalr	468(ra) # 80003c2c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a60:	00003597          	auipc	a1,0x3
    80005a64:	d2858593          	addi	a1,a1,-728 # 80008788 <syscalls+0x2c8>
    80005a68:	fb040513          	addi	a0,s0,-80
    80005a6c:	ffffe097          	auipc	ra,0xffffe
    80005a70:	688080e7          	jalr	1672(ra) # 800040f4 <namecmp>
    80005a74:	14050a63          	beqz	a0,80005bc8 <sys_unlink+0x1b0>
    80005a78:	00003597          	auipc	a1,0x3
    80005a7c:	d1858593          	addi	a1,a1,-744 # 80008790 <syscalls+0x2d0>
    80005a80:	fb040513          	addi	a0,s0,-80
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	670080e7          	jalr	1648(ra) # 800040f4 <namecmp>
    80005a8c:	12050e63          	beqz	a0,80005bc8 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a90:	f2c40613          	addi	a2,s0,-212
    80005a94:	fb040593          	addi	a1,s0,-80
    80005a98:	8526                	mv	a0,s1
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	674080e7          	jalr	1652(ra) # 8000410e <dirlookup>
    80005aa2:	892a                	mv	s2,a0
    80005aa4:	12050263          	beqz	a0,80005bc8 <sys_unlink+0x1b0>
  ilock(ip);
    80005aa8:	ffffe097          	auipc	ra,0xffffe
    80005aac:	184080e7          	jalr	388(ra) # 80003c2c <ilock>
  if(ip->nlink < 1)
    80005ab0:	05291783          	lh	a5,82(s2)
    80005ab4:	08f05263          	blez	a5,80005b38 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005ab8:	04c91703          	lh	a4,76(s2)
    80005abc:	4785                	li	a5,1
    80005abe:	08f70563          	beq	a4,a5,80005b48 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005ac2:	4641                	li	a2,16
    80005ac4:	4581                	li	a1,0
    80005ac6:	fc040513          	addi	a0,s0,-64
    80005aca:	ffffb097          	auipc	ra,0xffffb
    80005ace:	612080e7          	jalr	1554(ra) # 800010dc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ad2:	4741                	li	a4,16
    80005ad4:	f2c42683          	lw	a3,-212(s0)
    80005ad8:	fc040613          	addi	a2,s0,-64
    80005adc:	4581                	li	a1,0
    80005ade:	8526                	mv	a0,s1
    80005ae0:	ffffe097          	auipc	ra,0xffffe
    80005ae4:	4f8080e7          	jalr	1272(ra) # 80003fd8 <writei>
    80005ae8:	47c1                	li	a5,16
    80005aea:	0af51563          	bne	a0,a5,80005b94 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005aee:	04c91703          	lh	a4,76(s2)
    80005af2:	4785                	li	a5,1
    80005af4:	0af70863          	beq	a4,a5,80005ba4 <sys_unlink+0x18c>
  iunlockput(dp);
    80005af8:	8526                	mv	a0,s1
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	394080e7          	jalr	916(ra) # 80003e8e <iunlockput>
  ip->nlink--;
    80005b02:	05295783          	lhu	a5,82(s2)
    80005b06:	37fd                	addiw	a5,a5,-1
    80005b08:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    80005b0c:	854a                	mv	a0,s2
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	054080e7          	jalr	84(ra) # 80003b62 <iupdate>
  iunlockput(ip);
    80005b16:	854a                	mv	a0,s2
    80005b18:	ffffe097          	auipc	ra,0xffffe
    80005b1c:	376080e7          	jalr	886(ra) # 80003e8e <iunlockput>
  end_op();
    80005b20:	fffff097          	auipc	ra,0xfffff
    80005b24:	b5c080e7          	jalr	-1188(ra) # 8000467c <end_op>
  return 0;
    80005b28:	4501                	li	a0,0
    80005b2a:	a84d                	j	80005bdc <sys_unlink+0x1c4>
    end_op();
    80005b2c:	fffff097          	auipc	ra,0xfffff
    80005b30:	b50080e7          	jalr	-1200(ra) # 8000467c <end_op>
    return -1;
    80005b34:	557d                	li	a0,-1
    80005b36:	a05d                	j	80005bdc <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b38:	00003517          	auipc	a0,0x3
    80005b3c:	c8050513          	addi	a0,a0,-896 # 800087b8 <syscalls+0x2f8>
    80005b40:	ffffb097          	auipc	ra,0xffffb
    80005b44:	a0a080e7          	jalr	-1526(ra) # 8000054a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b48:	05492703          	lw	a4,84(s2)
    80005b4c:	02000793          	li	a5,32
    80005b50:	f6e7f9e3          	bgeu	a5,a4,80005ac2 <sys_unlink+0xaa>
    80005b54:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b58:	4741                	li	a4,16
    80005b5a:	86ce                	mv	a3,s3
    80005b5c:	f1840613          	addi	a2,s0,-232
    80005b60:	4581                	li	a1,0
    80005b62:	854a                	mv	a0,s2
    80005b64:	ffffe097          	auipc	ra,0xffffe
    80005b68:	37c080e7          	jalr	892(ra) # 80003ee0 <readi>
    80005b6c:	47c1                	li	a5,16
    80005b6e:	00f51b63          	bne	a0,a5,80005b84 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b72:	f1845783          	lhu	a5,-232(s0)
    80005b76:	e7a1                	bnez	a5,80005bbe <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b78:	29c1                	addiw	s3,s3,16
    80005b7a:	05492783          	lw	a5,84(s2)
    80005b7e:	fcf9ede3          	bltu	s3,a5,80005b58 <sys_unlink+0x140>
    80005b82:	b781                	j	80005ac2 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b84:	00003517          	auipc	a0,0x3
    80005b88:	c4c50513          	addi	a0,a0,-948 # 800087d0 <syscalls+0x310>
    80005b8c:	ffffb097          	auipc	ra,0xffffb
    80005b90:	9be080e7          	jalr	-1602(ra) # 8000054a <panic>
    panic("unlink: writei");
    80005b94:	00003517          	auipc	a0,0x3
    80005b98:	c5450513          	addi	a0,a0,-940 # 800087e8 <syscalls+0x328>
    80005b9c:	ffffb097          	auipc	ra,0xffffb
    80005ba0:	9ae080e7          	jalr	-1618(ra) # 8000054a <panic>
    dp->nlink--;
    80005ba4:	0524d783          	lhu	a5,82(s1)
    80005ba8:	37fd                	addiw	a5,a5,-1
    80005baa:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005bae:	8526                	mv	a0,s1
    80005bb0:	ffffe097          	auipc	ra,0xffffe
    80005bb4:	fb2080e7          	jalr	-78(ra) # 80003b62 <iupdate>
    80005bb8:	b781                	j	80005af8 <sys_unlink+0xe0>
    return -1;
    80005bba:	557d                	li	a0,-1
    80005bbc:	a005                	j	80005bdc <sys_unlink+0x1c4>
    iunlockput(ip);
    80005bbe:	854a                	mv	a0,s2
    80005bc0:	ffffe097          	auipc	ra,0xffffe
    80005bc4:	2ce080e7          	jalr	718(ra) # 80003e8e <iunlockput>
  iunlockput(dp);
    80005bc8:	8526                	mv	a0,s1
    80005bca:	ffffe097          	auipc	ra,0xffffe
    80005bce:	2c4080e7          	jalr	708(ra) # 80003e8e <iunlockput>
  end_op();
    80005bd2:	fffff097          	auipc	ra,0xfffff
    80005bd6:	aaa080e7          	jalr	-1366(ra) # 8000467c <end_op>
  return -1;
    80005bda:	557d                	li	a0,-1
}
    80005bdc:	70ae                	ld	ra,232(sp)
    80005bde:	740e                	ld	s0,224(sp)
    80005be0:	64ee                	ld	s1,216(sp)
    80005be2:	694e                	ld	s2,208(sp)
    80005be4:	69ae                	ld	s3,200(sp)
    80005be6:	616d                	addi	sp,sp,240
    80005be8:	8082                	ret

0000000080005bea <sys_open>:

uint64
sys_open(void)
{
    80005bea:	7131                	addi	sp,sp,-192
    80005bec:	fd06                	sd	ra,184(sp)
    80005bee:	f922                	sd	s0,176(sp)
    80005bf0:	f526                	sd	s1,168(sp)
    80005bf2:	f14a                	sd	s2,160(sp)
    80005bf4:	ed4e                	sd	s3,152(sp)
    80005bf6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005bf8:	08000613          	li	a2,128
    80005bfc:	f5040593          	addi	a1,s0,-176
    80005c00:	4501                	li	a0,0
    80005c02:	ffffd097          	auipc	ra,0xffffd
    80005c06:	23e080e7          	jalr	574(ra) # 80002e40 <argstr>
    return -1;
    80005c0a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c0c:	0c054163          	bltz	a0,80005cce <sys_open+0xe4>
    80005c10:	f4c40593          	addi	a1,s0,-180
    80005c14:	4505                	li	a0,1
    80005c16:	ffffd097          	auipc	ra,0xffffd
    80005c1a:	1e6080e7          	jalr	486(ra) # 80002dfc <argint>
    80005c1e:	0a054863          	bltz	a0,80005cce <sys_open+0xe4>

  begin_op();
    80005c22:	fffff097          	auipc	ra,0xfffff
    80005c26:	9da080e7          	jalr	-1574(ra) # 800045fc <begin_op>

  if(omode & O_CREATE){
    80005c2a:	f4c42783          	lw	a5,-180(s0)
    80005c2e:	2007f793          	andi	a5,a5,512
    80005c32:	cbdd                	beqz	a5,80005ce8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c34:	4681                	li	a3,0
    80005c36:	4601                	li	a2,0
    80005c38:	4589                	li	a1,2
    80005c3a:	f5040513          	addi	a0,s0,-176
    80005c3e:	00000097          	auipc	ra,0x0
    80005c42:	974080e7          	jalr	-1676(ra) # 800055b2 <create>
    80005c46:	892a                	mv	s2,a0
    if(ip == 0){
    80005c48:	c959                	beqz	a0,80005cde <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c4a:	04c91703          	lh	a4,76(s2)
    80005c4e:	478d                	li	a5,3
    80005c50:	00f71763          	bne	a4,a5,80005c5e <sys_open+0x74>
    80005c54:	04e95703          	lhu	a4,78(s2)
    80005c58:	47a5                	li	a5,9
    80005c5a:	0ce7ec63          	bltu	a5,a4,80005d32 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c5e:	fffff097          	auipc	ra,0xfffff
    80005c62:	db6080e7          	jalr	-586(ra) # 80004a14 <filealloc>
    80005c66:	89aa                	mv	s3,a0
    80005c68:	10050263          	beqz	a0,80005d6c <sys_open+0x182>
    80005c6c:	00000097          	auipc	ra,0x0
    80005c70:	904080e7          	jalr	-1788(ra) # 80005570 <fdalloc>
    80005c74:	84aa                	mv	s1,a0
    80005c76:	0e054663          	bltz	a0,80005d62 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c7a:	04c91703          	lh	a4,76(s2)
    80005c7e:	478d                	li	a5,3
    80005c80:	0cf70463          	beq	a4,a5,80005d48 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c84:	4789                	li	a5,2
    80005c86:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c8a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c8e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c92:	f4c42783          	lw	a5,-180(s0)
    80005c96:	0017c713          	xori	a4,a5,1
    80005c9a:	8b05                	andi	a4,a4,1
    80005c9c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ca0:	0037f713          	andi	a4,a5,3
    80005ca4:	00e03733          	snez	a4,a4
    80005ca8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005cac:	4007f793          	andi	a5,a5,1024
    80005cb0:	c791                	beqz	a5,80005cbc <sys_open+0xd2>
    80005cb2:	04c91703          	lh	a4,76(s2)
    80005cb6:	4789                	li	a5,2
    80005cb8:	08f70f63          	beq	a4,a5,80005d56 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005cbc:	854a                	mv	a0,s2
    80005cbe:	ffffe097          	auipc	ra,0xffffe
    80005cc2:	030080e7          	jalr	48(ra) # 80003cee <iunlock>
  end_op();
    80005cc6:	fffff097          	auipc	ra,0xfffff
    80005cca:	9b6080e7          	jalr	-1610(ra) # 8000467c <end_op>

  return fd;
}
    80005cce:	8526                	mv	a0,s1
    80005cd0:	70ea                	ld	ra,184(sp)
    80005cd2:	744a                	ld	s0,176(sp)
    80005cd4:	74aa                	ld	s1,168(sp)
    80005cd6:	790a                	ld	s2,160(sp)
    80005cd8:	69ea                	ld	s3,152(sp)
    80005cda:	6129                	addi	sp,sp,192
    80005cdc:	8082                	ret
      end_op();
    80005cde:	fffff097          	auipc	ra,0xfffff
    80005ce2:	99e080e7          	jalr	-1634(ra) # 8000467c <end_op>
      return -1;
    80005ce6:	b7e5                	j	80005cce <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005ce8:	f5040513          	addi	a0,s0,-176
    80005cec:	ffffe097          	auipc	ra,0xffffe
    80005cf0:	6f4080e7          	jalr	1780(ra) # 800043e0 <namei>
    80005cf4:	892a                	mv	s2,a0
    80005cf6:	c905                	beqz	a0,80005d26 <sys_open+0x13c>
    ilock(ip);
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	f34080e7          	jalr	-204(ra) # 80003c2c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d00:	04c91703          	lh	a4,76(s2)
    80005d04:	4785                	li	a5,1
    80005d06:	f4f712e3          	bne	a4,a5,80005c4a <sys_open+0x60>
    80005d0a:	f4c42783          	lw	a5,-180(s0)
    80005d0e:	dba1                	beqz	a5,80005c5e <sys_open+0x74>
      iunlockput(ip);
    80005d10:	854a                	mv	a0,s2
    80005d12:	ffffe097          	auipc	ra,0xffffe
    80005d16:	17c080e7          	jalr	380(ra) # 80003e8e <iunlockput>
      end_op();
    80005d1a:	fffff097          	auipc	ra,0xfffff
    80005d1e:	962080e7          	jalr	-1694(ra) # 8000467c <end_op>
      return -1;
    80005d22:	54fd                	li	s1,-1
    80005d24:	b76d                	j	80005cce <sys_open+0xe4>
      end_op();
    80005d26:	fffff097          	auipc	ra,0xfffff
    80005d2a:	956080e7          	jalr	-1706(ra) # 8000467c <end_op>
      return -1;
    80005d2e:	54fd                	li	s1,-1
    80005d30:	bf79                	j	80005cce <sys_open+0xe4>
    iunlockput(ip);
    80005d32:	854a                	mv	a0,s2
    80005d34:	ffffe097          	auipc	ra,0xffffe
    80005d38:	15a080e7          	jalr	346(ra) # 80003e8e <iunlockput>
    end_op();
    80005d3c:	fffff097          	auipc	ra,0xfffff
    80005d40:	940080e7          	jalr	-1728(ra) # 8000467c <end_op>
    return -1;
    80005d44:	54fd                	li	s1,-1
    80005d46:	b761                	j	80005cce <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d48:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d4c:	04e91783          	lh	a5,78(s2)
    80005d50:	02f99223          	sh	a5,36(s3)
    80005d54:	bf2d                	j	80005c8e <sys_open+0xa4>
    itrunc(ip);
    80005d56:	854a                	mv	a0,s2
    80005d58:	ffffe097          	auipc	ra,0xffffe
    80005d5c:	fe2080e7          	jalr	-30(ra) # 80003d3a <itrunc>
    80005d60:	bfb1                	j	80005cbc <sys_open+0xd2>
      fileclose(f);
    80005d62:	854e                	mv	a0,s3
    80005d64:	fffff097          	auipc	ra,0xfffff
    80005d68:	d6c080e7          	jalr	-660(ra) # 80004ad0 <fileclose>
    iunlockput(ip);
    80005d6c:	854a                	mv	a0,s2
    80005d6e:	ffffe097          	auipc	ra,0xffffe
    80005d72:	120080e7          	jalr	288(ra) # 80003e8e <iunlockput>
    end_op();
    80005d76:	fffff097          	auipc	ra,0xfffff
    80005d7a:	906080e7          	jalr	-1786(ra) # 8000467c <end_op>
    return -1;
    80005d7e:	54fd                	li	s1,-1
    80005d80:	b7b9                	j	80005cce <sys_open+0xe4>

0000000080005d82 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d82:	7175                	addi	sp,sp,-144
    80005d84:	e506                	sd	ra,136(sp)
    80005d86:	e122                	sd	s0,128(sp)
    80005d88:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d8a:	fffff097          	auipc	ra,0xfffff
    80005d8e:	872080e7          	jalr	-1934(ra) # 800045fc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d92:	08000613          	li	a2,128
    80005d96:	f7040593          	addi	a1,s0,-144
    80005d9a:	4501                	li	a0,0
    80005d9c:	ffffd097          	auipc	ra,0xffffd
    80005da0:	0a4080e7          	jalr	164(ra) # 80002e40 <argstr>
    80005da4:	02054963          	bltz	a0,80005dd6 <sys_mkdir+0x54>
    80005da8:	4681                	li	a3,0
    80005daa:	4601                	li	a2,0
    80005dac:	4585                	li	a1,1
    80005dae:	f7040513          	addi	a0,s0,-144
    80005db2:	00000097          	auipc	ra,0x0
    80005db6:	800080e7          	jalr	-2048(ra) # 800055b2 <create>
    80005dba:	cd11                	beqz	a0,80005dd6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dbc:	ffffe097          	auipc	ra,0xffffe
    80005dc0:	0d2080e7          	jalr	210(ra) # 80003e8e <iunlockput>
  end_op();
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	8b8080e7          	jalr	-1864(ra) # 8000467c <end_op>
  return 0;
    80005dcc:	4501                	li	a0,0
}
    80005dce:	60aa                	ld	ra,136(sp)
    80005dd0:	640a                	ld	s0,128(sp)
    80005dd2:	6149                	addi	sp,sp,144
    80005dd4:	8082                	ret
    end_op();
    80005dd6:	fffff097          	auipc	ra,0xfffff
    80005dda:	8a6080e7          	jalr	-1882(ra) # 8000467c <end_op>
    return -1;
    80005dde:	557d                	li	a0,-1
    80005de0:	b7fd                	j	80005dce <sys_mkdir+0x4c>

0000000080005de2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005de2:	7135                	addi	sp,sp,-160
    80005de4:	ed06                	sd	ra,152(sp)
    80005de6:	e922                	sd	s0,144(sp)
    80005de8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005dea:	fffff097          	auipc	ra,0xfffff
    80005dee:	812080e7          	jalr	-2030(ra) # 800045fc <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005df2:	08000613          	li	a2,128
    80005df6:	f7040593          	addi	a1,s0,-144
    80005dfa:	4501                	li	a0,0
    80005dfc:	ffffd097          	auipc	ra,0xffffd
    80005e00:	044080e7          	jalr	68(ra) # 80002e40 <argstr>
    80005e04:	04054a63          	bltz	a0,80005e58 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005e08:	f6c40593          	addi	a1,s0,-148
    80005e0c:	4505                	li	a0,1
    80005e0e:	ffffd097          	auipc	ra,0xffffd
    80005e12:	fee080e7          	jalr	-18(ra) # 80002dfc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e16:	04054163          	bltz	a0,80005e58 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005e1a:	f6840593          	addi	a1,s0,-152
    80005e1e:	4509                	li	a0,2
    80005e20:	ffffd097          	auipc	ra,0xffffd
    80005e24:	fdc080e7          	jalr	-36(ra) # 80002dfc <argint>
     argint(1, &major) < 0 ||
    80005e28:	02054863          	bltz	a0,80005e58 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e2c:	f6841683          	lh	a3,-152(s0)
    80005e30:	f6c41603          	lh	a2,-148(s0)
    80005e34:	458d                	li	a1,3
    80005e36:	f7040513          	addi	a0,s0,-144
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	778080e7          	jalr	1912(ra) # 800055b2 <create>
     argint(2, &minor) < 0 ||
    80005e42:	c919                	beqz	a0,80005e58 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e44:	ffffe097          	auipc	ra,0xffffe
    80005e48:	04a080e7          	jalr	74(ra) # 80003e8e <iunlockput>
  end_op();
    80005e4c:	fffff097          	auipc	ra,0xfffff
    80005e50:	830080e7          	jalr	-2000(ra) # 8000467c <end_op>
  return 0;
    80005e54:	4501                	li	a0,0
    80005e56:	a031                	j	80005e62 <sys_mknod+0x80>
    end_op();
    80005e58:	fffff097          	auipc	ra,0xfffff
    80005e5c:	824080e7          	jalr	-2012(ra) # 8000467c <end_op>
    return -1;
    80005e60:	557d                	li	a0,-1
}
    80005e62:	60ea                	ld	ra,152(sp)
    80005e64:	644a                	ld	s0,144(sp)
    80005e66:	610d                	addi	sp,sp,160
    80005e68:	8082                	ret

0000000080005e6a <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e6a:	7135                	addi	sp,sp,-160
    80005e6c:	ed06                	sd	ra,152(sp)
    80005e6e:	e922                	sd	s0,144(sp)
    80005e70:	e526                	sd	s1,136(sp)
    80005e72:	e14a                	sd	s2,128(sp)
    80005e74:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e76:	ffffc097          	auipc	ra,0xffffc
    80005e7a:	ecc080e7          	jalr	-308(ra) # 80001d42 <myproc>
    80005e7e:	892a                	mv	s2,a0
  
  begin_op();
    80005e80:	ffffe097          	auipc	ra,0xffffe
    80005e84:	77c080e7          	jalr	1916(ra) # 800045fc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e88:	08000613          	li	a2,128
    80005e8c:	f6040593          	addi	a1,s0,-160
    80005e90:	4501                	li	a0,0
    80005e92:	ffffd097          	auipc	ra,0xffffd
    80005e96:	fae080e7          	jalr	-82(ra) # 80002e40 <argstr>
    80005e9a:	04054b63          	bltz	a0,80005ef0 <sys_chdir+0x86>
    80005e9e:	f6040513          	addi	a0,s0,-160
    80005ea2:	ffffe097          	auipc	ra,0xffffe
    80005ea6:	53e080e7          	jalr	1342(ra) # 800043e0 <namei>
    80005eaa:	84aa                	mv	s1,a0
    80005eac:	c131                	beqz	a0,80005ef0 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005eae:	ffffe097          	auipc	ra,0xffffe
    80005eb2:	d7e080e7          	jalr	-642(ra) # 80003c2c <ilock>
  if(ip->type != T_DIR){
    80005eb6:	04c49703          	lh	a4,76(s1)
    80005eba:	4785                	li	a5,1
    80005ebc:	04f71063          	bne	a4,a5,80005efc <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ec0:	8526                	mv	a0,s1
    80005ec2:	ffffe097          	auipc	ra,0xffffe
    80005ec6:	e2c080e7          	jalr	-468(ra) # 80003cee <iunlock>
  iput(p->cwd);
    80005eca:	15893503          	ld	a0,344(s2)
    80005ece:	ffffe097          	auipc	ra,0xffffe
    80005ed2:	f18080e7          	jalr	-232(ra) # 80003de6 <iput>
  end_op();
    80005ed6:	ffffe097          	auipc	ra,0xffffe
    80005eda:	7a6080e7          	jalr	1958(ra) # 8000467c <end_op>
  p->cwd = ip;
    80005ede:	14993c23          	sd	s1,344(s2)
  return 0;
    80005ee2:	4501                	li	a0,0
}
    80005ee4:	60ea                	ld	ra,152(sp)
    80005ee6:	644a                	ld	s0,144(sp)
    80005ee8:	64aa                	ld	s1,136(sp)
    80005eea:	690a                	ld	s2,128(sp)
    80005eec:	610d                	addi	sp,sp,160
    80005eee:	8082                	ret
    end_op();
    80005ef0:	ffffe097          	auipc	ra,0xffffe
    80005ef4:	78c080e7          	jalr	1932(ra) # 8000467c <end_op>
    return -1;
    80005ef8:	557d                	li	a0,-1
    80005efa:	b7ed                	j	80005ee4 <sys_chdir+0x7a>
    iunlockput(ip);
    80005efc:	8526                	mv	a0,s1
    80005efe:	ffffe097          	auipc	ra,0xffffe
    80005f02:	f90080e7          	jalr	-112(ra) # 80003e8e <iunlockput>
    end_op();
    80005f06:	ffffe097          	auipc	ra,0xffffe
    80005f0a:	776080e7          	jalr	1910(ra) # 8000467c <end_op>
    return -1;
    80005f0e:	557d                	li	a0,-1
    80005f10:	bfd1                	j	80005ee4 <sys_chdir+0x7a>

0000000080005f12 <sys_exec>:

uint64
sys_exec(void)
{
    80005f12:	7145                	addi	sp,sp,-464
    80005f14:	e786                	sd	ra,456(sp)
    80005f16:	e3a2                	sd	s0,448(sp)
    80005f18:	ff26                	sd	s1,440(sp)
    80005f1a:	fb4a                	sd	s2,432(sp)
    80005f1c:	f74e                	sd	s3,424(sp)
    80005f1e:	f352                	sd	s4,416(sp)
    80005f20:	ef56                	sd	s5,408(sp)
    80005f22:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f24:	08000613          	li	a2,128
    80005f28:	f4040593          	addi	a1,s0,-192
    80005f2c:	4501                	li	a0,0
    80005f2e:	ffffd097          	auipc	ra,0xffffd
    80005f32:	f12080e7          	jalr	-238(ra) # 80002e40 <argstr>
    return -1;
    80005f36:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f38:	0c054a63          	bltz	a0,8000600c <sys_exec+0xfa>
    80005f3c:	e3840593          	addi	a1,s0,-456
    80005f40:	4505                	li	a0,1
    80005f42:	ffffd097          	auipc	ra,0xffffd
    80005f46:	edc080e7          	jalr	-292(ra) # 80002e1e <argaddr>
    80005f4a:	0c054163          	bltz	a0,8000600c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f4e:	10000613          	li	a2,256
    80005f52:	4581                	li	a1,0
    80005f54:	e4040513          	addi	a0,s0,-448
    80005f58:	ffffb097          	auipc	ra,0xffffb
    80005f5c:	184080e7          	jalr	388(ra) # 800010dc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f60:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f64:	89a6                	mv	s3,s1
    80005f66:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f68:	02000a13          	li	s4,32
    80005f6c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f70:	00391793          	slli	a5,s2,0x3
    80005f74:	e3040593          	addi	a1,s0,-464
    80005f78:	e3843503          	ld	a0,-456(s0)
    80005f7c:	953e                	add	a0,a0,a5
    80005f7e:	ffffd097          	auipc	ra,0xffffd
    80005f82:	de4080e7          	jalr	-540(ra) # 80002d62 <fetchaddr>
    80005f86:	02054a63          	bltz	a0,80005fba <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005f8a:	e3043783          	ld	a5,-464(s0)
    80005f8e:	c3b9                	beqz	a5,80005fd4 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f90:	ffffb097          	auipc	ra,0xffffb
    80005f94:	bf0080e7          	jalr	-1040(ra) # 80000b80 <kalloc>
    80005f98:	85aa                	mv	a1,a0
    80005f9a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f9e:	cd11                	beqz	a0,80005fba <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005fa0:	6605                	lui	a2,0x1
    80005fa2:	e3043503          	ld	a0,-464(s0)
    80005fa6:	ffffd097          	auipc	ra,0xffffd
    80005faa:	e0e080e7          	jalr	-498(ra) # 80002db4 <fetchstr>
    80005fae:	00054663          	bltz	a0,80005fba <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005fb2:	0905                	addi	s2,s2,1
    80005fb4:	09a1                	addi	s3,s3,8
    80005fb6:	fb491be3          	bne	s2,s4,80005f6c <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fba:	10048913          	addi	s2,s1,256
    80005fbe:	6088                	ld	a0,0(s1)
    80005fc0:	c529                	beqz	a0,8000600a <sys_exec+0xf8>
    kfree(argv[i]);
    80005fc2:	ffffb097          	auipc	ra,0xffffb
    80005fc6:	a58080e7          	jalr	-1448(ra) # 80000a1a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fca:	04a1                	addi	s1,s1,8
    80005fcc:	ff2499e3          	bne	s1,s2,80005fbe <sys_exec+0xac>
  return -1;
    80005fd0:	597d                	li	s2,-1
    80005fd2:	a82d                	j	8000600c <sys_exec+0xfa>
      argv[i] = 0;
    80005fd4:	0a8e                	slli	s5,s5,0x3
    80005fd6:	fc040793          	addi	a5,s0,-64
    80005fda:	9abe                	add	s5,s5,a5
    80005fdc:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd2e58>
  int ret = exec(path, argv);
    80005fe0:	e4040593          	addi	a1,s0,-448
    80005fe4:	f4040513          	addi	a0,s0,-192
    80005fe8:	fffff097          	auipc	ra,0xfffff
    80005fec:	178080e7          	jalr	376(ra) # 80005160 <exec>
    80005ff0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ff2:	10048993          	addi	s3,s1,256
    80005ff6:	6088                	ld	a0,0(s1)
    80005ff8:	c911                	beqz	a0,8000600c <sys_exec+0xfa>
    kfree(argv[i]);
    80005ffa:	ffffb097          	auipc	ra,0xffffb
    80005ffe:	a20080e7          	jalr	-1504(ra) # 80000a1a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006002:	04a1                	addi	s1,s1,8
    80006004:	ff3499e3          	bne	s1,s3,80005ff6 <sys_exec+0xe4>
    80006008:	a011                	j	8000600c <sys_exec+0xfa>
  return -1;
    8000600a:	597d                	li	s2,-1
}
    8000600c:	854a                	mv	a0,s2
    8000600e:	60be                	ld	ra,456(sp)
    80006010:	641e                	ld	s0,448(sp)
    80006012:	74fa                	ld	s1,440(sp)
    80006014:	795a                	ld	s2,432(sp)
    80006016:	79ba                	ld	s3,424(sp)
    80006018:	7a1a                	ld	s4,416(sp)
    8000601a:	6afa                	ld	s5,408(sp)
    8000601c:	6179                	addi	sp,sp,464
    8000601e:	8082                	ret

0000000080006020 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006020:	7139                	addi	sp,sp,-64
    80006022:	fc06                	sd	ra,56(sp)
    80006024:	f822                	sd	s0,48(sp)
    80006026:	f426                	sd	s1,40(sp)
    80006028:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000602a:	ffffc097          	auipc	ra,0xffffc
    8000602e:	d18080e7          	jalr	-744(ra) # 80001d42 <myproc>
    80006032:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006034:	fd840593          	addi	a1,s0,-40
    80006038:	4501                	li	a0,0
    8000603a:	ffffd097          	auipc	ra,0xffffd
    8000603e:	de4080e7          	jalr	-540(ra) # 80002e1e <argaddr>
    return -1;
    80006042:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006044:	0e054063          	bltz	a0,80006124 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006048:	fc840593          	addi	a1,s0,-56
    8000604c:	fd040513          	addi	a0,s0,-48
    80006050:	fffff097          	auipc	ra,0xfffff
    80006054:	dd6080e7          	jalr	-554(ra) # 80004e26 <pipealloc>
    return -1;
    80006058:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000605a:	0c054563          	bltz	a0,80006124 <sys_pipe+0x104>
  fd0 = -1;
    8000605e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006062:	fd043503          	ld	a0,-48(s0)
    80006066:	fffff097          	auipc	ra,0xfffff
    8000606a:	50a080e7          	jalr	1290(ra) # 80005570 <fdalloc>
    8000606e:	fca42223          	sw	a0,-60(s0)
    80006072:	08054c63          	bltz	a0,8000610a <sys_pipe+0xea>
    80006076:	fc843503          	ld	a0,-56(s0)
    8000607a:	fffff097          	auipc	ra,0xfffff
    8000607e:	4f6080e7          	jalr	1270(ra) # 80005570 <fdalloc>
    80006082:	fca42023          	sw	a0,-64(s0)
    80006086:	06054863          	bltz	a0,800060f6 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000608a:	4691                	li	a3,4
    8000608c:	fc440613          	addi	a2,s0,-60
    80006090:	fd843583          	ld	a1,-40(s0)
    80006094:	6ca8                	ld	a0,88(s1)
    80006096:	ffffc097          	auipc	ra,0xffffc
    8000609a:	99e080e7          	jalr	-1634(ra) # 80001a34 <copyout>
    8000609e:	02054063          	bltz	a0,800060be <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800060a2:	4691                	li	a3,4
    800060a4:	fc040613          	addi	a2,s0,-64
    800060a8:	fd843583          	ld	a1,-40(s0)
    800060ac:	0591                	addi	a1,a1,4
    800060ae:	6ca8                	ld	a0,88(s1)
    800060b0:	ffffc097          	auipc	ra,0xffffc
    800060b4:	984080e7          	jalr	-1660(ra) # 80001a34 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800060b8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060ba:	06055563          	bgez	a0,80006124 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800060be:	fc442783          	lw	a5,-60(s0)
    800060c2:	07e9                	addi	a5,a5,26
    800060c4:	078e                	slli	a5,a5,0x3
    800060c6:	97a6                	add	a5,a5,s1
    800060c8:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800060cc:	fc042503          	lw	a0,-64(s0)
    800060d0:	0569                	addi	a0,a0,26
    800060d2:	050e                	slli	a0,a0,0x3
    800060d4:	9526                	add	a0,a0,s1
    800060d6:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    800060da:	fd043503          	ld	a0,-48(s0)
    800060de:	fffff097          	auipc	ra,0xfffff
    800060e2:	9f2080e7          	jalr	-1550(ra) # 80004ad0 <fileclose>
    fileclose(wf);
    800060e6:	fc843503          	ld	a0,-56(s0)
    800060ea:	fffff097          	auipc	ra,0xfffff
    800060ee:	9e6080e7          	jalr	-1562(ra) # 80004ad0 <fileclose>
    return -1;
    800060f2:	57fd                	li	a5,-1
    800060f4:	a805                	j	80006124 <sys_pipe+0x104>
    if(fd0 >= 0)
    800060f6:	fc442783          	lw	a5,-60(s0)
    800060fa:	0007c863          	bltz	a5,8000610a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800060fe:	01a78513          	addi	a0,a5,26
    80006102:	050e                	slli	a0,a0,0x3
    80006104:	9526                	add	a0,a0,s1
    80006106:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    8000610a:	fd043503          	ld	a0,-48(s0)
    8000610e:	fffff097          	auipc	ra,0xfffff
    80006112:	9c2080e7          	jalr	-1598(ra) # 80004ad0 <fileclose>
    fileclose(wf);
    80006116:	fc843503          	ld	a0,-56(s0)
    8000611a:	fffff097          	auipc	ra,0xfffff
    8000611e:	9b6080e7          	jalr	-1610(ra) # 80004ad0 <fileclose>
    return -1;
    80006122:	57fd                	li	a5,-1
}
    80006124:	853e                	mv	a0,a5
    80006126:	70e2                	ld	ra,56(sp)
    80006128:	7442                	ld	s0,48(sp)
    8000612a:	74a2                	ld	s1,40(sp)
    8000612c:	6121                	addi	sp,sp,64
    8000612e:	8082                	ret

0000000080006130 <kernelvec>:
    80006130:	7111                	addi	sp,sp,-256
    80006132:	e006                	sd	ra,0(sp)
    80006134:	e40a                	sd	sp,8(sp)
    80006136:	e80e                	sd	gp,16(sp)
    80006138:	ec12                	sd	tp,24(sp)
    8000613a:	f016                	sd	t0,32(sp)
    8000613c:	f41a                	sd	t1,40(sp)
    8000613e:	f81e                	sd	t2,48(sp)
    80006140:	fc22                	sd	s0,56(sp)
    80006142:	e0a6                	sd	s1,64(sp)
    80006144:	e4aa                	sd	a0,72(sp)
    80006146:	e8ae                	sd	a1,80(sp)
    80006148:	ecb2                	sd	a2,88(sp)
    8000614a:	f0b6                	sd	a3,96(sp)
    8000614c:	f4ba                	sd	a4,104(sp)
    8000614e:	f8be                	sd	a5,112(sp)
    80006150:	fcc2                	sd	a6,120(sp)
    80006152:	e146                	sd	a7,128(sp)
    80006154:	e54a                	sd	s2,136(sp)
    80006156:	e94e                	sd	s3,144(sp)
    80006158:	ed52                	sd	s4,152(sp)
    8000615a:	f156                	sd	s5,160(sp)
    8000615c:	f55a                	sd	s6,168(sp)
    8000615e:	f95e                	sd	s7,176(sp)
    80006160:	fd62                	sd	s8,184(sp)
    80006162:	e1e6                	sd	s9,192(sp)
    80006164:	e5ea                	sd	s10,200(sp)
    80006166:	e9ee                	sd	s11,208(sp)
    80006168:	edf2                	sd	t3,216(sp)
    8000616a:	f1f6                	sd	t4,224(sp)
    8000616c:	f5fa                	sd	t5,232(sp)
    8000616e:	f9fe                	sd	t6,240(sp)
    80006170:	abffc0ef          	jal	ra,80002c2e <kerneltrap>
    80006174:	6082                	ld	ra,0(sp)
    80006176:	6122                	ld	sp,8(sp)
    80006178:	61c2                	ld	gp,16(sp)
    8000617a:	7282                	ld	t0,32(sp)
    8000617c:	7322                	ld	t1,40(sp)
    8000617e:	73c2                	ld	t2,48(sp)
    80006180:	7462                	ld	s0,56(sp)
    80006182:	6486                	ld	s1,64(sp)
    80006184:	6526                	ld	a0,72(sp)
    80006186:	65c6                	ld	a1,80(sp)
    80006188:	6666                	ld	a2,88(sp)
    8000618a:	7686                	ld	a3,96(sp)
    8000618c:	7726                	ld	a4,104(sp)
    8000618e:	77c6                	ld	a5,112(sp)
    80006190:	7866                	ld	a6,120(sp)
    80006192:	688a                	ld	a7,128(sp)
    80006194:	692a                	ld	s2,136(sp)
    80006196:	69ca                	ld	s3,144(sp)
    80006198:	6a6a                	ld	s4,152(sp)
    8000619a:	7a8a                	ld	s5,160(sp)
    8000619c:	7b2a                	ld	s6,168(sp)
    8000619e:	7bca                	ld	s7,176(sp)
    800061a0:	7c6a                	ld	s8,184(sp)
    800061a2:	6c8e                	ld	s9,192(sp)
    800061a4:	6d2e                	ld	s10,200(sp)
    800061a6:	6dce                	ld	s11,208(sp)
    800061a8:	6e6e                	ld	t3,216(sp)
    800061aa:	7e8e                	ld	t4,224(sp)
    800061ac:	7f2e                	ld	t5,232(sp)
    800061ae:	7fce                	ld	t6,240(sp)
    800061b0:	6111                	addi	sp,sp,256
    800061b2:	10200073          	sret
    800061b6:	00000013          	nop
    800061ba:	00000013          	nop
    800061be:	0001                	nop

00000000800061c0 <timervec>:
    800061c0:	34051573          	csrrw	a0,mscratch,a0
    800061c4:	e10c                	sd	a1,0(a0)
    800061c6:	e510                	sd	a2,8(a0)
    800061c8:	e914                	sd	a3,16(a0)
    800061ca:	6d0c                	ld	a1,24(a0)
    800061cc:	7110                	ld	a2,32(a0)
    800061ce:	6194                	ld	a3,0(a1)
    800061d0:	96b2                	add	a3,a3,a2
    800061d2:	e194                	sd	a3,0(a1)
    800061d4:	4589                	li	a1,2
    800061d6:	14459073          	csrw	sip,a1
    800061da:	6914                	ld	a3,16(a0)
    800061dc:	6510                	ld	a2,8(a0)
    800061de:	610c                	ld	a1,0(a0)
    800061e0:	34051573          	csrrw	a0,mscratch,a0
    800061e4:	30200073          	mret
	...

00000000800061ea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800061ea:	1141                	addi	sp,sp,-16
    800061ec:	e422                	sd	s0,8(sp)
    800061ee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800061f0:	0c0007b7          	lui	a5,0xc000
    800061f4:	4705                	li	a4,1
    800061f6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800061f8:	c3d8                	sw	a4,4(a5)
}
    800061fa:	6422                	ld	s0,8(sp)
    800061fc:	0141                	addi	sp,sp,16
    800061fe:	8082                	ret

0000000080006200 <plicinithart>:

void
plicinithart(void)
{
    80006200:	1141                	addi	sp,sp,-16
    80006202:	e406                	sd	ra,8(sp)
    80006204:	e022                	sd	s0,0(sp)
    80006206:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006208:	ffffc097          	auipc	ra,0xffffc
    8000620c:	b0e080e7          	jalr	-1266(ra) # 80001d16 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006210:	0085171b          	slliw	a4,a0,0x8
    80006214:	0c0027b7          	lui	a5,0xc002
    80006218:	97ba                	add	a5,a5,a4
    8000621a:	40200713          	li	a4,1026
    8000621e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006222:	00d5151b          	slliw	a0,a0,0xd
    80006226:	0c2017b7          	lui	a5,0xc201
    8000622a:	953e                	add	a0,a0,a5
    8000622c:	00052023          	sw	zero,0(a0)
}
    80006230:	60a2                	ld	ra,8(sp)
    80006232:	6402                	ld	s0,0(sp)
    80006234:	0141                	addi	sp,sp,16
    80006236:	8082                	ret

0000000080006238 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006238:	1141                	addi	sp,sp,-16
    8000623a:	e406                	sd	ra,8(sp)
    8000623c:	e022                	sd	s0,0(sp)
    8000623e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006240:	ffffc097          	auipc	ra,0xffffc
    80006244:	ad6080e7          	jalr	-1322(ra) # 80001d16 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006248:	00d5179b          	slliw	a5,a0,0xd
    8000624c:	0c201537          	lui	a0,0xc201
    80006250:	953e                	add	a0,a0,a5
  return irq;
}
    80006252:	4148                	lw	a0,4(a0)
    80006254:	60a2                	ld	ra,8(sp)
    80006256:	6402                	ld	s0,0(sp)
    80006258:	0141                	addi	sp,sp,16
    8000625a:	8082                	ret

000000008000625c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000625c:	1101                	addi	sp,sp,-32
    8000625e:	ec06                	sd	ra,24(sp)
    80006260:	e822                	sd	s0,16(sp)
    80006262:	e426                	sd	s1,8(sp)
    80006264:	1000                	addi	s0,sp,32
    80006266:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006268:	ffffc097          	auipc	ra,0xffffc
    8000626c:	aae080e7          	jalr	-1362(ra) # 80001d16 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006270:	00d5151b          	slliw	a0,a0,0xd
    80006274:	0c2017b7          	lui	a5,0xc201
    80006278:	97aa                	add	a5,a5,a0
    8000627a:	c3c4                	sw	s1,4(a5)
}
    8000627c:	60e2                	ld	ra,24(sp)
    8000627e:	6442                	ld	s0,16(sp)
    80006280:	64a2                	ld	s1,8(sp)
    80006282:	6105                	addi	sp,sp,32
    80006284:	8082                	ret

0000000080006286 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006286:	1141                	addi	sp,sp,-16
    80006288:	e406                	sd	ra,8(sp)
    8000628a:	e022                	sd	s0,0(sp)
    8000628c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000628e:	479d                	li	a5,7
    80006290:	06a7c963          	blt	a5,a0,80006302 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006294:	00022797          	auipc	a5,0x22
    80006298:	d6c78793          	addi	a5,a5,-660 # 80028000 <disk>
    8000629c:	00a78733          	add	a4,a5,a0
    800062a0:	6789                	lui	a5,0x2
    800062a2:	97ba                	add	a5,a5,a4
    800062a4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800062a8:	e7ad                	bnez	a5,80006312 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800062aa:	00451793          	slli	a5,a0,0x4
    800062ae:	00024717          	auipc	a4,0x24
    800062b2:	d5270713          	addi	a4,a4,-686 # 8002a000 <disk+0x2000>
    800062b6:	6314                	ld	a3,0(a4)
    800062b8:	96be                	add	a3,a3,a5
    800062ba:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800062be:	6314                	ld	a3,0(a4)
    800062c0:	96be                	add	a3,a3,a5
    800062c2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800062c6:	6314                	ld	a3,0(a4)
    800062c8:	96be                	add	a3,a3,a5
    800062ca:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800062ce:	6318                	ld	a4,0(a4)
    800062d0:	97ba                	add	a5,a5,a4
    800062d2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800062d6:	00022797          	auipc	a5,0x22
    800062da:	d2a78793          	addi	a5,a5,-726 # 80028000 <disk>
    800062de:	97aa                	add	a5,a5,a0
    800062e0:	6509                	lui	a0,0x2
    800062e2:	953e                	add	a0,a0,a5
    800062e4:	4785                	li	a5,1
    800062e6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800062ea:	00024517          	auipc	a0,0x24
    800062ee:	d2e50513          	addi	a0,a0,-722 # 8002a018 <disk+0x2018>
    800062f2:	ffffc097          	auipc	ra,0xffffc
    800062f6:	3e4080e7          	jalr	996(ra) # 800026d6 <wakeup>
}
    800062fa:	60a2                	ld	ra,8(sp)
    800062fc:	6402                	ld	s0,0(sp)
    800062fe:	0141                	addi	sp,sp,16
    80006300:	8082                	ret
    panic("free_desc 1");
    80006302:	00002517          	auipc	a0,0x2
    80006306:	4f650513          	addi	a0,a0,1270 # 800087f8 <syscalls+0x338>
    8000630a:	ffffa097          	auipc	ra,0xffffa
    8000630e:	240080e7          	jalr	576(ra) # 8000054a <panic>
    panic("free_desc 2");
    80006312:	00002517          	auipc	a0,0x2
    80006316:	4f650513          	addi	a0,a0,1270 # 80008808 <syscalls+0x348>
    8000631a:	ffffa097          	auipc	ra,0xffffa
    8000631e:	230080e7          	jalr	560(ra) # 8000054a <panic>

0000000080006322 <virtio_disk_init>:
{
    80006322:	1101                	addi	sp,sp,-32
    80006324:	ec06                	sd	ra,24(sp)
    80006326:	e822                	sd	s0,16(sp)
    80006328:	e426                	sd	s1,8(sp)
    8000632a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000632c:	00002597          	auipc	a1,0x2
    80006330:	4ec58593          	addi	a1,a1,1260 # 80008818 <syscalls+0x358>
    80006334:	00024517          	auipc	a0,0x24
    80006338:	df450513          	addi	a0,a0,-524 # 8002a128 <disk+0x2128>
    8000633c:	ffffb097          	auipc	ra,0xffffb
    80006340:	b3c080e7          	jalr	-1220(ra) # 80000e78 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006344:	100017b7          	lui	a5,0x10001
    80006348:	4398                	lw	a4,0(a5)
    8000634a:	2701                	sext.w	a4,a4
    8000634c:	747277b7          	lui	a5,0x74727
    80006350:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006354:	0ef71163          	bne	a4,a5,80006436 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006358:	100017b7          	lui	a5,0x10001
    8000635c:	43dc                	lw	a5,4(a5)
    8000635e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006360:	4705                	li	a4,1
    80006362:	0ce79a63          	bne	a5,a4,80006436 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006366:	100017b7          	lui	a5,0x10001
    8000636a:	479c                	lw	a5,8(a5)
    8000636c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000636e:	4709                	li	a4,2
    80006370:	0ce79363          	bne	a5,a4,80006436 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006374:	100017b7          	lui	a5,0x10001
    80006378:	47d8                	lw	a4,12(a5)
    8000637a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000637c:	554d47b7          	lui	a5,0x554d4
    80006380:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006384:	0af71963          	bne	a4,a5,80006436 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006388:	100017b7          	lui	a5,0x10001
    8000638c:	4705                	li	a4,1
    8000638e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006390:	470d                	li	a4,3
    80006392:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006394:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006396:	c7ffe737          	lui	a4,0xc7ffe
    8000639a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd2737>
    8000639e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063a0:	2701                	sext.w	a4,a4
    800063a2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063a4:	472d                	li	a4,11
    800063a6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063a8:	473d                	li	a4,15
    800063aa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800063ac:	6705                	lui	a4,0x1
    800063ae:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800063b0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800063b4:	5bdc                	lw	a5,52(a5)
    800063b6:	2781                	sext.w	a5,a5
  if(max == 0)
    800063b8:	c7d9                	beqz	a5,80006446 <virtio_disk_init+0x124>
  if(max < NUM)
    800063ba:	471d                	li	a4,7
    800063bc:	08f77d63          	bgeu	a4,a5,80006456 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063c0:	100014b7          	lui	s1,0x10001
    800063c4:	47a1                	li	a5,8
    800063c6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800063c8:	6609                	lui	a2,0x2
    800063ca:	4581                	li	a1,0
    800063cc:	00022517          	auipc	a0,0x22
    800063d0:	c3450513          	addi	a0,a0,-972 # 80028000 <disk>
    800063d4:	ffffb097          	auipc	ra,0xffffb
    800063d8:	d08080e7          	jalr	-760(ra) # 800010dc <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800063dc:	00022717          	auipc	a4,0x22
    800063e0:	c2470713          	addi	a4,a4,-988 # 80028000 <disk>
    800063e4:	00c75793          	srli	a5,a4,0xc
    800063e8:	2781                	sext.w	a5,a5
    800063ea:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800063ec:	00024797          	auipc	a5,0x24
    800063f0:	c1478793          	addi	a5,a5,-1004 # 8002a000 <disk+0x2000>
    800063f4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800063f6:	00022717          	auipc	a4,0x22
    800063fa:	c8a70713          	addi	a4,a4,-886 # 80028080 <disk+0x80>
    800063fe:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006400:	00023717          	auipc	a4,0x23
    80006404:	c0070713          	addi	a4,a4,-1024 # 80029000 <disk+0x1000>
    80006408:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000640a:	4705                	li	a4,1
    8000640c:	00e78c23          	sb	a4,24(a5)
    80006410:	00e78ca3          	sb	a4,25(a5)
    80006414:	00e78d23          	sb	a4,26(a5)
    80006418:	00e78da3          	sb	a4,27(a5)
    8000641c:	00e78e23          	sb	a4,28(a5)
    80006420:	00e78ea3          	sb	a4,29(a5)
    80006424:	00e78f23          	sb	a4,30(a5)
    80006428:	00e78fa3          	sb	a4,31(a5)
}
    8000642c:	60e2                	ld	ra,24(sp)
    8000642e:	6442                	ld	s0,16(sp)
    80006430:	64a2                	ld	s1,8(sp)
    80006432:	6105                	addi	sp,sp,32
    80006434:	8082                	ret
    panic("could not find virtio disk");
    80006436:	00002517          	auipc	a0,0x2
    8000643a:	3f250513          	addi	a0,a0,1010 # 80008828 <syscalls+0x368>
    8000643e:	ffffa097          	auipc	ra,0xffffa
    80006442:	10c080e7          	jalr	268(ra) # 8000054a <panic>
    panic("virtio disk has no queue 0");
    80006446:	00002517          	auipc	a0,0x2
    8000644a:	40250513          	addi	a0,a0,1026 # 80008848 <syscalls+0x388>
    8000644e:	ffffa097          	auipc	ra,0xffffa
    80006452:	0fc080e7          	jalr	252(ra) # 8000054a <panic>
    panic("virtio disk max queue too short");
    80006456:	00002517          	auipc	a0,0x2
    8000645a:	41250513          	addi	a0,a0,1042 # 80008868 <syscalls+0x3a8>
    8000645e:	ffffa097          	auipc	ra,0xffffa
    80006462:	0ec080e7          	jalr	236(ra) # 8000054a <panic>

0000000080006466 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006466:	7119                	addi	sp,sp,-128
    80006468:	fc86                	sd	ra,120(sp)
    8000646a:	f8a2                	sd	s0,112(sp)
    8000646c:	f4a6                	sd	s1,104(sp)
    8000646e:	f0ca                	sd	s2,96(sp)
    80006470:	ecce                	sd	s3,88(sp)
    80006472:	e8d2                	sd	s4,80(sp)
    80006474:	e4d6                	sd	s5,72(sp)
    80006476:	e0da                	sd	s6,64(sp)
    80006478:	fc5e                	sd	s7,56(sp)
    8000647a:	f862                	sd	s8,48(sp)
    8000647c:	f466                	sd	s9,40(sp)
    8000647e:	f06a                	sd	s10,32(sp)
    80006480:	ec6e                	sd	s11,24(sp)
    80006482:	0100                	addi	s0,sp,128
    80006484:	8aaa                	mv	s5,a0
    80006486:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006488:	00c52c83          	lw	s9,12(a0)
    8000648c:	001c9c9b          	slliw	s9,s9,0x1
    80006490:	1c82                	slli	s9,s9,0x20
    80006492:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006496:	00024517          	auipc	a0,0x24
    8000649a:	c9250513          	addi	a0,a0,-878 # 8002a128 <disk+0x2128>
    8000649e:	ffffb097          	auipc	ra,0xffffb
    800064a2:	85e080e7          	jalr	-1954(ra) # 80000cfc <acquire>
  for(int i = 0; i < 3; i++){
    800064a6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064a8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064aa:	00022c17          	auipc	s8,0x22
    800064ae:	b56c0c13          	addi	s8,s8,-1194 # 80028000 <disk>
    800064b2:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800064b4:	4b0d                	li	s6,3
    800064b6:	a0ad                	j	80006520 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800064b8:	00fc0733          	add	a4,s8,a5
    800064bc:	975e                	add	a4,a4,s7
    800064be:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800064c2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800064c4:	0207c563          	bltz	a5,800064ee <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800064c8:	2905                	addiw	s2,s2,1
    800064ca:	0611                	addi	a2,a2,4
    800064cc:	19690d63          	beq	s2,s6,80006666 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    800064d0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800064d2:	00024717          	auipc	a4,0x24
    800064d6:	b4670713          	addi	a4,a4,-1210 # 8002a018 <disk+0x2018>
    800064da:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800064dc:	00074683          	lbu	a3,0(a4)
    800064e0:	fee1                	bnez	a3,800064b8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800064e2:	2785                	addiw	a5,a5,1
    800064e4:	0705                	addi	a4,a4,1
    800064e6:	fe979be3          	bne	a5,s1,800064dc <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800064ea:	57fd                	li	a5,-1
    800064ec:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800064ee:	01205d63          	blez	s2,80006508 <virtio_disk_rw+0xa2>
    800064f2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800064f4:	000a2503          	lw	a0,0(s4)
    800064f8:	00000097          	auipc	ra,0x0
    800064fc:	d8e080e7          	jalr	-626(ra) # 80006286 <free_desc>
      for(int j = 0; j < i; j++)
    80006500:	2d85                	addiw	s11,s11,1
    80006502:	0a11                	addi	s4,s4,4
    80006504:	ffb918e3          	bne	s2,s11,800064f4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006508:	00024597          	auipc	a1,0x24
    8000650c:	c2058593          	addi	a1,a1,-992 # 8002a128 <disk+0x2128>
    80006510:	00024517          	auipc	a0,0x24
    80006514:	b0850513          	addi	a0,a0,-1272 # 8002a018 <disk+0x2018>
    80006518:	ffffc097          	auipc	ra,0xffffc
    8000651c:	03e080e7          	jalr	62(ra) # 80002556 <sleep>
  for(int i = 0; i < 3; i++){
    80006520:	f8040a13          	addi	s4,s0,-128
{
    80006524:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006526:	894e                	mv	s2,s3
    80006528:	b765                	j	800064d0 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000652a:	00024697          	auipc	a3,0x24
    8000652e:	ad66b683          	ld	a3,-1322(a3) # 8002a000 <disk+0x2000>
    80006532:	96ba                	add	a3,a3,a4
    80006534:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006538:	00022817          	auipc	a6,0x22
    8000653c:	ac880813          	addi	a6,a6,-1336 # 80028000 <disk>
    80006540:	00024697          	auipc	a3,0x24
    80006544:	ac068693          	addi	a3,a3,-1344 # 8002a000 <disk+0x2000>
    80006548:	6290                	ld	a2,0(a3)
    8000654a:	963a                	add	a2,a2,a4
    8000654c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006550:	0015e593          	ori	a1,a1,1
    80006554:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006558:	f8842603          	lw	a2,-120(s0)
    8000655c:	628c                	ld	a1,0(a3)
    8000655e:	972e                	add	a4,a4,a1
    80006560:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006564:	20050593          	addi	a1,a0,512
    80006568:	0592                	slli	a1,a1,0x4
    8000656a:	95c2                	add	a1,a1,a6
    8000656c:	577d                	li	a4,-1
    8000656e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006572:	00461713          	slli	a4,a2,0x4
    80006576:	6290                	ld	a2,0(a3)
    80006578:	963a                	add	a2,a2,a4
    8000657a:	03078793          	addi	a5,a5,48
    8000657e:	97c2                	add	a5,a5,a6
    80006580:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006582:	629c                	ld	a5,0(a3)
    80006584:	97ba                	add	a5,a5,a4
    80006586:	4605                	li	a2,1
    80006588:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000658a:	629c                	ld	a5,0(a3)
    8000658c:	97ba                	add	a5,a5,a4
    8000658e:	4809                	li	a6,2
    80006590:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006594:	629c                	ld	a5,0(a3)
    80006596:	973e                	add	a4,a4,a5
    80006598:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000659c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800065a0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800065a4:	6698                	ld	a4,8(a3)
    800065a6:	00275783          	lhu	a5,2(a4)
    800065aa:	8b9d                	andi	a5,a5,7
    800065ac:	0786                	slli	a5,a5,0x1
    800065ae:	97ba                	add	a5,a5,a4
    800065b0:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    800065b4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800065b8:	6698                	ld	a4,8(a3)
    800065ba:	00275783          	lhu	a5,2(a4)
    800065be:	2785                	addiw	a5,a5,1
    800065c0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800065c4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800065c8:	100017b7          	lui	a5,0x10001
    800065cc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800065d0:	004aa783          	lw	a5,4(s5)
    800065d4:	02c79163          	bne	a5,a2,800065f6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800065d8:	00024917          	auipc	s2,0x24
    800065dc:	b5090913          	addi	s2,s2,-1200 # 8002a128 <disk+0x2128>
  while(b->disk == 1) {
    800065e0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800065e2:	85ca                	mv	a1,s2
    800065e4:	8556                	mv	a0,s5
    800065e6:	ffffc097          	auipc	ra,0xffffc
    800065ea:	f70080e7          	jalr	-144(ra) # 80002556 <sleep>
  while(b->disk == 1) {
    800065ee:	004aa783          	lw	a5,4(s5)
    800065f2:	fe9788e3          	beq	a5,s1,800065e2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800065f6:	f8042903          	lw	s2,-128(s0)
    800065fa:	20090793          	addi	a5,s2,512
    800065fe:	00479713          	slli	a4,a5,0x4
    80006602:	00022797          	auipc	a5,0x22
    80006606:	9fe78793          	addi	a5,a5,-1538 # 80028000 <disk>
    8000660a:	97ba                	add	a5,a5,a4
    8000660c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006610:	00024997          	auipc	s3,0x24
    80006614:	9f098993          	addi	s3,s3,-1552 # 8002a000 <disk+0x2000>
    80006618:	00491713          	slli	a4,s2,0x4
    8000661c:	0009b783          	ld	a5,0(s3)
    80006620:	97ba                	add	a5,a5,a4
    80006622:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006626:	854a                	mv	a0,s2
    80006628:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000662c:	00000097          	auipc	ra,0x0
    80006630:	c5a080e7          	jalr	-934(ra) # 80006286 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006634:	8885                	andi	s1,s1,1
    80006636:	f0ed                	bnez	s1,80006618 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006638:	00024517          	auipc	a0,0x24
    8000663c:	af050513          	addi	a0,a0,-1296 # 8002a128 <disk+0x2128>
    80006640:	ffffa097          	auipc	ra,0xffffa
    80006644:	78c080e7          	jalr	1932(ra) # 80000dcc <release>
}
    80006648:	70e6                	ld	ra,120(sp)
    8000664a:	7446                	ld	s0,112(sp)
    8000664c:	74a6                	ld	s1,104(sp)
    8000664e:	7906                	ld	s2,96(sp)
    80006650:	69e6                	ld	s3,88(sp)
    80006652:	6a46                	ld	s4,80(sp)
    80006654:	6aa6                	ld	s5,72(sp)
    80006656:	6b06                	ld	s6,64(sp)
    80006658:	7be2                	ld	s7,56(sp)
    8000665a:	7c42                	ld	s8,48(sp)
    8000665c:	7ca2                	ld	s9,40(sp)
    8000665e:	7d02                	ld	s10,32(sp)
    80006660:	6de2                	ld	s11,24(sp)
    80006662:	6109                	addi	sp,sp,128
    80006664:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006666:	f8042503          	lw	a0,-128(s0)
    8000666a:	20050793          	addi	a5,a0,512
    8000666e:	0792                	slli	a5,a5,0x4
  if(write)
    80006670:	00022817          	auipc	a6,0x22
    80006674:	99080813          	addi	a6,a6,-1648 # 80028000 <disk>
    80006678:	00f80733          	add	a4,a6,a5
    8000667c:	01a036b3          	snez	a3,s10
    80006680:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006684:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006688:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000668c:	7679                	lui	a2,0xffffe
    8000668e:	963e                	add	a2,a2,a5
    80006690:	00024697          	auipc	a3,0x24
    80006694:	97068693          	addi	a3,a3,-1680 # 8002a000 <disk+0x2000>
    80006698:	6298                	ld	a4,0(a3)
    8000669a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000669c:	0a878593          	addi	a1,a5,168
    800066a0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066a2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800066a4:	6298                	ld	a4,0(a3)
    800066a6:	9732                	add	a4,a4,a2
    800066a8:	45c1                	li	a1,16
    800066aa:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800066ac:	6298                	ld	a4,0(a3)
    800066ae:	9732                	add	a4,a4,a2
    800066b0:	4585                	li	a1,1
    800066b2:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800066b6:	f8442703          	lw	a4,-124(s0)
    800066ba:	628c                	ld	a1,0(a3)
    800066bc:	962e                	add	a2,a2,a1
    800066be:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd1fe6>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800066c2:	0712                	slli	a4,a4,0x4
    800066c4:	6290                	ld	a2,0(a3)
    800066c6:	963a                	add	a2,a2,a4
    800066c8:	060a8593          	addi	a1,s5,96
    800066cc:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800066ce:	6294                	ld	a3,0(a3)
    800066d0:	96ba                	add	a3,a3,a4
    800066d2:	40000613          	li	a2,1024
    800066d6:	c690                	sw	a2,8(a3)
  if(write)
    800066d8:	e40d19e3          	bnez	s10,8000652a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800066dc:	00024697          	auipc	a3,0x24
    800066e0:	9246b683          	ld	a3,-1756(a3) # 8002a000 <disk+0x2000>
    800066e4:	96ba                	add	a3,a3,a4
    800066e6:	4609                	li	a2,2
    800066e8:	00c69623          	sh	a2,12(a3)
    800066ec:	b5b1                	j	80006538 <virtio_disk_rw+0xd2>

00000000800066ee <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800066ee:	1101                	addi	sp,sp,-32
    800066f0:	ec06                	sd	ra,24(sp)
    800066f2:	e822                	sd	s0,16(sp)
    800066f4:	e426                	sd	s1,8(sp)
    800066f6:	e04a                	sd	s2,0(sp)
    800066f8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066fa:	00024517          	auipc	a0,0x24
    800066fe:	a2e50513          	addi	a0,a0,-1490 # 8002a128 <disk+0x2128>
    80006702:	ffffa097          	auipc	ra,0xffffa
    80006706:	5fa080e7          	jalr	1530(ra) # 80000cfc <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000670a:	10001737          	lui	a4,0x10001
    8000670e:	533c                	lw	a5,96(a4)
    80006710:	8b8d                	andi	a5,a5,3
    80006712:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006714:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006718:	00024797          	auipc	a5,0x24
    8000671c:	8e878793          	addi	a5,a5,-1816 # 8002a000 <disk+0x2000>
    80006720:	6b94                	ld	a3,16(a5)
    80006722:	0207d703          	lhu	a4,32(a5)
    80006726:	0026d783          	lhu	a5,2(a3)
    8000672a:	06f70163          	beq	a4,a5,8000678c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000672e:	00022917          	auipc	s2,0x22
    80006732:	8d290913          	addi	s2,s2,-1838 # 80028000 <disk>
    80006736:	00024497          	auipc	s1,0x24
    8000673a:	8ca48493          	addi	s1,s1,-1846 # 8002a000 <disk+0x2000>
    __sync_synchronize();
    8000673e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006742:	6898                	ld	a4,16(s1)
    80006744:	0204d783          	lhu	a5,32(s1)
    80006748:	8b9d                	andi	a5,a5,7
    8000674a:	078e                	slli	a5,a5,0x3
    8000674c:	97ba                	add	a5,a5,a4
    8000674e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006750:	20078713          	addi	a4,a5,512
    80006754:	0712                	slli	a4,a4,0x4
    80006756:	974a                	add	a4,a4,s2
    80006758:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000675c:	e731                	bnez	a4,800067a8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000675e:	20078793          	addi	a5,a5,512
    80006762:	0792                	slli	a5,a5,0x4
    80006764:	97ca                	add	a5,a5,s2
    80006766:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006768:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000676c:	ffffc097          	auipc	ra,0xffffc
    80006770:	f6a080e7          	jalr	-150(ra) # 800026d6 <wakeup>

    disk.used_idx += 1;
    80006774:	0204d783          	lhu	a5,32(s1)
    80006778:	2785                	addiw	a5,a5,1
    8000677a:	17c2                	slli	a5,a5,0x30
    8000677c:	93c1                	srli	a5,a5,0x30
    8000677e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006782:	6898                	ld	a4,16(s1)
    80006784:	00275703          	lhu	a4,2(a4)
    80006788:	faf71be3          	bne	a4,a5,8000673e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000678c:	00024517          	auipc	a0,0x24
    80006790:	99c50513          	addi	a0,a0,-1636 # 8002a128 <disk+0x2128>
    80006794:	ffffa097          	auipc	ra,0xffffa
    80006798:	638080e7          	jalr	1592(ra) # 80000dcc <release>
}
    8000679c:	60e2                	ld	ra,24(sp)
    8000679e:	6442                	ld	s0,16(sp)
    800067a0:	64a2                	ld	s1,8(sp)
    800067a2:	6902                	ld	s2,0(sp)
    800067a4:	6105                	addi	sp,sp,32
    800067a6:	8082                	ret
      panic("virtio_disk_intr status");
    800067a8:	00002517          	auipc	a0,0x2
    800067ac:	0e050513          	addi	a0,a0,224 # 80008888 <syscalls+0x3c8>
    800067b0:	ffffa097          	auipc	ra,0xffffa
    800067b4:	d9a080e7          	jalr	-614(ra) # 8000054a <panic>

00000000800067b8 <statswrite>:
int statscopyin(char*, int);
int statslock(char*, int);
  
int
statswrite(int user_src, uint64 src, int n)
{
    800067b8:	1141                	addi	sp,sp,-16
    800067ba:	e422                	sd	s0,8(sp)
    800067bc:	0800                	addi	s0,sp,16
  return -1;
}
    800067be:	557d                	li	a0,-1
    800067c0:	6422                	ld	s0,8(sp)
    800067c2:	0141                	addi	sp,sp,16
    800067c4:	8082                	ret

00000000800067c6 <statsread>:

int
statsread(int user_dst, uint64 dst, int n)
{
    800067c6:	7179                	addi	sp,sp,-48
    800067c8:	f406                	sd	ra,40(sp)
    800067ca:	f022                	sd	s0,32(sp)
    800067cc:	ec26                	sd	s1,24(sp)
    800067ce:	e84a                	sd	s2,16(sp)
    800067d0:	e44e                	sd	s3,8(sp)
    800067d2:	e052                	sd	s4,0(sp)
    800067d4:	1800                	addi	s0,sp,48
    800067d6:	892a                	mv	s2,a0
    800067d8:	89ae                	mv	s3,a1
    800067da:	84b2                	mv	s1,a2
  int m;

  acquire(&stats.lock);
    800067dc:	00025517          	auipc	a0,0x25
    800067e0:	82450513          	addi	a0,a0,-2012 # 8002b000 <stats>
    800067e4:	ffffa097          	auipc	ra,0xffffa
    800067e8:	518080e7          	jalr	1304(ra) # 80000cfc <acquire>

  if(stats.sz == 0) {
    800067ec:	00026797          	auipc	a5,0x26
    800067f0:	8347a783          	lw	a5,-1996(a5) # 8002c020 <stats+0x1020>
    800067f4:	cbb5                	beqz	a5,80006868 <statsread+0xa2>
#endif
#ifdef LAB_LOCK
    stats.sz = statslock(stats.buf, BUFSZ);
#endif
  }
  m = stats.sz - stats.off;
    800067f6:	00026797          	auipc	a5,0x26
    800067fa:	80a78793          	addi	a5,a5,-2038 # 8002c000 <stats+0x1000>
    800067fe:	53d8                	lw	a4,36(a5)
    80006800:	539c                	lw	a5,32(a5)
    80006802:	9f99                	subw	a5,a5,a4
    80006804:	0007869b          	sext.w	a3,a5

  if (m > 0) {
    80006808:	06d05e63          	blez	a3,80006884 <statsread+0xbe>
    if(m > n)
    8000680c:	8a3e                	mv	s4,a5
    8000680e:	00d4d363          	bge	s1,a3,80006814 <statsread+0x4e>
    80006812:	8a26                	mv	s4,s1
    80006814:	000a049b          	sext.w	s1,s4
      m  = n;
    if(either_copyout(user_dst, dst, stats.buf+stats.off, m) != -1) {
    80006818:	86a6                	mv	a3,s1
    8000681a:	00025617          	auipc	a2,0x25
    8000681e:	80660613          	addi	a2,a2,-2042 # 8002b020 <stats+0x20>
    80006822:	963a                	add	a2,a2,a4
    80006824:	85ce                	mv	a1,s3
    80006826:	854a                	mv	a0,s2
    80006828:	ffffc097          	auipc	ra,0xffffc
    8000682c:	f88080e7          	jalr	-120(ra) # 800027b0 <either_copyout>
    80006830:	57fd                	li	a5,-1
    80006832:	00f50a63          	beq	a0,a5,80006846 <statsread+0x80>
      stats.off += m;
    80006836:	00025717          	auipc	a4,0x25
    8000683a:	7ca70713          	addi	a4,a4,1994 # 8002c000 <stats+0x1000>
    8000683e:	535c                	lw	a5,36(a4)
    80006840:	014787bb          	addw	a5,a5,s4
    80006844:	d35c                	sw	a5,36(a4)
  } else {
    m = -1;
    stats.sz = 0;
    stats.off = 0;
  }
  release(&stats.lock);
    80006846:	00024517          	auipc	a0,0x24
    8000684a:	7ba50513          	addi	a0,a0,1978 # 8002b000 <stats>
    8000684e:	ffffa097          	auipc	ra,0xffffa
    80006852:	57e080e7          	jalr	1406(ra) # 80000dcc <release>
  return m;
}
    80006856:	8526                	mv	a0,s1
    80006858:	70a2                	ld	ra,40(sp)
    8000685a:	7402                	ld	s0,32(sp)
    8000685c:	64e2                	ld	s1,24(sp)
    8000685e:	6942                	ld	s2,16(sp)
    80006860:	69a2                	ld	s3,8(sp)
    80006862:	6a02                	ld	s4,0(sp)
    80006864:	6145                	addi	sp,sp,48
    80006866:	8082                	ret
    stats.sz = statslock(stats.buf, BUFSZ);
    80006868:	6585                	lui	a1,0x1
    8000686a:	00024517          	auipc	a0,0x24
    8000686e:	7b650513          	addi	a0,a0,1974 # 8002b020 <stats+0x20>
    80006872:	ffffa097          	auipc	ra,0xffffa
    80006876:	6b4080e7          	jalr	1716(ra) # 80000f26 <statslock>
    8000687a:	00025797          	auipc	a5,0x25
    8000687e:	7aa7a323          	sw	a0,1958(a5) # 8002c020 <stats+0x1020>
    80006882:	bf95                	j	800067f6 <statsread+0x30>
    stats.sz = 0;
    80006884:	00025797          	auipc	a5,0x25
    80006888:	77c78793          	addi	a5,a5,1916 # 8002c000 <stats+0x1000>
    8000688c:	0207a023          	sw	zero,32(a5)
    stats.off = 0;
    80006890:	0207a223          	sw	zero,36(a5)
    m = -1;
    80006894:	54fd                	li	s1,-1
    80006896:	bf45                	j	80006846 <statsread+0x80>

0000000080006898 <statsinit>:

void
statsinit(void)
{
    80006898:	1141                	addi	sp,sp,-16
    8000689a:	e406                	sd	ra,8(sp)
    8000689c:	e022                	sd	s0,0(sp)
    8000689e:	0800                	addi	s0,sp,16
  initlock(&stats.lock, "stats");
    800068a0:	00002597          	auipc	a1,0x2
    800068a4:	00058593          	mv	a1,a1
    800068a8:	00024517          	auipc	a0,0x24
    800068ac:	75850513          	addi	a0,a0,1880 # 8002b000 <stats>
    800068b0:	ffffa097          	auipc	ra,0xffffa
    800068b4:	5c8080e7          	jalr	1480(ra) # 80000e78 <initlock>

  devsw[STATS].read = statsread;
    800068b8:	00020797          	auipc	a5,0x20
    800068bc:	c0078793          	addi	a5,a5,-1024 # 800264b8 <devsw>
    800068c0:	00000717          	auipc	a4,0x0
    800068c4:	f0670713          	addi	a4,a4,-250 # 800067c6 <statsread>
    800068c8:	f398                	sd	a4,32(a5)
  devsw[STATS].write = statswrite;
    800068ca:	00000717          	auipc	a4,0x0
    800068ce:	eee70713          	addi	a4,a4,-274 # 800067b8 <statswrite>
    800068d2:	f798                	sd	a4,40(a5)
}
    800068d4:	60a2                	ld	ra,8(sp)
    800068d6:	6402                	ld	s0,0(sp)
    800068d8:	0141                	addi	sp,sp,16
    800068da:	8082                	ret

00000000800068dc <sprintint>:
  return 1;
}

static int
sprintint(char *s, int xx, int base, int sign)
{
    800068dc:	1101                	addi	sp,sp,-32
    800068de:	ec22                	sd	s0,24(sp)
    800068e0:	1000                	addi	s0,sp,32
    800068e2:	882a                	mv	a6,a0
  char buf[16];
  int i, n;
  uint x;

  if(sign && (sign = xx < 0))
    800068e4:	c299                	beqz	a3,800068ea <sprintint+0xe>
    800068e6:	0805c163          	bltz	a1,80006968 <sprintint+0x8c>
    x = -xx;
  else
    x = xx;
    800068ea:	2581                	sext.w	a1,a1
    800068ec:	4301                	li	t1,0

  i = 0;
    800068ee:	fe040713          	addi	a4,s0,-32
    800068f2:	4501                	li	a0,0
  do {
    buf[i++] = digits[x % base];
    800068f4:	2601                	sext.w	a2,a2
    800068f6:	00002697          	auipc	a3,0x2
    800068fa:	fb268693          	addi	a3,a3,-78 # 800088a8 <digits>
    800068fe:	88aa                	mv	a7,a0
    80006900:	2505                	addiw	a0,a0,1
    80006902:	02c5f7bb          	remuw	a5,a1,a2
    80006906:	1782                	slli	a5,a5,0x20
    80006908:	9381                	srli	a5,a5,0x20
    8000690a:	97b6                	add	a5,a5,a3
    8000690c:	0007c783          	lbu	a5,0(a5)
    80006910:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    80006914:	0005879b          	sext.w	a5,a1
    80006918:	02c5d5bb          	divuw	a1,a1,a2
    8000691c:	0705                	addi	a4,a4,1
    8000691e:	fec7f0e3          	bgeu	a5,a2,800068fe <sprintint+0x22>

  if(sign)
    80006922:	00030b63          	beqz	t1,80006938 <sprintint+0x5c>
    buf[i++] = '-';
    80006926:	ff040793          	addi	a5,s0,-16
    8000692a:	97aa                	add	a5,a5,a0
    8000692c:	02d00713          	li	a4,45
    80006930:	fee78823          	sb	a4,-16(a5)
    80006934:	0028851b          	addiw	a0,a7,2

  n = 0;
  while(--i >= 0)
    80006938:	02a05c63          	blez	a0,80006970 <sprintint+0x94>
    8000693c:	fe040793          	addi	a5,s0,-32
    80006940:	00a78733          	add	a4,a5,a0
    80006944:	87c2                	mv	a5,a6
    80006946:	0805                	addi	a6,a6,1
    80006948:	fff5061b          	addiw	a2,a0,-1
    8000694c:	1602                	slli	a2,a2,0x20
    8000694e:	9201                	srli	a2,a2,0x20
    80006950:	9642                	add	a2,a2,a6
  *s = c;
    80006952:	fff74683          	lbu	a3,-1(a4)
    80006956:	00d78023          	sb	a3,0(a5)
  while(--i >= 0)
    8000695a:	177d                	addi	a4,a4,-1
    8000695c:	0785                	addi	a5,a5,1
    8000695e:	fec79ae3          	bne	a5,a2,80006952 <sprintint+0x76>
    n += sputc(s+n, buf[i]);
  return n;
}
    80006962:	6462                	ld	s0,24(sp)
    80006964:	6105                	addi	sp,sp,32
    80006966:	8082                	ret
    x = -xx;
    80006968:	40b005bb          	negw	a1,a1
  if(sign && (sign = xx < 0))
    8000696c:	4305                	li	t1,1
    x = -xx;
    8000696e:	b741                	j	800068ee <sprintint+0x12>
  while(--i >= 0)
    80006970:	4501                	li	a0,0
    80006972:	bfc5                	j	80006962 <sprintint+0x86>

0000000080006974 <snprintf>:

int
snprintf(char *buf, int sz, char *fmt, ...)
{
    80006974:	7135                	addi	sp,sp,-160
    80006976:	f486                	sd	ra,104(sp)
    80006978:	f0a2                	sd	s0,96(sp)
    8000697a:	eca6                	sd	s1,88(sp)
    8000697c:	e8ca                	sd	s2,80(sp)
    8000697e:	e4ce                	sd	s3,72(sp)
    80006980:	e0d2                	sd	s4,64(sp)
    80006982:	fc56                	sd	s5,56(sp)
    80006984:	f85a                	sd	s6,48(sp)
    80006986:	f45e                	sd	s7,40(sp)
    80006988:	f062                	sd	s8,32(sp)
    8000698a:	ec66                	sd	s9,24(sp)
    8000698c:	e86a                	sd	s10,16(sp)
    8000698e:	1880                	addi	s0,sp,112
    80006990:	e414                	sd	a3,8(s0)
    80006992:	e818                	sd	a4,16(s0)
    80006994:	ec1c                	sd	a5,24(s0)
    80006996:	03043023          	sd	a6,32(s0)
    8000699a:	03143423          	sd	a7,40(s0)
  va_list ap;
  int i, c;
  int off = 0;
  char *s;

  if (fmt == 0)
    8000699e:	c61d                	beqz	a2,800069cc <snprintf+0x58>
    800069a0:	8baa                	mv	s7,a0
    800069a2:	89ae                	mv	s3,a1
    800069a4:	8a32                	mv	s4,a2
    panic("null fmt");

  va_start(ap, fmt);
    800069a6:	00840793          	addi	a5,s0,8
    800069aa:	f8f43c23          	sd	a5,-104(s0)
  int off = 0;
    800069ae:	4481                	li	s1,0
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    800069b0:	4901                	li	s2,0
    800069b2:	02b05563          	blez	a1,800069dc <snprintf+0x68>
    if(c != '%'){
    800069b6:	02500a93          	li	s5,37
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    800069ba:	07300b13          	li	s6,115
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s && off < sz; s++)
    800069be:	02800d13          	li	s10,40
    switch(c){
    800069c2:	07800c93          	li	s9,120
    800069c6:	06400c13          	li	s8,100
    800069ca:	a01d                	j	800069f0 <snprintf+0x7c>
    panic("null fmt");
    800069cc:	00001517          	auipc	a0,0x1
    800069d0:	65c50513          	addi	a0,a0,1628 # 80008028 <etext+0x28>
    800069d4:	ffffa097          	auipc	ra,0xffffa
    800069d8:	b76080e7          	jalr	-1162(ra) # 8000054a <panic>
  int off = 0;
    800069dc:	4481                	li	s1,0
    800069de:	a86d                	j	80006a98 <snprintf+0x124>
  *s = c;
    800069e0:	009b8733          	add	a4,s7,s1
    800069e4:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    800069e8:	2485                	addiw	s1,s1,1
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    800069ea:	2905                	addiw	s2,s2,1
    800069ec:	0b34d663          	bge	s1,s3,80006a98 <snprintf+0x124>
    800069f0:	012a07b3          	add	a5,s4,s2
    800069f4:	0007c783          	lbu	a5,0(a5)
    800069f8:	0007871b          	sext.w	a4,a5
    800069fc:	cfd1                	beqz	a5,80006a98 <snprintf+0x124>
    if(c != '%'){
    800069fe:	ff5711e3          	bne	a4,s5,800069e0 <snprintf+0x6c>
    c = fmt[++i] & 0xff;
    80006a02:	2905                	addiw	s2,s2,1
    80006a04:	012a07b3          	add	a5,s4,s2
    80006a08:	0007c783          	lbu	a5,0(a5)
    if(c == 0)
    80006a0c:	c7d1                	beqz	a5,80006a98 <snprintf+0x124>
    switch(c){
    80006a0e:	05678c63          	beq	a5,s6,80006a66 <snprintf+0xf2>
    80006a12:	02fb6763          	bltu	s6,a5,80006a40 <snprintf+0xcc>
    80006a16:	0b578663          	beq	a5,s5,80006ac2 <snprintf+0x14e>
    80006a1a:	0b879a63          	bne	a5,s8,80006ace <snprintf+0x15a>
      off += sprintint(buf+off, va_arg(ap, int), 10, 1);
    80006a1e:	f9843783          	ld	a5,-104(s0)
    80006a22:	00878713          	addi	a4,a5,8
    80006a26:	f8e43c23          	sd	a4,-104(s0)
    80006a2a:	4685                	li	a3,1
    80006a2c:	4629                	li	a2,10
    80006a2e:	438c                	lw	a1,0(a5)
    80006a30:	009b8533          	add	a0,s7,s1
    80006a34:	00000097          	auipc	ra,0x0
    80006a38:	ea8080e7          	jalr	-344(ra) # 800068dc <sprintint>
    80006a3c:	9ca9                	addw	s1,s1,a0
      break;
    80006a3e:	b775                	j	800069ea <snprintf+0x76>
    switch(c){
    80006a40:	09979763          	bne	a5,s9,80006ace <snprintf+0x15a>
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
    80006a44:	f9843783          	ld	a5,-104(s0)
    80006a48:	00878713          	addi	a4,a5,8
    80006a4c:	f8e43c23          	sd	a4,-104(s0)
    80006a50:	4685                	li	a3,1
    80006a52:	4641                	li	a2,16
    80006a54:	438c                	lw	a1,0(a5)
    80006a56:	009b8533          	add	a0,s7,s1
    80006a5a:	00000097          	auipc	ra,0x0
    80006a5e:	e82080e7          	jalr	-382(ra) # 800068dc <sprintint>
    80006a62:	9ca9                	addw	s1,s1,a0
      break;
    80006a64:	b759                	j	800069ea <snprintf+0x76>
      if((s = va_arg(ap, char*)) == 0)
    80006a66:	f9843783          	ld	a5,-104(s0)
    80006a6a:	00878713          	addi	a4,a5,8
    80006a6e:	f8e43c23          	sd	a4,-104(s0)
    80006a72:	639c                	ld	a5,0(a5)
    80006a74:	c3a9                	beqz	a5,80006ab6 <snprintf+0x142>
      for(; *s && off < sz; s++)
    80006a76:	0007c703          	lbu	a4,0(a5)
    80006a7a:	db25                	beqz	a4,800069ea <snprintf+0x76>
    80006a7c:	0134de63          	bge	s1,s3,80006a98 <snprintf+0x124>
    80006a80:	009b86b3          	add	a3,s7,s1
  *s = c;
    80006a84:	00e68023          	sb	a4,0(a3)
        off += sputc(buf+off, *s);
    80006a88:	2485                	addiw	s1,s1,1
      for(; *s && off < sz; s++)
    80006a8a:	0785                	addi	a5,a5,1
    80006a8c:	0007c703          	lbu	a4,0(a5)
    80006a90:	df29                	beqz	a4,800069ea <snprintf+0x76>
    80006a92:	0685                	addi	a3,a3,1
    80006a94:	fe9998e3          	bne	s3,s1,80006a84 <snprintf+0x110>
      off += sputc(buf+off, c);
      break;
    }
  }
  return off;
}
    80006a98:	8526                	mv	a0,s1
    80006a9a:	70a6                	ld	ra,104(sp)
    80006a9c:	7406                	ld	s0,96(sp)
    80006a9e:	64e6                	ld	s1,88(sp)
    80006aa0:	6946                	ld	s2,80(sp)
    80006aa2:	69a6                	ld	s3,72(sp)
    80006aa4:	6a06                	ld	s4,64(sp)
    80006aa6:	7ae2                	ld	s5,56(sp)
    80006aa8:	7b42                	ld	s6,48(sp)
    80006aaa:	7ba2                	ld	s7,40(sp)
    80006aac:	7c02                	ld	s8,32(sp)
    80006aae:	6ce2                	ld	s9,24(sp)
    80006ab0:	6d42                	ld	s10,16(sp)
    80006ab2:	610d                	addi	sp,sp,160
    80006ab4:	8082                	ret
        s = "(null)";
    80006ab6:	00001797          	auipc	a5,0x1
    80006aba:	56a78793          	addi	a5,a5,1386 # 80008020 <etext+0x20>
      for(; *s && off < sz; s++)
    80006abe:	876a                	mv	a4,s10
    80006ac0:	bf75                	j	80006a7c <snprintf+0x108>
  *s = c;
    80006ac2:	009b87b3          	add	a5,s7,s1
    80006ac6:	01578023          	sb	s5,0(a5)
      off += sputc(buf+off, '%');
    80006aca:	2485                	addiw	s1,s1,1
      break;
    80006acc:	bf39                	j	800069ea <snprintf+0x76>
  *s = c;
    80006ace:	009b8733          	add	a4,s7,s1
    80006ad2:	01570023          	sb	s5,0(a4)
      off += sputc(buf+off, c);
    80006ad6:	0014871b          	addiw	a4,s1,1
  *s = c;
    80006ada:	975e                	add	a4,a4,s7
    80006adc:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80006ae0:	2489                	addiw	s1,s1,2
      break;
    80006ae2:	b721                	j	800069ea <snprintf+0x76>
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
