
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <__global_pointer$+0x1d4ac>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <__global_pointer$+0x2336>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <__global_pointer$+0xffffffffffffd67b>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00001517          	auipc	a0,0x1
      64:	61850513          	addi	a0,a0,1560 # 1678 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	e4e080e7          	jalr	-434(ra) # ede <sbrk>
      98:	8a2a                	mv	s4,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	2f650513          	addi	a0,a0,758 # 1390 <malloc+0xe4>
      a2:	00001097          	auipc	ra,0x1
      a6:	e1c080e7          	jalr	-484(ra) # ebe <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	2e650513          	addi	a0,a0,742 # 1390 <malloc+0xe4>
      b2:	00001097          	auipc	ra,0x1
      b6:	e14080e7          	jalr	-492(ra) # ec6 <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	2dc50513          	addi	a0,a0,732 # 1398 <malloc+0xec>
      c4:	00001097          	auipc	ra,0x1
      c8:	12a080e7          	jalr	298(ra) # 11ee <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	d88080e7          	jalr	-632(ra) # e56 <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	2da50513          	addi	a0,a0,730 # 13b0 <malloc+0x104>
      de:	00001097          	auipc	ra,0x1
      e2:	de8080e7          	jalr	-536(ra) # ec6 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      e6:	00001997          	auipc	s3,0x1
      ea:	2da98993          	addi	s3,s3,730 # 13c0 <malloc+0x114>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	2c898993          	addi	s3,s3,712 # 13b8 <malloc+0x10c>
    iters++;
      f8:	4485                	li	s1,1
  int fd = -1;
      fa:	597d                	li	s2,-1
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 15){
      sbrk(6011);
      fc:	6a85                	lui	s5,0x1
      fe:	77ba8a93          	addi	s5,s5,1915 # 177b <buf.0+0xf3>
     102:	a825                	j	13a <go+0xc2>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     104:	20200593          	li	a1,514
     108:	00001517          	auipc	a0,0x1
     10c:	2c050513          	addi	a0,a0,704 # 13c8 <malloc+0x11c>
     110:	00001097          	auipc	ra,0x1
     114:	d86080e7          	jalr	-634(ra) # e96 <open>
     118:	00001097          	auipc	ra,0x1
     11c:	d66080e7          	jalr	-666(ra) # e7e <close>
    iters++;
     120:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     122:	1f400793          	li	a5,500
     126:	02f4f7b3          	remu	a5,s1,a5
     12a:	eb81                	bnez	a5,13a <go+0xc2>
      write(1, which_child?"B":"A", 1);
     12c:	4605                	li	a2,1
     12e:	85ce                	mv	a1,s3
     130:	4505                	li	a0,1
     132:	00001097          	auipc	ra,0x1
     136:	d44080e7          	jalr	-700(ra) # e76 <write>
    int what = rand() % 23;
     13a:	00000097          	auipc	ra,0x0
     13e:	f1e080e7          	jalr	-226(ra) # 58 <rand>
     142:	47dd                	li	a5,23
     144:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     148:	4785                	li	a5,1
     14a:	faf50de3          	beq	a0,a5,104 <go+0x8c>
    } else if(what == 2){
     14e:	4789                	li	a5,2
     150:	16f50e63          	beq	a0,a5,2cc <go+0x254>
    } else if(what == 3){
     154:	478d                	li	a5,3
     156:	18f50a63          	beq	a0,a5,2ea <go+0x272>
    } else if(what == 4){
     15a:	4791                	li	a5,4
     15c:	1af50063          	beq	a0,a5,2fc <go+0x284>
    } else if(what == 5){
     160:	4795                	li	a5,5
     162:	1ef50463          	beq	a0,a5,34a <go+0x2d2>
    } else if(what == 6){
     166:	4799                	li	a5,6
     168:	20f50263          	beq	a0,a5,36c <go+0x2f4>
    } else if(what == 7){
     16c:	479d                	li	a5,7
     16e:	22f50063          	beq	a0,a5,38e <go+0x316>
    } else if(what == 8){
     172:	47a1                	li	a5,8
     174:	22f50963          	beq	a0,a5,3a6 <go+0x32e>
    } else if(what == 9){
     178:	47a5                	li	a5,9
     17a:	24f50263          	beq	a0,a5,3be <go+0x346>
    } else if(what == 10){
     17e:	47a9                	li	a5,10
     180:	26f50e63          	beq	a0,a5,3fc <go+0x384>
    } else if(what == 11){
     184:	47ad                	li	a5,11
     186:	2af50a63          	beq	a0,a5,43a <go+0x3c2>
    } else if(what == 12){
     18a:	47b1                	li	a5,12
     18c:	2cf50c63          	beq	a0,a5,464 <go+0x3ec>
    } else if(what == 13){
     190:	47b5                	li	a5,13
     192:	2ef50e63          	beq	a0,a5,48e <go+0x416>
    } else if(what == 14){
     196:	47b9                	li	a5,14
     198:	32f50963          	beq	a0,a5,4ca <go+0x452>
    } else if(what == 15){
     19c:	47bd                	li	a5,15
     19e:	36f50d63          	beq	a0,a5,518 <go+0x4a0>
    } else if(what == 16){
     1a2:	47c1                	li	a5,16
     1a4:	38f50063          	beq	a0,a5,524 <go+0x4ac>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     1a8:	47c5                	li	a5,17
     1aa:	3af50063          	beq	a0,a5,54a <go+0x4d2>
        printf("chdir failed\n");
        exit(1);
      }
      kill(pid);
      wait(0);
    } else if(what == 18){
     1ae:	47c9                	li	a5,18
     1b0:	42f50663          	beq	a0,a5,5dc <go+0x564>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 19){
     1b4:	47cd                	li	a5,19
     1b6:	46f50a63          	beq	a0,a5,62a <go+0x5b2>
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0);
    } else if(what == 20){
     1ba:	47d1                	li	a5,20
     1bc:	54f50b63          	beq	a0,a5,712 <go+0x69a>
      } else if(pid < 0){
        printf("fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 21){
     1c0:	47d5                	li	a5,21
     1c2:	5ef50963          	beq	a0,a5,7b4 <go+0x73c>
        printf("fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     1c6:	47d9                	li	a5,22
     1c8:	f4f51ce3          	bne	a0,a5,120 <go+0xa8>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1cc:	f9840513          	addi	a0,s0,-104
     1d0:	00001097          	auipc	ra,0x1
     1d4:	c96080e7          	jalr	-874(ra) # e66 <pipe>
     1d8:	6e054263          	bltz	a0,8bc <go+0x844>
        fprintf(2, "pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     1dc:	fa040513          	addi	a0,s0,-96
     1e0:	00001097          	auipc	ra,0x1
     1e4:	c86080e7          	jalr	-890(ra) # e66 <pipe>
     1e8:	6e054863          	bltz	a0,8d8 <go+0x860>
        fprintf(2, "pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     1ec:	00001097          	auipc	ra,0x1
     1f0:	c62080e7          	jalr	-926(ra) # e4e <fork>
      if(pid1 == 0){
     1f4:	70050063          	beqz	a0,8f4 <go+0x87c>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     1f8:	7a054863          	bltz	a0,9a8 <go+0x930>
        fprintf(2, "fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     1fc:	00001097          	auipc	ra,0x1
     200:	c52080e7          	jalr	-942(ra) # e4e <fork>
      if(pid2 == 0){
     204:	7c050063          	beqz	a0,9c4 <go+0x94c>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     208:	08054ce3          	bltz	a0,aa0 <go+0xa28>
        fprintf(2, "fork failed\n");
        exit(7);
      }
      close(aa[0]);
     20c:	f9842503          	lw	a0,-104(s0)
     210:	00001097          	auipc	ra,0x1
     214:	c6e080e7          	jalr	-914(ra) # e7e <close>
      close(aa[1]);
     218:	f9c42503          	lw	a0,-100(s0)
     21c:	00001097          	auipc	ra,0x1
     220:	c62080e7          	jalr	-926(ra) # e7e <close>
      close(bb[1]);
     224:	fa442503          	lw	a0,-92(s0)
     228:	00001097          	auipc	ra,0x1
     22c:	c56080e7          	jalr	-938(ra) # e7e <close>
      char buf[3] = { 0, 0, 0 };
     230:	f8041823          	sh	zero,-112(s0)
     234:	f8040923          	sb	zero,-110(s0)
      read(bb[0], buf+0, 1);
     238:	4605                	li	a2,1
     23a:	f9040593          	addi	a1,s0,-112
     23e:	fa042503          	lw	a0,-96(s0)
     242:	00001097          	auipc	ra,0x1
     246:	c2c080e7          	jalr	-980(ra) # e6e <read>
      read(bb[0], buf+1, 1);
     24a:	4605                	li	a2,1
     24c:	f9140593          	addi	a1,s0,-111
     250:	fa042503          	lw	a0,-96(s0)
     254:	00001097          	auipc	ra,0x1
     258:	c1a080e7          	jalr	-998(ra) # e6e <read>
      close(bb[0]);
     25c:	fa042503          	lw	a0,-96(s0)
     260:	00001097          	auipc	ra,0x1
     264:	c1e080e7          	jalr	-994(ra) # e7e <close>
      int st1, st2;
      wait(&st1);
     268:	f9440513          	addi	a0,s0,-108
     26c:	00001097          	auipc	ra,0x1
     270:	bf2080e7          	jalr	-1038(ra) # e5e <wait>
      wait(&st2);
     274:	fa840513          	addi	a0,s0,-88
     278:	00001097          	auipc	ra,0x1
     27c:	be6080e7          	jalr	-1050(ra) # e5e <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi") != 0){
     280:	f9442783          	lw	a5,-108(s0)
     284:	fa842703          	lw	a4,-88(s0)
     288:	8fd9                	or	a5,a5,a4
     28a:	2781                	sext.w	a5,a5
     28c:	ef89                	bnez	a5,2a6 <go+0x22e>
     28e:	00001597          	auipc	a1,0x1
     292:	35258593          	addi	a1,a1,850 # 15e0 <malloc+0x334>
     296:	f9040513          	addi	a0,s0,-112
     29a:	00001097          	auipc	ra,0x1
     29e:	96a080e7          	jalr	-1686(ra) # c04 <strcmp>
     2a2:	e6050fe3          	beqz	a0,120 <go+0xa8>
        printf("exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     2a6:	f9040693          	addi	a3,s0,-112
     2aa:	fa842603          	lw	a2,-88(s0)
     2ae:	f9442583          	lw	a1,-108(s0)
     2b2:	00001517          	auipc	a0,0x1
     2b6:	37e50513          	addi	a0,a0,894 # 1630 <malloc+0x384>
     2ba:	00001097          	auipc	ra,0x1
     2be:	f34080e7          	jalr	-204(ra) # 11ee <printf>
        exit(1);
     2c2:	4505                	li	a0,1
     2c4:	00001097          	auipc	ra,0x1
     2c8:	b92080e7          	jalr	-1134(ra) # e56 <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     2cc:	20200593          	li	a1,514
     2d0:	00001517          	auipc	a0,0x1
     2d4:	10850513          	addi	a0,a0,264 # 13d8 <malloc+0x12c>
     2d8:	00001097          	auipc	ra,0x1
     2dc:	bbe080e7          	jalr	-1090(ra) # e96 <open>
     2e0:	00001097          	auipc	ra,0x1
     2e4:	b9e080e7          	jalr	-1122(ra) # e7e <close>
     2e8:	bd25                	j	120 <go+0xa8>
      unlink("grindir/../a");
     2ea:	00001517          	auipc	a0,0x1
     2ee:	0de50513          	addi	a0,a0,222 # 13c8 <malloc+0x11c>
     2f2:	00001097          	auipc	ra,0x1
     2f6:	bb4080e7          	jalr	-1100(ra) # ea6 <unlink>
     2fa:	b51d                	j	120 <go+0xa8>
      if(chdir("grindir") != 0){
     2fc:	00001517          	auipc	a0,0x1
     300:	09450513          	addi	a0,a0,148 # 1390 <malloc+0xe4>
     304:	00001097          	auipc	ra,0x1
     308:	bc2080e7          	jalr	-1086(ra) # ec6 <chdir>
     30c:	e115                	bnez	a0,330 <go+0x2b8>
      unlink("../b");
     30e:	00001517          	auipc	a0,0x1
     312:	0e250513          	addi	a0,a0,226 # 13f0 <malloc+0x144>
     316:	00001097          	auipc	ra,0x1
     31a:	b90080e7          	jalr	-1136(ra) # ea6 <unlink>
      chdir("/");
     31e:	00001517          	auipc	a0,0x1
     322:	09250513          	addi	a0,a0,146 # 13b0 <malloc+0x104>
     326:	00001097          	auipc	ra,0x1
     32a:	ba0080e7          	jalr	-1120(ra) # ec6 <chdir>
     32e:	bbcd                	j	120 <go+0xa8>
        printf("chdir grindir failed\n");
     330:	00001517          	auipc	a0,0x1
     334:	06850513          	addi	a0,a0,104 # 1398 <malloc+0xec>
     338:	00001097          	auipc	ra,0x1
     33c:	eb6080e7          	jalr	-330(ra) # 11ee <printf>
        exit(1);
     340:	4505                	li	a0,1
     342:	00001097          	auipc	ra,0x1
     346:	b14080e7          	jalr	-1260(ra) # e56 <exit>
      close(fd);
     34a:	854a                	mv	a0,s2
     34c:	00001097          	auipc	ra,0x1
     350:	b32080e7          	jalr	-1230(ra) # e7e <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     354:	20200593          	li	a1,514
     358:	00001517          	auipc	a0,0x1
     35c:	0a050513          	addi	a0,a0,160 # 13f8 <malloc+0x14c>
     360:	00001097          	auipc	ra,0x1
     364:	b36080e7          	jalr	-1226(ra) # e96 <open>
     368:	892a                	mv	s2,a0
     36a:	bb5d                	j	120 <go+0xa8>
      close(fd);
     36c:	854a                	mv	a0,s2
     36e:	00001097          	auipc	ra,0x1
     372:	b10080e7          	jalr	-1264(ra) # e7e <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     376:	20200593          	li	a1,514
     37a:	00001517          	auipc	a0,0x1
     37e:	08e50513          	addi	a0,a0,142 # 1408 <malloc+0x15c>
     382:	00001097          	auipc	ra,0x1
     386:	b14080e7          	jalr	-1260(ra) # e96 <open>
     38a:	892a                	mv	s2,a0
     38c:	bb51                	j	120 <go+0xa8>
      write(fd, buf, sizeof(buf));
     38e:	3e700613          	li	a2,999
     392:	00001597          	auipc	a1,0x1
     396:	2f658593          	addi	a1,a1,758 # 1688 <buf.0>
     39a:	854a                	mv	a0,s2
     39c:	00001097          	auipc	ra,0x1
     3a0:	ada080e7          	jalr	-1318(ra) # e76 <write>
     3a4:	bbb5                	j	120 <go+0xa8>
      read(fd, buf, sizeof(buf));
     3a6:	3e700613          	li	a2,999
     3aa:	00001597          	auipc	a1,0x1
     3ae:	2de58593          	addi	a1,a1,734 # 1688 <buf.0>
     3b2:	854a                	mv	a0,s2
     3b4:	00001097          	auipc	ra,0x1
     3b8:	aba080e7          	jalr	-1350(ra) # e6e <read>
     3bc:	b395                	j	120 <go+0xa8>
      mkdir("grindir/../a");
     3be:	00001517          	auipc	a0,0x1
     3c2:	00a50513          	addi	a0,a0,10 # 13c8 <malloc+0x11c>
     3c6:	00001097          	auipc	ra,0x1
     3ca:	af8080e7          	jalr	-1288(ra) # ebe <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     3ce:	20200593          	li	a1,514
     3d2:	00001517          	auipc	a0,0x1
     3d6:	04e50513          	addi	a0,a0,78 # 1420 <malloc+0x174>
     3da:	00001097          	auipc	ra,0x1
     3de:	abc080e7          	jalr	-1348(ra) # e96 <open>
     3e2:	00001097          	auipc	ra,0x1
     3e6:	a9c080e7          	jalr	-1380(ra) # e7e <close>
      unlink("a/a");
     3ea:	00001517          	auipc	a0,0x1
     3ee:	04650513          	addi	a0,a0,70 # 1430 <malloc+0x184>
     3f2:	00001097          	auipc	ra,0x1
     3f6:	ab4080e7          	jalr	-1356(ra) # ea6 <unlink>
     3fa:	b31d                	j	120 <go+0xa8>
      mkdir("/../b");
     3fc:	00001517          	auipc	a0,0x1
     400:	03c50513          	addi	a0,a0,60 # 1438 <malloc+0x18c>
     404:	00001097          	auipc	ra,0x1
     408:	aba080e7          	jalr	-1350(ra) # ebe <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     40c:	20200593          	li	a1,514
     410:	00001517          	auipc	a0,0x1
     414:	03050513          	addi	a0,a0,48 # 1440 <malloc+0x194>
     418:	00001097          	auipc	ra,0x1
     41c:	a7e080e7          	jalr	-1410(ra) # e96 <open>
     420:	00001097          	auipc	ra,0x1
     424:	a5e080e7          	jalr	-1442(ra) # e7e <close>
      unlink("b/b");
     428:	00001517          	auipc	a0,0x1
     42c:	02850513          	addi	a0,a0,40 # 1450 <malloc+0x1a4>
     430:	00001097          	auipc	ra,0x1
     434:	a76080e7          	jalr	-1418(ra) # ea6 <unlink>
     438:	b1e5                	j	120 <go+0xa8>
      unlink("b");
     43a:	00001517          	auipc	a0,0x1
     43e:	fde50513          	addi	a0,a0,-34 # 1418 <malloc+0x16c>
     442:	00001097          	auipc	ra,0x1
     446:	a64080e7          	jalr	-1436(ra) # ea6 <unlink>
      link("../grindir/./../a", "../b");
     44a:	00001597          	auipc	a1,0x1
     44e:	fa658593          	addi	a1,a1,-90 # 13f0 <malloc+0x144>
     452:	00001517          	auipc	a0,0x1
     456:	00650513          	addi	a0,a0,6 # 1458 <malloc+0x1ac>
     45a:	00001097          	auipc	ra,0x1
     45e:	a5c080e7          	jalr	-1444(ra) # eb6 <link>
     462:	b97d                	j	120 <go+0xa8>
      unlink("../grindir/../a");
     464:	00001517          	auipc	a0,0x1
     468:	00c50513          	addi	a0,a0,12 # 1470 <malloc+0x1c4>
     46c:	00001097          	auipc	ra,0x1
     470:	a3a080e7          	jalr	-1478(ra) # ea6 <unlink>
      link(".././b", "/grindir/../a");
     474:	00001597          	auipc	a1,0x1
     478:	f8458593          	addi	a1,a1,-124 # 13f8 <malloc+0x14c>
     47c:	00001517          	auipc	a0,0x1
     480:	00450513          	addi	a0,a0,4 # 1480 <malloc+0x1d4>
     484:	00001097          	auipc	ra,0x1
     488:	a32080e7          	jalr	-1486(ra) # eb6 <link>
     48c:	b951                	j	120 <go+0xa8>
      int pid = fork();
     48e:	00001097          	auipc	ra,0x1
     492:	9c0080e7          	jalr	-1600(ra) # e4e <fork>
      if(pid == 0){
     496:	c909                	beqz	a0,4a8 <go+0x430>
      } else if(pid < 0){
     498:	00054c63          	bltz	a0,4b0 <go+0x438>
      wait(0);
     49c:	4501                	li	a0,0
     49e:	00001097          	auipc	ra,0x1
     4a2:	9c0080e7          	jalr	-1600(ra) # e5e <wait>
     4a6:	b9ad                	j	120 <go+0xa8>
        exit(0);
     4a8:	00001097          	auipc	ra,0x1
     4ac:	9ae080e7          	jalr	-1618(ra) # e56 <exit>
        printf("grind: fork failed\n");
     4b0:	00001517          	auipc	a0,0x1
     4b4:	fd850513          	addi	a0,a0,-40 # 1488 <malloc+0x1dc>
     4b8:	00001097          	auipc	ra,0x1
     4bc:	d36080e7          	jalr	-714(ra) # 11ee <printf>
        exit(1);
     4c0:	4505                	li	a0,1
     4c2:	00001097          	auipc	ra,0x1
     4c6:	994080e7          	jalr	-1644(ra) # e56 <exit>
      int pid = fork();
     4ca:	00001097          	auipc	ra,0x1
     4ce:	984080e7          	jalr	-1660(ra) # e4e <fork>
      if(pid == 0){
     4d2:	c909                	beqz	a0,4e4 <go+0x46c>
      } else if(pid < 0){
     4d4:	02054563          	bltz	a0,4fe <go+0x486>
      wait(0);
     4d8:	4501                	li	a0,0
     4da:	00001097          	auipc	ra,0x1
     4de:	984080e7          	jalr	-1660(ra) # e5e <wait>
     4e2:	b93d                	j	120 <go+0xa8>
        fork();
     4e4:	00001097          	auipc	ra,0x1
     4e8:	96a080e7          	jalr	-1686(ra) # e4e <fork>
        fork();
     4ec:	00001097          	auipc	ra,0x1
     4f0:	962080e7          	jalr	-1694(ra) # e4e <fork>
        exit(0);
     4f4:	4501                	li	a0,0
     4f6:	00001097          	auipc	ra,0x1
     4fa:	960080e7          	jalr	-1696(ra) # e56 <exit>
        printf("grind: fork failed\n");
     4fe:	00001517          	auipc	a0,0x1
     502:	f8a50513          	addi	a0,a0,-118 # 1488 <malloc+0x1dc>
     506:	00001097          	auipc	ra,0x1
     50a:	ce8080e7          	jalr	-792(ra) # 11ee <printf>
        exit(1);
     50e:	4505                	li	a0,1
     510:	00001097          	auipc	ra,0x1
     514:	946080e7          	jalr	-1722(ra) # e56 <exit>
      sbrk(6011);
     518:	8556                	mv	a0,s5
     51a:	00001097          	auipc	ra,0x1
     51e:	9c4080e7          	jalr	-1596(ra) # ede <sbrk>
     522:	befd                	j	120 <go+0xa8>
      if(sbrk(0) > break0)
     524:	4501                	li	a0,0
     526:	00001097          	auipc	ra,0x1
     52a:	9b8080e7          	jalr	-1608(ra) # ede <sbrk>
     52e:	beaa79e3          	bgeu	s4,a0,120 <go+0xa8>
        sbrk(-(sbrk(0) - break0));
     532:	4501                	li	a0,0
     534:	00001097          	auipc	ra,0x1
     538:	9aa080e7          	jalr	-1622(ra) # ede <sbrk>
     53c:	40aa053b          	subw	a0,s4,a0
     540:	00001097          	auipc	ra,0x1
     544:	99e080e7          	jalr	-1634(ra) # ede <sbrk>
     548:	bee1                	j	120 <go+0xa8>
      int pid = fork();
     54a:	00001097          	auipc	ra,0x1
     54e:	904080e7          	jalr	-1788(ra) # e4e <fork>
     552:	8b2a                	mv	s6,a0
      if(pid == 0){
     554:	c51d                	beqz	a0,582 <go+0x50a>
      } else if(pid < 0){
     556:	04054963          	bltz	a0,5a8 <go+0x530>
      if(chdir("../grindir/..") != 0){
     55a:	00001517          	auipc	a0,0x1
     55e:	f4650513          	addi	a0,a0,-186 # 14a0 <malloc+0x1f4>
     562:	00001097          	auipc	ra,0x1
     566:	964080e7          	jalr	-1692(ra) # ec6 <chdir>
     56a:	ed21                	bnez	a0,5c2 <go+0x54a>
      kill(pid);
     56c:	855a                	mv	a0,s6
     56e:	00001097          	auipc	ra,0x1
     572:	918080e7          	jalr	-1768(ra) # e86 <kill>
      wait(0);
     576:	4501                	li	a0,0
     578:	00001097          	auipc	ra,0x1
     57c:	8e6080e7          	jalr	-1818(ra) # e5e <wait>
     580:	b645                	j	120 <go+0xa8>
        close(open("a", O_CREATE|O_RDWR));
     582:	20200593          	li	a1,514
     586:	00001517          	auipc	a0,0x1
     58a:	ee250513          	addi	a0,a0,-286 # 1468 <malloc+0x1bc>
     58e:	00001097          	auipc	ra,0x1
     592:	908080e7          	jalr	-1784(ra) # e96 <open>
     596:	00001097          	auipc	ra,0x1
     59a:	8e8080e7          	jalr	-1816(ra) # e7e <close>
        exit(0);
     59e:	4501                	li	a0,0
     5a0:	00001097          	auipc	ra,0x1
     5a4:	8b6080e7          	jalr	-1866(ra) # e56 <exit>
        printf("grind: fork failed\n");
     5a8:	00001517          	auipc	a0,0x1
     5ac:	ee050513          	addi	a0,a0,-288 # 1488 <malloc+0x1dc>
     5b0:	00001097          	auipc	ra,0x1
     5b4:	c3e080e7          	jalr	-962(ra) # 11ee <printf>
        exit(1);
     5b8:	4505                	li	a0,1
     5ba:	00001097          	auipc	ra,0x1
     5be:	89c080e7          	jalr	-1892(ra) # e56 <exit>
        printf("chdir failed\n");
     5c2:	00001517          	auipc	a0,0x1
     5c6:	eee50513          	addi	a0,a0,-274 # 14b0 <malloc+0x204>
     5ca:	00001097          	auipc	ra,0x1
     5ce:	c24080e7          	jalr	-988(ra) # 11ee <printf>
        exit(1);
     5d2:	4505                	li	a0,1
     5d4:	00001097          	auipc	ra,0x1
     5d8:	882080e7          	jalr	-1918(ra) # e56 <exit>
      int pid = fork();
     5dc:	00001097          	auipc	ra,0x1
     5e0:	872080e7          	jalr	-1934(ra) # e4e <fork>
      if(pid == 0){
     5e4:	c909                	beqz	a0,5f6 <go+0x57e>
      } else if(pid < 0){
     5e6:	02054563          	bltz	a0,610 <go+0x598>
      wait(0);
     5ea:	4501                	li	a0,0
     5ec:	00001097          	auipc	ra,0x1
     5f0:	872080e7          	jalr	-1934(ra) # e5e <wait>
     5f4:	b635                	j	120 <go+0xa8>
        kill(getpid());
     5f6:	00001097          	auipc	ra,0x1
     5fa:	8e0080e7          	jalr	-1824(ra) # ed6 <getpid>
     5fe:	00001097          	auipc	ra,0x1
     602:	888080e7          	jalr	-1912(ra) # e86 <kill>
        exit(0);
     606:	4501                	li	a0,0
     608:	00001097          	auipc	ra,0x1
     60c:	84e080e7          	jalr	-1970(ra) # e56 <exit>
        printf("grind: fork failed\n");
     610:	00001517          	auipc	a0,0x1
     614:	e7850513          	addi	a0,a0,-392 # 1488 <malloc+0x1dc>
     618:	00001097          	auipc	ra,0x1
     61c:	bd6080e7          	jalr	-1066(ra) # 11ee <printf>
        exit(1);
     620:	4505                	li	a0,1
     622:	00001097          	auipc	ra,0x1
     626:	834080e7          	jalr	-1996(ra) # e56 <exit>
      if(pipe(fds) < 0){
     62a:	fa840513          	addi	a0,s0,-88
     62e:	00001097          	auipc	ra,0x1
     632:	838080e7          	jalr	-1992(ra) # e66 <pipe>
     636:	02054b63          	bltz	a0,66c <go+0x5f4>
      int pid = fork();
     63a:	00001097          	auipc	ra,0x1
     63e:	814080e7          	jalr	-2028(ra) # e4e <fork>
      if(pid == 0){
     642:	c131                	beqz	a0,686 <go+0x60e>
      } else if(pid < 0){
     644:	0a054a63          	bltz	a0,6f8 <go+0x680>
      close(fds[0]);
     648:	fa842503          	lw	a0,-88(s0)
     64c:	00001097          	auipc	ra,0x1
     650:	832080e7          	jalr	-1998(ra) # e7e <close>
      close(fds[1]);
     654:	fac42503          	lw	a0,-84(s0)
     658:	00001097          	auipc	ra,0x1
     65c:	826080e7          	jalr	-2010(ra) # e7e <close>
      wait(0);
     660:	4501                	li	a0,0
     662:	00000097          	auipc	ra,0x0
     666:	7fc080e7          	jalr	2044(ra) # e5e <wait>
     66a:	bc5d                	j	120 <go+0xa8>
        printf("grind: pipe failed\n");
     66c:	00001517          	auipc	a0,0x1
     670:	e5450513          	addi	a0,a0,-428 # 14c0 <malloc+0x214>
     674:	00001097          	auipc	ra,0x1
     678:	b7a080e7          	jalr	-1158(ra) # 11ee <printf>
        exit(1);
     67c:	4505                	li	a0,1
     67e:	00000097          	auipc	ra,0x0
     682:	7d8080e7          	jalr	2008(ra) # e56 <exit>
        fork();
     686:	00000097          	auipc	ra,0x0
     68a:	7c8080e7          	jalr	1992(ra) # e4e <fork>
        fork();
     68e:	00000097          	auipc	ra,0x0
     692:	7c0080e7          	jalr	1984(ra) # e4e <fork>
        if(write(fds[1], "x", 1) != 1)
     696:	4605                	li	a2,1
     698:	00001597          	auipc	a1,0x1
     69c:	e4058593          	addi	a1,a1,-448 # 14d8 <malloc+0x22c>
     6a0:	fac42503          	lw	a0,-84(s0)
     6a4:	00000097          	auipc	ra,0x0
     6a8:	7d2080e7          	jalr	2002(ra) # e76 <write>
     6ac:	4785                	li	a5,1
     6ae:	02f51363          	bne	a0,a5,6d4 <go+0x65c>
        if(read(fds[0], &c, 1) != 1)
     6b2:	4605                	li	a2,1
     6b4:	fa040593          	addi	a1,s0,-96
     6b8:	fa842503          	lw	a0,-88(s0)
     6bc:	00000097          	auipc	ra,0x0
     6c0:	7b2080e7          	jalr	1970(ra) # e6e <read>
     6c4:	4785                	li	a5,1
     6c6:	02f51063          	bne	a0,a5,6e6 <go+0x66e>
        exit(0);
     6ca:	4501                	li	a0,0
     6cc:	00000097          	auipc	ra,0x0
     6d0:	78a080e7          	jalr	1930(ra) # e56 <exit>
          printf("grind: pipe write failed\n");
     6d4:	00001517          	auipc	a0,0x1
     6d8:	e0c50513          	addi	a0,a0,-500 # 14e0 <malloc+0x234>
     6dc:	00001097          	auipc	ra,0x1
     6e0:	b12080e7          	jalr	-1262(ra) # 11ee <printf>
     6e4:	b7f9                	j	6b2 <go+0x63a>
          printf("grind: pipe read failed\n");
     6e6:	00001517          	auipc	a0,0x1
     6ea:	e1a50513          	addi	a0,a0,-486 # 1500 <malloc+0x254>
     6ee:	00001097          	auipc	ra,0x1
     6f2:	b00080e7          	jalr	-1280(ra) # 11ee <printf>
     6f6:	bfd1                	j	6ca <go+0x652>
        printf("grind: fork failed\n");
     6f8:	00001517          	auipc	a0,0x1
     6fc:	d9050513          	addi	a0,a0,-624 # 1488 <malloc+0x1dc>
     700:	00001097          	auipc	ra,0x1
     704:	aee080e7          	jalr	-1298(ra) # 11ee <printf>
        exit(1);
     708:	4505                	li	a0,1
     70a:	00000097          	auipc	ra,0x0
     70e:	74c080e7          	jalr	1868(ra) # e56 <exit>
      int pid = fork();
     712:	00000097          	auipc	ra,0x0
     716:	73c080e7          	jalr	1852(ra) # e4e <fork>
      if(pid == 0){
     71a:	c909                	beqz	a0,72c <go+0x6b4>
      } else if(pid < 0){
     71c:	06054f63          	bltz	a0,79a <go+0x722>
      wait(0);
     720:	4501                	li	a0,0
     722:	00000097          	auipc	ra,0x0
     726:	73c080e7          	jalr	1852(ra) # e5e <wait>
     72a:	badd                	j	120 <go+0xa8>
        unlink("a");
     72c:	00001517          	auipc	a0,0x1
     730:	d3c50513          	addi	a0,a0,-708 # 1468 <malloc+0x1bc>
     734:	00000097          	auipc	ra,0x0
     738:	772080e7          	jalr	1906(ra) # ea6 <unlink>
        mkdir("a");
     73c:	00001517          	auipc	a0,0x1
     740:	d2c50513          	addi	a0,a0,-724 # 1468 <malloc+0x1bc>
     744:	00000097          	auipc	ra,0x0
     748:	77a080e7          	jalr	1914(ra) # ebe <mkdir>
        chdir("a");
     74c:	00001517          	auipc	a0,0x1
     750:	d1c50513          	addi	a0,a0,-740 # 1468 <malloc+0x1bc>
     754:	00000097          	auipc	ra,0x0
     758:	772080e7          	jalr	1906(ra) # ec6 <chdir>
        unlink("../a");
     75c:	00001517          	auipc	a0,0x1
     760:	c7450513          	addi	a0,a0,-908 # 13d0 <malloc+0x124>
     764:	00000097          	auipc	ra,0x0
     768:	742080e7          	jalr	1858(ra) # ea6 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     76c:	20200593          	li	a1,514
     770:	00001517          	auipc	a0,0x1
     774:	d6850513          	addi	a0,a0,-664 # 14d8 <malloc+0x22c>
     778:	00000097          	auipc	ra,0x0
     77c:	71e080e7          	jalr	1822(ra) # e96 <open>
        unlink("x");
     780:	00001517          	auipc	a0,0x1
     784:	d5850513          	addi	a0,a0,-680 # 14d8 <malloc+0x22c>
     788:	00000097          	auipc	ra,0x0
     78c:	71e080e7          	jalr	1822(ra) # ea6 <unlink>
        exit(0);
     790:	4501                	li	a0,0
     792:	00000097          	auipc	ra,0x0
     796:	6c4080e7          	jalr	1732(ra) # e56 <exit>
        printf("fork failed\n");
     79a:	00001517          	auipc	a0,0x1
     79e:	d8650513          	addi	a0,a0,-634 # 1520 <malloc+0x274>
     7a2:	00001097          	auipc	ra,0x1
     7a6:	a4c080e7          	jalr	-1460(ra) # 11ee <printf>
        exit(1);
     7aa:	4505                	li	a0,1
     7ac:	00000097          	auipc	ra,0x0
     7b0:	6aa080e7          	jalr	1706(ra) # e56 <exit>
      unlink("c");
     7b4:	00001517          	auipc	a0,0x1
     7b8:	d7c50513          	addi	a0,a0,-644 # 1530 <malloc+0x284>
     7bc:	00000097          	auipc	ra,0x0
     7c0:	6ea080e7          	jalr	1770(ra) # ea6 <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     7c4:	20200593          	li	a1,514
     7c8:	00001517          	auipc	a0,0x1
     7cc:	d6850513          	addi	a0,a0,-664 # 1530 <malloc+0x284>
     7d0:	00000097          	auipc	ra,0x0
     7d4:	6c6080e7          	jalr	1734(ra) # e96 <open>
     7d8:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     7da:	04054f63          	bltz	a0,838 <go+0x7c0>
      if(write(fd1, "x", 1) != 1){
     7de:	4605                	li	a2,1
     7e0:	00001597          	auipc	a1,0x1
     7e4:	cf858593          	addi	a1,a1,-776 # 14d8 <malloc+0x22c>
     7e8:	00000097          	auipc	ra,0x0
     7ec:	68e080e7          	jalr	1678(ra) # e76 <write>
     7f0:	4785                	li	a5,1
     7f2:	06f51063          	bne	a0,a5,852 <go+0x7da>
      if(fstat(fd1, &st) != 0){
     7f6:	fa840593          	addi	a1,s0,-88
     7fa:	855a                	mv	a0,s6
     7fc:	00000097          	auipc	ra,0x0
     800:	6b2080e7          	jalr	1714(ra) # eae <fstat>
     804:	e525                	bnez	a0,86c <go+0x7f4>
      if(st.size != 1){
     806:	fb843583          	ld	a1,-72(s0)
     80a:	4785                	li	a5,1
     80c:	06f59d63          	bne	a1,a5,886 <go+0x80e>
      if(st.ino > 200){
     810:	fac42583          	lw	a1,-84(s0)
     814:	0c800793          	li	a5,200
     818:	08b7e563          	bltu	a5,a1,8a2 <go+0x82a>
      close(fd1);
     81c:	855a                	mv	a0,s6
     81e:	00000097          	auipc	ra,0x0
     822:	660080e7          	jalr	1632(ra) # e7e <close>
      unlink("c");
     826:	00001517          	auipc	a0,0x1
     82a:	d0a50513          	addi	a0,a0,-758 # 1530 <malloc+0x284>
     82e:	00000097          	auipc	ra,0x0
     832:	678080e7          	jalr	1656(ra) # ea6 <unlink>
     836:	b0ed                	j	120 <go+0xa8>
        printf("create c failed\n");
     838:	00001517          	auipc	a0,0x1
     83c:	d0050513          	addi	a0,a0,-768 # 1538 <malloc+0x28c>
     840:	00001097          	auipc	ra,0x1
     844:	9ae080e7          	jalr	-1618(ra) # 11ee <printf>
        exit(1);
     848:	4505                	li	a0,1
     84a:	00000097          	auipc	ra,0x0
     84e:	60c080e7          	jalr	1548(ra) # e56 <exit>
        printf("write c failed\n");
     852:	00001517          	auipc	a0,0x1
     856:	cfe50513          	addi	a0,a0,-770 # 1550 <malloc+0x2a4>
     85a:	00001097          	auipc	ra,0x1
     85e:	994080e7          	jalr	-1644(ra) # 11ee <printf>
        exit(1);
     862:	4505                	li	a0,1
     864:	00000097          	auipc	ra,0x0
     868:	5f2080e7          	jalr	1522(ra) # e56 <exit>
        printf("fstat failed\n");
     86c:	00001517          	auipc	a0,0x1
     870:	cf450513          	addi	a0,a0,-780 # 1560 <malloc+0x2b4>
     874:	00001097          	auipc	ra,0x1
     878:	97a080e7          	jalr	-1670(ra) # 11ee <printf>
        exit(1);
     87c:	4505                	li	a0,1
     87e:	00000097          	auipc	ra,0x0
     882:	5d8080e7          	jalr	1496(ra) # e56 <exit>
        printf("fstat reports wrong size %d\n", (int)st.size);
     886:	2581                	sext.w	a1,a1
     888:	00001517          	auipc	a0,0x1
     88c:	ce850513          	addi	a0,a0,-792 # 1570 <malloc+0x2c4>
     890:	00001097          	auipc	ra,0x1
     894:	95e080e7          	jalr	-1698(ra) # 11ee <printf>
        exit(1);
     898:	4505                	li	a0,1
     89a:	00000097          	auipc	ra,0x0
     89e:	5bc080e7          	jalr	1468(ra) # e56 <exit>
        printf("fstat reports crazy i-number %d\n", st.ino);
     8a2:	00001517          	auipc	a0,0x1
     8a6:	cee50513          	addi	a0,a0,-786 # 1590 <malloc+0x2e4>
     8aa:	00001097          	auipc	ra,0x1
     8ae:	944080e7          	jalr	-1724(ra) # 11ee <printf>
        exit(1);
     8b2:	4505                	li	a0,1
     8b4:	00000097          	auipc	ra,0x0
     8b8:	5a2080e7          	jalr	1442(ra) # e56 <exit>
        fprintf(2, "pipe failed\n");
     8bc:	00001597          	auipc	a1,0x1
     8c0:	cfc58593          	addi	a1,a1,-772 # 15b8 <malloc+0x30c>
     8c4:	4509                	li	a0,2
     8c6:	00001097          	auipc	ra,0x1
     8ca:	8fa080e7          	jalr	-1798(ra) # 11c0 <fprintf>
        exit(1);
     8ce:	4505                	li	a0,1
     8d0:	00000097          	auipc	ra,0x0
     8d4:	586080e7          	jalr	1414(ra) # e56 <exit>
        fprintf(2, "pipe failed\n");
     8d8:	00001597          	auipc	a1,0x1
     8dc:	ce058593          	addi	a1,a1,-800 # 15b8 <malloc+0x30c>
     8e0:	4509                	li	a0,2
     8e2:	00001097          	auipc	ra,0x1
     8e6:	8de080e7          	jalr	-1826(ra) # 11c0 <fprintf>
        exit(1);
     8ea:	4505                	li	a0,1
     8ec:	00000097          	auipc	ra,0x0
     8f0:	56a080e7          	jalr	1386(ra) # e56 <exit>
        close(bb[0]);
     8f4:	fa042503          	lw	a0,-96(s0)
     8f8:	00000097          	auipc	ra,0x0
     8fc:	586080e7          	jalr	1414(ra) # e7e <close>
        close(bb[1]);
     900:	fa442503          	lw	a0,-92(s0)
     904:	00000097          	auipc	ra,0x0
     908:	57a080e7          	jalr	1402(ra) # e7e <close>
        close(aa[0]);
     90c:	f9842503          	lw	a0,-104(s0)
     910:	00000097          	auipc	ra,0x0
     914:	56e080e7          	jalr	1390(ra) # e7e <close>
        close(1);
     918:	4505                	li	a0,1
     91a:	00000097          	auipc	ra,0x0
     91e:	564080e7          	jalr	1380(ra) # e7e <close>
        if(dup(aa[1]) != 1){
     922:	f9c42503          	lw	a0,-100(s0)
     926:	00000097          	auipc	ra,0x0
     92a:	5a8080e7          	jalr	1448(ra) # ece <dup>
     92e:	4785                	li	a5,1
     930:	02f50063          	beq	a0,a5,950 <go+0x8d8>
          fprintf(2, "dup failed\n");
     934:	00001597          	auipc	a1,0x1
     938:	c9458593          	addi	a1,a1,-876 # 15c8 <malloc+0x31c>
     93c:	4509                	li	a0,2
     93e:	00001097          	auipc	ra,0x1
     942:	882080e7          	jalr	-1918(ra) # 11c0 <fprintf>
          exit(1);
     946:	4505                	li	a0,1
     948:	00000097          	auipc	ra,0x0
     94c:	50e080e7          	jalr	1294(ra) # e56 <exit>
        close(aa[1]);
     950:	f9c42503          	lw	a0,-100(s0)
     954:	00000097          	auipc	ra,0x0
     958:	52a080e7          	jalr	1322(ra) # e7e <close>
        char *args[3] = { "echo", "hi", 0 };
     95c:	00001797          	auipc	a5,0x1
     960:	c7c78793          	addi	a5,a5,-900 # 15d8 <malloc+0x32c>
     964:	faf43423          	sd	a5,-88(s0)
     968:	00001797          	auipc	a5,0x1
     96c:	c7878793          	addi	a5,a5,-904 # 15e0 <malloc+0x334>
     970:	faf43823          	sd	a5,-80(s0)
     974:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     978:	fa840593          	addi	a1,s0,-88
     97c:	00001517          	auipc	a0,0x1
     980:	c6c50513          	addi	a0,a0,-916 # 15e8 <malloc+0x33c>
     984:	00000097          	auipc	ra,0x0
     988:	50a080e7          	jalr	1290(ra) # e8e <exec>
        fprintf(2, "echo: not found\n");
     98c:	00001597          	auipc	a1,0x1
     990:	c6c58593          	addi	a1,a1,-916 # 15f8 <malloc+0x34c>
     994:	4509                	li	a0,2
     996:	00001097          	auipc	ra,0x1
     99a:	82a080e7          	jalr	-2006(ra) # 11c0 <fprintf>
        exit(2);
     99e:	4509                	li	a0,2
     9a0:	00000097          	auipc	ra,0x0
     9a4:	4b6080e7          	jalr	1206(ra) # e56 <exit>
        fprintf(2, "fork failed\n");
     9a8:	00001597          	auipc	a1,0x1
     9ac:	b7858593          	addi	a1,a1,-1160 # 1520 <malloc+0x274>
     9b0:	4509                	li	a0,2
     9b2:	00001097          	auipc	ra,0x1
     9b6:	80e080e7          	jalr	-2034(ra) # 11c0 <fprintf>
        exit(3);
     9ba:	450d                	li	a0,3
     9bc:	00000097          	auipc	ra,0x0
     9c0:	49a080e7          	jalr	1178(ra) # e56 <exit>
        close(aa[1]);
     9c4:	f9c42503          	lw	a0,-100(s0)
     9c8:	00000097          	auipc	ra,0x0
     9cc:	4b6080e7          	jalr	1206(ra) # e7e <close>
        close(bb[0]);
     9d0:	fa042503          	lw	a0,-96(s0)
     9d4:	00000097          	auipc	ra,0x0
     9d8:	4aa080e7          	jalr	1194(ra) # e7e <close>
        close(0);
     9dc:	4501                	li	a0,0
     9de:	00000097          	auipc	ra,0x0
     9e2:	4a0080e7          	jalr	1184(ra) # e7e <close>
        if(dup(aa[0]) != 0){
     9e6:	f9842503          	lw	a0,-104(s0)
     9ea:	00000097          	auipc	ra,0x0
     9ee:	4e4080e7          	jalr	1252(ra) # ece <dup>
     9f2:	cd19                	beqz	a0,a10 <go+0x998>
          fprintf(2, "dup failed\n");
     9f4:	00001597          	auipc	a1,0x1
     9f8:	bd458593          	addi	a1,a1,-1068 # 15c8 <malloc+0x31c>
     9fc:	4509                	li	a0,2
     9fe:	00000097          	auipc	ra,0x0
     a02:	7c2080e7          	jalr	1986(ra) # 11c0 <fprintf>
          exit(4);
     a06:	4511                	li	a0,4
     a08:	00000097          	auipc	ra,0x0
     a0c:	44e080e7          	jalr	1102(ra) # e56 <exit>
        close(aa[0]);
     a10:	f9842503          	lw	a0,-104(s0)
     a14:	00000097          	auipc	ra,0x0
     a18:	46a080e7          	jalr	1130(ra) # e7e <close>
        close(1);
     a1c:	4505                	li	a0,1
     a1e:	00000097          	auipc	ra,0x0
     a22:	460080e7          	jalr	1120(ra) # e7e <close>
        if(dup(bb[1]) != 1){
     a26:	fa442503          	lw	a0,-92(s0)
     a2a:	00000097          	auipc	ra,0x0
     a2e:	4a4080e7          	jalr	1188(ra) # ece <dup>
     a32:	4785                	li	a5,1
     a34:	02f50063          	beq	a0,a5,a54 <go+0x9dc>
          fprintf(2, "dup failed\n");
     a38:	00001597          	auipc	a1,0x1
     a3c:	b9058593          	addi	a1,a1,-1136 # 15c8 <malloc+0x31c>
     a40:	4509                	li	a0,2
     a42:	00000097          	auipc	ra,0x0
     a46:	77e080e7          	jalr	1918(ra) # 11c0 <fprintf>
          exit(5);
     a4a:	4515                	li	a0,5
     a4c:	00000097          	auipc	ra,0x0
     a50:	40a080e7          	jalr	1034(ra) # e56 <exit>
        close(bb[1]);
     a54:	fa442503          	lw	a0,-92(s0)
     a58:	00000097          	auipc	ra,0x0
     a5c:	426080e7          	jalr	1062(ra) # e7e <close>
        char *args[2] = { "cat", 0 };
     a60:	00001797          	auipc	a5,0x1
     a64:	bb078793          	addi	a5,a5,-1104 # 1610 <malloc+0x364>
     a68:	faf43423          	sd	a5,-88(s0)
     a6c:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a70:	fa840593          	addi	a1,s0,-88
     a74:	00001517          	auipc	a0,0x1
     a78:	ba450513          	addi	a0,a0,-1116 # 1618 <malloc+0x36c>
     a7c:	00000097          	auipc	ra,0x0
     a80:	412080e7          	jalr	1042(ra) # e8e <exec>
        fprintf(2, "cat: not found\n");
     a84:	00001597          	auipc	a1,0x1
     a88:	b9c58593          	addi	a1,a1,-1124 # 1620 <malloc+0x374>
     a8c:	4509                	li	a0,2
     a8e:	00000097          	auipc	ra,0x0
     a92:	732080e7          	jalr	1842(ra) # 11c0 <fprintf>
        exit(6);
     a96:	4519                	li	a0,6
     a98:	00000097          	auipc	ra,0x0
     a9c:	3be080e7          	jalr	958(ra) # e56 <exit>
        fprintf(2, "fork failed\n");
     aa0:	00001597          	auipc	a1,0x1
     aa4:	a8058593          	addi	a1,a1,-1408 # 1520 <malloc+0x274>
     aa8:	4509                	li	a0,2
     aaa:	00000097          	auipc	ra,0x0
     aae:	716080e7          	jalr	1814(ra) # 11c0 <fprintf>
        exit(7);
     ab2:	451d                	li	a0,7
     ab4:	00000097          	auipc	ra,0x0
     ab8:	3a2080e7          	jalr	930(ra) # e56 <exit>

0000000000000abc <iter>:
  }
}

void
iter()
{
     abc:	7179                	addi	sp,sp,-48
     abe:	f406                	sd	ra,40(sp)
     ac0:	f022                	sd	s0,32(sp)
     ac2:	ec26                	sd	s1,24(sp)
     ac4:	e84a                	sd	s2,16(sp)
     ac6:	1800                	addi	s0,sp,48
  unlink("a");
     ac8:	00001517          	auipc	a0,0x1
     acc:	9a050513          	addi	a0,a0,-1632 # 1468 <malloc+0x1bc>
     ad0:	00000097          	auipc	ra,0x0
     ad4:	3d6080e7          	jalr	982(ra) # ea6 <unlink>
  unlink("b");
     ad8:	00001517          	auipc	a0,0x1
     adc:	94050513          	addi	a0,a0,-1728 # 1418 <malloc+0x16c>
     ae0:	00000097          	auipc	ra,0x0
     ae4:	3c6080e7          	jalr	966(ra) # ea6 <unlink>
  
  int pid1 = fork();
     ae8:	00000097          	auipc	ra,0x0
     aec:	366080e7          	jalr	870(ra) # e4e <fork>
  if(pid1 < 0){
     af0:	00054e63          	bltz	a0,b0c <iter+0x50>
     af4:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     af6:	e905                	bnez	a0,b26 <iter+0x6a>
    rand_next = 31;
     af8:	47fd                	li	a5,31
     afa:	00001717          	auipc	a4,0x1
     afe:	b6f73f23          	sd	a5,-1154(a4) # 1678 <rand_next>
    go(0);
     b02:	4501                	li	a0,0
     b04:	fffff097          	auipc	ra,0xfffff
     b08:	574080e7          	jalr	1396(ra) # 78 <go>
    printf("grind: fork failed\n");
     b0c:	00001517          	auipc	a0,0x1
     b10:	97c50513          	addi	a0,a0,-1668 # 1488 <malloc+0x1dc>
     b14:	00000097          	auipc	ra,0x0
     b18:	6da080e7          	jalr	1754(ra) # 11ee <printf>
    exit(1);
     b1c:	4505                	li	a0,1
     b1e:	00000097          	auipc	ra,0x0
     b22:	338080e7          	jalr	824(ra) # e56 <exit>
    exit(0);
  }

  int pid2 = fork();
     b26:	00000097          	auipc	ra,0x0
     b2a:	328080e7          	jalr	808(ra) # e4e <fork>
     b2e:	892a                	mv	s2,a0
  if(pid2 < 0){
     b30:	00054f63          	bltz	a0,b4e <iter+0x92>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     b34:	e915                	bnez	a0,b68 <iter+0xac>
    rand_next = 7177;
     b36:	6789                	lui	a5,0x2
     b38:	c0978793          	addi	a5,a5,-1015 # 1c09 <__BSS_END__+0x189>
     b3c:	00001717          	auipc	a4,0x1
     b40:	b2f73e23          	sd	a5,-1220(a4) # 1678 <rand_next>
    go(1);
     b44:	4505                	li	a0,1
     b46:	fffff097          	auipc	ra,0xfffff
     b4a:	532080e7          	jalr	1330(ra) # 78 <go>
    printf("grind: fork failed\n");
     b4e:	00001517          	auipc	a0,0x1
     b52:	93a50513          	addi	a0,a0,-1734 # 1488 <malloc+0x1dc>
     b56:	00000097          	auipc	ra,0x0
     b5a:	698080e7          	jalr	1688(ra) # 11ee <printf>
    exit(1);
     b5e:	4505                	li	a0,1
     b60:	00000097          	auipc	ra,0x0
     b64:	2f6080e7          	jalr	758(ra) # e56 <exit>
    exit(0);
  }

  int st1 = -1;
     b68:	57fd                	li	a5,-1
     b6a:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b6e:	fdc40513          	addi	a0,s0,-36
     b72:	00000097          	auipc	ra,0x0
     b76:	2ec080e7          	jalr	748(ra) # e5e <wait>
  if(st1 != 0){
     b7a:	fdc42783          	lw	a5,-36(s0)
     b7e:	ef99                	bnez	a5,b9c <iter+0xe0>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b80:	57fd                	li	a5,-1
     b82:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b86:	fd840513          	addi	a0,s0,-40
     b8a:	00000097          	auipc	ra,0x0
     b8e:	2d4080e7          	jalr	724(ra) # e5e <wait>

  exit(0);
     b92:	4501                	li	a0,0
     b94:	00000097          	auipc	ra,0x0
     b98:	2c2080e7          	jalr	706(ra) # e56 <exit>
    kill(pid1);
     b9c:	8526                	mv	a0,s1
     b9e:	00000097          	auipc	ra,0x0
     ba2:	2e8080e7          	jalr	744(ra) # e86 <kill>
    kill(pid2);
     ba6:	854a                	mv	a0,s2
     ba8:	00000097          	auipc	ra,0x0
     bac:	2de080e7          	jalr	734(ra) # e86 <kill>
     bb0:	bfc1                	j	b80 <iter+0xc4>

0000000000000bb2 <main>:
}

int
main()
{
     bb2:	1141                	addi	sp,sp,-16
     bb4:	e406                	sd	ra,8(sp)
     bb6:	e022                	sd	s0,0(sp)
     bb8:	0800                	addi	s0,sp,16
     bba:	a811                	j	bce <main+0x1c>
  while(1){
    int pid = fork();
    if(pid == 0){
      iter();
     bbc:	00000097          	auipc	ra,0x0
     bc0:	f00080e7          	jalr	-256(ra) # abc <iter>
      exit(0);
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
     bc4:	4551                	li	a0,20
     bc6:	00000097          	auipc	ra,0x0
     bca:	320080e7          	jalr	800(ra) # ee6 <sleep>
    int pid = fork();
     bce:	00000097          	auipc	ra,0x0
     bd2:	280080e7          	jalr	640(ra) # e4e <fork>
    if(pid == 0){
     bd6:	d17d                	beqz	a0,bbc <main+0xa>
    if(pid > 0){
     bd8:	fea056e3          	blez	a0,bc4 <main+0x12>
      wait(0);
     bdc:	4501                	li	a0,0
     bde:	00000097          	auipc	ra,0x0
     be2:	280080e7          	jalr	640(ra) # e5e <wait>
     be6:	bff9                	j	bc4 <main+0x12>

0000000000000be8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     be8:	1141                	addi	sp,sp,-16
     bea:	e422                	sd	s0,8(sp)
     bec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bee:	87aa                	mv	a5,a0
     bf0:	0585                	addi	a1,a1,1
     bf2:	0785                	addi	a5,a5,1
     bf4:	fff5c703          	lbu	a4,-1(a1)
     bf8:	fee78fa3          	sb	a4,-1(a5)
     bfc:	fb75                	bnez	a4,bf0 <strcpy+0x8>
    ;
  return os;
}
     bfe:	6422                	ld	s0,8(sp)
     c00:	0141                	addi	sp,sp,16
     c02:	8082                	ret

0000000000000c04 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c04:	1141                	addi	sp,sp,-16
     c06:	e422                	sd	s0,8(sp)
     c08:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c0a:	00054783          	lbu	a5,0(a0)
     c0e:	cb91                	beqz	a5,c22 <strcmp+0x1e>
     c10:	0005c703          	lbu	a4,0(a1)
     c14:	00f71763          	bne	a4,a5,c22 <strcmp+0x1e>
    p++, q++;
     c18:	0505                	addi	a0,a0,1
     c1a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c1c:	00054783          	lbu	a5,0(a0)
     c20:	fbe5                	bnez	a5,c10 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c22:	0005c503          	lbu	a0,0(a1)
}
     c26:	40a7853b          	subw	a0,a5,a0
     c2a:	6422                	ld	s0,8(sp)
     c2c:	0141                	addi	sp,sp,16
     c2e:	8082                	ret

0000000000000c30 <strlen>:

uint
strlen(const char *s)
{
     c30:	1141                	addi	sp,sp,-16
     c32:	e422                	sd	s0,8(sp)
     c34:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c36:	00054783          	lbu	a5,0(a0)
     c3a:	cf91                	beqz	a5,c56 <strlen+0x26>
     c3c:	0505                	addi	a0,a0,1
     c3e:	87aa                	mv	a5,a0
     c40:	4685                	li	a3,1
     c42:	9e89                	subw	a3,a3,a0
     c44:	00f6853b          	addw	a0,a3,a5
     c48:	0785                	addi	a5,a5,1
     c4a:	fff7c703          	lbu	a4,-1(a5)
     c4e:	fb7d                	bnez	a4,c44 <strlen+0x14>
    ;
  return n;
}
     c50:	6422                	ld	s0,8(sp)
     c52:	0141                	addi	sp,sp,16
     c54:	8082                	ret
  for(n = 0; s[n]; n++)
     c56:	4501                	li	a0,0
     c58:	bfe5                	j	c50 <strlen+0x20>

0000000000000c5a <memset>:

void*
memset(void *dst, int c, uint n)
{
     c5a:	1141                	addi	sp,sp,-16
     c5c:	e422                	sd	s0,8(sp)
     c5e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c60:	ca19                	beqz	a2,c76 <memset+0x1c>
     c62:	87aa                	mv	a5,a0
     c64:	1602                	slli	a2,a2,0x20
     c66:	9201                	srli	a2,a2,0x20
     c68:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c6c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c70:	0785                	addi	a5,a5,1
     c72:	fee79de3          	bne	a5,a4,c6c <memset+0x12>
  }
  return dst;
}
     c76:	6422                	ld	s0,8(sp)
     c78:	0141                	addi	sp,sp,16
     c7a:	8082                	ret

0000000000000c7c <strchr>:

char*
strchr(const char *s, char c)
{
     c7c:	1141                	addi	sp,sp,-16
     c7e:	e422                	sd	s0,8(sp)
     c80:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c82:	00054783          	lbu	a5,0(a0)
     c86:	cb99                	beqz	a5,c9c <strchr+0x20>
    if(*s == c)
     c88:	00f58763          	beq	a1,a5,c96 <strchr+0x1a>
  for(; *s; s++)
     c8c:	0505                	addi	a0,a0,1
     c8e:	00054783          	lbu	a5,0(a0)
     c92:	fbfd                	bnez	a5,c88 <strchr+0xc>
      return (char*)s;
  return 0;
     c94:	4501                	li	a0,0
}
     c96:	6422                	ld	s0,8(sp)
     c98:	0141                	addi	sp,sp,16
     c9a:	8082                	ret
  return 0;
     c9c:	4501                	li	a0,0
     c9e:	bfe5                	j	c96 <strchr+0x1a>

0000000000000ca0 <gets>:

char*
gets(char *buf, int max)
{
     ca0:	711d                	addi	sp,sp,-96
     ca2:	ec86                	sd	ra,88(sp)
     ca4:	e8a2                	sd	s0,80(sp)
     ca6:	e4a6                	sd	s1,72(sp)
     ca8:	e0ca                	sd	s2,64(sp)
     caa:	fc4e                	sd	s3,56(sp)
     cac:	f852                	sd	s4,48(sp)
     cae:	f456                	sd	s5,40(sp)
     cb0:	f05a                	sd	s6,32(sp)
     cb2:	ec5e                	sd	s7,24(sp)
     cb4:	1080                	addi	s0,sp,96
     cb6:	8baa                	mv	s7,a0
     cb8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cba:	892a                	mv	s2,a0
     cbc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     cbe:	4aa9                	li	s5,10
     cc0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     cc2:	89a6                	mv	s3,s1
     cc4:	2485                	addiw	s1,s1,1
     cc6:	0344d863          	bge	s1,s4,cf6 <gets+0x56>
    cc = read(0, &c, 1);
     cca:	4605                	li	a2,1
     ccc:	faf40593          	addi	a1,s0,-81
     cd0:	4501                	li	a0,0
     cd2:	00000097          	auipc	ra,0x0
     cd6:	19c080e7          	jalr	412(ra) # e6e <read>
    if(cc < 1)
     cda:	00a05e63          	blez	a0,cf6 <gets+0x56>
    buf[i++] = c;
     cde:	faf44783          	lbu	a5,-81(s0)
     ce2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     ce6:	01578763          	beq	a5,s5,cf4 <gets+0x54>
     cea:	0905                	addi	s2,s2,1
     cec:	fd679be3          	bne	a5,s6,cc2 <gets+0x22>
  for(i=0; i+1 < max; ){
     cf0:	89a6                	mv	s3,s1
     cf2:	a011                	j	cf6 <gets+0x56>
     cf4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     cf6:	99de                	add	s3,s3,s7
     cf8:	00098023          	sb	zero,0(s3)
  return buf;
}
     cfc:	855e                	mv	a0,s7
     cfe:	60e6                	ld	ra,88(sp)
     d00:	6446                	ld	s0,80(sp)
     d02:	64a6                	ld	s1,72(sp)
     d04:	6906                	ld	s2,64(sp)
     d06:	79e2                	ld	s3,56(sp)
     d08:	7a42                	ld	s4,48(sp)
     d0a:	7aa2                	ld	s5,40(sp)
     d0c:	7b02                	ld	s6,32(sp)
     d0e:	6be2                	ld	s7,24(sp)
     d10:	6125                	addi	sp,sp,96
     d12:	8082                	ret

0000000000000d14 <stat>:

int
stat(const char *n, struct stat *st)
{
     d14:	1101                	addi	sp,sp,-32
     d16:	ec06                	sd	ra,24(sp)
     d18:	e822                	sd	s0,16(sp)
     d1a:	e426                	sd	s1,8(sp)
     d1c:	e04a                	sd	s2,0(sp)
     d1e:	1000                	addi	s0,sp,32
     d20:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d22:	4581                	li	a1,0
     d24:	00000097          	auipc	ra,0x0
     d28:	172080e7          	jalr	370(ra) # e96 <open>
  if(fd < 0)
     d2c:	02054563          	bltz	a0,d56 <stat+0x42>
     d30:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d32:	85ca                	mv	a1,s2
     d34:	00000097          	auipc	ra,0x0
     d38:	17a080e7          	jalr	378(ra) # eae <fstat>
     d3c:	892a                	mv	s2,a0
  close(fd);
     d3e:	8526                	mv	a0,s1
     d40:	00000097          	auipc	ra,0x0
     d44:	13e080e7          	jalr	318(ra) # e7e <close>
  return r;
}
     d48:	854a                	mv	a0,s2
     d4a:	60e2                	ld	ra,24(sp)
     d4c:	6442                	ld	s0,16(sp)
     d4e:	64a2                	ld	s1,8(sp)
     d50:	6902                	ld	s2,0(sp)
     d52:	6105                	addi	sp,sp,32
     d54:	8082                	ret
    return -1;
     d56:	597d                	li	s2,-1
     d58:	bfc5                	j	d48 <stat+0x34>

0000000000000d5a <atoi>:

int
atoi(const char *s)
{
     d5a:	1141                	addi	sp,sp,-16
     d5c:	e422                	sd	s0,8(sp)
     d5e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d60:	00054603          	lbu	a2,0(a0)
     d64:	fd06079b          	addiw	a5,a2,-48
     d68:	0ff7f793          	andi	a5,a5,255
     d6c:	4725                	li	a4,9
     d6e:	02f76963          	bltu	a4,a5,da0 <atoi+0x46>
     d72:	86aa                	mv	a3,a0
  n = 0;
     d74:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     d76:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     d78:	0685                	addi	a3,a3,1
     d7a:	0025179b          	slliw	a5,a0,0x2
     d7e:	9fa9                	addw	a5,a5,a0
     d80:	0017979b          	slliw	a5,a5,0x1
     d84:	9fb1                	addw	a5,a5,a2
     d86:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d8a:	0006c603          	lbu	a2,0(a3)
     d8e:	fd06071b          	addiw	a4,a2,-48
     d92:	0ff77713          	andi	a4,a4,255
     d96:	fee5f1e3          	bgeu	a1,a4,d78 <atoi+0x1e>
  return n;
}
     d9a:	6422                	ld	s0,8(sp)
     d9c:	0141                	addi	sp,sp,16
     d9e:	8082                	ret
  n = 0;
     da0:	4501                	li	a0,0
     da2:	bfe5                	j	d9a <atoi+0x40>

0000000000000da4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     da4:	1141                	addi	sp,sp,-16
     da6:	e422                	sd	s0,8(sp)
     da8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     daa:	02b57463          	bgeu	a0,a1,dd2 <memmove+0x2e>
    while(n-- > 0)
     dae:	00c05f63          	blez	a2,dcc <memmove+0x28>
     db2:	1602                	slli	a2,a2,0x20
     db4:	9201                	srli	a2,a2,0x20
     db6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     dba:	872a                	mv	a4,a0
      *dst++ = *src++;
     dbc:	0585                	addi	a1,a1,1
     dbe:	0705                	addi	a4,a4,1
     dc0:	fff5c683          	lbu	a3,-1(a1)
     dc4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     dc8:	fee79ae3          	bne	a5,a4,dbc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     dcc:	6422                	ld	s0,8(sp)
     dce:	0141                	addi	sp,sp,16
     dd0:	8082                	ret
    dst += n;
     dd2:	00c50733          	add	a4,a0,a2
    src += n;
     dd6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     dd8:	fec05ae3          	blez	a2,dcc <memmove+0x28>
     ddc:	fff6079b          	addiw	a5,a2,-1
     de0:	1782                	slli	a5,a5,0x20
     de2:	9381                	srli	a5,a5,0x20
     de4:	fff7c793          	not	a5,a5
     de8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     dea:	15fd                	addi	a1,a1,-1
     dec:	177d                	addi	a4,a4,-1
     dee:	0005c683          	lbu	a3,0(a1)
     df2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     df6:	fee79ae3          	bne	a5,a4,dea <memmove+0x46>
     dfa:	bfc9                	j	dcc <memmove+0x28>

0000000000000dfc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     dfc:	1141                	addi	sp,sp,-16
     dfe:	e422                	sd	s0,8(sp)
     e00:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e02:	ca05                	beqz	a2,e32 <memcmp+0x36>
     e04:	fff6069b          	addiw	a3,a2,-1
     e08:	1682                	slli	a3,a3,0x20
     e0a:	9281                	srli	a3,a3,0x20
     e0c:	0685                	addi	a3,a3,1
     e0e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e10:	00054783          	lbu	a5,0(a0)
     e14:	0005c703          	lbu	a4,0(a1)
     e18:	00e79863          	bne	a5,a4,e28 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e1c:	0505                	addi	a0,a0,1
    p2++;
     e1e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e20:	fed518e3          	bne	a0,a3,e10 <memcmp+0x14>
  }
  return 0;
     e24:	4501                	li	a0,0
     e26:	a019                	j	e2c <memcmp+0x30>
      return *p1 - *p2;
     e28:	40e7853b          	subw	a0,a5,a4
}
     e2c:	6422                	ld	s0,8(sp)
     e2e:	0141                	addi	sp,sp,16
     e30:	8082                	ret
  return 0;
     e32:	4501                	li	a0,0
     e34:	bfe5                	j	e2c <memcmp+0x30>

0000000000000e36 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e36:	1141                	addi	sp,sp,-16
     e38:	e406                	sd	ra,8(sp)
     e3a:	e022                	sd	s0,0(sp)
     e3c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e3e:	00000097          	auipc	ra,0x0
     e42:	f66080e7          	jalr	-154(ra) # da4 <memmove>
}
     e46:	60a2                	ld	ra,8(sp)
     e48:	6402                	ld	s0,0(sp)
     e4a:	0141                	addi	sp,sp,16
     e4c:	8082                	ret

0000000000000e4e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e4e:	4885                	li	a7,1
 ecall
     e50:	00000073          	ecall
 ret
     e54:	8082                	ret

0000000000000e56 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e56:	4889                	li	a7,2
 ecall
     e58:	00000073          	ecall
 ret
     e5c:	8082                	ret

0000000000000e5e <wait>:
.global wait
wait:
 li a7, SYS_wait
     e5e:	488d                	li	a7,3
 ecall
     e60:	00000073          	ecall
 ret
     e64:	8082                	ret

0000000000000e66 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e66:	4891                	li	a7,4
 ecall
     e68:	00000073          	ecall
 ret
     e6c:	8082                	ret

0000000000000e6e <read>:
.global read
read:
 li a7, SYS_read
     e6e:	4895                	li	a7,5
 ecall
     e70:	00000073          	ecall
 ret
     e74:	8082                	ret

0000000000000e76 <write>:
.global write
write:
 li a7, SYS_write
     e76:	48c1                	li	a7,16
 ecall
     e78:	00000073          	ecall
 ret
     e7c:	8082                	ret

0000000000000e7e <close>:
.global close
close:
 li a7, SYS_close
     e7e:	48d5                	li	a7,21
 ecall
     e80:	00000073          	ecall
 ret
     e84:	8082                	ret

0000000000000e86 <kill>:
.global kill
kill:
 li a7, SYS_kill
     e86:	4899                	li	a7,6
 ecall
     e88:	00000073          	ecall
 ret
     e8c:	8082                	ret

0000000000000e8e <exec>:
.global exec
exec:
 li a7, SYS_exec
     e8e:	489d                	li	a7,7
 ecall
     e90:	00000073          	ecall
 ret
     e94:	8082                	ret

0000000000000e96 <open>:
.global open
open:
 li a7, SYS_open
     e96:	48bd                	li	a7,15
 ecall
     e98:	00000073          	ecall
 ret
     e9c:	8082                	ret

0000000000000e9e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e9e:	48c5                	li	a7,17
 ecall
     ea0:	00000073          	ecall
 ret
     ea4:	8082                	ret

0000000000000ea6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     ea6:	48c9                	li	a7,18
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     eae:	48a1                	li	a7,8
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <link>:
.global link
link:
 li a7, SYS_link
     eb6:	48cd                	li	a7,19
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     ebe:	48d1                	li	a7,20
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     ec6:	48a5                	li	a7,9
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

0000000000000ece <dup>:
.global dup
dup:
 li a7, SYS_dup
     ece:	48a9                	li	a7,10
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ed6:	48ad                	li	a7,11
 ecall
     ed8:	00000073          	ecall
 ret
     edc:	8082                	ret

0000000000000ede <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     ede:	48b1                	li	a7,12
 ecall
     ee0:	00000073          	ecall
 ret
     ee4:	8082                	ret

0000000000000ee6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ee6:	48b5                	li	a7,13
 ecall
     ee8:	00000073          	ecall
 ret
     eec:	8082                	ret

0000000000000eee <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     eee:	48b9                	li	a7,14
 ecall
     ef0:	00000073          	ecall
 ret
     ef4:	8082                	ret

0000000000000ef6 <trace>:
.global trace
trace:
 li a7, SYS_trace
     ef6:	48d9                	li	a7,22
 ecall
     ef8:	00000073          	ecall
 ret
     efc:	8082                	ret

0000000000000efe <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
     efe:	48dd                	li	a7,23
 ecall
     f00:	00000073          	ecall
 ret
     f04:	8082                	ret

0000000000000f06 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
     f06:	48e1                	li	a7,24
 ecall
     f08:	00000073          	ecall
 ret
     f0c:	8082                	ret

0000000000000f0e <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
     f0e:	48e5                	li	a7,25
 ecall
     f10:	00000073          	ecall
 ret
     f14:	8082                	ret

0000000000000f16 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f16:	1101                	addi	sp,sp,-32
     f18:	ec06                	sd	ra,24(sp)
     f1a:	e822                	sd	s0,16(sp)
     f1c:	1000                	addi	s0,sp,32
     f1e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f22:	4605                	li	a2,1
     f24:	fef40593          	addi	a1,s0,-17
     f28:	00000097          	auipc	ra,0x0
     f2c:	f4e080e7          	jalr	-178(ra) # e76 <write>
}
     f30:	60e2                	ld	ra,24(sp)
     f32:	6442                	ld	s0,16(sp)
     f34:	6105                	addi	sp,sp,32
     f36:	8082                	ret

0000000000000f38 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f38:	7139                	addi	sp,sp,-64
     f3a:	fc06                	sd	ra,56(sp)
     f3c:	f822                	sd	s0,48(sp)
     f3e:	f426                	sd	s1,40(sp)
     f40:	f04a                	sd	s2,32(sp)
     f42:	ec4e                	sd	s3,24(sp)
     f44:	0080                	addi	s0,sp,64
     f46:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f48:	c299                	beqz	a3,f4e <printint+0x16>
     f4a:	0805c863          	bltz	a1,fda <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f4e:	2581                	sext.w	a1,a1
  neg = 0;
     f50:	4881                	li	a7,0
     f52:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f56:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f58:	2601                	sext.w	a2,a2
     f5a:	00000517          	auipc	a0,0x0
     f5e:	70650513          	addi	a0,a0,1798 # 1660 <digits>
     f62:	883a                	mv	a6,a4
     f64:	2705                	addiw	a4,a4,1
     f66:	02c5f7bb          	remuw	a5,a1,a2
     f6a:	1782                	slli	a5,a5,0x20
     f6c:	9381                	srli	a5,a5,0x20
     f6e:	97aa                	add	a5,a5,a0
     f70:	0007c783          	lbu	a5,0(a5)
     f74:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f78:	0005879b          	sext.w	a5,a1
     f7c:	02c5d5bb          	divuw	a1,a1,a2
     f80:	0685                	addi	a3,a3,1
     f82:	fec7f0e3          	bgeu	a5,a2,f62 <printint+0x2a>
  if(neg)
     f86:	00088b63          	beqz	a7,f9c <printint+0x64>
    buf[i++] = '-';
     f8a:	fd040793          	addi	a5,s0,-48
     f8e:	973e                	add	a4,a4,a5
     f90:	02d00793          	li	a5,45
     f94:	fef70823          	sb	a5,-16(a4)
     f98:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     f9c:	02e05863          	blez	a4,fcc <printint+0x94>
     fa0:	fc040793          	addi	a5,s0,-64
     fa4:	00e78933          	add	s2,a5,a4
     fa8:	fff78993          	addi	s3,a5,-1
     fac:	99ba                	add	s3,s3,a4
     fae:	377d                	addiw	a4,a4,-1
     fb0:	1702                	slli	a4,a4,0x20
     fb2:	9301                	srli	a4,a4,0x20
     fb4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     fb8:	fff94583          	lbu	a1,-1(s2)
     fbc:	8526                	mv	a0,s1
     fbe:	00000097          	auipc	ra,0x0
     fc2:	f58080e7          	jalr	-168(ra) # f16 <putc>
  while(--i >= 0)
     fc6:	197d                	addi	s2,s2,-1
     fc8:	ff3918e3          	bne	s2,s3,fb8 <printint+0x80>
}
     fcc:	70e2                	ld	ra,56(sp)
     fce:	7442                	ld	s0,48(sp)
     fd0:	74a2                	ld	s1,40(sp)
     fd2:	7902                	ld	s2,32(sp)
     fd4:	69e2                	ld	s3,24(sp)
     fd6:	6121                	addi	sp,sp,64
     fd8:	8082                	ret
    x = -xx;
     fda:	40b005bb          	negw	a1,a1
    neg = 1;
     fde:	4885                	li	a7,1
    x = -xx;
     fe0:	bf8d                	j	f52 <printint+0x1a>

0000000000000fe2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fe2:	7119                	addi	sp,sp,-128
     fe4:	fc86                	sd	ra,120(sp)
     fe6:	f8a2                	sd	s0,112(sp)
     fe8:	f4a6                	sd	s1,104(sp)
     fea:	f0ca                	sd	s2,96(sp)
     fec:	ecce                	sd	s3,88(sp)
     fee:	e8d2                	sd	s4,80(sp)
     ff0:	e4d6                	sd	s5,72(sp)
     ff2:	e0da                	sd	s6,64(sp)
     ff4:	fc5e                	sd	s7,56(sp)
     ff6:	f862                	sd	s8,48(sp)
     ff8:	f466                	sd	s9,40(sp)
     ffa:	f06a                	sd	s10,32(sp)
     ffc:	ec6e                	sd	s11,24(sp)
     ffe:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1000:	0005c903          	lbu	s2,0(a1)
    1004:	18090f63          	beqz	s2,11a2 <vprintf+0x1c0>
    1008:	8aaa                	mv	s5,a0
    100a:	8b32                	mv	s6,a2
    100c:	00158493          	addi	s1,a1,1
  state = 0;
    1010:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1012:	02500a13          	li	s4,37
      if(c == 'd'){
    1016:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    101a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    101e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    1022:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1026:	00000b97          	auipc	s7,0x0
    102a:	63ab8b93          	addi	s7,s7,1594 # 1660 <digits>
    102e:	a839                	j	104c <vprintf+0x6a>
        putc(fd, c);
    1030:	85ca                	mv	a1,s2
    1032:	8556                	mv	a0,s5
    1034:	00000097          	auipc	ra,0x0
    1038:	ee2080e7          	jalr	-286(ra) # f16 <putc>
    103c:	a019                	j	1042 <vprintf+0x60>
    } else if(state == '%'){
    103e:	01498f63          	beq	s3,s4,105c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    1042:	0485                	addi	s1,s1,1
    1044:	fff4c903          	lbu	s2,-1(s1)
    1048:	14090d63          	beqz	s2,11a2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    104c:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1050:	fe0997e3          	bnez	s3,103e <vprintf+0x5c>
      if(c == '%'){
    1054:	fd479ee3          	bne	a5,s4,1030 <vprintf+0x4e>
        state = '%';
    1058:	89be                	mv	s3,a5
    105a:	b7e5                	j	1042 <vprintf+0x60>
      if(c == 'd'){
    105c:	05878063          	beq	a5,s8,109c <vprintf+0xba>
      } else if(c == 'l') {
    1060:	05978c63          	beq	a5,s9,10b8 <vprintf+0xd6>
      } else if(c == 'x') {
    1064:	07a78863          	beq	a5,s10,10d4 <vprintf+0xf2>
      } else if(c == 'p') {
    1068:	09b78463          	beq	a5,s11,10f0 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    106c:	07300713          	li	a4,115
    1070:	0ce78663          	beq	a5,a4,113c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1074:	06300713          	li	a4,99
    1078:	0ee78e63          	beq	a5,a4,1174 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    107c:	11478863          	beq	a5,s4,118c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1080:	85d2                	mv	a1,s4
    1082:	8556                	mv	a0,s5
    1084:	00000097          	auipc	ra,0x0
    1088:	e92080e7          	jalr	-366(ra) # f16 <putc>
        putc(fd, c);
    108c:	85ca                	mv	a1,s2
    108e:	8556                	mv	a0,s5
    1090:	00000097          	auipc	ra,0x0
    1094:	e86080e7          	jalr	-378(ra) # f16 <putc>
      }
      state = 0;
    1098:	4981                	li	s3,0
    109a:	b765                	j	1042 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    109c:	008b0913          	addi	s2,s6,8
    10a0:	4685                	li	a3,1
    10a2:	4629                	li	a2,10
    10a4:	000b2583          	lw	a1,0(s6)
    10a8:	8556                	mv	a0,s5
    10aa:	00000097          	auipc	ra,0x0
    10ae:	e8e080e7          	jalr	-370(ra) # f38 <printint>
    10b2:	8b4a                	mv	s6,s2
      state = 0;
    10b4:	4981                	li	s3,0
    10b6:	b771                	j	1042 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10b8:	008b0913          	addi	s2,s6,8
    10bc:	4681                	li	a3,0
    10be:	4629                	li	a2,10
    10c0:	000b2583          	lw	a1,0(s6)
    10c4:	8556                	mv	a0,s5
    10c6:	00000097          	auipc	ra,0x0
    10ca:	e72080e7          	jalr	-398(ra) # f38 <printint>
    10ce:	8b4a                	mv	s6,s2
      state = 0;
    10d0:	4981                	li	s3,0
    10d2:	bf85                	j	1042 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    10d4:	008b0913          	addi	s2,s6,8
    10d8:	4681                	li	a3,0
    10da:	4641                	li	a2,16
    10dc:	000b2583          	lw	a1,0(s6)
    10e0:	8556                	mv	a0,s5
    10e2:	00000097          	auipc	ra,0x0
    10e6:	e56080e7          	jalr	-426(ra) # f38 <printint>
    10ea:	8b4a                	mv	s6,s2
      state = 0;
    10ec:	4981                	li	s3,0
    10ee:	bf91                	j	1042 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    10f0:	008b0793          	addi	a5,s6,8
    10f4:	f8f43423          	sd	a5,-120(s0)
    10f8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    10fc:	03000593          	li	a1,48
    1100:	8556                	mv	a0,s5
    1102:	00000097          	auipc	ra,0x0
    1106:	e14080e7          	jalr	-492(ra) # f16 <putc>
  putc(fd, 'x');
    110a:	85ea                	mv	a1,s10
    110c:	8556                	mv	a0,s5
    110e:	00000097          	auipc	ra,0x0
    1112:	e08080e7          	jalr	-504(ra) # f16 <putc>
    1116:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1118:	03c9d793          	srli	a5,s3,0x3c
    111c:	97de                	add	a5,a5,s7
    111e:	0007c583          	lbu	a1,0(a5)
    1122:	8556                	mv	a0,s5
    1124:	00000097          	auipc	ra,0x0
    1128:	df2080e7          	jalr	-526(ra) # f16 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    112c:	0992                	slli	s3,s3,0x4
    112e:	397d                	addiw	s2,s2,-1
    1130:	fe0914e3          	bnez	s2,1118 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    1134:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1138:	4981                	li	s3,0
    113a:	b721                	j	1042 <vprintf+0x60>
        s = va_arg(ap, char*);
    113c:	008b0993          	addi	s3,s6,8
    1140:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    1144:	02090163          	beqz	s2,1166 <vprintf+0x184>
        while(*s != 0){
    1148:	00094583          	lbu	a1,0(s2)
    114c:	c9a1                	beqz	a1,119c <vprintf+0x1ba>
          putc(fd, *s);
    114e:	8556                	mv	a0,s5
    1150:	00000097          	auipc	ra,0x0
    1154:	dc6080e7          	jalr	-570(ra) # f16 <putc>
          s++;
    1158:	0905                	addi	s2,s2,1
        while(*s != 0){
    115a:	00094583          	lbu	a1,0(s2)
    115e:	f9e5                	bnez	a1,114e <vprintf+0x16c>
        s = va_arg(ap, char*);
    1160:	8b4e                	mv	s6,s3
      state = 0;
    1162:	4981                	li	s3,0
    1164:	bdf9                	j	1042 <vprintf+0x60>
          s = "(null)";
    1166:	00000917          	auipc	s2,0x0
    116a:	4f290913          	addi	s2,s2,1266 # 1658 <malloc+0x3ac>
        while(*s != 0){
    116e:	02800593          	li	a1,40
    1172:	bff1                	j	114e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    1174:	008b0913          	addi	s2,s6,8
    1178:	000b4583          	lbu	a1,0(s6)
    117c:	8556                	mv	a0,s5
    117e:	00000097          	auipc	ra,0x0
    1182:	d98080e7          	jalr	-616(ra) # f16 <putc>
    1186:	8b4a                	mv	s6,s2
      state = 0;
    1188:	4981                	li	s3,0
    118a:	bd65                	j	1042 <vprintf+0x60>
        putc(fd, c);
    118c:	85d2                	mv	a1,s4
    118e:	8556                	mv	a0,s5
    1190:	00000097          	auipc	ra,0x0
    1194:	d86080e7          	jalr	-634(ra) # f16 <putc>
      state = 0;
    1198:	4981                	li	s3,0
    119a:	b565                	j	1042 <vprintf+0x60>
        s = va_arg(ap, char*);
    119c:	8b4e                	mv	s6,s3
      state = 0;
    119e:	4981                	li	s3,0
    11a0:	b54d                	j	1042 <vprintf+0x60>
    }
  }
}
    11a2:	70e6                	ld	ra,120(sp)
    11a4:	7446                	ld	s0,112(sp)
    11a6:	74a6                	ld	s1,104(sp)
    11a8:	7906                	ld	s2,96(sp)
    11aa:	69e6                	ld	s3,88(sp)
    11ac:	6a46                	ld	s4,80(sp)
    11ae:	6aa6                	ld	s5,72(sp)
    11b0:	6b06                	ld	s6,64(sp)
    11b2:	7be2                	ld	s7,56(sp)
    11b4:	7c42                	ld	s8,48(sp)
    11b6:	7ca2                	ld	s9,40(sp)
    11b8:	7d02                	ld	s10,32(sp)
    11ba:	6de2                	ld	s11,24(sp)
    11bc:	6109                	addi	sp,sp,128
    11be:	8082                	ret

00000000000011c0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    11c0:	715d                	addi	sp,sp,-80
    11c2:	ec06                	sd	ra,24(sp)
    11c4:	e822                	sd	s0,16(sp)
    11c6:	1000                	addi	s0,sp,32
    11c8:	e010                	sd	a2,0(s0)
    11ca:	e414                	sd	a3,8(s0)
    11cc:	e818                	sd	a4,16(s0)
    11ce:	ec1c                	sd	a5,24(s0)
    11d0:	03043023          	sd	a6,32(s0)
    11d4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    11d8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    11dc:	8622                	mv	a2,s0
    11de:	00000097          	auipc	ra,0x0
    11e2:	e04080e7          	jalr	-508(ra) # fe2 <vprintf>
}
    11e6:	60e2                	ld	ra,24(sp)
    11e8:	6442                	ld	s0,16(sp)
    11ea:	6161                	addi	sp,sp,80
    11ec:	8082                	ret

00000000000011ee <printf>:

void
printf(const char *fmt, ...)
{
    11ee:	711d                	addi	sp,sp,-96
    11f0:	ec06                	sd	ra,24(sp)
    11f2:	e822                	sd	s0,16(sp)
    11f4:	1000                	addi	s0,sp,32
    11f6:	e40c                	sd	a1,8(s0)
    11f8:	e810                	sd	a2,16(s0)
    11fa:	ec14                	sd	a3,24(s0)
    11fc:	f018                	sd	a4,32(s0)
    11fe:	f41c                	sd	a5,40(s0)
    1200:	03043823          	sd	a6,48(s0)
    1204:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1208:	00840613          	addi	a2,s0,8
    120c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1210:	85aa                	mv	a1,a0
    1212:	4505                	li	a0,1
    1214:	00000097          	auipc	ra,0x0
    1218:	dce080e7          	jalr	-562(ra) # fe2 <vprintf>
}
    121c:	60e2                	ld	ra,24(sp)
    121e:	6442                	ld	s0,16(sp)
    1220:	6125                	addi	sp,sp,96
    1222:	8082                	ret

0000000000001224 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1224:	1141                	addi	sp,sp,-16
    1226:	e422                	sd	s0,8(sp)
    1228:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    122a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    122e:	00000797          	auipc	a5,0x0
    1232:	4527b783          	ld	a5,1106(a5) # 1680 <freep>
    1236:	a805                	j	1266 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1238:	4618                	lw	a4,8(a2)
    123a:	9db9                	addw	a1,a1,a4
    123c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1240:	6398                	ld	a4,0(a5)
    1242:	6318                	ld	a4,0(a4)
    1244:	fee53823          	sd	a4,-16(a0)
    1248:	a091                	j	128c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    124a:	ff852703          	lw	a4,-8(a0)
    124e:	9e39                	addw	a2,a2,a4
    1250:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    1252:	ff053703          	ld	a4,-16(a0)
    1256:	e398                	sd	a4,0(a5)
    1258:	a099                	j	129e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    125a:	6398                	ld	a4,0(a5)
    125c:	00e7e463          	bltu	a5,a4,1264 <free+0x40>
    1260:	00e6ea63          	bltu	a3,a4,1274 <free+0x50>
{
    1264:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1266:	fed7fae3          	bgeu	a5,a3,125a <free+0x36>
    126a:	6398                	ld	a4,0(a5)
    126c:	00e6e463          	bltu	a3,a4,1274 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1270:	fee7eae3          	bltu	a5,a4,1264 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1274:	ff852583          	lw	a1,-8(a0)
    1278:	6390                	ld	a2,0(a5)
    127a:	02059713          	slli	a4,a1,0x20
    127e:	9301                	srli	a4,a4,0x20
    1280:	0712                	slli	a4,a4,0x4
    1282:	9736                	add	a4,a4,a3
    1284:	fae60ae3          	beq	a2,a4,1238 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1288:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    128c:	4790                	lw	a2,8(a5)
    128e:	02061713          	slli	a4,a2,0x20
    1292:	9301                	srli	a4,a4,0x20
    1294:	0712                	slli	a4,a4,0x4
    1296:	973e                	add	a4,a4,a5
    1298:	fae689e3          	beq	a3,a4,124a <free+0x26>
  } else
    p->s.ptr = bp;
    129c:	e394                	sd	a3,0(a5)
  freep = p;
    129e:	00000717          	auipc	a4,0x0
    12a2:	3ef73123          	sd	a5,994(a4) # 1680 <freep>
}
    12a6:	6422                	ld	s0,8(sp)
    12a8:	0141                	addi	sp,sp,16
    12aa:	8082                	ret

00000000000012ac <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12ac:	7139                	addi	sp,sp,-64
    12ae:	fc06                	sd	ra,56(sp)
    12b0:	f822                	sd	s0,48(sp)
    12b2:	f426                	sd	s1,40(sp)
    12b4:	f04a                	sd	s2,32(sp)
    12b6:	ec4e                	sd	s3,24(sp)
    12b8:	e852                	sd	s4,16(sp)
    12ba:	e456                	sd	s5,8(sp)
    12bc:	e05a                	sd	s6,0(sp)
    12be:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    12c0:	02051493          	slli	s1,a0,0x20
    12c4:	9081                	srli	s1,s1,0x20
    12c6:	04bd                	addi	s1,s1,15
    12c8:	8091                	srli	s1,s1,0x4
    12ca:	0014899b          	addiw	s3,s1,1
    12ce:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    12d0:	00000517          	auipc	a0,0x0
    12d4:	3b053503          	ld	a0,944(a0) # 1680 <freep>
    12d8:	c515                	beqz	a0,1304 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12dc:	4798                	lw	a4,8(a5)
    12de:	02977f63          	bgeu	a4,s1,131c <malloc+0x70>
    12e2:	8a4e                	mv	s4,s3
    12e4:	0009871b          	sext.w	a4,s3
    12e8:	6685                	lui	a3,0x1
    12ea:	00d77363          	bgeu	a4,a3,12f0 <malloc+0x44>
    12ee:	6a05                	lui	s4,0x1
    12f0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    12f4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    12f8:	00000917          	auipc	s2,0x0
    12fc:	38890913          	addi	s2,s2,904 # 1680 <freep>
  if(p == (char*)-1)
    1300:	5afd                	li	s5,-1
    1302:	a88d                	j	1374 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    1304:	00000797          	auipc	a5,0x0
    1308:	76c78793          	addi	a5,a5,1900 # 1a70 <base>
    130c:	00000717          	auipc	a4,0x0
    1310:	36f73a23          	sd	a5,884(a4) # 1680 <freep>
    1314:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1316:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    131a:	b7e1                	j	12e2 <malloc+0x36>
      if(p->s.size == nunits)
    131c:	02e48b63          	beq	s1,a4,1352 <malloc+0xa6>
        p->s.size -= nunits;
    1320:	4137073b          	subw	a4,a4,s3
    1324:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1326:	1702                	slli	a4,a4,0x20
    1328:	9301                	srli	a4,a4,0x20
    132a:	0712                	slli	a4,a4,0x4
    132c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    132e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1332:	00000717          	auipc	a4,0x0
    1336:	34a73723          	sd	a0,846(a4) # 1680 <freep>
      return (void*)(p + 1);
    133a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    133e:	70e2                	ld	ra,56(sp)
    1340:	7442                	ld	s0,48(sp)
    1342:	74a2                	ld	s1,40(sp)
    1344:	7902                	ld	s2,32(sp)
    1346:	69e2                	ld	s3,24(sp)
    1348:	6a42                	ld	s4,16(sp)
    134a:	6aa2                	ld	s5,8(sp)
    134c:	6b02                	ld	s6,0(sp)
    134e:	6121                	addi	sp,sp,64
    1350:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1352:	6398                	ld	a4,0(a5)
    1354:	e118                	sd	a4,0(a0)
    1356:	bff1                	j	1332 <malloc+0x86>
  hp->s.size = nu;
    1358:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    135c:	0541                	addi	a0,a0,16
    135e:	00000097          	auipc	ra,0x0
    1362:	ec6080e7          	jalr	-314(ra) # 1224 <free>
  return freep;
    1366:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    136a:	d971                	beqz	a0,133e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    136c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    136e:	4798                	lw	a4,8(a5)
    1370:	fa9776e3          	bgeu	a4,s1,131c <malloc+0x70>
    if(p == freep)
    1374:	00093703          	ld	a4,0(s2)
    1378:	853e                	mv	a0,a5
    137a:	fef719e3          	bne	a4,a5,136c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    137e:	8552                	mv	a0,s4
    1380:	00000097          	auipc	ra,0x0
    1384:	b5e080e7          	jalr	-1186(ra) # ede <sbrk>
  if(p == (char*)-1)
    1388:	fd5518e3          	bne	a0,s5,1358 <malloc+0xac>
        return 0;
    138c:	4501                	li	a0,0
    138e:	bf45                	j	133e <malloc+0x92>
