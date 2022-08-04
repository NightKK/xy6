
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00005097          	auipc	ra,0x5
      14:	4f6080e7          	jalr	1270(ra) # 5506 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	4e4080e7          	jalr	1252(ra) # 5506 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	cb250513          	addi	a0,a0,-846 # 5cf0 <malloc+0x3f4>
      46:	00005097          	auipc	ra,0x5
      4a:	7f8080e7          	jalr	2040(ra) # 583e <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	476080e7          	jalr	1142(ra) # 54c6 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	1b878793          	addi	a5,a5,440 # 9210 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	8c068693          	addi	a3,a3,-1856 # b920 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	c9050513          	addi	a0,a0,-880 # 5d10 <malloc+0x414>
      88:	00005097          	auipc	ra,0x5
      8c:	7b6080e7          	jalr	1974(ra) # 583e <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	434080e7          	jalr	1076(ra) # 54c6 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	c8050513          	addi	a0,a0,-896 # 5d28 <malloc+0x42c>
      b0:	00005097          	auipc	ra,0x5
      b4:	456080e7          	jalr	1110(ra) # 5506 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	432080e7          	jalr	1074(ra) # 54ee <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	c8250513          	addi	a0,a0,-894 # 5d48 <malloc+0x44c>
      ce:	00005097          	auipc	ra,0x5
      d2:	438080e7          	jalr	1080(ra) # 5506 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	c4a50513          	addi	a0,a0,-950 # 5d30 <malloc+0x434>
      ee:	00005097          	auipc	ra,0x5
      f2:	750080e7          	jalr	1872(ra) # 583e <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	3ce080e7          	jalr	974(ra) # 54c6 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	c5650513          	addi	a0,a0,-938 # 5d58 <malloc+0x45c>
     10a:	00005097          	auipc	ra,0x5
     10e:	734080e7          	jalr	1844(ra) # 583e <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	3b2080e7          	jalr	946(ra) # 54c6 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	c5450513          	addi	a0,a0,-940 # 5d80 <malloc+0x484>
     134:	00005097          	auipc	ra,0x5
     138:	3e2080e7          	jalr	994(ra) # 5516 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	c4050513          	addi	a0,a0,-960 # 5d80 <malloc+0x484>
     148:	00005097          	auipc	ra,0x5
     14c:	3be080e7          	jalr	958(ra) # 5506 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	c3c58593          	addi	a1,a1,-964 # 5d90 <malloc+0x494>
     15c:	00005097          	auipc	ra,0x5
     160:	38a080e7          	jalr	906(ra) # 54e6 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	c1850513          	addi	a0,a0,-1000 # 5d80 <malloc+0x484>
     170:	00005097          	auipc	ra,0x5
     174:	396080e7          	jalr	918(ra) # 5506 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	c1c58593          	addi	a1,a1,-996 # 5d98 <malloc+0x49c>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	360080e7          	jalr	864(ra) # 54e6 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	bec50513          	addi	a0,a0,-1044 # 5d80 <malloc+0x484>
     19c:	00005097          	auipc	ra,0x5
     1a0:	37a080e7          	jalr	890(ra) # 5516 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	348080e7          	jalr	840(ra) # 54ee <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	33e080e7          	jalr	830(ra) # 54ee <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	bd650513          	addi	a0,a0,-1066 # 5da0 <malloc+0x4a4>
     1d2:	00005097          	auipc	ra,0x5
     1d6:	66c080e7          	jalr	1644(ra) # 583e <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	2ea080e7          	jalr	746(ra) # 54c6 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	e44e                	sd	s3,8(sp)
     1f0:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f2:	00008797          	auipc	a5,0x8
     1f6:	f0678793          	addi	a5,a5,-250 # 80f8 <name>
     1fa:	06100713          	li	a4,97
     1fe:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     202:	00078123          	sb	zero,2(a5)
     206:	03000493          	li	s1,48
    name[1] = '0' + i;
     20a:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     20c:	06400993          	li	s3,100
    name[1] = '0' + i;
     210:	009900a3          	sb	s1,1(s2)
    fd = open(name, O_CREATE|O_RDWR);
     214:	20200593          	li	a1,514
     218:	854a                	mv	a0,s2
     21a:	00005097          	auipc	ra,0x5
     21e:	2ec080e7          	jalr	748(ra) # 5506 <open>
    close(fd);
     222:	00005097          	auipc	ra,0x5
     226:	2cc080e7          	jalr	716(ra) # 54ee <close>
  for(i = 0; i < N; i++){
     22a:	2485                	addiw	s1,s1,1
     22c:	0ff4f493          	andi	s1,s1,255
     230:	ff3490e3          	bne	s1,s3,210 <createtest+0x2c>
  name[0] = 'a';
     234:	00008797          	auipc	a5,0x8
     238:	ec478793          	addi	a5,a5,-316 # 80f8 <name>
     23c:	06100713          	li	a4,97
     240:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     244:	00078123          	sb	zero,2(a5)
     248:	03000493          	li	s1,48
    name[1] = '0' + i;
     24c:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     24e:	06400993          	li	s3,100
    name[1] = '0' + i;
     252:	009900a3          	sb	s1,1(s2)
    unlink(name);
     256:	854a                	mv	a0,s2
     258:	00005097          	auipc	ra,0x5
     25c:	2be080e7          	jalr	702(ra) # 5516 <unlink>
  for(i = 0; i < N; i++){
     260:	2485                	addiw	s1,s1,1
     262:	0ff4f493          	andi	s1,s1,255
     266:	ff3496e3          	bne	s1,s3,252 <createtest+0x6e>
}
     26a:	70a2                	ld	ra,40(sp)
     26c:	7402                	ld	s0,32(sp)
     26e:	64e2                	ld	s1,24(sp)
     270:	6942                	ld	s2,16(sp)
     272:	69a2                	ld	s3,8(sp)
     274:	6145                	addi	sp,sp,48
     276:	8082                	ret

0000000000000278 <bigwrite>:
{
     278:	715d                	addi	sp,sp,-80
     27a:	e486                	sd	ra,72(sp)
     27c:	e0a2                	sd	s0,64(sp)
     27e:	fc26                	sd	s1,56(sp)
     280:	f84a                	sd	s2,48(sp)
     282:	f44e                	sd	s3,40(sp)
     284:	f052                	sd	s4,32(sp)
     286:	ec56                	sd	s5,24(sp)
     288:	e85a                	sd	s6,16(sp)
     28a:	e45e                	sd	s7,8(sp)
     28c:	0880                	addi	s0,sp,80
     28e:	8baa                	mv	s7,a0
  unlink("bigwrite");
     290:	00006517          	auipc	a0,0x6
     294:	91050513          	addi	a0,a0,-1776 # 5ba0 <malloc+0x2a4>
     298:	00005097          	auipc	ra,0x5
     29c:	27e080e7          	jalr	638(ra) # 5516 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a4:	00006a97          	auipc	s5,0x6
     2a8:	8fca8a93          	addi	s5,s5,-1796 # 5ba0 <malloc+0x2a4>
      int cc = write(fd, buf, sz);
     2ac:	0000ba17          	auipc	s4,0xb
     2b0:	674a0a13          	addi	s4,s4,1652 # b920 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2b4:	6b0d                	lui	s6,0x3
     2b6:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x2a9>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2ba:	20200593          	li	a1,514
     2be:	8556                	mv	a0,s5
     2c0:	00005097          	auipc	ra,0x5
     2c4:	246080e7          	jalr	582(ra) # 5506 <open>
     2c8:	892a                	mv	s2,a0
    if(fd < 0){
     2ca:	04054d63          	bltz	a0,324 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ce:	8626                	mv	a2,s1
     2d0:	85d2                	mv	a1,s4
     2d2:	00005097          	auipc	ra,0x5
     2d6:	214080e7          	jalr	532(ra) # 54e6 <write>
     2da:	89aa                	mv	s3,a0
      if(cc != sz){
     2dc:	06a49463          	bne	s1,a0,344 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2e0:	8626                	mv	a2,s1
     2e2:	85d2                	mv	a1,s4
     2e4:	854a                	mv	a0,s2
     2e6:	00005097          	auipc	ra,0x5
     2ea:	200080e7          	jalr	512(ra) # 54e6 <write>
      if(cc != sz){
     2ee:	04951963          	bne	a0,s1,340 <bigwrite+0xc8>
    close(fd);
     2f2:	854a                	mv	a0,s2
     2f4:	00005097          	auipc	ra,0x5
     2f8:	1fa080e7          	jalr	506(ra) # 54ee <close>
    unlink("bigwrite");
     2fc:	8556                	mv	a0,s5
     2fe:	00005097          	auipc	ra,0x5
     302:	218080e7          	jalr	536(ra) # 5516 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     306:	1d74849b          	addiw	s1,s1,471
     30a:	fb6498e3          	bne	s1,s6,2ba <bigwrite+0x42>
}
     30e:	60a6                	ld	ra,72(sp)
     310:	6406                	ld	s0,64(sp)
     312:	74e2                	ld	s1,56(sp)
     314:	7942                	ld	s2,48(sp)
     316:	79a2                	ld	s3,40(sp)
     318:	7a02                	ld	s4,32(sp)
     31a:	6ae2                	ld	s5,24(sp)
     31c:	6b42                	ld	s6,16(sp)
     31e:	6ba2                	ld	s7,8(sp)
     320:	6161                	addi	sp,sp,80
     322:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     324:	85de                	mv	a1,s7
     326:	00006517          	auipc	a0,0x6
     32a:	aa250513          	addi	a0,a0,-1374 # 5dc8 <malloc+0x4cc>
     32e:	00005097          	auipc	ra,0x5
     332:	510080e7          	jalr	1296(ra) # 583e <printf>
      exit(1);
     336:	4505                	li	a0,1
     338:	00005097          	auipc	ra,0x5
     33c:	18e080e7          	jalr	398(ra) # 54c6 <exit>
     340:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     342:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     344:	86ce                	mv	a3,s3
     346:	8626                	mv	a2,s1
     348:	85de                	mv	a1,s7
     34a:	00006517          	auipc	a0,0x6
     34e:	a9e50513          	addi	a0,a0,-1378 # 5de8 <malloc+0x4ec>
     352:	00005097          	auipc	ra,0x5
     356:	4ec080e7          	jalr	1260(ra) # 583e <printf>
        exit(1);
     35a:	4505                	li	a0,1
     35c:	00005097          	auipc	ra,0x5
     360:	16a080e7          	jalr	362(ra) # 54c6 <exit>

0000000000000364 <copyin>:
{
     364:	715d                	addi	sp,sp,-80
     366:	e486                	sd	ra,72(sp)
     368:	e0a2                	sd	s0,64(sp)
     36a:	fc26                	sd	s1,56(sp)
     36c:	f84a                	sd	s2,48(sp)
     36e:	f44e                	sd	s3,40(sp)
     370:	f052                	sd	s4,32(sp)
     372:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     374:	4785                	li	a5,1
     376:	07fe                	slli	a5,a5,0x1f
     378:	fcf43023          	sd	a5,-64(s0)
     37c:	57fd                	li	a5,-1
     37e:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     382:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     386:	00006a17          	auipc	s4,0x6
     38a:	a7aa0a13          	addi	s4,s4,-1414 # 5e00 <malloc+0x504>
    uint64 addr = addrs[ai];
     38e:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     392:	20100593          	li	a1,513
     396:	8552                	mv	a0,s4
     398:	00005097          	auipc	ra,0x5
     39c:	16e080e7          	jalr	366(ra) # 5506 <open>
     3a0:	84aa                	mv	s1,a0
    if(fd < 0){
     3a2:	08054863          	bltz	a0,432 <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     3a6:	6609                	lui	a2,0x2
     3a8:	85ce                	mv	a1,s3
     3aa:	00005097          	auipc	ra,0x5
     3ae:	13c080e7          	jalr	316(ra) # 54e6 <write>
    if(n >= 0){
     3b2:	08055d63          	bgez	a0,44c <copyin+0xe8>
    close(fd);
     3b6:	8526                	mv	a0,s1
     3b8:	00005097          	auipc	ra,0x5
     3bc:	136080e7          	jalr	310(ra) # 54ee <close>
    unlink("copyin1");
     3c0:	8552                	mv	a0,s4
     3c2:	00005097          	auipc	ra,0x5
     3c6:	154080e7          	jalr	340(ra) # 5516 <unlink>
    n = write(1, (char*)addr, 8192);
     3ca:	6609                	lui	a2,0x2
     3cc:	85ce                	mv	a1,s3
     3ce:	4505                	li	a0,1
     3d0:	00005097          	auipc	ra,0x5
     3d4:	116080e7          	jalr	278(ra) # 54e6 <write>
    if(n > 0){
     3d8:	08a04963          	bgtz	a0,46a <copyin+0x106>
    if(pipe(fds) < 0){
     3dc:	fb840513          	addi	a0,s0,-72
     3e0:	00005097          	auipc	ra,0x5
     3e4:	0f6080e7          	jalr	246(ra) # 54d6 <pipe>
     3e8:	0a054063          	bltz	a0,488 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3ec:	6609                	lui	a2,0x2
     3ee:	85ce                	mv	a1,s3
     3f0:	fbc42503          	lw	a0,-68(s0)
     3f4:	00005097          	auipc	ra,0x5
     3f8:	0f2080e7          	jalr	242(ra) # 54e6 <write>
    if(n > 0){
     3fc:	0aa04363          	bgtz	a0,4a2 <copyin+0x13e>
    close(fds[0]);
     400:	fb842503          	lw	a0,-72(s0)
     404:	00005097          	auipc	ra,0x5
     408:	0ea080e7          	jalr	234(ra) # 54ee <close>
    close(fds[1]);
     40c:	fbc42503          	lw	a0,-68(s0)
     410:	00005097          	auipc	ra,0x5
     414:	0de080e7          	jalr	222(ra) # 54ee <close>
  for(int ai = 0; ai < 2; ai++){
     418:	0921                	addi	s2,s2,8
     41a:	fd040793          	addi	a5,s0,-48
     41e:	f6f918e3          	bne	s2,a5,38e <copyin+0x2a>
}
     422:	60a6                	ld	ra,72(sp)
     424:	6406                	ld	s0,64(sp)
     426:	74e2                	ld	s1,56(sp)
     428:	7942                	ld	s2,48(sp)
     42a:	79a2                	ld	s3,40(sp)
     42c:	7a02                	ld	s4,32(sp)
     42e:	6161                	addi	sp,sp,80
     430:	8082                	ret
      printf("open(copyin1) failed\n");
     432:	00006517          	auipc	a0,0x6
     436:	9d650513          	addi	a0,a0,-1578 # 5e08 <malloc+0x50c>
     43a:	00005097          	auipc	ra,0x5
     43e:	404080e7          	jalr	1028(ra) # 583e <printf>
      exit(1);
     442:	4505                	li	a0,1
     444:	00005097          	auipc	ra,0x5
     448:	082080e7          	jalr	130(ra) # 54c6 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     44c:	862a                	mv	a2,a0
     44e:	85ce                	mv	a1,s3
     450:	00006517          	auipc	a0,0x6
     454:	9d050513          	addi	a0,a0,-1584 # 5e20 <malloc+0x524>
     458:	00005097          	auipc	ra,0x5
     45c:	3e6080e7          	jalr	998(ra) # 583e <printf>
      exit(1);
     460:	4505                	li	a0,1
     462:	00005097          	auipc	ra,0x5
     466:	064080e7          	jalr	100(ra) # 54c6 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     46a:	862a                	mv	a2,a0
     46c:	85ce                	mv	a1,s3
     46e:	00006517          	auipc	a0,0x6
     472:	9e250513          	addi	a0,a0,-1566 # 5e50 <malloc+0x554>
     476:	00005097          	auipc	ra,0x5
     47a:	3c8080e7          	jalr	968(ra) # 583e <printf>
      exit(1);
     47e:	4505                	li	a0,1
     480:	00005097          	auipc	ra,0x5
     484:	046080e7          	jalr	70(ra) # 54c6 <exit>
      printf("pipe() failed\n");
     488:	00006517          	auipc	a0,0x6
     48c:	9f850513          	addi	a0,a0,-1544 # 5e80 <malloc+0x584>
     490:	00005097          	auipc	ra,0x5
     494:	3ae080e7          	jalr	942(ra) # 583e <printf>
      exit(1);
     498:	4505                	li	a0,1
     49a:	00005097          	auipc	ra,0x5
     49e:	02c080e7          	jalr	44(ra) # 54c6 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     4a2:	862a                	mv	a2,a0
     4a4:	85ce                	mv	a1,s3
     4a6:	00006517          	auipc	a0,0x6
     4aa:	9ea50513          	addi	a0,a0,-1558 # 5e90 <malloc+0x594>
     4ae:	00005097          	auipc	ra,0x5
     4b2:	390080e7          	jalr	912(ra) # 583e <printf>
      exit(1);
     4b6:	4505                	li	a0,1
     4b8:	00005097          	auipc	ra,0x5
     4bc:	00e080e7          	jalr	14(ra) # 54c6 <exit>

00000000000004c0 <copyout>:
{
     4c0:	711d                	addi	sp,sp,-96
     4c2:	ec86                	sd	ra,88(sp)
     4c4:	e8a2                	sd	s0,80(sp)
     4c6:	e4a6                	sd	s1,72(sp)
     4c8:	e0ca                	sd	s2,64(sp)
     4ca:	fc4e                	sd	s3,56(sp)
     4cc:	f852                	sd	s4,48(sp)
     4ce:	f456                	sd	s5,40(sp)
     4d0:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4d2:	4785                	li	a5,1
     4d4:	07fe                	slli	a5,a5,0x1f
     4d6:	faf43823          	sd	a5,-80(s0)
     4da:	57fd                	li	a5,-1
     4dc:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4e0:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     4e4:	00006a17          	auipc	s4,0x6
     4e8:	9dca0a13          	addi	s4,s4,-1572 # 5ec0 <malloc+0x5c4>
    n = write(fds[1], "x", 1);
     4ec:	00006a97          	auipc	s5,0x6
     4f0:	8aca8a93          	addi	s5,s5,-1876 # 5d98 <malloc+0x49c>
    uint64 addr = addrs[ai];
     4f4:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4f8:	4581                	li	a1,0
     4fa:	8552                	mv	a0,s4
     4fc:	00005097          	auipc	ra,0x5
     500:	00a080e7          	jalr	10(ra) # 5506 <open>
     504:	84aa                	mv	s1,a0
    if(fd < 0){
     506:	08054663          	bltz	a0,592 <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     50a:	6609                	lui	a2,0x2
     50c:	85ce                	mv	a1,s3
     50e:	00005097          	auipc	ra,0x5
     512:	fd0080e7          	jalr	-48(ra) # 54de <read>
    if(n > 0){
     516:	08a04b63          	bgtz	a0,5ac <copyout+0xec>
    close(fd);
     51a:	8526                	mv	a0,s1
     51c:	00005097          	auipc	ra,0x5
     520:	fd2080e7          	jalr	-46(ra) # 54ee <close>
    if(pipe(fds) < 0){
     524:	fa840513          	addi	a0,s0,-88
     528:	00005097          	auipc	ra,0x5
     52c:	fae080e7          	jalr	-82(ra) # 54d6 <pipe>
     530:	08054d63          	bltz	a0,5ca <copyout+0x10a>
    n = write(fds[1], "x", 1);
     534:	4605                	li	a2,1
     536:	85d6                	mv	a1,s5
     538:	fac42503          	lw	a0,-84(s0)
     53c:	00005097          	auipc	ra,0x5
     540:	faa080e7          	jalr	-86(ra) # 54e6 <write>
    if(n != 1){
     544:	4785                	li	a5,1
     546:	08f51f63          	bne	a0,a5,5e4 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     54a:	6609                	lui	a2,0x2
     54c:	85ce                	mv	a1,s3
     54e:	fa842503          	lw	a0,-88(s0)
     552:	00005097          	auipc	ra,0x5
     556:	f8c080e7          	jalr	-116(ra) # 54de <read>
    if(n > 0){
     55a:	0aa04263          	bgtz	a0,5fe <copyout+0x13e>
    close(fds[0]);
     55e:	fa842503          	lw	a0,-88(s0)
     562:	00005097          	auipc	ra,0x5
     566:	f8c080e7          	jalr	-116(ra) # 54ee <close>
    close(fds[1]);
     56a:	fac42503          	lw	a0,-84(s0)
     56e:	00005097          	auipc	ra,0x5
     572:	f80080e7          	jalr	-128(ra) # 54ee <close>
  for(int ai = 0; ai < 2; ai++){
     576:	0921                	addi	s2,s2,8
     578:	fc040793          	addi	a5,s0,-64
     57c:	f6f91ce3          	bne	s2,a5,4f4 <copyout+0x34>
}
     580:	60e6                	ld	ra,88(sp)
     582:	6446                	ld	s0,80(sp)
     584:	64a6                	ld	s1,72(sp)
     586:	6906                	ld	s2,64(sp)
     588:	79e2                	ld	s3,56(sp)
     58a:	7a42                	ld	s4,48(sp)
     58c:	7aa2                	ld	s5,40(sp)
     58e:	6125                	addi	sp,sp,96
     590:	8082                	ret
      printf("open(README) failed\n");
     592:	00006517          	auipc	a0,0x6
     596:	93650513          	addi	a0,a0,-1738 # 5ec8 <malloc+0x5cc>
     59a:	00005097          	auipc	ra,0x5
     59e:	2a4080e7          	jalr	676(ra) # 583e <printf>
      exit(1);
     5a2:	4505                	li	a0,1
     5a4:	00005097          	auipc	ra,0x5
     5a8:	f22080e7          	jalr	-222(ra) # 54c6 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ac:	862a                	mv	a2,a0
     5ae:	85ce                	mv	a1,s3
     5b0:	00006517          	auipc	a0,0x6
     5b4:	93050513          	addi	a0,a0,-1744 # 5ee0 <malloc+0x5e4>
     5b8:	00005097          	auipc	ra,0x5
     5bc:	286080e7          	jalr	646(ra) # 583e <printf>
      exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00005097          	auipc	ra,0x5
     5c6:	f04080e7          	jalr	-252(ra) # 54c6 <exit>
      printf("pipe() failed\n");
     5ca:	00006517          	auipc	a0,0x6
     5ce:	8b650513          	addi	a0,a0,-1866 # 5e80 <malloc+0x584>
     5d2:	00005097          	auipc	ra,0x5
     5d6:	26c080e7          	jalr	620(ra) # 583e <printf>
      exit(1);
     5da:	4505                	li	a0,1
     5dc:	00005097          	auipc	ra,0x5
     5e0:	eea080e7          	jalr	-278(ra) # 54c6 <exit>
      printf("pipe write failed\n");
     5e4:	00006517          	auipc	a0,0x6
     5e8:	92c50513          	addi	a0,a0,-1748 # 5f10 <malloc+0x614>
     5ec:	00005097          	auipc	ra,0x5
     5f0:	252080e7          	jalr	594(ra) # 583e <printf>
      exit(1);
     5f4:	4505                	li	a0,1
     5f6:	00005097          	auipc	ra,0x5
     5fa:	ed0080e7          	jalr	-304(ra) # 54c6 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5fe:	862a                	mv	a2,a0
     600:	85ce                	mv	a1,s3
     602:	00006517          	auipc	a0,0x6
     606:	92650513          	addi	a0,a0,-1754 # 5f28 <malloc+0x62c>
     60a:	00005097          	auipc	ra,0x5
     60e:	234080e7          	jalr	564(ra) # 583e <printf>
      exit(1);
     612:	4505                	li	a0,1
     614:	00005097          	auipc	ra,0x5
     618:	eb2080e7          	jalr	-334(ra) # 54c6 <exit>

000000000000061c <truncate1>:
{
     61c:	711d                	addi	sp,sp,-96
     61e:	ec86                	sd	ra,88(sp)
     620:	e8a2                	sd	s0,80(sp)
     622:	e4a6                	sd	s1,72(sp)
     624:	e0ca                	sd	s2,64(sp)
     626:	fc4e                	sd	s3,56(sp)
     628:	f852                	sd	s4,48(sp)
     62a:	f456                	sd	s5,40(sp)
     62c:	1080                	addi	s0,sp,96
     62e:	8aaa                	mv	s5,a0
  unlink("truncfile");
     630:	00005517          	auipc	a0,0x5
     634:	75050513          	addi	a0,a0,1872 # 5d80 <malloc+0x484>
     638:	00005097          	auipc	ra,0x5
     63c:	ede080e7          	jalr	-290(ra) # 5516 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     640:	60100593          	li	a1,1537
     644:	00005517          	auipc	a0,0x5
     648:	73c50513          	addi	a0,a0,1852 # 5d80 <malloc+0x484>
     64c:	00005097          	auipc	ra,0x5
     650:	eba080e7          	jalr	-326(ra) # 5506 <open>
     654:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     656:	4611                	li	a2,4
     658:	00005597          	auipc	a1,0x5
     65c:	73858593          	addi	a1,a1,1848 # 5d90 <malloc+0x494>
     660:	00005097          	auipc	ra,0x5
     664:	e86080e7          	jalr	-378(ra) # 54e6 <write>
  close(fd1);
     668:	8526                	mv	a0,s1
     66a:	00005097          	auipc	ra,0x5
     66e:	e84080e7          	jalr	-380(ra) # 54ee <close>
  int fd2 = open("truncfile", O_RDONLY);
     672:	4581                	li	a1,0
     674:	00005517          	auipc	a0,0x5
     678:	70c50513          	addi	a0,a0,1804 # 5d80 <malloc+0x484>
     67c:	00005097          	auipc	ra,0x5
     680:	e8a080e7          	jalr	-374(ra) # 5506 <open>
     684:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     686:	02000613          	li	a2,32
     68a:	fa040593          	addi	a1,s0,-96
     68e:	00005097          	auipc	ra,0x5
     692:	e50080e7          	jalr	-432(ra) # 54de <read>
  if(n != 4){
     696:	4791                	li	a5,4
     698:	0cf51e63          	bne	a0,a5,774 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     69c:	40100593          	li	a1,1025
     6a0:	00005517          	auipc	a0,0x5
     6a4:	6e050513          	addi	a0,a0,1760 # 5d80 <malloc+0x484>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	e5e080e7          	jalr	-418(ra) # 5506 <open>
     6b0:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     6b2:	4581                	li	a1,0
     6b4:	00005517          	auipc	a0,0x5
     6b8:	6cc50513          	addi	a0,a0,1740 # 5d80 <malloc+0x484>
     6bc:	00005097          	auipc	ra,0x5
     6c0:	e4a080e7          	jalr	-438(ra) # 5506 <open>
     6c4:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	00005097          	auipc	ra,0x5
     6d2:	e10080e7          	jalr	-496(ra) # 54de <read>
     6d6:	8a2a                	mv	s4,a0
  if(n != 0){
     6d8:	ed4d                	bnez	a0,792 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6da:	02000613          	li	a2,32
     6de:	fa040593          	addi	a1,s0,-96
     6e2:	8526                	mv	a0,s1
     6e4:	00005097          	auipc	ra,0x5
     6e8:	dfa080e7          	jalr	-518(ra) # 54de <read>
     6ec:	8a2a                	mv	s4,a0
  if(n != 0){
     6ee:	e971                	bnez	a0,7c2 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6f0:	4619                	li	a2,6
     6f2:	00006597          	auipc	a1,0x6
     6f6:	8c658593          	addi	a1,a1,-1850 # 5fb8 <malloc+0x6bc>
     6fa:	854e                	mv	a0,s3
     6fc:	00005097          	auipc	ra,0x5
     700:	dea080e7          	jalr	-534(ra) # 54e6 <write>
  n = read(fd3, buf, sizeof(buf));
     704:	02000613          	li	a2,32
     708:	fa040593          	addi	a1,s0,-96
     70c:	854a                	mv	a0,s2
     70e:	00005097          	auipc	ra,0x5
     712:	dd0080e7          	jalr	-560(ra) # 54de <read>
  if(n != 6){
     716:	4799                	li	a5,6
     718:	0cf51d63          	bne	a0,a5,7f2 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     71c:	02000613          	li	a2,32
     720:	fa040593          	addi	a1,s0,-96
     724:	8526                	mv	a0,s1
     726:	00005097          	auipc	ra,0x5
     72a:	db8080e7          	jalr	-584(ra) # 54de <read>
  if(n != 2){
     72e:	4789                	li	a5,2
     730:	0ef51063          	bne	a0,a5,810 <truncate1+0x1f4>
  unlink("truncfile");
     734:	00005517          	auipc	a0,0x5
     738:	64c50513          	addi	a0,a0,1612 # 5d80 <malloc+0x484>
     73c:	00005097          	auipc	ra,0x5
     740:	dda080e7          	jalr	-550(ra) # 5516 <unlink>
  close(fd1);
     744:	854e                	mv	a0,s3
     746:	00005097          	auipc	ra,0x5
     74a:	da8080e7          	jalr	-600(ra) # 54ee <close>
  close(fd2);
     74e:	8526                	mv	a0,s1
     750:	00005097          	auipc	ra,0x5
     754:	d9e080e7          	jalr	-610(ra) # 54ee <close>
  close(fd3);
     758:	854a                	mv	a0,s2
     75a:	00005097          	auipc	ra,0x5
     75e:	d94080e7          	jalr	-620(ra) # 54ee <close>
}
     762:	60e6                	ld	ra,88(sp)
     764:	6446                	ld	s0,80(sp)
     766:	64a6                	ld	s1,72(sp)
     768:	6906                	ld	s2,64(sp)
     76a:	79e2                	ld	s3,56(sp)
     76c:	7a42                	ld	s4,48(sp)
     76e:	7aa2                	ld	s5,40(sp)
     770:	6125                	addi	sp,sp,96
     772:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     774:	862a                	mv	a2,a0
     776:	85d6                	mv	a1,s5
     778:	00005517          	auipc	a0,0x5
     77c:	7e050513          	addi	a0,a0,2016 # 5f58 <malloc+0x65c>
     780:	00005097          	auipc	ra,0x5
     784:	0be080e7          	jalr	190(ra) # 583e <printf>
    exit(1);
     788:	4505                	li	a0,1
     78a:	00005097          	auipc	ra,0x5
     78e:	d3c080e7          	jalr	-708(ra) # 54c6 <exit>
    printf("aaa fd3=%d\n", fd3);
     792:	85ca                	mv	a1,s2
     794:	00005517          	auipc	a0,0x5
     798:	7e450513          	addi	a0,a0,2020 # 5f78 <malloc+0x67c>
     79c:	00005097          	auipc	ra,0x5
     7a0:	0a2080e7          	jalr	162(ra) # 583e <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7a4:	8652                	mv	a2,s4
     7a6:	85d6                	mv	a1,s5
     7a8:	00005517          	auipc	a0,0x5
     7ac:	7e050513          	addi	a0,a0,2016 # 5f88 <malloc+0x68c>
     7b0:	00005097          	auipc	ra,0x5
     7b4:	08e080e7          	jalr	142(ra) # 583e <printf>
    exit(1);
     7b8:	4505                	li	a0,1
     7ba:	00005097          	auipc	ra,0x5
     7be:	d0c080e7          	jalr	-756(ra) # 54c6 <exit>
    printf("bbb fd2=%d\n", fd2);
     7c2:	85a6                	mv	a1,s1
     7c4:	00005517          	auipc	a0,0x5
     7c8:	7e450513          	addi	a0,a0,2020 # 5fa8 <malloc+0x6ac>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	072080e7          	jalr	114(ra) # 583e <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7d4:	8652                	mv	a2,s4
     7d6:	85d6                	mv	a1,s5
     7d8:	00005517          	auipc	a0,0x5
     7dc:	7b050513          	addi	a0,a0,1968 # 5f88 <malloc+0x68c>
     7e0:	00005097          	auipc	ra,0x5
     7e4:	05e080e7          	jalr	94(ra) # 583e <printf>
    exit(1);
     7e8:	4505                	li	a0,1
     7ea:	00005097          	auipc	ra,0x5
     7ee:	cdc080e7          	jalr	-804(ra) # 54c6 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7f2:	862a                	mv	a2,a0
     7f4:	85d6                	mv	a1,s5
     7f6:	00005517          	auipc	a0,0x5
     7fa:	7ca50513          	addi	a0,a0,1994 # 5fc0 <malloc+0x6c4>
     7fe:	00005097          	auipc	ra,0x5
     802:	040080e7          	jalr	64(ra) # 583e <printf>
    exit(1);
     806:	4505                	li	a0,1
     808:	00005097          	auipc	ra,0x5
     80c:	cbe080e7          	jalr	-834(ra) # 54c6 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     810:	862a                	mv	a2,a0
     812:	85d6                	mv	a1,s5
     814:	00005517          	auipc	a0,0x5
     818:	7cc50513          	addi	a0,a0,1996 # 5fe0 <malloc+0x6e4>
     81c:	00005097          	auipc	ra,0x5
     820:	022080e7          	jalr	34(ra) # 583e <printf>
    exit(1);
     824:	4505                	li	a0,1
     826:	00005097          	auipc	ra,0x5
     82a:	ca0080e7          	jalr	-864(ra) # 54c6 <exit>

000000000000082e <writetest>:
{
     82e:	7139                	addi	sp,sp,-64
     830:	fc06                	sd	ra,56(sp)
     832:	f822                	sd	s0,48(sp)
     834:	f426                	sd	s1,40(sp)
     836:	f04a                	sd	s2,32(sp)
     838:	ec4e                	sd	s3,24(sp)
     83a:	e852                	sd	s4,16(sp)
     83c:	e456                	sd	s5,8(sp)
     83e:	e05a                	sd	s6,0(sp)
     840:	0080                	addi	s0,sp,64
     842:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     844:	20200593          	li	a1,514
     848:	00005517          	auipc	a0,0x5
     84c:	7b850513          	addi	a0,a0,1976 # 6000 <malloc+0x704>
     850:	00005097          	auipc	ra,0x5
     854:	cb6080e7          	jalr	-842(ra) # 5506 <open>
  if(fd < 0){
     858:	0a054d63          	bltz	a0,912 <writetest+0xe4>
     85c:	892a                	mv	s2,a0
     85e:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	00005997          	auipc	s3,0x5
     864:	7c898993          	addi	s3,s3,1992 # 6028 <malloc+0x72c>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     868:	00005a97          	auipc	s5,0x5
     86c:	7f8a8a93          	addi	s5,s5,2040 # 6060 <malloc+0x764>
  for(i = 0; i < N; i++){
     870:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85ce                	mv	a1,s3
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	c6c080e7          	jalr	-916(ra) # 54e6 <write>
     882:	47a9                	li	a5,10
     884:	0af51563          	bne	a0,a5,92e <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     888:	4629                	li	a2,10
     88a:	85d6                	mv	a1,s5
     88c:	854a                	mv	a0,s2
     88e:	00005097          	auipc	ra,0x5
     892:	c58080e7          	jalr	-936(ra) # 54e6 <write>
     896:	47a9                	li	a5,10
     898:	0af51a63          	bne	a0,a5,94c <writetest+0x11e>
  for(i = 0; i < N; i++){
     89c:	2485                	addiw	s1,s1,1
     89e:	fd449be3          	bne	s1,s4,874 <writetest+0x46>
  close(fd);
     8a2:	854a                	mv	a0,s2
     8a4:	00005097          	auipc	ra,0x5
     8a8:	c4a080e7          	jalr	-950(ra) # 54ee <close>
  fd = open("small", O_RDONLY);
     8ac:	4581                	li	a1,0
     8ae:	00005517          	auipc	a0,0x5
     8b2:	75250513          	addi	a0,a0,1874 # 6000 <malloc+0x704>
     8b6:	00005097          	auipc	ra,0x5
     8ba:	c50080e7          	jalr	-944(ra) # 5506 <open>
     8be:	84aa                	mv	s1,a0
  if(fd < 0){
     8c0:	0a054563          	bltz	a0,96a <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8c4:	7d000613          	li	a2,2000
     8c8:	0000b597          	auipc	a1,0xb
     8cc:	05858593          	addi	a1,a1,88 # b920 <buf>
     8d0:	00005097          	auipc	ra,0x5
     8d4:	c0e080e7          	jalr	-1010(ra) # 54de <read>
  if(i != N*SZ*2){
     8d8:	7d000793          	li	a5,2000
     8dc:	0af51563          	bne	a0,a5,986 <writetest+0x158>
  close(fd);
     8e0:	8526                	mv	a0,s1
     8e2:	00005097          	auipc	ra,0x5
     8e6:	c0c080e7          	jalr	-1012(ra) # 54ee <close>
  if(unlink("small") < 0){
     8ea:	00005517          	auipc	a0,0x5
     8ee:	71650513          	addi	a0,a0,1814 # 6000 <malloc+0x704>
     8f2:	00005097          	auipc	ra,0x5
     8f6:	c24080e7          	jalr	-988(ra) # 5516 <unlink>
     8fa:	0a054463          	bltz	a0,9a2 <writetest+0x174>
}
     8fe:	70e2                	ld	ra,56(sp)
     900:	7442                	ld	s0,48(sp)
     902:	74a2                	ld	s1,40(sp)
     904:	7902                	ld	s2,32(sp)
     906:	69e2                	ld	s3,24(sp)
     908:	6a42                	ld	s4,16(sp)
     90a:	6aa2                	ld	s5,8(sp)
     90c:	6b02                	ld	s6,0(sp)
     90e:	6121                	addi	sp,sp,64
     910:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     912:	85da                	mv	a1,s6
     914:	00005517          	auipc	a0,0x5
     918:	6f450513          	addi	a0,a0,1780 # 6008 <malloc+0x70c>
     91c:	00005097          	auipc	ra,0x5
     920:	f22080e7          	jalr	-222(ra) # 583e <printf>
    exit(1);
     924:	4505                	li	a0,1
     926:	00005097          	auipc	ra,0x5
     92a:	ba0080e7          	jalr	-1120(ra) # 54c6 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     92e:	8626                	mv	a2,s1
     930:	85da                	mv	a1,s6
     932:	00005517          	auipc	a0,0x5
     936:	70650513          	addi	a0,a0,1798 # 6038 <malloc+0x73c>
     93a:	00005097          	auipc	ra,0x5
     93e:	f04080e7          	jalr	-252(ra) # 583e <printf>
      exit(1);
     942:	4505                	li	a0,1
     944:	00005097          	auipc	ra,0x5
     948:	b82080e7          	jalr	-1150(ra) # 54c6 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     94c:	8626                	mv	a2,s1
     94e:	85da                	mv	a1,s6
     950:	00005517          	auipc	a0,0x5
     954:	72050513          	addi	a0,a0,1824 # 6070 <malloc+0x774>
     958:	00005097          	auipc	ra,0x5
     95c:	ee6080e7          	jalr	-282(ra) # 583e <printf>
      exit(1);
     960:	4505                	li	a0,1
     962:	00005097          	auipc	ra,0x5
     966:	b64080e7          	jalr	-1180(ra) # 54c6 <exit>
    printf("%s: error: open small failed!\n", s);
     96a:	85da                	mv	a1,s6
     96c:	00005517          	auipc	a0,0x5
     970:	72c50513          	addi	a0,a0,1836 # 6098 <malloc+0x79c>
     974:	00005097          	auipc	ra,0x5
     978:	eca080e7          	jalr	-310(ra) # 583e <printf>
    exit(1);
     97c:	4505                	li	a0,1
     97e:	00005097          	auipc	ra,0x5
     982:	b48080e7          	jalr	-1208(ra) # 54c6 <exit>
    printf("%s: read failed\n", s);
     986:	85da                	mv	a1,s6
     988:	00005517          	auipc	a0,0x5
     98c:	73050513          	addi	a0,a0,1840 # 60b8 <malloc+0x7bc>
     990:	00005097          	auipc	ra,0x5
     994:	eae080e7          	jalr	-338(ra) # 583e <printf>
    exit(1);
     998:	4505                	li	a0,1
     99a:	00005097          	auipc	ra,0x5
     99e:	b2c080e7          	jalr	-1236(ra) # 54c6 <exit>
    printf("%s: unlink small failed\n", s);
     9a2:	85da                	mv	a1,s6
     9a4:	00005517          	auipc	a0,0x5
     9a8:	72c50513          	addi	a0,a0,1836 # 60d0 <malloc+0x7d4>
     9ac:	00005097          	auipc	ra,0x5
     9b0:	e92080e7          	jalr	-366(ra) # 583e <printf>
    exit(1);
     9b4:	4505                	li	a0,1
     9b6:	00005097          	auipc	ra,0x5
     9ba:	b10080e7          	jalr	-1264(ra) # 54c6 <exit>

00000000000009be <writebig>:
{
     9be:	7139                	addi	sp,sp,-64
     9c0:	fc06                	sd	ra,56(sp)
     9c2:	f822                	sd	s0,48(sp)
     9c4:	f426                	sd	s1,40(sp)
     9c6:	f04a                	sd	s2,32(sp)
     9c8:	ec4e                	sd	s3,24(sp)
     9ca:	e852                	sd	s4,16(sp)
     9cc:	e456                	sd	s5,8(sp)
     9ce:	0080                	addi	s0,sp,64
     9d0:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9d2:	20200593          	li	a1,514
     9d6:	00005517          	auipc	a0,0x5
     9da:	71a50513          	addi	a0,a0,1818 # 60f0 <malloc+0x7f4>
     9de:	00005097          	auipc	ra,0x5
     9e2:	b28080e7          	jalr	-1240(ra) # 5506 <open>
     9e6:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9e8:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9ea:	0000b917          	auipc	s2,0xb
     9ee:	f3690913          	addi	s2,s2,-202 # b920 <buf>
  for(i = 0; i < MAXFILE; i++){
     9f2:	10c00a13          	li	s4,268
  if(fd < 0){
     9f6:	06054c63          	bltz	a0,a6e <writebig+0xb0>
    ((int*)buf)[0] = i;
     9fa:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fe:	40000613          	li	a2,1024
     a02:	85ca                	mv	a1,s2
     a04:	854e                	mv	a0,s3
     a06:	00005097          	auipc	ra,0x5
     a0a:	ae0080e7          	jalr	-1312(ra) # 54e6 <write>
     a0e:	40000793          	li	a5,1024
     a12:	06f51c63          	bne	a0,a5,a8a <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a16:	2485                	addiw	s1,s1,1
     a18:	ff4491e3          	bne	s1,s4,9fa <writebig+0x3c>
  close(fd);
     a1c:	854e                	mv	a0,s3
     a1e:	00005097          	auipc	ra,0x5
     a22:	ad0080e7          	jalr	-1328(ra) # 54ee <close>
  fd = open("big", O_RDONLY);
     a26:	4581                	li	a1,0
     a28:	00005517          	auipc	a0,0x5
     a2c:	6c850513          	addi	a0,a0,1736 # 60f0 <malloc+0x7f4>
     a30:	00005097          	auipc	ra,0x5
     a34:	ad6080e7          	jalr	-1322(ra) # 5506 <open>
     a38:	89aa                	mv	s3,a0
  n = 0;
     a3a:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a3c:	0000b917          	auipc	s2,0xb
     a40:	ee490913          	addi	s2,s2,-284 # b920 <buf>
  if(fd < 0){
     a44:	06054263          	bltz	a0,aa8 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     a48:	40000613          	li	a2,1024
     a4c:	85ca                	mv	a1,s2
     a4e:	854e                	mv	a0,s3
     a50:	00005097          	auipc	ra,0x5
     a54:	a8e080e7          	jalr	-1394(ra) # 54de <read>
    if(i == 0){
     a58:	c535                	beqz	a0,ac4 <writebig+0x106>
    } else if(i != BSIZE){
     a5a:	40000793          	li	a5,1024
     a5e:	0af51f63          	bne	a0,a5,b1c <writebig+0x15e>
    if(((int*)buf)[0] != n){
     a62:	00092683          	lw	a3,0(s2)
     a66:	0c969a63          	bne	a3,s1,b3a <writebig+0x17c>
    n++;
     a6a:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a6c:	bff1                	j	a48 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a6e:	85d6                	mv	a1,s5
     a70:	00005517          	auipc	a0,0x5
     a74:	68850513          	addi	a0,a0,1672 # 60f8 <malloc+0x7fc>
     a78:	00005097          	auipc	ra,0x5
     a7c:	dc6080e7          	jalr	-570(ra) # 583e <printf>
    exit(1);
     a80:	4505                	li	a0,1
     a82:	00005097          	auipc	ra,0x5
     a86:	a44080e7          	jalr	-1468(ra) # 54c6 <exit>
      printf("%s: error: write big file failed\n", s, i);
     a8a:	8626                	mv	a2,s1
     a8c:	85d6                	mv	a1,s5
     a8e:	00005517          	auipc	a0,0x5
     a92:	68a50513          	addi	a0,a0,1674 # 6118 <malloc+0x81c>
     a96:	00005097          	auipc	ra,0x5
     a9a:	da8080e7          	jalr	-600(ra) # 583e <printf>
      exit(1);
     a9e:	4505                	li	a0,1
     aa0:	00005097          	auipc	ra,0x5
     aa4:	a26080e7          	jalr	-1498(ra) # 54c6 <exit>
    printf("%s: error: open big failed!\n", s);
     aa8:	85d6                	mv	a1,s5
     aaa:	00005517          	auipc	a0,0x5
     aae:	69650513          	addi	a0,a0,1686 # 6140 <malloc+0x844>
     ab2:	00005097          	auipc	ra,0x5
     ab6:	d8c080e7          	jalr	-628(ra) # 583e <printf>
    exit(1);
     aba:	4505                	li	a0,1
     abc:	00005097          	auipc	ra,0x5
     ac0:	a0a080e7          	jalr	-1526(ra) # 54c6 <exit>
      if(n == MAXFILE - 1){
     ac4:	10b00793          	li	a5,267
     ac8:	02f48a63          	beq	s1,a5,afc <writebig+0x13e>
  close(fd);
     acc:	854e                	mv	a0,s3
     ace:	00005097          	auipc	ra,0x5
     ad2:	a20080e7          	jalr	-1504(ra) # 54ee <close>
  if(unlink("big") < 0){
     ad6:	00005517          	auipc	a0,0x5
     ada:	61a50513          	addi	a0,a0,1562 # 60f0 <malloc+0x7f4>
     ade:	00005097          	auipc	ra,0x5
     ae2:	a38080e7          	jalr	-1480(ra) # 5516 <unlink>
     ae6:	06054963          	bltz	a0,b58 <writebig+0x19a>
}
     aea:	70e2                	ld	ra,56(sp)
     aec:	7442                	ld	s0,48(sp)
     aee:	74a2                	ld	s1,40(sp)
     af0:	7902                	ld	s2,32(sp)
     af2:	69e2                	ld	s3,24(sp)
     af4:	6a42                	ld	s4,16(sp)
     af6:	6aa2                	ld	s5,8(sp)
     af8:	6121                	addi	sp,sp,64
     afa:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     afc:	10b00613          	li	a2,267
     b00:	85d6                	mv	a1,s5
     b02:	00005517          	auipc	a0,0x5
     b06:	65e50513          	addi	a0,a0,1630 # 6160 <malloc+0x864>
     b0a:	00005097          	auipc	ra,0x5
     b0e:	d34080e7          	jalr	-716(ra) # 583e <printf>
        exit(1);
     b12:	4505                	li	a0,1
     b14:	00005097          	auipc	ra,0x5
     b18:	9b2080e7          	jalr	-1614(ra) # 54c6 <exit>
      printf("%s: read failed %d\n", s, i);
     b1c:	862a                	mv	a2,a0
     b1e:	85d6                	mv	a1,s5
     b20:	00005517          	auipc	a0,0x5
     b24:	66850513          	addi	a0,a0,1640 # 6188 <malloc+0x88c>
     b28:	00005097          	auipc	ra,0x5
     b2c:	d16080e7          	jalr	-746(ra) # 583e <printf>
      exit(1);
     b30:	4505                	li	a0,1
     b32:	00005097          	auipc	ra,0x5
     b36:	994080e7          	jalr	-1644(ra) # 54c6 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b3a:	8626                	mv	a2,s1
     b3c:	85d6                	mv	a1,s5
     b3e:	00005517          	auipc	a0,0x5
     b42:	66250513          	addi	a0,a0,1634 # 61a0 <malloc+0x8a4>
     b46:	00005097          	auipc	ra,0x5
     b4a:	cf8080e7          	jalr	-776(ra) # 583e <printf>
      exit(1);
     b4e:	4505                	li	a0,1
     b50:	00005097          	auipc	ra,0x5
     b54:	976080e7          	jalr	-1674(ra) # 54c6 <exit>
    printf("%s: unlink big failed\n", s);
     b58:	85d6                	mv	a1,s5
     b5a:	00005517          	auipc	a0,0x5
     b5e:	66e50513          	addi	a0,a0,1646 # 61c8 <malloc+0x8cc>
     b62:	00005097          	auipc	ra,0x5
     b66:	cdc080e7          	jalr	-804(ra) # 583e <printf>
    exit(1);
     b6a:	4505                	li	a0,1
     b6c:	00005097          	auipc	ra,0x5
     b70:	95a080e7          	jalr	-1702(ra) # 54c6 <exit>

0000000000000b74 <unlinkread>:
{
     b74:	7179                	addi	sp,sp,-48
     b76:	f406                	sd	ra,40(sp)
     b78:	f022                	sd	s0,32(sp)
     b7a:	ec26                	sd	s1,24(sp)
     b7c:	e84a                	sd	s2,16(sp)
     b7e:	e44e                	sd	s3,8(sp)
     b80:	1800                	addi	s0,sp,48
     b82:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b84:	20200593          	li	a1,514
     b88:	00005517          	auipc	a0,0x5
     b8c:	fa850513          	addi	a0,a0,-88 # 5b30 <malloc+0x234>
     b90:	00005097          	auipc	ra,0x5
     b94:	976080e7          	jalr	-1674(ra) # 5506 <open>
  if(fd < 0){
     b98:	0e054563          	bltz	a0,c82 <unlinkread+0x10e>
     b9c:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b9e:	4615                	li	a2,5
     ba0:	00005597          	auipc	a1,0x5
     ba4:	66058593          	addi	a1,a1,1632 # 6200 <malloc+0x904>
     ba8:	00005097          	auipc	ra,0x5
     bac:	93e080e7          	jalr	-1730(ra) # 54e6 <write>
  close(fd);
     bb0:	8526                	mv	a0,s1
     bb2:	00005097          	auipc	ra,0x5
     bb6:	93c080e7          	jalr	-1732(ra) # 54ee <close>
  fd = open("unlinkread", O_RDWR);
     bba:	4589                	li	a1,2
     bbc:	00005517          	auipc	a0,0x5
     bc0:	f7450513          	addi	a0,a0,-140 # 5b30 <malloc+0x234>
     bc4:	00005097          	auipc	ra,0x5
     bc8:	942080e7          	jalr	-1726(ra) # 5506 <open>
     bcc:	84aa                	mv	s1,a0
  if(fd < 0){
     bce:	0c054863          	bltz	a0,c9e <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bd2:	00005517          	auipc	a0,0x5
     bd6:	f5e50513          	addi	a0,a0,-162 # 5b30 <malloc+0x234>
     bda:	00005097          	auipc	ra,0x5
     bde:	93c080e7          	jalr	-1732(ra) # 5516 <unlink>
     be2:	ed61                	bnez	a0,cba <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     be4:	20200593          	li	a1,514
     be8:	00005517          	auipc	a0,0x5
     bec:	f4850513          	addi	a0,a0,-184 # 5b30 <malloc+0x234>
     bf0:	00005097          	auipc	ra,0x5
     bf4:	916080e7          	jalr	-1770(ra) # 5506 <open>
     bf8:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     bfa:	460d                	li	a2,3
     bfc:	00005597          	auipc	a1,0x5
     c00:	64c58593          	addi	a1,a1,1612 # 6248 <malloc+0x94c>
     c04:	00005097          	auipc	ra,0x5
     c08:	8e2080e7          	jalr	-1822(ra) # 54e6 <write>
  close(fd1);
     c0c:	854a                	mv	a0,s2
     c0e:	00005097          	auipc	ra,0x5
     c12:	8e0080e7          	jalr	-1824(ra) # 54ee <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c16:	660d                	lui	a2,0x3
     c18:	0000b597          	auipc	a1,0xb
     c1c:	d0858593          	addi	a1,a1,-760 # b920 <buf>
     c20:	8526                	mv	a0,s1
     c22:	00005097          	auipc	ra,0x5
     c26:	8bc080e7          	jalr	-1860(ra) # 54de <read>
     c2a:	4795                	li	a5,5
     c2c:	0af51563          	bne	a0,a5,cd6 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c30:	0000b717          	auipc	a4,0xb
     c34:	cf074703          	lbu	a4,-784(a4) # b920 <buf>
     c38:	06800793          	li	a5,104
     c3c:	0af71b63          	bne	a4,a5,cf2 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c40:	4629                	li	a2,10
     c42:	0000b597          	auipc	a1,0xb
     c46:	cde58593          	addi	a1,a1,-802 # b920 <buf>
     c4a:	8526                	mv	a0,s1
     c4c:	00005097          	auipc	ra,0x5
     c50:	89a080e7          	jalr	-1894(ra) # 54e6 <write>
     c54:	47a9                	li	a5,10
     c56:	0af51c63          	bne	a0,a5,d0e <unlinkread+0x19a>
  close(fd);
     c5a:	8526                	mv	a0,s1
     c5c:	00005097          	auipc	ra,0x5
     c60:	892080e7          	jalr	-1902(ra) # 54ee <close>
  unlink("unlinkread");
     c64:	00005517          	auipc	a0,0x5
     c68:	ecc50513          	addi	a0,a0,-308 # 5b30 <malloc+0x234>
     c6c:	00005097          	auipc	ra,0x5
     c70:	8aa080e7          	jalr	-1878(ra) # 5516 <unlink>
}
     c74:	70a2                	ld	ra,40(sp)
     c76:	7402                	ld	s0,32(sp)
     c78:	64e2                	ld	s1,24(sp)
     c7a:	6942                	ld	s2,16(sp)
     c7c:	69a2                	ld	s3,8(sp)
     c7e:	6145                	addi	sp,sp,48
     c80:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c82:	85ce                	mv	a1,s3
     c84:	00005517          	auipc	a0,0x5
     c88:	55c50513          	addi	a0,a0,1372 # 61e0 <malloc+0x8e4>
     c8c:	00005097          	auipc	ra,0x5
     c90:	bb2080e7          	jalr	-1102(ra) # 583e <printf>
    exit(1);
     c94:	4505                	li	a0,1
     c96:	00005097          	auipc	ra,0x5
     c9a:	830080e7          	jalr	-2000(ra) # 54c6 <exit>
    printf("%s: open unlinkread failed\n", s);
     c9e:	85ce                	mv	a1,s3
     ca0:	00005517          	auipc	a0,0x5
     ca4:	56850513          	addi	a0,a0,1384 # 6208 <malloc+0x90c>
     ca8:	00005097          	auipc	ra,0x5
     cac:	b96080e7          	jalr	-1130(ra) # 583e <printf>
    exit(1);
     cb0:	4505                	li	a0,1
     cb2:	00005097          	auipc	ra,0x5
     cb6:	814080e7          	jalr	-2028(ra) # 54c6 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     cba:	85ce                	mv	a1,s3
     cbc:	00005517          	auipc	a0,0x5
     cc0:	56c50513          	addi	a0,a0,1388 # 6228 <malloc+0x92c>
     cc4:	00005097          	auipc	ra,0x5
     cc8:	b7a080e7          	jalr	-1158(ra) # 583e <printf>
    exit(1);
     ccc:	4505                	li	a0,1
     cce:	00004097          	auipc	ra,0x4
     cd2:	7f8080e7          	jalr	2040(ra) # 54c6 <exit>
    printf("%s: unlinkread read failed", s);
     cd6:	85ce                	mv	a1,s3
     cd8:	00005517          	auipc	a0,0x5
     cdc:	57850513          	addi	a0,a0,1400 # 6250 <malloc+0x954>
     ce0:	00005097          	auipc	ra,0x5
     ce4:	b5e080e7          	jalr	-1186(ra) # 583e <printf>
    exit(1);
     ce8:	4505                	li	a0,1
     cea:	00004097          	auipc	ra,0x4
     cee:	7dc080e7          	jalr	2012(ra) # 54c6 <exit>
    printf("%s: unlinkread wrong data\n", s);
     cf2:	85ce                	mv	a1,s3
     cf4:	00005517          	auipc	a0,0x5
     cf8:	57c50513          	addi	a0,a0,1404 # 6270 <malloc+0x974>
     cfc:	00005097          	auipc	ra,0x5
     d00:	b42080e7          	jalr	-1214(ra) # 583e <printf>
    exit(1);
     d04:	4505                	li	a0,1
     d06:	00004097          	auipc	ra,0x4
     d0a:	7c0080e7          	jalr	1984(ra) # 54c6 <exit>
    printf("%s: unlinkread write failed\n", s);
     d0e:	85ce                	mv	a1,s3
     d10:	00005517          	auipc	a0,0x5
     d14:	58050513          	addi	a0,a0,1408 # 6290 <malloc+0x994>
     d18:	00005097          	auipc	ra,0x5
     d1c:	b26080e7          	jalr	-1242(ra) # 583e <printf>
    exit(1);
     d20:	4505                	li	a0,1
     d22:	00004097          	auipc	ra,0x4
     d26:	7a4080e7          	jalr	1956(ra) # 54c6 <exit>

0000000000000d2a <linktest>:
{
     d2a:	1101                	addi	sp,sp,-32
     d2c:	ec06                	sd	ra,24(sp)
     d2e:	e822                	sd	s0,16(sp)
     d30:	e426                	sd	s1,8(sp)
     d32:	e04a                	sd	s2,0(sp)
     d34:	1000                	addi	s0,sp,32
     d36:	892a                	mv	s2,a0
  unlink("lf1");
     d38:	00005517          	auipc	a0,0x5
     d3c:	57850513          	addi	a0,a0,1400 # 62b0 <malloc+0x9b4>
     d40:	00004097          	auipc	ra,0x4
     d44:	7d6080e7          	jalr	2006(ra) # 5516 <unlink>
  unlink("lf2");
     d48:	00005517          	auipc	a0,0x5
     d4c:	57050513          	addi	a0,a0,1392 # 62b8 <malloc+0x9bc>
     d50:	00004097          	auipc	ra,0x4
     d54:	7c6080e7          	jalr	1990(ra) # 5516 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d58:	20200593          	li	a1,514
     d5c:	00005517          	auipc	a0,0x5
     d60:	55450513          	addi	a0,a0,1364 # 62b0 <malloc+0x9b4>
     d64:	00004097          	auipc	ra,0x4
     d68:	7a2080e7          	jalr	1954(ra) # 5506 <open>
  if(fd < 0){
     d6c:	10054763          	bltz	a0,e7a <linktest+0x150>
     d70:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d72:	4615                	li	a2,5
     d74:	00005597          	auipc	a1,0x5
     d78:	48c58593          	addi	a1,a1,1164 # 6200 <malloc+0x904>
     d7c:	00004097          	auipc	ra,0x4
     d80:	76a080e7          	jalr	1898(ra) # 54e6 <write>
     d84:	4795                	li	a5,5
     d86:	10f51863          	bne	a0,a5,e96 <linktest+0x16c>
  close(fd);
     d8a:	8526                	mv	a0,s1
     d8c:	00004097          	auipc	ra,0x4
     d90:	762080e7          	jalr	1890(ra) # 54ee <close>
  if(link("lf1", "lf2") < 0){
     d94:	00005597          	auipc	a1,0x5
     d98:	52458593          	addi	a1,a1,1316 # 62b8 <malloc+0x9bc>
     d9c:	00005517          	auipc	a0,0x5
     da0:	51450513          	addi	a0,a0,1300 # 62b0 <malloc+0x9b4>
     da4:	00004097          	auipc	ra,0x4
     da8:	782080e7          	jalr	1922(ra) # 5526 <link>
     dac:	10054363          	bltz	a0,eb2 <linktest+0x188>
  unlink("lf1");
     db0:	00005517          	auipc	a0,0x5
     db4:	50050513          	addi	a0,a0,1280 # 62b0 <malloc+0x9b4>
     db8:	00004097          	auipc	ra,0x4
     dbc:	75e080e7          	jalr	1886(ra) # 5516 <unlink>
  if(open("lf1", 0) >= 0){
     dc0:	4581                	li	a1,0
     dc2:	00005517          	auipc	a0,0x5
     dc6:	4ee50513          	addi	a0,a0,1262 # 62b0 <malloc+0x9b4>
     dca:	00004097          	auipc	ra,0x4
     dce:	73c080e7          	jalr	1852(ra) # 5506 <open>
     dd2:	0e055e63          	bgez	a0,ece <linktest+0x1a4>
  fd = open("lf2", 0);
     dd6:	4581                	li	a1,0
     dd8:	00005517          	auipc	a0,0x5
     ddc:	4e050513          	addi	a0,a0,1248 # 62b8 <malloc+0x9bc>
     de0:	00004097          	auipc	ra,0x4
     de4:	726080e7          	jalr	1830(ra) # 5506 <open>
     de8:	84aa                	mv	s1,a0
  if(fd < 0){
     dea:	10054063          	bltz	a0,eea <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     dee:	660d                	lui	a2,0x3
     df0:	0000b597          	auipc	a1,0xb
     df4:	b3058593          	addi	a1,a1,-1232 # b920 <buf>
     df8:	00004097          	auipc	ra,0x4
     dfc:	6e6080e7          	jalr	1766(ra) # 54de <read>
     e00:	4795                	li	a5,5
     e02:	10f51263          	bne	a0,a5,f06 <linktest+0x1dc>
  close(fd);
     e06:	8526                	mv	a0,s1
     e08:	00004097          	auipc	ra,0x4
     e0c:	6e6080e7          	jalr	1766(ra) # 54ee <close>
  if(link("lf2", "lf2") >= 0){
     e10:	00005597          	auipc	a1,0x5
     e14:	4a858593          	addi	a1,a1,1192 # 62b8 <malloc+0x9bc>
     e18:	852e                	mv	a0,a1
     e1a:	00004097          	auipc	ra,0x4
     e1e:	70c080e7          	jalr	1804(ra) # 5526 <link>
     e22:	10055063          	bgez	a0,f22 <linktest+0x1f8>
  unlink("lf2");
     e26:	00005517          	auipc	a0,0x5
     e2a:	49250513          	addi	a0,a0,1170 # 62b8 <malloc+0x9bc>
     e2e:	00004097          	auipc	ra,0x4
     e32:	6e8080e7          	jalr	1768(ra) # 5516 <unlink>
  if(link("lf2", "lf1") >= 0){
     e36:	00005597          	auipc	a1,0x5
     e3a:	47a58593          	addi	a1,a1,1146 # 62b0 <malloc+0x9b4>
     e3e:	00005517          	auipc	a0,0x5
     e42:	47a50513          	addi	a0,a0,1146 # 62b8 <malloc+0x9bc>
     e46:	00004097          	auipc	ra,0x4
     e4a:	6e0080e7          	jalr	1760(ra) # 5526 <link>
     e4e:	0e055863          	bgez	a0,f3e <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e52:	00005597          	auipc	a1,0x5
     e56:	45e58593          	addi	a1,a1,1118 # 62b0 <malloc+0x9b4>
     e5a:	00005517          	auipc	a0,0x5
     e5e:	56650513          	addi	a0,a0,1382 # 63c0 <malloc+0xac4>
     e62:	00004097          	auipc	ra,0x4
     e66:	6c4080e7          	jalr	1732(ra) # 5526 <link>
     e6a:	0e055863          	bgez	a0,f5a <linktest+0x230>
}
     e6e:	60e2                	ld	ra,24(sp)
     e70:	6442                	ld	s0,16(sp)
     e72:	64a2                	ld	s1,8(sp)
     e74:	6902                	ld	s2,0(sp)
     e76:	6105                	addi	sp,sp,32
     e78:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e7a:	85ca                	mv	a1,s2
     e7c:	00005517          	auipc	a0,0x5
     e80:	44450513          	addi	a0,a0,1092 # 62c0 <malloc+0x9c4>
     e84:	00005097          	auipc	ra,0x5
     e88:	9ba080e7          	jalr	-1606(ra) # 583e <printf>
    exit(1);
     e8c:	4505                	li	a0,1
     e8e:	00004097          	auipc	ra,0x4
     e92:	638080e7          	jalr	1592(ra) # 54c6 <exit>
    printf("%s: write lf1 failed\n", s);
     e96:	85ca                	mv	a1,s2
     e98:	00005517          	auipc	a0,0x5
     e9c:	44050513          	addi	a0,a0,1088 # 62d8 <malloc+0x9dc>
     ea0:	00005097          	auipc	ra,0x5
     ea4:	99e080e7          	jalr	-1634(ra) # 583e <printf>
    exit(1);
     ea8:	4505                	li	a0,1
     eaa:	00004097          	auipc	ra,0x4
     eae:	61c080e7          	jalr	1564(ra) # 54c6 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     eb2:	85ca                	mv	a1,s2
     eb4:	00005517          	auipc	a0,0x5
     eb8:	43c50513          	addi	a0,a0,1084 # 62f0 <malloc+0x9f4>
     ebc:	00005097          	auipc	ra,0x5
     ec0:	982080e7          	jalr	-1662(ra) # 583e <printf>
    exit(1);
     ec4:	4505                	li	a0,1
     ec6:	00004097          	auipc	ra,0x4
     eca:	600080e7          	jalr	1536(ra) # 54c6 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     ece:	85ca                	mv	a1,s2
     ed0:	00005517          	auipc	a0,0x5
     ed4:	44050513          	addi	a0,a0,1088 # 6310 <malloc+0xa14>
     ed8:	00005097          	auipc	ra,0x5
     edc:	966080e7          	jalr	-1690(ra) # 583e <printf>
    exit(1);
     ee0:	4505                	li	a0,1
     ee2:	00004097          	auipc	ra,0x4
     ee6:	5e4080e7          	jalr	1508(ra) # 54c6 <exit>
    printf("%s: open lf2 failed\n", s);
     eea:	85ca                	mv	a1,s2
     eec:	00005517          	auipc	a0,0x5
     ef0:	45450513          	addi	a0,a0,1108 # 6340 <malloc+0xa44>
     ef4:	00005097          	auipc	ra,0x5
     ef8:	94a080e7          	jalr	-1718(ra) # 583e <printf>
    exit(1);
     efc:	4505                	li	a0,1
     efe:	00004097          	auipc	ra,0x4
     f02:	5c8080e7          	jalr	1480(ra) # 54c6 <exit>
    printf("%s: read lf2 failed\n", s);
     f06:	85ca                	mv	a1,s2
     f08:	00005517          	auipc	a0,0x5
     f0c:	45050513          	addi	a0,a0,1104 # 6358 <malloc+0xa5c>
     f10:	00005097          	auipc	ra,0x5
     f14:	92e080e7          	jalr	-1746(ra) # 583e <printf>
    exit(1);
     f18:	4505                	li	a0,1
     f1a:	00004097          	auipc	ra,0x4
     f1e:	5ac080e7          	jalr	1452(ra) # 54c6 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f22:	85ca                	mv	a1,s2
     f24:	00005517          	auipc	a0,0x5
     f28:	44c50513          	addi	a0,a0,1100 # 6370 <malloc+0xa74>
     f2c:	00005097          	auipc	ra,0x5
     f30:	912080e7          	jalr	-1774(ra) # 583e <printf>
    exit(1);
     f34:	4505                	li	a0,1
     f36:	00004097          	auipc	ra,0x4
     f3a:	590080e7          	jalr	1424(ra) # 54c6 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f3e:	85ca                	mv	a1,s2
     f40:	00005517          	auipc	a0,0x5
     f44:	45850513          	addi	a0,a0,1112 # 6398 <malloc+0xa9c>
     f48:	00005097          	auipc	ra,0x5
     f4c:	8f6080e7          	jalr	-1802(ra) # 583e <printf>
    exit(1);
     f50:	4505                	li	a0,1
     f52:	00004097          	auipc	ra,0x4
     f56:	574080e7          	jalr	1396(ra) # 54c6 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f5a:	85ca                	mv	a1,s2
     f5c:	00005517          	auipc	a0,0x5
     f60:	46c50513          	addi	a0,a0,1132 # 63c8 <malloc+0xacc>
     f64:	00005097          	auipc	ra,0x5
     f68:	8da080e7          	jalr	-1830(ra) # 583e <printf>
    exit(1);
     f6c:	4505                	li	a0,1
     f6e:	00004097          	auipc	ra,0x4
     f72:	558080e7          	jalr	1368(ra) # 54c6 <exit>

0000000000000f76 <bigdir>:
{
     f76:	715d                	addi	sp,sp,-80
     f78:	e486                	sd	ra,72(sp)
     f7a:	e0a2                	sd	s0,64(sp)
     f7c:	fc26                	sd	s1,56(sp)
     f7e:	f84a                	sd	s2,48(sp)
     f80:	f44e                	sd	s3,40(sp)
     f82:	f052                	sd	s4,32(sp)
     f84:	ec56                	sd	s5,24(sp)
     f86:	e85a                	sd	s6,16(sp)
     f88:	0880                	addi	s0,sp,80
     f8a:	89aa                	mv	s3,a0
  unlink("bd");
     f8c:	00005517          	auipc	a0,0x5
     f90:	45c50513          	addi	a0,a0,1116 # 63e8 <malloc+0xaec>
     f94:	00004097          	auipc	ra,0x4
     f98:	582080e7          	jalr	1410(ra) # 5516 <unlink>
  fd = open("bd", O_CREATE);
     f9c:	20000593          	li	a1,512
     fa0:	00005517          	auipc	a0,0x5
     fa4:	44850513          	addi	a0,a0,1096 # 63e8 <malloc+0xaec>
     fa8:	00004097          	auipc	ra,0x4
     fac:	55e080e7          	jalr	1374(ra) # 5506 <open>
  if(fd < 0){
     fb0:	0c054963          	bltz	a0,1082 <bigdir+0x10c>
  close(fd);
     fb4:	00004097          	auipc	ra,0x4
     fb8:	53a080e7          	jalr	1338(ra) # 54ee <close>
  for(i = 0; i < N; i++){
     fbc:	4901                	li	s2,0
    name[0] = 'x';
     fbe:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fc2:	00005a17          	auipc	s4,0x5
     fc6:	426a0a13          	addi	s4,s4,1062 # 63e8 <malloc+0xaec>
  for(i = 0; i < N; i++){
     fca:	1f400b13          	li	s6,500
    name[0] = 'x';
     fce:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fd2:	41f9579b          	sraiw	a5,s2,0x1f
     fd6:	01a7d71b          	srliw	a4,a5,0x1a
     fda:	012707bb          	addw	a5,a4,s2
     fde:	4067d69b          	sraiw	a3,a5,0x6
     fe2:	0306869b          	addiw	a3,a3,48
     fe6:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fea:	03f7f793          	andi	a5,a5,63
     fee:	9f99                	subw	a5,a5,a4
     ff0:	0307879b          	addiw	a5,a5,48
     ff4:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     ff8:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     ffc:	fb040593          	addi	a1,s0,-80
    1000:	8552                	mv	a0,s4
    1002:	00004097          	auipc	ra,0x4
    1006:	524080e7          	jalr	1316(ra) # 5526 <link>
    100a:	84aa                	mv	s1,a0
    100c:	e949                	bnez	a0,109e <bigdir+0x128>
  for(i = 0; i < N; i++){
    100e:	2905                	addiw	s2,s2,1
    1010:	fb691fe3          	bne	s2,s6,fce <bigdir+0x58>
  unlink("bd");
    1014:	00005517          	auipc	a0,0x5
    1018:	3d450513          	addi	a0,a0,980 # 63e8 <malloc+0xaec>
    101c:	00004097          	auipc	ra,0x4
    1020:	4fa080e7          	jalr	1274(ra) # 5516 <unlink>
    name[0] = 'x';
    1024:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1028:	1f400a13          	li	s4,500
    name[0] = 'x';
    102c:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1030:	41f4d79b          	sraiw	a5,s1,0x1f
    1034:	01a7d71b          	srliw	a4,a5,0x1a
    1038:	009707bb          	addw	a5,a4,s1
    103c:	4067d69b          	sraiw	a3,a5,0x6
    1040:	0306869b          	addiw	a3,a3,48
    1044:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1048:	03f7f793          	andi	a5,a5,63
    104c:	9f99                	subw	a5,a5,a4
    104e:	0307879b          	addiw	a5,a5,48
    1052:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1056:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    105a:	fb040513          	addi	a0,s0,-80
    105e:	00004097          	auipc	ra,0x4
    1062:	4b8080e7          	jalr	1208(ra) # 5516 <unlink>
    1066:	ed21                	bnez	a0,10be <bigdir+0x148>
  for(i = 0; i < N; i++){
    1068:	2485                	addiw	s1,s1,1
    106a:	fd4491e3          	bne	s1,s4,102c <bigdir+0xb6>
}
    106e:	60a6                	ld	ra,72(sp)
    1070:	6406                	ld	s0,64(sp)
    1072:	74e2                	ld	s1,56(sp)
    1074:	7942                	ld	s2,48(sp)
    1076:	79a2                	ld	s3,40(sp)
    1078:	7a02                	ld	s4,32(sp)
    107a:	6ae2                	ld	s5,24(sp)
    107c:	6b42                	ld	s6,16(sp)
    107e:	6161                	addi	sp,sp,80
    1080:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1082:	85ce                	mv	a1,s3
    1084:	00005517          	auipc	a0,0x5
    1088:	36c50513          	addi	a0,a0,876 # 63f0 <malloc+0xaf4>
    108c:	00004097          	auipc	ra,0x4
    1090:	7b2080e7          	jalr	1970(ra) # 583e <printf>
    exit(1);
    1094:	4505                	li	a0,1
    1096:	00004097          	auipc	ra,0x4
    109a:	430080e7          	jalr	1072(ra) # 54c6 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    109e:	fb040613          	addi	a2,s0,-80
    10a2:	85ce                	mv	a1,s3
    10a4:	00005517          	auipc	a0,0x5
    10a8:	36c50513          	addi	a0,a0,876 # 6410 <malloc+0xb14>
    10ac:	00004097          	auipc	ra,0x4
    10b0:	792080e7          	jalr	1938(ra) # 583e <printf>
      exit(1);
    10b4:	4505                	li	a0,1
    10b6:	00004097          	auipc	ra,0x4
    10ba:	410080e7          	jalr	1040(ra) # 54c6 <exit>
      printf("%s: bigdir unlink failed", s);
    10be:	85ce                	mv	a1,s3
    10c0:	00005517          	auipc	a0,0x5
    10c4:	37050513          	addi	a0,a0,880 # 6430 <malloc+0xb34>
    10c8:	00004097          	auipc	ra,0x4
    10cc:	776080e7          	jalr	1910(ra) # 583e <printf>
      exit(1);
    10d0:	4505                	li	a0,1
    10d2:	00004097          	auipc	ra,0x4
    10d6:	3f4080e7          	jalr	1012(ra) # 54c6 <exit>

00000000000010da <validatetest>:
{
    10da:	7139                	addi	sp,sp,-64
    10dc:	fc06                	sd	ra,56(sp)
    10de:	f822                	sd	s0,48(sp)
    10e0:	f426                	sd	s1,40(sp)
    10e2:	f04a                	sd	s2,32(sp)
    10e4:	ec4e                	sd	s3,24(sp)
    10e6:	e852                	sd	s4,16(sp)
    10e8:	e456                	sd	s5,8(sp)
    10ea:	e05a                	sd	s6,0(sp)
    10ec:	0080                	addi	s0,sp,64
    10ee:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10f0:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10f2:	00005997          	auipc	s3,0x5
    10f6:	35e98993          	addi	s3,s3,862 # 6450 <malloc+0xb54>
    10fa:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10fc:	6a85                	lui	s5,0x1
    10fe:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1102:	85a6                	mv	a1,s1
    1104:	854e                	mv	a0,s3
    1106:	00004097          	auipc	ra,0x4
    110a:	420080e7          	jalr	1056(ra) # 5526 <link>
    110e:	01251f63          	bne	a0,s2,112c <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1112:	94d6                	add	s1,s1,s5
    1114:	ff4497e3          	bne	s1,s4,1102 <validatetest+0x28>
}
    1118:	70e2                	ld	ra,56(sp)
    111a:	7442                	ld	s0,48(sp)
    111c:	74a2                	ld	s1,40(sp)
    111e:	7902                	ld	s2,32(sp)
    1120:	69e2                	ld	s3,24(sp)
    1122:	6a42                	ld	s4,16(sp)
    1124:	6aa2                	ld	s5,8(sp)
    1126:	6b02                	ld	s6,0(sp)
    1128:	6121                	addi	sp,sp,64
    112a:	8082                	ret
      printf("%s: link should not succeed\n", s);
    112c:	85da                	mv	a1,s6
    112e:	00005517          	auipc	a0,0x5
    1132:	33250513          	addi	a0,a0,818 # 6460 <malloc+0xb64>
    1136:	00004097          	auipc	ra,0x4
    113a:	708080e7          	jalr	1800(ra) # 583e <printf>
      exit(1);
    113e:	4505                	li	a0,1
    1140:	00004097          	auipc	ra,0x4
    1144:	386080e7          	jalr	902(ra) # 54c6 <exit>

0000000000001148 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1148:	7179                	addi	sp,sp,-48
    114a:	f406                	sd	ra,40(sp)
    114c:	f022                	sd	s0,32(sp)
    114e:	ec26                	sd	s1,24(sp)
    1150:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1152:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1156:	00007497          	auipc	s1,0x7
    115a:	f924b483          	ld	s1,-110(s1) # 80e8 <__SDATA_BEGIN__>
    115e:	fd840593          	addi	a1,s0,-40
    1162:	8526                	mv	a0,s1
    1164:	00004097          	auipc	ra,0x4
    1168:	39a080e7          	jalr	922(ra) # 54fe <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    116c:	8526                	mv	a0,s1
    116e:	00004097          	auipc	ra,0x4
    1172:	368080e7          	jalr	872(ra) # 54d6 <pipe>

  exit(0);
    1176:	4501                	li	a0,0
    1178:	00004097          	auipc	ra,0x4
    117c:	34e080e7          	jalr	846(ra) # 54c6 <exit>

0000000000001180 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1180:	7139                	addi	sp,sp,-64
    1182:	fc06                	sd	ra,56(sp)
    1184:	f822                	sd	s0,48(sp)
    1186:	f426                	sd	s1,40(sp)
    1188:	f04a                	sd	s2,32(sp)
    118a:	ec4e                	sd	s3,24(sp)
    118c:	0080                	addi	s0,sp,64
    118e:	64b1                	lui	s1,0xc
    1190:	35048493          	addi	s1,s1,848 # c350 <buf+0xa30>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1194:	597d                	li	s2,-1
    1196:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    119a:	00005997          	auipc	s3,0x5
    119e:	b8e98993          	addi	s3,s3,-1138 # 5d28 <malloc+0x42c>
    argv[0] = (char*)0xffffffff;
    11a2:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    11a6:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    11aa:	fc040593          	addi	a1,s0,-64
    11ae:	854e                	mv	a0,s3
    11b0:	00004097          	auipc	ra,0x4
    11b4:	34e080e7          	jalr	846(ra) # 54fe <exec>
  for(int i = 0; i < 50000; i++){
    11b8:	34fd                	addiw	s1,s1,-1
    11ba:	f4e5                	bnez	s1,11a2 <badarg+0x22>
  }
  
  exit(0);
    11bc:	4501                	li	a0,0
    11be:	00004097          	auipc	ra,0x4
    11c2:	308080e7          	jalr	776(ra) # 54c6 <exit>

00000000000011c6 <copyinstr2>:
{
    11c6:	7155                	addi	sp,sp,-208
    11c8:	e586                	sd	ra,200(sp)
    11ca:	e1a2                	sd	s0,192(sp)
    11cc:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11ce:	f6840793          	addi	a5,s0,-152
    11d2:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11d6:	07800713          	li	a4,120
    11da:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11de:	0785                	addi	a5,a5,1
    11e0:	fed79de3          	bne	a5,a3,11da <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11e4:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11e8:	f6840513          	addi	a0,s0,-152
    11ec:	00004097          	auipc	ra,0x4
    11f0:	32a080e7          	jalr	810(ra) # 5516 <unlink>
  if(ret != -1){
    11f4:	57fd                	li	a5,-1
    11f6:	0ef51063          	bne	a0,a5,12d6 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11fa:	20100593          	li	a1,513
    11fe:	f6840513          	addi	a0,s0,-152
    1202:	00004097          	auipc	ra,0x4
    1206:	304080e7          	jalr	772(ra) # 5506 <open>
  if(fd != -1){
    120a:	57fd                	li	a5,-1
    120c:	0ef51563          	bne	a0,a5,12f6 <copyinstr2+0x130>
  ret = link(b, b);
    1210:	f6840593          	addi	a1,s0,-152
    1214:	852e                	mv	a0,a1
    1216:	00004097          	auipc	ra,0x4
    121a:	310080e7          	jalr	784(ra) # 5526 <link>
  if(ret != -1){
    121e:	57fd                	li	a5,-1
    1220:	0ef51b63          	bne	a0,a5,1316 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1224:	00006797          	auipc	a5,0x6
    1228:	3f478793          	addi	a5,a5,1012 # 7618 <malloc+0x1d1c>
    122c:	f4f43c23          	sd	a5,-168(s0)
    1230:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1234:	f5840593          	addi	a1,s0,-168
    1238:	f6840513          	addi	a0,s0,-152
    123c:	00004097          	auipc	ra,0x4
    1240:	2c2080e7          	jalr	706(ra) # 54fe <exec>
  if(ret != -1){
    1244:	57fd                	li	a5,-1
    1246:	0ef51963          	bne	a0,a5,1338 <copyinstr2+0x172>
  int pid = fork();
    124a:	00004097          	auipc	ra,0x4
    124e:	274080e7          	jalr	628(ra) # 54be <fork>
  if(pid < 0){
    1252:	10054363          	bltz	a0,1358 <copyinstr2+0x192>
  if(pid == 0){
    1256:	12051463          	bnez	a0,137e <copyinstr2+0x1b8>
    125a:	00007797          	auipc	a5,0x7
    125e:	fae78793          	addi	a5,a5,-82 # 8208 <big.0>
    1262:	00008697          	auipc	a3,0x8
    1266:	fa668693          	addi	a3,a3,-90 # 9208 <__global_pointer$+0x920>
      big[i] = 'x';
    126a:	07800713          	li	a4,120
    126e:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1272:	0785                	addi	a5,a5,1
    1274:	fed79de3          	bne	a5,a3,126e <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1278:	00008797          	auipc	a5,0x8
    127c:	f8078823          	sb	zero,-112(a5) # 9208 <__global_pointer$+0x920>
    char *args2[] = { big, big, big, 0 };
    1280:	00007797          	auipc	a5,0x7
    1284:	a8878793          	addi	a5,a5,-1400 # 7d08 <malloc+0x240c>
    1288:	6390                	ld	a2,0(a5)
    128a:	6794                	ld	a3,8(a5)
    128c:	6b98                	ld	a4,16(a5)
    128e:	6f9c                	ld	a5,24(a5)
    1290:	f2c43823          	sd	a2,-208(s0)
    1294:	f2d43c23          	sd	a3,-200(s0)
    1298:	f4e43023          	sd	a4,-192(s0)
    129c:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    12a0:	f3040593          	addi	a1,s0,-208
    12a4:	00005517          	auipc	a0,0x5
    12a8:	a8450513          	addi	a0,a0,-1404 # 5d28 <malloc+0x42c>
    12ac:	00004097          	auipc	ra,0x4
    12b0:	252080e7          	jalr	594(ra) # 54fe <exec>
    if(ret != -1){
    12b4:	57fd                	li	a5,-1
    12b6:	0af50e63          	beq	a0,a5,1372 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12ba:	55fd                	li	a1,-1
    12bc:	00005517          	auipc	a0,0x5
    12c0:	24c50513          	addi	a0,a0,588 # 6508 <malloc+0xc0c>
    12c4:	00004097          	auipc	ra,0x4
    12c8:	57a080e7          	jalr	1402(ra) # 583e <printf>
      exit(1);
    12cc:	4505                	li	a0,1
    12ce:	00004097          	auipc	ra,0x4
    12d2:	1f8080e7          	jalr	504(ra) # 54c6 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12d6:	862a                	mv	a2,a0
    12d8:	f6840593          	addi	a1,s0,-152
    12dc:	00005517          	auipc	a0,0x5
    12e0:	1a450513          	addi	a0,a0,420 # 6480 <malloc+0xb84>
    12e4:	00004097          	auipc	ra,0x4
    12e8:	55a080e7          	jalr	1370(ra) # 583e <printf>
    exit(1);
    12ec:	4505                	li	a0,1
    12ee:	00004097          	auipc	ra,0x4
    12f2:	1d8080e7          	jalr	472(ra) # 54c6 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12f6:	862a                	mv	a2,a0
    12f8:	f6840593          	addi	a1,s0,-152
    12fc:	00005517          	auipc	a0,0x5
    1300:	1a450513          	addi	a0,a0,420 # 64a0 <malloc+0xba4>
    1304:	00004097          	auipc	ra,0x4
    1308:	53a080e7          	jalr	1338(ra) # 583e <printf>
    exit(1);
    130c:	4505                	li	a0,1
    130e:	00004097          	auipc	ra,0x4
    1312:	1b8080e7          	jalr	440(ra) # 54c6 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1316:	86aa                	mv	a3,a0
    1318:	f6840613          	addi	a2,s0,-152
    131c:	85b2                	mv	a1,a2
    131e:	00005517          	auipc	a0,0x5
    1322:	1a250513          	addi	a0,a0,418 # 64c0 <malloc+0xbc4>
    1326:	00004097          	auipc	ra,0x4
    132a:	518080e7          	jalr	1304(ra) # 583e <printf>
    exit(1);
    132e:	4505                	li	a0,1
    1330:	00004097          	auipc	ra,0x4
    1334:	196080e7          	jalr	406(ra) # 54c6 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1338:	567d                	li	a2,-1
    133a:	f6840593          	addi	a1,s0,-152
    133e:	00005517          	auipc	a0,0x5
    1342:	1aa50513          	addi	a0,a0,426 # 64e8 <malloc+0xbec>
    1346:	00004097          	auipc	ra,0x4
    134a:	4f8080e7          	jalr	1272(ra) # 583e <printf>
    exit(1);
    134e:	4505                	li	a0,1
    1350:	00004097          	auipc	ra,0x4
    1354:	176080e7          	jalr	374(ra) # 54c6 <exit>
    printf("fork failed\n");
    1358:	00005517          	auipc	a0,0x5
    135c:	5f850513          	addi	a0,a0,1528 # 6950 <malloc+0x1054>
    1360:	00004097          	auipc	ra,0x4
    1364:	4de080e7          	jalr	1246(ra) # 583e <printf>
    exit(1);
    1368:	4505                	li	a0,1
    136a:	00004097          	auipc	ra,0x4
    136e:	15c080e7          	jalr	348(ra) # 54c6 <exit>
    exit(747); // OK
    1372:	2eb00513          	li	a0,747
    1376:	00004097          	auipc	ra,0x4
    137a:	150080e7          	jalr	336(ra) # 54c6 <exit>
  int st = 0;
    137e:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1382:	f5440513          	addi	a0,s0,-172
    1386:	00004097          	auipc	ra,0x4
    138a:	148080e7          	jalr	328(ra) # 54ce <wait>
  if(st != 747){
    138e:	f5442703          	lw	a4,-172(s0)
    1392:	2eb00793          	li	a5,747
    1396:	00f71663          	bne	a4,a5,13a2 <copyinstr2+0x1dc>
}
    139a:	60ae                	ld	ra,200(sp)
    139c:	640e                	ld	s0,192(sp)
    139e:	6169                	addi	sp,sp,208
    13a0:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    13a2:	00005517          	auipc	a0,0x5
    13a6:	18e50513          	addi	a0,a0,398 # 6530 <malloc+0xc34>
    13aa:	00004097          	auipc	ra,0x4
    13ae:	494080e7          	jalr	1172(ra) # 583e <printf>
    exit(1);
    13b2:	4505                	li	a0,1
    13b4:	00004097          	auipc	ra,0x4
    13b8:	112080e7          	jalr	274(ra) # 54c6 <exit>

00000000000013bc <truncate3>:
{
    13bc:	7159                	addi	sp,sp,-112
    13be:	f486                	sd	ra,104(sp)
    13c0:	f0a2                	sd	s0,96(sp)
    13c2:	eca6                	sd	s1,88(sp)
    13c4:	e8ca                	sd	s2,80(sp)
    13c6:	e4ce                	sd	s3,72(sp)
    13c8:	e0d2                	sd	s4,64(sp)
    13ca:	fc56                	sd	s5,56(sp)
    13cc:	1880                	addi	s0,sp,112
    13ce:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13d0:	60100593          	li	a1,1537
    13d4:	00005517          	auipc	a0,0x5
    13d8:	9ac50513          	addi	a0,a0,-1620 # 5d80 <malloc+0x484>
    13dc:	00004097          	auipc	ra,0x4
    13e0:	12a080e7          	jalr	298(ra) # 5506 <open>
    13e4:	00004097          	auipc	ra,0x4
    13e8:	10a080e7          	jalr	266(ra) # 54ee <close>
  pid = fork();
    13ec:	00004097          	auipc	ra,0x4
    13f0:	0d2080e7          	jalr	210(ra) # 54be <fork>
  if(pid < 0){
    13f4:	08054063          	bltz	a0,1474 <truncate3+0xb8>
  if(pid == 0){
    13f8:	e969                	bnez	a0,14ca <truncate3+0x10e>
    13fa:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    13fe:	00005a17          	auipc	s4,0x5
    1402:	982a0a13          	addi	s4,s4,-1662 # 5d80 <malloc+0x484>
      int n = write(fd, "1234567890", 10);
    1406:	00005a97          	auipc	s5,0x5
    140a:	18aa8a93          	addi	s5,s5,394 # 6590 <malloc+0xc94>
      int fd = open("truncfile", O_WRONLY);
    140e:	4585                	li	a1,1
    1410:	8552                	mv	a0,s4
    1412:	00004097          	auipc	ra,0x4
    1416:	0f4080e7          	jalr	244(ra) # 5506 <open>
    141a:	84aa                	mv	s1,a0
      if(fd < 0){
    141c:	06054a63          	bltz	a0,1490 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1420:	4629                	li	a2,10
    1422:	85d6                	mv	a1,s5
    1424:	00004097          	auipc	ra,0x4
    1428:	0c2080e7          	jalr	194(ra) # 54e6 <write>
      if(n != 10){
    142c:	47a9                	li	a5,10
    142e:	06f51f63          	bne	a0,a5,14ac <truncate3+0xf0>
      close(fd);
    1432:	8526                	mv	a0,s1
    1434:	00004097          	auipc	ra,0x4
    1438:	0ba080e7          	jalr	186(ra) # 54ee <close>
      fd = open("truncfile", O_RDONLY);
    143c:	4581                	li	a1,0
    143e:	8552                	mv	a0,s4
    1440:	00004097          	auipc	ra,0x4
    1444:	0c6080e7          	jalr	198(ra) # 5506 <open>
    1448:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    144a:	02000613          	li	a2,32
    144e:	f9840593          	addi	a1,s0,-104
    1452:	00004097          	auipc	ra,0x4
    1456:	08c080e7          	jalr	140(ra) # 54de <read>
      close(fd);
    145a:	8526                	mv	a0,s1
    145c:	00004097          	auipc	ra,0x4
    1460:	092080e7          	jalr	146(ra) # 54ee <close>
    for(int i = 0; i < 100; i++){
    1464:	39fd                	addiw	s3,s3,-1
    1466:	fa0994e3          	bnez	s3,140e <truncate3+0x52>
    exit(0);
    146a:	4501                	li	a0,0
    146c:	00004097          	auipc	ra,0x4
    1470:	05a080e7          	jalr	90(ra) # 54c6 <exit>
    printf("%s: fork failed\n", s);
    1474:	85ca                	mv	a1,s2
    1476:	00005517          	auipc	a0,0x5
    147a:	0ea50513          	addi	a0,a0,234 # 6560 <malloc+0xc64>
    147e:	00004097          	auipc	ra,0x4
    1482:	3c0080e7          	jalr	960(ra) # 583e <printf>
    exit(1);
    1486:	4505                	li	a0,1
    1488:	00004097          	auipc	ra,0x4
    148c:	03e080e7          	jalr	62(ra) # 54c6 <exit>
        printf("%s: open failed\n", s);
    1490:	85ca                	mv	a1,s2
    1492:	00005517          	auipc	a0,0x5
    1496:	0e650513          	addi	a0,a0,230 # 6578 <malloc+0xc7c>
    149a:	00004097          	auipc	ra,0x4
    149e:	3a4080e7          	jalr	932(ra) # 583e <printf>
        exit(1);
    14a2:	4505                	li	a0,1
    14a4:	00004097          	auipc	ra,0x4
    14a8:	022080e7          	jalr	34(ra) # 54c6 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    14ac:	862a                	mv	a2,a0
    14ae:	85ca                	mv	a1,s2
    14b0:	00005517          	auipc	a0,0x5
    14b4:	0f050513          	addi	a0,a0,240 # 65a0 <malloc+0xca4>
    14b8:	00004097          	auipc	ra,0x4
    14bc:	386080e7          	jalr	902(ra) # 583e <printf>
        exit(1);
    14c0:	4505                	li	a0,1
    14c2:	00004097          	auipc	ra,0x4
    14c6:	004080e7          	jalr	4(ra) # 54c6 <exit>
    14ca:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ce:	00005a17          	auipc	s4,0x5
    14d2:	8b2a0a13          	addi	s4,s4,-1870 # 5d80 <malloc+0x484>
    int n = write(fd, "xxx", 3);
    14d6:	00005a97          	auipc	s5,0x5
    14da:	0eaa8a93          	addi	s5,s5,234 # 65c0 <malloc+0xcc4>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14de:	60100593          	li	a1,1537
    14e2:	8552                	mv	a0,s4
    14e4:	00004097          	auipc	ra,0x4
    14e8:	022080e7          	jalr	34(ra) # 5506 <open>
    14ec:	84aa                	mv	s1,a0
    if(fd < 0){
    14ee:	04054763          	bltz	a0,153c <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14f2:	460d                	li	a2,3
    14f4:	85d6                	mv	a1,s5
    14f6:	00004097          	auipc	ra,0x4
    14fa:	ff0080e7          	jalr	-16(ra) # 54e6 <write>
    if(n != 3){
    14fe:	478d                	li	a5,3
    1500:	04f51c63          	bne	a0,a5,1558 <truncate3+0x19c>
    close(fd);
    1504:	8526                	mv	a0,s1
    1506:	00004097          	auipc	ra,0x4
    150a:	fe8080e7          	jalr	-24(ra) # 54ee <close>
  for(int i = 0; i < 150; i++){
    150e:	39fd                	addiw	s3,s3,-1
    1510:	fc0997e3          	bnez	s3,14de <truncate3+0x122>
  wait(&xstatus);
    1514:	fbc40513          	addi	a0,s0,-68
    1518:	00004097          	auipc	ra,0x4
    151c:	fb6080e7          	jalr	-74(ra) # 54ce <wait>
  unlink("truncfile");
    1520:	00005517          	auipc	a0,0x5
    1524:	86050513          	addi	a0,a0,-1952 # 5d80 <malloc+0x484>
    1528:	00004097          	auipc	ra,0x4
    152c:	fee080e7          	jalr	-18(ra) # 5516 <unlink>
  exit(xstatus);
    1530:	fbc42503          	lw	a0,-68(s0)
    1534:	00004097          	auipc	ra,0x4
    1538:	f92080e7          	jalr	-110(ra) # 54c6 <exit>
      printf("%s: open failed\n", s);
    153c:	85ca                	mv	a1,s2
    153e:	00005517          	auipc	a0,0x5
    1542:	03a50513          	addi	a0,a0,58 # 6578 <malloc+0xc7c>
    1546:	00004097          	auipc	ra,0x4
    154a:	2f8080e7          	jalr	760(ra) # 583e <printf>
      exit(1);
    154e:	4505                	li	a0,1
    1550:	00004097          	auipc	ra,0x4
    1554:	f76080e7          	jalr	-138(ra) # 54c6 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1558:	862a                	mv	a2,a0
    155a:	85ca                	mv	a1,s2
    155c:	00005517          	auipc	a0,0x5
    1560:	06c50513          	addi	a0,a0,108 # 65c8 <malloc+0xccc>
    1564:	00004097          	auipc	ra,0x4
    1568:	2da080e7          	jalr	730(ra) # 583e <printf>
      exit(1);
    156c:	4505                	li	a0,1
    156e:	00004097          	auipc	ra,0x4
    1572:	f58080e7          	jalr	-168(ra) # 54c6 <exit>

0000000000001576 <exectest>:
{
    1576:	715d                	addi	sp,sp,-80
    1578:	e486                	sd	ra,72(sp)
    157a:	e0a2                	sd	s0,64(sp)
    157c:	fc26                	sd	s1,56(sp)
    157e:	f84a                	sd	s2,48(sp)
    1580:	0880                	addi	s0,sp,80
    1582:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1584:	00004797          	auipc	a5,0x4
    1588:	7a478793          	addi	a5,a5,1956 # 5d28 <malloc+0x42c>
    158c:	fcf43023          	sd	a5,-64(s0)
    1590:	00005797          	auipc	a5,0x5
    1594:	05878793          	addi	a5,a5,88 # 65e8 <malloc+0xcec>
    1598:	fcf43423          	sd	a5,-56(s0)
    159c:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    15a0:	00005517          	auipc	a0,0x5
    15a4:	05050513          	addi	a0,a0,80 # 65f0 <malloc+0xcf4>
    15a8:	00004097          	auipc	ra,0x4
    15ac:	f6e080e7          	jalr	-146(ra) # 5516 <unlink>
  pid = fork();
    15b0:	00004097          	auipc	ra,0x4
    15b4:	f0e080e7          	jalr	-242(ra) # 54be <fork>
  if(pid < 0) {
    15b8:	04054663          	bltz	a0,1604 <exectest+0x8e>
    15bc:	84aa                	mv	s1,a0
  if(pid == 0) {
    15be:	e959                	bnez	a0,1654 <exectest+0xde>
    close(1);
    15c0:	4505                	li	a0,1
    15c2:	00004097          	auipc	ra,0x4
    15c6:	f2c080e7          	jalr	-212(ra) # 54ee <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15ca:	20100593          	li	a1,513
    15ce:	00005517          	auipc	a0,0x5
    15d2:	02250513          	addi	a0,a0,34 # 65f0 <malloc+0xcf4>
    15d6:	00004097          	auipc	ra,0x4
    15da:	f30080e7          	jalr	-208(ra) # 5506 <open>
    if(fd < 0) {
    15de:	04054163          	bltz	a0,1620 <exectest+0xaa>
    if(fd != 1) {
    15e2:	4785                	li	a5,1
    15e4:	04f50c63          	beq	a0,a5,163c <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15e8:	85ca                	mv	a1,s2
    15ea:	00005517          	auipc	a0,0x5
    15ee:	02650513          	addi	a0,a0,38 # 6610 <malloc+0xd14>
    15f2:	00004097          	auipc	ra,0x4
    15f6:	24c080e7          	jalr	588(ra) # 583e <printf>
      exit(1);
    15fa:	4505                	li	a0,1
    15fc:	00004097          	auipc	ra,0x4
    1600:	eca080e7          	jalr	-310(ra) # 54c6 <exit>
     printf("%s: fork failed\n", s);
    1604:	85ca                	mv	a1,s2
    1606:	00005517          	auipc	a0,0x5
    160a:	f5a50513          	addi	a0,a0,-166 # 6560 <malloc+0xc64>
    160e:	00004097          	auipc	ra,0x4
    1612:	230080e7          	jalr	560(ra) # 583e <printf>
     exit(1);
    1616:	4505                	li	a0,1
    1618:	00004097          	auipc	ra,0x4
    161c:	eae080e7          	jalr	-338(ra) # 54c6 <exit>
      printf("%s: create failed\n", s);
    1620:	85ca                	mv	a1,s2
    1622:	00005517          	auipc	a0,0x5
    1626:	fd650513          	addi	a0,a0,-42 # 65f8 <malloc+0xcfc>
    162a:	00004097          	auipc	ra,0x4
    162e:	214080e7          	jalr	532(ra) # 583e <printf>
      exit(1);
    1632:	4505                	li	a0,1
    1634:	00004097          	auipc	ra,0x4
    1638:	e92080e7          	jalr	-366(ra) # 54c6 <exit>
    if(exec("echo", echoargv) < 0){
    163c:	fc040593          	addi	a1,s0,-64
    1640:	00004517          	auipc	a0,0x4
    1644:	6e850513          	addi	a0,a0,1768 # 5d28 <malloc+0x42c>
    1648:	00004097          	auipc	ra,0x4
    164c:	eb6080e7          	jalr	-330(ra) # 54fe <exec>
    1650:	02054163          	bltz	a0,1672 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1654:	fdc40513          	addi	a0,s0,-36
    1658:	00004097          	auipc	ra,0x4
    165c:	e76080e7          	jalr	-394(ra) # 54ce <wait>
    1660:	02951763          	bne	a0,s1,168e <exectest+0x118>
  if(xstatus != 0)
    1664:	fdc42503          	lw	a0,-36(s0)
    1668:	cd0d                	beqz	a0,16a2 <exectest+0x12c>
    exit(xstatus);
    166a:	00004097          	auipc	ra,0x4
    166e:	e5c080e7          	jalr	-420(ra) # 54c6 <exit>
      printf("%s: exec echo failed\n", s);
    1672:	85ca                	mv	a1,s2
    1674:	00005517          	auipc	a0,0x5
    1678:	fac50513          	addi	a0,a0,-84 # 6620 <malloc+0xd24>
    167c:	00004097          	auipc	ra,0x4
    1680:	1c2080e7          	jalr	450(ra) # 583e <printf>
      exit(1);
    1684:	4505                	li	a0,1
    1686:	00004097          	auipc	ra,0x4
    168a:	e40080e7          	jalr	-448(ra) # 54c6 <exit>
    printf("%s: wait failed!\n", s);
    168e:	85ca                	mv	a1,s2
    1690:	00005517          	auipc	a0,0x5
    1694:	fa850513          	addi	a0,a0,-88 # 6638 <malloc+0xd3c>
    1698:	00004097          	auipc	ra,0x4
    169c:	1a6080e7          	jalr	422(ra) # 583e <printf>
    16a0:	b7d1                	j	1664 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    16a2:	4581                	li	a1,0
    16a4:	00005517          	auipc	a0,0x5
    16a8:	f4c50513          	addi	a0,a0,-180 # 65f0 <malloc+0xcf4>
    16ac:	00004097          	auipc	ra,0x4
    16b0:	e5a080e7          	jalr	-422(ra) # 5506 <open>
  if(fd < 0) {
    16b4:	02054a63          	bltz	a0,16e8 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16b8:	4609                	li	a2,2
    16ba:	fb840593          	addi	a1,s0,-72
    16be:	00004097          	auipc	ra,0x4
    16c2:	e20080e7          	jalr	-480(ra) # 54de <read>
    16c6:	4789                	li	a5,2
    16c8:	02f50e63          	beq	a0,a5,1704 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16cc:	85ca                	mv	a1,s2
    16ce:	00005517          	auipc	a0,0x5
    16d2:	9ea50513          	addi	a0,a0,-1558 # 60b8 <malloc+0x7bc>
    16d6:	00004097          	auipc	ra,0x4
    16da:	168080e7          	jalr	360(ra) # 583e <printf>
    exit(1);
    16de:	4505                	li	a0,1
    16e0:	00004097          	auipc	ra,0x4
    16e4:	de6080e7          	jalr	-538(ra) # 54c6 <exit>
    printf("%s: open failed\n", s);
    16e8:	85ca                	mv	a1,s2
    16ea:	00005517          	auipc	a0,0x5
    16ee:	e8e50513          	addi	a0,a0,-370 # 6578 <malloc+0xc7c>
    16f2:	00004097          	auipc	ra,0x4
    16f6:	14c080e7          	jalr	332(ra) # 583e <printf>
    exit(1);
    16fa:	4505                	li	a0,1
    16fc:	00004097          	auipc	ra,0x4
    1700:	dca080e7          	jalr	-566(ra) # 54c6 <exit>
  unlink("echo-ok");
    1704:	00005517          	auipc	a0,0x5
    1708:	eec50513          	addi	a0,a0,-276 # 65f0 <malloc+0xcf4>
    170c:	00004097          	auipc	ra,0x4
    1710:	e0a080e7          	jalr	-502(ra) # 5516 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1714:	fb844703          	lbu	a4,-72(s0)
    1718:	04f00793          	li	a5,79
    171c:	00f71863          	bne	a4,a5,172c <exectest+0x1b6>
    1720:	fb944703          	lbu	a4,-71(s0)
    1724:	04b00793          	li	a5,75
    1728:	02f70063          	beq	a4,a5,1748 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    172c:	85ca                	mv	a1,s2
    172e:	00005517          	auipc	a0,0x5
    1732:	f2250513          	addi	a0,a0,-222 # 6650 <malloc+0xd54>
    1736:	00004097          	auipc	ra,0x4
    173a:	108080e7          	jalr	264(ra) # 583e <printf>
    exit(1);
    173e:	4505                	li	a0,1
    1740:	00004097          	auipc	ra,0x4
    1744:	d86080e7          	jalr	-634(ra) # 54c6 <exit>
    exit(0);
    1748:	4501                	li	a0,0
    174a:	00004097          	auipc	ra,0x4
    174e:	d7c080e7          	jalr	-644(ra) # 54c6 <exit>

0000000000001752 <pipe1>:
{
    1752:	711d                	addi	sp,sp,-96
    1754:	ec86                	sd	ra,88(sp)
    1756:	e8a2                	sd	s0,80(sp)
    1758:	e4a6                	sd	s1,72(sp)
    175a:	e0ca                	sd	s2,64(sp)
    175c:	fc4e                	sd	s3,56(sp)
    175e:	f852                	sd	s4,48(sp)
    1760:	f456                	sd	s5,40(sp)
    1762:	f05a                	sd	s6,32(sp)
    1764:	ec5e                	sd	s7,24(sp)
    1766:	1080                	addi	s0,sp,96
    1768:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    176a:	fa840513          	addi	a0,s0,-88
    176e:	00004097          	auipc	ra,0x4
    1772:	d68080e7          	jalr	-664(ra) # 54d6 <pipe>
    1776:	ed25                	bnez	a0,17ee <pipe1+0x9c>
    1778:	84aa                	mv	s1,a0
  pid = fork();
    177a:	00004097          	auipc	ra,0x4
    177e:	d44080e7          	jalr	-700(ra) # 54be <fork>
    1782:	8a2a                	mv	s4,a0
  if(pid == 0){
    1784:	c159                	beqz	a0,180a <pipe1+0xb8>
  } else if(pid > 0){
    1786:	16a05e63          	blez	a0,1902 <pipe1+0x1b0>
    close(fds[1]);
    178a:	fac42503          	lw	a0,-84(s0)
    178e:	00004097          	auipc	ra,0x4
    1792:	d60080e7          	jalr	-672(ra) # 54ee <close>
    total = 0;
    1796:	8a26                	mv	s4,s1
    cc = 1;
    1798:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    179a:	0000aa97          	auipc	s5,0xa
    179e:	186a8a93          	addi	s5,s5,390 # b920 <buf>
      if(cc > sizeof(buf))
    17a2:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    17a4:	864e                	mv	a2,s3
    17a6:	85d6                	mv	a1,s5
    17a8:	fa842503          	lw	a0,-88(s0)
    17ac:	00004097          	auipc	ra,0x4
    17b0:	d32080e7          	jalr	-718(ra) # 54de <read>
    17b4:	10a05263          	blez	a0,18b8 <pipe1+0x166>
      for(i = 0; i < n; i++){
    17b8:	0000a717          	auipc	a4,0xa
    17bc:	16870713          	addi	a4,a4,360 # b920 <buf>
    17c0:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17c4:	00074683          	lbu	a3,0(a4)
    17c8:	0ff4f793          	andi	a5,s1,255
    17cc:	2485                	addiw	s1,s1,1
    17ce:	0cf69163          	bne	a3,a5,1890 <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17d2:	0705                	addi	a4,a4,1
    17d4:	fec498e3          	bne	s1,a2,17c4 <pipe1+0x72>
      total += n;
    17d8:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17dc:	0019979b          	slliw	a5,s3,0x1
    17e0:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17e4:	013b7363          	bgeu	s6,s3,17ea <pipe1+0x98>
        cc = sizeof(buf);
    17e8:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17ea:	84b2                	mv	s1,a2
    17ec:	bf65                	j	17a4 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17ee:	85ca                	mv	a1,s2
    17f0:	00005517          	auipc	a0,0x5
    17f4:	e7850513          	addi	a0,a0,-392 # 6668 <malloc+0xd6c>
    17f8:	00004097          	auipc	ra,0x4
    17fc:	046080e7          	jalr	70(ra) # 583e <printf>
    exit(1);
    1800:	4505                	li	a0,1
    1802:	00004097          	auipc	ra,0x4
    1806:	cc4080e7          	jalr	-828(ra) # 54c6 <exit>
    close(fds[0]);
    180a:	fa842503          	lw	a0,-88(s0)
    180e:	00004097          	auipc	ra,0x4
    1812:	ce0080e7          	jalr	-800(ra) # 54ee <close>
    for(n = 0; n < N; n++){
    1816:	0000ab17          	auipc	s6,0xa
    181a:	10ab0b13          	addi	s6,s6,266 # b920 <buf>
    181e:	416004bb          	negw	s1,s6
    1822:	0ff4f493          	andi	s1,s1,255
    1826:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    182a:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    182c:	6a85                	lui	s5,0x1
    182e:	42da8a93          	addi	s5,s5,1069 # 142d <truncate3+0x71>
{
    1832:	87da                	mv	a5,s6
        buf[i] = seq++;
    1834:	0097873b          	addw	a4,a5,s1
    1838:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    183c:	0785                	addi	a5,a5,1
    183e:	fef99be3          	bne	s3,a5,1834 <pipe1+0xe2>
        buf[i] = seq++;
    1842:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1846:	40900613          	li	a2,1033
    184a:	85de                	mv	a1,s7
    184c:	fac42503          	lw	a0,-84(s0)
    1850:	00004097          	auipc	ra,0x4
    1854:	c96080e7          	jalr	-874(ra) # 54e6 <write>
    1858:	40900793          	li	a5,1033
    185c:	00f51c63          	bne	a0,a5,1874 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1860:	24a5                	addiw	s1,s1,9
    1862:	0ff4f493          	andi	s1,s1,255
    1866:	fd5a16e3          	bne	s4,s5,1832 <pipe1+0xe0>
    exit(0);
    186a:	4501                	li	a0,0
    186c:	00004097          	auipc	ra,0x4
    1870:	c5a080e7          	jalr	-934(ra) # 54c6 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1874:	85ca                	mv	a1,s2
    1876:	00005517          	auipc	a0,0x5
    187a:	e0a50513          	addi	a0,a0,-502 # 6680 <malloc+0xd84>
    187e:	00004097          	auipc	ra,0x4
    1882:	fc0080e7          	jalr	-64(ra) # 583e <printf>
        exit(1);
    1886:	4505                	li	a0,1
    1888:	00004097          	auipc	ra,0x4
    188c:	c3e080e7          	jalr	-962(ra) # 54c6 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1890:	85ca                	mv	a1,s2
    1892:	00005517          	auipc	a0,0x5
    1896:	e0650513          	addi	a0,a0,-506 # 6698 <malloc+0xd9c>
    189a:	00004097          	auipc	ra,0x4
    189e:	fa4080e7          	jalr	-92(ra) # 583e <printf>
}
    18a2:	60e6                	ld	ra,88(sp)
    18a4:	6446                	ld	s0,80(sp)
    18a6:	64a6                	ld	s1,72(sp)
    18a8:	6906                	ld	s2,64(sp)
    18aa:	79e2                	ld	s3,56(sp)
    18ac:	7a42                	ld	s4,48(sp)
    18ae:	7aa2                	ld	s5,40(sp)
    18b0:	7b02                	ld	s6,32(sp)
    18b2:	6be2                	ld	s7,24(sp)
    18b4:	6125                	addi	sp,sp,96
    18b6:	8082                	ret
    if(total != N * SZ){
    18b8:	6785                	lui	a5,0x1
    18ba:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x71>
    18be:	02fa0063          	beq	s4,a5,18de <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18c2:	85d2                	mv	a1,s4
    18c4:	00005517          	auipc	a0,0x5
    18c8:	dec50513          	addi	a0,a0,-532 # 66b0 <malloc+0xdb4>
    18cc:	00004097          	auipc	ra,0x4
    18d0:	f72080e7          	jalr	-142(ra) # 583e <printf>
      exit(1);
    18d4:	4505                	li	a0,1
    18d6:	00004097          	auipc	ra,0x4
    18da:	bf0080e7          	jalr	-1040(ra) # 54c6 <exit>
    close(fds[0]);
    18de:	fa842503          	lw	a0,-88(s0)
    18e2:	00004097          	auipc	ra,0x4
    18e6:	c0c080e7          	jalr	-1012(ra) # 54ee <close>
    wait(&xstatus);
    18ea:	fa440513          	addi	a0,s0,-92
    18ee:	00004097          	auipc	ra,0x4
    18f2:	be0080e7          	jalr	-1056(ra) # 54ce <wait>
    exit(xstatus);
    18f6:	fa442503          	lw	a0,-92(s0)
    18fa:	00004097          	auipc	ra,0x4
    18fe:	bcc080e7          	jalr	-1076(ra) # 54c6 <exit>
    printf("%s: fork() failed\n", s);
    1902:	85ca                	mv	a1,s2
    1904:	00005517          	auipc	a0,0x5
    1908:	dcc50513          	addi	a0,a0,-564 # 66d0 <malloc+0xdd4>
    190c:	00004097          	auipc	ra,0x4
    1910:	f32080e7          	jalr	-206(ra) # 583e <printf>
    exit(1);
    1914:	4505                	li	a0,1
    1916:	00004097          	auipc	ra,0x4
    191a:	bb0080e7          	jalr	-1104(ra) # 54c6 <exit>

000000000000191e <exitwait>:
{
    191e:	7139                	addi	sp,sp,-64
    1920:	fc06                	sd	ra,56(sp)
    1922:	f822                	sd	s0,48(sp)
    1924:	f426                	sd	s1,40(sp)
    1926:	f04a                	sd	s2,32(sp)
    1928:	ec4e                	sd	s3,24(sp)
    192a:	e852                	sd	s4,16(sp)
    192c:	0080                	addi	s0,sp,64
    192e:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1930:	4901                	li	s2,0
    1932:	06400993          	li	s3,100
    pid = fork();
    1936:	00004097          	auipc	ra,0x4
    193a:	b88080e7          	jalr	-1144(ra) # 54be <fork>
    193e:	84aa                	mv	s1,a0
    if(pid < 0){
    1940:	02054a63          	bltz	a0,1974 <exitwait+0x56>
    if(pid){
    1944:	c151                	beqz	a0,19c8 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1946:	fcc40513          	addi	a0,s0,-52
    194a:	00004097          	auipc	ra,0x4
    194e:	b84080e7          	jalr	-1148(ra) # 54ce <wait>
    1952:	02951f63          	bne	a0,s1,1990 <exitwait+0x72>
      if(i != xstate) {
    1956:	fcc42783          	lw	a5,-52(s0)
    195a:	05279963          	bne	a5,s2,19ac <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    195e:	2905                	addiw	s2,s2,1
    1960:	fd391be3          	bne	s2,s3,1936 <exitwait+0x18>
}
    1964:	70e2                	ld	ra,56(sp)
    1966:	7442                	ld	s0,48(sp)
    1968:	74a2                	ld	s1,40(sp)
    196a:	7902                	ld	s2,32(sp)
    196c:	69e2                	ld	s3,24(sp)
    196e:	6a42                	ld	s4,16(sp)
    1970:	6121                	addi	sp,sp,64
    1972:	8082                	ret
      printf("%s: fork failed\n", s);
    1974:	85d2                	mv	a1,s4
    1976:	00005517          	auipc	a0,0x5
    197a:	bea50513          	addi	a0,a0,-1046 # 6560 <malloc+0xc64>
    197e:	00004097          	auipc	ra,0x4
    1982:	ec0080e7          	jalr	-320(ra) # 583e <printf>
      exit(1);
    1986:	4505                	li	a0,1
    1988:	00004097          	auipc	ra,0x4
    198c:	b3e080e7          	jalr	-1218(ra) # 54c6 <exit>
        printf("%s: wait wrong pid\n", s);
    1990:	85d2                	mv	a1,s4
    1992:	00005517          	auipc	a0,0x5
    1996:	d5650513          	addi	a0,a0,-682 # 66e8 <malloc+0xdec>
    199a:	00004097          	auipc	ra,0x4
    199e:	ea4080e7          	jalr	-348(ra) # 583e <printf>
        exit(1);
    19a2:	4505                	li	a0,1
    19a4:	00004097          	auipc	ra,0x4
    19a8:	b22080e7          	jalr	-1246(ra) # 54c6 <exit>
        printf("%s: wait wrong exit status\n", s);
    19ac:	85d2                	mv	a1,s4
    19ae:	00005517          	auipc	a0,0x5
    19b2:	d5250513          	addi	a0,a0,-686 # 6700 <malloc+0xe04>
    19b6:	00004097          	auipc	ra,0x4
    19ba:	e88080e7          	jalr	-376(ra) # 583e <printf>
        exit(1);
    19be:	4505                	li	a0,1
    19c0:	00004097          	auipc	ra,0x4
    19c4:	b06080e7          	jalr	-1274(ra) # 54c6 <exit>
      exit(i);
    19c8:	854a                	mv	a0,s2
    19ca:	00004097          	auipc	ra,0x4
    19ce:	afc080e7          	jalr	-1284(ra) # 54c6 <exit>

00000000000019d2 <twochildren>:
{
    19d2:	1101                	addi	sp,sp,-32
    19d4:	ec06                	sd	ra,24(sp)
    19d6:	e822                	sd	s0,16(sp)
    19d8:	e426                	sd	s1,8(sp)
    19da:	e04a                	sd	s2,0(sp)
    19dc:	1000                	addi	s0,sp,32
    19de:	892a                	mv	s2,a0
    19e0:	3e800493          	li	s1,1000
    int pid1 = fork();
    19e4:	00004097          	auipc	ra,0x4
    19e8:	ada080e7          	jalr	-1318(ra) # 54be <fork>
    if(pid1 < 0){
    19ec:	02054c63          	bltz	a0,1a24 <twochildren+0x52>
    if(pid1 == 0){
    19f0:	c921                	beqz	a0,1a40 <twochildren+0x6e>
      int pid2 = fork();
    19f2:	00004097          	auipc	ra,0x4
    19f6:	acc080e7          	jalr	-1332(ra) # 54be <fork>
      if(pid2 < 0){
    19fa:	04054763          	bltz	a0,1a48 <twochildren+0x76>
      if(pid2 == 0){
    19fe:	c13d                	beqz	a0,1a64 <twochildren+0x92>
        wait(0);
    1a00:	4501                	li	a0,0
    1a02:	00004097          	auipc	ra,0x4
    1a06:	acc080e7          	jalr	-1332(ra) # 54ce <wait>
        wait(0);
    1a0a:	4501                	li	a0,0
    1a0c:	00004097          	auipc	ra,0x4
    1a10:	ac2080e7          	jalr	-1342(ra) # 54ce <wait>
  for(int i = 0; i < 1000; i++){
    1a14:	34fd                	addiw	s1,s1,-1
    1a16:	f4f9                	bnez	s1,19e4 <twochildren+0x12>
}
    1a18:	60e2                	ld	ra,24(sp)
    1a1a:	6442                	ld	s0,16(sp)
    1a1c:	64a2                	ld	s1,8(sp)
    1a1e:	6902                	ld	s2,0(sp)
    1a20:	6105                	addi	sp,sp,32
    1a22:	8082                	ret
      printf("%s: fork failed\n", s);
    1a24:	85ca                	mv	a1,s2
    1a26:	00005517          	auipc	a0,0x5
    1a2a:	b3a50513          	addi	a0,a0,-1222 # 6560 <malloc+0xc64>
    1a2e:	00004097          	auipc	ra,0x4
    1a32:	e10080e7          	jalr	-496(ra) # 583e <printf>
      exit(1);
    1a36:	4505                	li	a0,1
    1a38:	00004097          	auipc	ra,0x4
    1a3c:	a8e080e7          	jalr	-1394(ra) # 54c6 <exit>
      exit(0);
    1a40:	00004097          	auipc	ra,0x4
    1a44:	a86080e7          	jalr	-1402(ra) # 54c6 <exit>
        printf("%s: fork failed\n", s);
    1a48:	85ca                	mv	a1,s2
    1a4a:	00005517          	auipc	a0,0x5
    1a4e:	b1650513          	addi	a0,a0,-1258 # 6560 <malloc+0xc64>
    1a52:	00004097          	auipc	ra,0x4
    1a56:	dec080e7          	jalr	-532(ra) # 583e <printf>
        exit(1);
    1a5a:	4505                	li	a0,1
    1a5c:	00004097          	auipc	ra,0x4
    1a60:	a6a080e7          	jalr	-1430(ra) # 54c6 <exit>
        exit(0);
    1a64:	00004097          	auipc	ra,0x4
    1a68:	a62080e7          	jalr	-1438(ra) # 54c6 <exit>

0000000000001a6c <forkfork>:
{
    1a6c:	7179                	addi	sp,sp,-48
    1a6e:	f406                	sd	ra,40(sp)
    1a70:	f022                	sd	s0,32(sp)
    1a72:	ec26                	sd	s1,24(sp)
    1a74:	1800                	addi	s0,sp,48
    1a76:	84aa                	mv	s1,a0
    int pid = fork();
    1a78:	00004097          	auipc	ra,0x4
    1a7c:	a46080e7          	jalr	-1466(ra) # 54be <fork>
    if(pid < 0){
    1a80:	04054163          	bltz	a0,1ac2 <forkfork+0x56>
    if(pid == 0){
    1a84:	cd29                	beqz	a0,1ade <forkfork+0x72>
    int pid = fork();
    1a86:	00004097          	auipc	ra,0x4
    1a8a:	a38080e7          	jalr	-1480(ra) # 54be <fork>
    if(pid < 0){
    1a8e:	02054a63          	bltz	a0,1ac2 <forkfork+0x56>
    if(pid == 0){
    1a92:	c531                	beqz	a0,1ade <forkfork+0x72>
    wait(&xstatus);
    1a94:	fdc40513          	addi	a0,s0,-36
    1a98:	00004097          	auipc	ra,0x4
    1a9c:	a36080e7          	jalr	-1482(ra) # 54ce <wait>
    if(xstatus != 0) {
    1aa0:	fdc42783          	lw	a5,-36(s0)
    1aa4:	ebbd                	bnez	a5,1b1a <forkfork+0xae>
    wait(&xstatus);
    1aa6:	fdc40513          	addi	a0,s0,-36
    1aaa:	00004097          	auipc	ra,0x4
    1aae:	a24080e7          	jalr	-1500(ra) # 54ce <wait>
    if(xstatus != 0) {
    1ab2:	fdc42783          	lw	a5,-36(s0)
    1ab6:	e3b5                	bnez	a5,1b1a <forkfork+0xae>
}
    1ab8:	70a2                	ld	ra,40(sp)
    1aba:	7402                	ld	s0,32(sp)
    1abc:	64e2                	ld	s1,24(sp)
    1abe:	6145                	addi	sp,sp,48
    1ac0:	8082                	ret
      printf("%s: fork failed", s);
    1ac2:	85a6                	mv	a1,s1
    1ac4:	00005517          	auipc	a0,0x5
    1ac8:	c5c50513          	addi	a0,a0,-932 # 6720 <malloc+0xe24>
    1acc:	00004097          	auipc	ra,0x4
    1ad0:	d72080e7          	jalr	-654(ra) # 583e <printf>
      exit(1);
    1ad4:	4505                	li	a0,1
    1ad6:	00004097          	auipc	ra,0x4
    1ada:	9f0080e7          	jalr	-1552(ra) # 54c6 <exit>
{
    1ade:	0c800493          	li	s1,200
        int pid1 = fork();
    1ae2:	00004097          	auipc	ra,0x4
    1ae6:	9dc080e7          	jalr	-1572(ra) # 54be <fork>
        if(pid1 < 0){
    1aea:	00054f63          	bltz	a0,1b08 <forkfork+0x9c>
        if(pid1 == 0){
    1aee:	c115                	beqz	a0,1b12 <forkfork+0xa6>
        wait(0);
    1af0:	4501                	li	a0,0
    1af2:	00004097          	auipc	ra,0x4
    1af6:	9dc080e7          	jalr	-1572(ra) # 54ce <wait>
      for(int j = 0; j < 200; j++){
    1afa:	34fd                	addiw	s1,s1,-1
    1afc:	f0fd                	bnez	s1,1ae2 <forkfork+0x76>
      exit(0);
    1afe:	4501                	li	a0,0
    1b00:	00004097          	auipc	ra,0x4
    1b04:	9c6080e7          	jalr	-1594(ra) # 54c6 <exit>
          exit(1);
    1b08:	4505                	li	a0,1
    1b0a:	00004097          	auipc	ra,0x4
    1b0e:	9bc080e7          	jalr	-1604(ra) # 54c6 <exit>
          exit(0);
    1b12:	00004097          	auipc	ra,0x4
    1b16:	9b4080e7          	jalr	-1612(ra) # 54c6 <exit>
      printf("%s: fork in child failed", s);
    1b1a:	85a6                	mv	a1,s1
    1b1c:	00005517          	auipc	a0,0x5
    1b20:	c1450513          	addi	a0,a0,-1004 # 6730 <malloc+0xe34>
    1b24:	00004097          	auipc	ra,0x4
    1b28:	d1a080e7          	jalr	-742(ra) # 583e <printf>
      exit(1);
    1b2c:	4505                	li	a0,1
    1b2e:	00004097          	auipc	ra,0x4
    1b32:	998080e7          	jalr	-1640(ra) # 54c6 <exit>

0000000000001b36 <reparent2>:
{
    1b36:	1101                	addi	sp,sp,-32
    1b38:	ec06                	sd	ra,24(sp)
    1b3a:	e822                	sd	s0,16(sp)
    1b3c:	e426                	sd	s1,8(sp)
    1b3e:	1000                	addi	s0,sp,32
    1b40:	32000493          	li	s1,800
    int pid1 = fork();
    1b44:	00004097          	auipc	ra,0x4
    1b48:	97a080e7          	jalr	-1670(ra) # 54be <fork>
    if(pid1 < 0){
    1b4c:	00054f63          	bltz	a0,1b6a <reparent2+0x34>
    if(pid1 == 0){
    1b50:	c915                	beqz	a0,1b84 <reparent2+0x4e>
    wait(0);
    1b52:	4501                	li	a0,0
    1b54:	00004097          	auipc	ra,0x4
    1b58:	97a080e7          	jalr	-1670(ra) # 54ce <wait>
  for(int i = 0; i < 800; i++){
    1b5c:	34fd                	addiw	s1,s1,-1
    1b5e:	f0fd                	bnez	s1,1b44 <reparent2+0xe>
  exit(0);
    1b60:	4501                	li	a0,0
    1b62:	00004097          	auipc	ra,0x4
    1b66:	964080e7          	jalr	-1692(ra) # 54c6 <exit>
      printf("fork failed\n");
    1b6a:	00005517          	auipc	a0,0x5
    1b6e:	de650513          	addi	a0,a0,-538 # 6950 <malloc+0x1054>
    1b72:	00004097          	auipc	ra,0x4
    1b76:	ccc080e7          	jalr	-820(ra) # 583e <printf>
      exit(1);
    1b7a:	4505                	li	a0,1
    1b7c:	00004097          	auipc	ra,0x4
    1b80:	94a080e7          	jalr	-1718(ra) # 54c6 <exit>
      fork();
    1b84:	00004097          	auipc	ra,0x4
    1b88:	93a080e7          	jalr	-1734(ra) # 54be <fork>
      fork();
    1b8c:	00004097          	auipc	ra,0x4
    1b90:	932080e7          	jalr	-1742(ra) # 54be <fork>
      exit(0);
    1b94:	4501                	li	a0,0
    1b96:	00004097          	auipc	ra,0x4
    1b9a:	930080e7          	jalr	-1744(ra) # 54c6 <exit>

0000000000001b9e <createdelete>:
{
    1b9e:	7175                	addi	sp,sp,-144
    1ba0:	e506                	sd	ra,136(sp)
    1ba2:	e122                	sd	s0,128(sp)
    1ba4:	fca6                	sd	s1,120(sp)
    1ba6:	f8ca                	sd	s2,112(sp)
    1ba8:	f4ce                	sd	s3,104(sp)
    1baa:	f0d2                	sd	s4,96(sp)
    1bac:	ecd6                	sd	s5,88(sp)
    1bae:	e8da                	sd	s6,80(sp)
    1bb0:	e4de                	sd	s7,72(sp)
    1bb2:	e0e2                	sd	s8,64(sp)
    1bb4:	fc66                	sd	s9,56(sp)
    1bb6:	0900                	addi	s0,sp,144
    1bb8:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1bba:	4901                	li	s2,0
    1bbc:	4991                	li	s3,4
    pid = fork();
    1bbe:	00004097          	auipc	ra,0x4
    1bc2:	900080e7          	jalr	-1792(ra) # 54be <fork>
    1bc6:	84aa                	mv	s1,a0
    if(pid < 0){
    1bc8:	02054f63          	bltz	a0,1c06 <createdelete+0x68>
    if(pid == 0){
    1bcc:	c939                	beqz	a0,1c22 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bce:	2905                	addiw	s2,s2,1
    1bd0:	ff3917e3          	bne	s2,s3,1bbe <createdelete+0x20>
    1bd4:	4491                	li	s1,4
    wait(&xstatus);
    1bd6:	f7c40513          	addi	a0,s0,-132
    1bda:	00004097          	auipc	ra,0x4
    1bde:	8f4080e7          	jalr	-1804(ra) # 54ce <wait>
    if(xstatus != 0)
    1be2:	f7c42903          	lw	s2,-132(s0)
    1be6:	0e091263          	bnez	s2,1cca <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bea:	34fd                	addiw	s1,s1,-1
    1bec:	f4ed                	bnez	s1,1bd6 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1bee:	f8040123          	sb	zero,-126(s0)
    1bf2:	03000993          	li	s3,48
    1bf6:	5a7d                	li	s4,-1
    1bf8:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1bfc:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1bfe:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1c00:	07400a93          	li	s5,116
    1c04:	a29d                	j	1d6a <createdelete+0x1cc>
      printf("fork failed\n", s);
    1c06:	85e6                	mv	a1,s9
    1c08:	00005517          	auipc	a0,0x5
    1c0c:	d4850513          	addi	a0,a0,-696 # 6950 <malloc+0x1054>
    1c10:	00004097          	auipc	ra,0x4
    1c14:	c2e080e7          	jalr	-978(ra) # 583e <printf>
      exit(1);
    1c18:	4505                	li	a0,1
    1c1a:	00004097          	auipc	ra,0x4
    1c1e:	8ac080e7          	jalr	-1876(ra) # 54c6 <exit>
      name[0] = 'p' + pi;
    1c22:	0709091b          	addiw	s2,s2,112
    1c26:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c2a:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c2e:	4951                	li	s2,20
    1c30:	a015                	j	1c54 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c32:	85e6                	mv	a1,s9
    1c34:	00005517          	auipc	a0,0x5
    1c38:	9c450513          	addi	a0,a0,-1596 # 65f8 <malloc+0xcfc>
    1c3c:	00004097          	auipc	ra,0x4
    1c40:	c02080e7          	jalr	-1022(ra) # 583e <printf>
          exit(1);
    1c44:	4505                	li	a0,1
    1c46:	00004097          	auipc	ra,0x4
    1c4a:	880080e7          	jalr	-1920(ra) # 54c6 <exit>
      for(i = 0; i < N; i++){
    1c4e:	2485                	addiw	s1,s1,1
    1c50:	07248863          	beq	s1,s2,1cc0 <createdelete+0x122>
        name[1] = '0' + i;
    1c54:	0304879b          	addiw	a5,s1,48
    1c58:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c5c:	20200593          	li	a1,514
    1c60:	f8040513          	addi	a0,s0,-128
    1c64:	00004097          	auipc	ra,0x4
    1c68:	8a2080e7          	jalr	-1886(ra) # 5506 <open>
        if(fd < 0){
    1c6c:	fc0543e3          	bltz	a0,1c32 <createdelete+0x94>
        close(fd);
    1c70:	00004097          	auipc	ra,0x4
    1c74:	87e080e7          	jalr	-1922(ra) # 54ee <close>
        if(i > 0 && (i % 2 ) == 0){
    1c78:	fc905be3          	blez	s1,1c4e <createdelete+0xb0>
    1c7c:	0014f793          	andi	a5,s1,1
    1c80:	f7f9                	bnez	a5,1c4e <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c82:	01f4d79b          	srliw	a5,s1,0x1f
    1c86:	9fa5                	addw	a5,a5,s1
    1c88:	4017d79b          	sraiw	a5,a5,0x1
    1c8c:	0307879b          	addiw	a5,a5,48
    1c90:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1c94:	f8040513          	addi	a0,s0,-128
    1c98:	00004097          	auipc	ra,0x4
    1c9c:	87e080e7          	jalr	-1922(ra) # 5516 <unlink>
    1ca0:	fa0557e3          	bgez	a0,1c4e <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1ca4:	85e6                	mv	a1,s9
    1ca6:	00005517          	auipc	a0,0x5
    1caa:	aaa50513          	addi	a0,a0,-1366 # 6750 <malloc+0xe54>
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	b90080e7          	jalr	-1136(ra) # 583e <printf>
            exit(1);
    1cb6:	4505                	li	a0,1
    1cb8:	00004097          	auipc	ra,0x4
    1cbc:	80e080e7          	jalr	-2034(ra) # 54c6 <exit>
      exit(0);
    1cc0:	4501                	li	a0,0
    1cc2:	00004097          	auipc	ra,0x4
    1cc6:	804080e7          	jalr	-2044(ra) # 54c6 <exit>
      exit(1);
    1cca:	4505                	li	a0,1
    1ccc:	00003097          	auipc	ra,0x3
    1cd0:	7fa080e7          	jalr	2042(ra) # 54c6 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cd4:	f8040613          	addi	a2,s0,-128
    1cd8:	85e6                	mv	a1,s9
    1cda:	00005517          	auipc	a0,0x5
    1cde:	a8e50513          	addi	a0,a0,-1394 # 6768 <malloc+0xe6c>
    1ce2:	00004097          	auipc	ra,0x4
    1ce6:	b5c080e7          	jalr	-1188(ra) # 583e <printf>
        exit(1);
    1cea:	4505                	li	a0,1
    1cec:	00003097          	auipc	ra,0x3
    1cf0:	7da080e7          	jalr	2010(ra) # 54c6 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1cf4:	054b7163          	bgeu	s6,s4,1d36 <createdelete+0x198>
      if(fd >= 0)
    1cf8:	02055a63          	bgez	a0,1d2c <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1cfc:	2485                	addiw	s1,s1,1
    1cfe:	0ff4f493          	andi	s1,s1,255
    1d02:	05548c63          	beq	s1,s5,1d5a <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1d06:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1d0a:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1d0e:	4581                	li	a1,0
    1d10:	f8040513          	addi	a0,s0,-128
    1d14:	00003097          	auipc	ra,0x3
    1d18:	7f2080e7          	jalr	2034(ra) # 5506 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d1c:	00090463          	beqz	s2,1d24 <createdelete+0x186>
    1d20:	fd2bdae3          	bge	s7,s2,1cf4 <createdelete+0x156>
    1d24:	fa0548e3          	bltz	a0,1cd4 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d28:	014b7963          	bgeu	s6,s4,1d3a <createdelete+0x19c>
        close(fd);
    1d2c:	00003097          	auipc	ra,0x3
    1d30:	7c2080e7          	jalr	1986(ra) # 54ee <close>
    1d34:	b7e1                	j	1cfc <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d36:	fc0543e3          	bltz	a0,1cfc <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d3a:	f8040613          	addi	a2,s0,-128
    1d3e:	85e6                	mv	a1,s9
    1d40:	00005517          	auipc	a0,0x5
    1d44:	a5050513          	addi	a0,a0,-1456 # 6790 <malloc+0xe94>
    1d48:	00004097          	auipc	ra,0x4
    1d4c:	af6080e7          	jalr	-1290(ra) # 583e <printf>
        exit(1);
    1d50:	4505                	li	a0,1
    1d52:	00003097          	auipc	ra,0x3
    1d56:	774080e7          	jalr	1908(ra) # 54c6 <exit>
  for(i = 0; i < N; i++){
    1d5a:	2905                	addiw	s2,s2,1
    1d5c:	2a05                	addiw	s4,s4,1
    1d5e:	2985                	addiw	s3,s3,1
    1d60:	0ff9f993          	andi	s3,s3,255
    1d64:	47d1                	li	a5,20
    1d66:	02f90a63          	beq	s2,a5,1d9a <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d6a:	84e2                	mv	s1,s8
    1d6c:	bf69                	j	1d06 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d6e:	2905                	addiw	s2,s2,1
    1d70:	0ff97913          	andi	s2,s2,255
    1d74:	2985                	addiw	s3,s3,1
    1d76:	0ff9f993          	andi	s3,s3,255
    1d7a:	03490863          	beq	s2,s4,1daa <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d7e:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d80:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d84:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d88:	f8040513          	addi	a0,s0,-128
    1d8c:	00003097          	auipc	ra,0x3
    1d90:	78a080e7          	jalr	1930(ra) # 5516 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1d94:	34fd                	addiw	s1,s1,-1
    1d96:	f4ed                	bnez	s1,1d80 <createdelete+0x1e2>
    1d98:	bfd9                	j	1d6e <createdelete+0x1d0>
    1d9a:	03000993          	li	s3,48
    1d9e:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1da2:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1da4:	08400a13          	li	s4,132
    1da8:	bfd9                	j	1d7e <createdelete+0x1e0>
}
    1daa:	60aa                	ld	ra,136(sp)
    1dac:	640a                	ld	s0,128(sp)
    1dae:	74e6                	ld	s1,120(sp)
    1db0:	7946                	ld	s2,112(sp)
    1db2:	79a6                	ld	s3,104(sp)
    1db4:	7a06                	ld	s4,96(sp)
    1db6:	6ae6                	ld	s5,88(sp)
    1db8:	6b46                	ld	s6,80(sp)
    1dba:	6ba6                	ld	s7,72(sp)
    1dbc:	6c06                	ld	s8,64(sp)
    1dbe:	7ce2                	ld	s9,56(sp)
    1dc0:	6149                	addi	sp,sp,144
    1dc2:	8082                	ret

0000000000001dc4 <linkunlink>:
{
    1dc4:	711d                	addi	sp,sp,-96
    1dc6:	ec86                	sd	ra,88(sp)
    1dc8:	e8a2                	sd	s0,80(sp)
    1dca:	e4a6                	sd	s1,72(sp)
    1dcc:	e0ca                	sd	s2,64(sp)
    1dce:	fc4e                	sd	s3,56(sp)
    1dd0:	f852                	sd	s4,48(sp)
    1dd2:	f456                	sd	s5,40(sp)
    1dd4:	f05a                	sd	s6,32(sp)
    1dd6:	ec5e                	sd	s7,24(sp)
    1dd8:	e862                	sd	s8,16(sp)
    1dda:	e466                	sd	s9,8(sp)
    1ddc:	1080                	addi	s0,sp,96
    1dde:	84aa                	mv	s1,a0
  unlink("x");
    1de0:	00004517          	auipc	a0,0x4
    1de4:	fb850513          	addi	a0,a0,-72 # 5d98 <malloc+0x49c>
    1de8:	00003097          	auipc	ra,0x3
    1dec:	72e080e7          	jalr	1838(ra) # 5516 <unlink>
  pid = fork();
    1df0:	00003097          	auipc	ra,0x3
    1df4:	6ce080e7          	jalr	1742(ra) # 54be <fork>
  if(pid < 0){
    1df8:	02054b63          	bltz	a0,1e2e <linkunlink+0x6a>
    1dfc:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1dfe:	4c85                	li	s9,1
    1e00:	e119                	bnez	a0,1e06 <linkunlink+0x42>
    1e02:	06100c93          	li	s9,97
    1e06:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1e0a:	41c659b7          	lui	s3,0x41c65
    1e0e:	e6d9899b          	addiw	s3,s3,-403
    1e12:	690d                	lui	s2,0x3
    1e14:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e18:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e1a:	4b05                	li	s6,1
      unlink("x");
    1e1c:	00004a97          	auipc	s5,0x4
    1e20:	f7ca8a93          	addi	s5,s5,-132 # 5d98 <malloc+0x49c>
      link("cat", "x");
    1e24:	00005b97          	auipc	s7,0x5
    1e28:	994b8b93          	addi	s7,s7,-1644 # 67b8 <malloc+0xebc>
    1e2c:	a825                	j	1e64 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    1e2e:	85a6                	mv	a1,s1
    1e30:	00004517          	auipc	a0,0x4
    1e34:	73050513          	addi	a0,a0,1840 # 6560 <malloc+0xc64>
    1e38:	00004097          	auipc	ra,0x4
    1e3c:	a06080e7          	jalr	-1530(ra) # 583e <printf>
    exit(1);
    1e40:	4505                	li	a0,1
    1e42:	00003097          	auipc	ra,0x3
    1e46:	684080e7          	jalr	1668(ra) # 54c6 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e4a:	20200593          	li	a1,514
    1e4e:	8556                	mv	a0,s5
    1e50:	00003097          	auipc	ra,0x3
    1e54:	6b6080e7          	jalr	1718(ra) # 5506 <open>
    1e58:	00003097          	auipc	ra,0x3
    1e5c:	696080e7          	jalr	1686(ra) # 54ee <close>
  for(i = 0; i < 100; i++){
    1e60:	34fd                	addiw	s1,s1,-1
    1e62:	c88d                	beqz	s1,1e94 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e64:	033c87bb          	mulw	a5,s9,s3
    1e68:	012787bb          	addw	a5,a5,s2
    1e6c:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e70:	0347f7bb          	remuw	a5,a5,s4
    1e74:	dbf9                	beqz	a5,1e4a <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e76:	01678863          	beq	a5,s6,1e86 <linkunlink+0xc2>
      unlink("x");
    1e7a:	8556                	mv	a0,s5
    1e7c:	00003097          	auipc	ra,0x3
    1e80:	69a080e7          	jalr	1690(ra) # 5516 <unlink>
    1e84:	bff1                	j	1e60 <linkunlink+0x9c>
      link("cat", "x");
    1e86:	85d6                	mv	a1,s5
    1e88:	855e                	mv	a0,s7
    1e8a:	00003097          	auipc	ra,0x3
    1e8e:	69c080e7          	jalr	1692(ra) # 5526 <link>
    1e92:	b7f9                	j	1e60 <linkunlink+0x9c>
  if(pid)
    1e94:	020c0463          	beqz	s8,1ebc <linkunlink+0xf8>
    wait(0);
    1e98:	4501                	li	a0,0
    1e9a:	00003097          	auipc	ra,0x3
    1e9e:	634080e7          	jalr	1588(ra) # 54ce <wait>
}
    1ea2:	60e6                	ld	ra,88(sp)
    1ea4:	6446                	ld	s0,80(sp)
    1ea6:	64a6                	ld	s1,72(sp)
    1ea8:	6906                	ld	s2,64(sp)
    1eaa:	79e2                	ld	s3,56(sp)
    1eac:	7a42                	ld	s4,48(sp)
    1eae:	7aa2                	ld	s5,40(sp)
    1eb0:	7b02                	ld	s6,32(sp)
    1eb2:	6be2                	ld	s7,24(sp)
    1eb4:	6c42                	ld	s8,16(sp)
    1eb6:	6ca2                	ld	s9,8(sp)
    1eb8:	6125                	addi	sp,sp,96
    1eba:	8082                	ret
    exit(0);
    1ebc:	4501                	li	a0,0
    1ebe:	00003097          	auipc	ra,0x3
    1ec2:	608080e7          	jalr	1544(ra) # 54c6 <exit>

0000000000001ec6 <forktest>:
{
    1ec6:	7179                	addi	sp,sp,-48
    1ec8:	f406                	sd	ra,40(sp)
    1eca:	f022                	sd	s0,32(sp)
    1ecc:	ec26                	sd	s1,24(sp)
    1ece:	e84a                	sd	s2,16(sp)
    1ed0:	e44e                	sd	s3,8(sp)
    1ed2:	1800                	addi	s0,sp,48
    1ed4:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1ed6:	4481                	li	s1,0
    1ed8:	3e800913          	li	s2,1000
    pid = fork();
    1edc:	00003097          	auipc	ra,0x3
    1ee0:	5e2080e7          	jalr	1506(ra) # 54be <fork>
    if(pid < 0)
    1ee4:	02054863          	bltz	a0,1f14 <forktest+0x4e>
    if(pid == 0)
    1ee8:	c115                	beqz	a0,1f0c <forktest+0x46>
  for(n=0; n<N; n++){
    1eea:	2485                	addiw	s1,s1,1
    1eec:	ff2498e3          	bne	s1,s2,1edc <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1ef0:	85ce                	mv	a1,s3
    1ef2:	00005517          	auipc	a0,0x5
    1ef6:	8e650513          	addi	a0,a0,-1818 # 67d8 <malloc+0xedc>
    1efa:	00004097          	auipc	ra,0x4
    1efe:	944080e7          	jalr	-1724(ra) # 583e <printf>
    exit(1);
    1f02:	4505                	li	a0,1
    1f04:	00003097          	auipc	ra,0x3
    1f08:	5c2080e7          	jalr	1474(ra) # 54c6 <exit>
      exit(0);
    1f0c:	00003097          	auipc	ra,0x3
    1f10:	5ba080e7          	jalr	1466(ra) # 54c6 <exit>
  if (n == 0) {
    1f14:	cc9d                	beqz	s1,1f52 <forktest+0x8c>
  if(n == N){
    1f16:	3e800793          	li	a5,1000
    1f1a:	fcf48be3          	beq	s1,a5,1ef0 <forktest+0x2a>
  for(; n > 0; n--){
    1f1e:	00905b63          	blez	s1,1f34 <forktest+0x6e>
    if(wait(0) < 0){
    1f22:	4501                	li	a0,0
    1f24:	00003097          	auipc	ra,0x3
    1f28:	5aa080e7          	jalr	1450(ra) # 54ce <wait>
    1f2c:	04054163          	bltz	a0,1f6e <forktest+0xa8>
  for(; n > 0; n--){
    1f30:	34fd                	addiw	s1,s1,-1
    1f32:	f8e5                	bnez	s1,1f22 <forktest+0x5c>
  if(wait(0) != -1){
    1f34:	4501                	li	a0,0
    1f36:	00003097          	auipc	ra,0x3
    1f3a:	598080e7          	jalr	1432(ra) # 54ce <wait>
    1f3e:	57fd                	li	a5,-1
    1f40:	04f51563          	bne	a0,a5,1f8a <forktest+0xc4>
}
    1f44:	70a2                	ld	ra,40(sp)
    1f46:	7402                	ld	s0,32(sp)
    1f48:	64e2                	ld	s1,24(sp)
    1f4a:	6942                	ld	s2,16(sp)
    1f4c:	69a2                	ld	s3,8(sp)
    1f4e:	6145                	addi	sp,sp,48
    1f50:	8082                	ret
    printf("%s: no fork at all!\n", s);
    1f52:	85ce                	mv	a1,s3
    1f54:	00005517          	auipc	a0,0x5
    1f58:	86c50513          	addi	a0,a0,-1940 # 67c0 <malloc+0xec4>
    1f5c:	00004097          	auipc	ra,0x4
    1f60:	8e2080e7          	jalr	-1822(ra) # 583e <printf>
    exit(1);
    1f64:	4505                	li	a0,1
    1f66:	00003097          	auipc	ra,0x3
    1f6a:	560080e7          	jalr	1376(ra) # 54c6 <exit>
      printf("%s: wait stopped early\n", s);
    1f6e:	85ce                	mv	a1,s3
    1f70:	00005517          	auipc	a0,0x5
    1f74:	89050513          	addi	a0,a0,-1904 # 6800 <malloc+0xf04>
    1f78:	00004097          	auipc	ra,0x4
    1f7c:	8c6080e7          	jalr	-1850(ra) # 583e <printf>
      exit(1);
    1f80:	4505                	li	a0,1
    1f82:	00003097          	auipc	ra,0x3
    1f86:	544080e7          	jalr	1348(ra) # 54c6 <exit>
    printf("%s: wait got too many\n", s);
    1f8a:	85ce                	mv	a1,s3
    1f8c:	00005517          	auipc	a0,0x5
    1f90:	88c50513          	addi	a0,a0,-1908 # 6818 <malloc+0xf1c>
    1f94:	00004097          	auipc	ra,0x4
    1f98:	8aa080e7          	jalr	-1878(ra) # 583e <printf>
    exit(1);
    1f9c:	4505                	li	a0,1
    1f9e:	00003097          	auipc	ra,0x3
    1fa2:	528080e7          	jalr	1320(ra) # 54c6 <exit>

0000000000001fa6 <kernmem>:
{
    1fa6:	715d                	addi	sp,sp,-80
    1fa8:	e486                	sd	ra,72(sp)
    1faa:	e0a2                	sd	s0,64(sp)
    1fac:	fc26                	sd	s1,56(sp)
    1fae:	f84a                	sd	s2,48(sp)
    1fb0:	f44e                	sd	s3,40(sp)
    1fb2:	f052                	sd	s4,32(sp)
    1fb4:	ec56                	sd	s5,24(sp)
    1fb6:	0880                	addi	s0,sp,80
    1fb8:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fba:	4485                	li	s1,1
    1fbc:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1fbe:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fc0:	69b1                	lui	s3,0xc
    1fc2:	35098993          	addi	s3,s3,848 # c350 <buf+0xa30>
    1fc6:	1003d937          	lui	s2,0x1003d
    1fca:	090e                	slli	s2,s2,0x3
    1fcc:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002eb50>
    pid = fork();
    1fd0:	00003097          	auipc	ra,0x3
    1fd4:	4ee080e7          	jalr	1262(ra) # 54be <fork>
    if(pid < 0){
    1fd8:	02054963          	bltz	a0,200a <kernmem+0x64>
    if(pid == 0){
    1fdc:	c529                	beqz	a0,2026 <kernmem+0x80>
    wait(&xstatus);
    1fde:	fbc40513          	addi	a0,s0,-68
    1fe2:	00003097          	auipc	ra,0x3
    1fe6:	4ec080e7          	jalr	1260(ra) # 54ce <wait>
    if(xstatus != -1)  // did kernel kill child?
    1fea:	fbc42783          	lw	a5,-68(s0)
    1fee:	05579d63          	bne	a5,s5,2048 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1ff2:	94ce                	add	s1,s1,s3
    1ff4:	fd249ee3          	bne	s1,s2,1fd0 <kernmem+0x2a>
}
    1ff8:	60a6                	ld	ra,72(sp)
    1ffa:	6406                	ld	s0,64(sp)
    1ffc:	74e2                	ld	s1,56(sp)
    1ffe:	7942                	ld	s2,48(sp)
    2000:	79a2                	ld	s3,40(sp)
    2002:	7a02                	ld	s4,32(sp)
    2004:	6ae2                	ld	s5,24(sp)
    2006:	6161                	addi	sp,sp,80
    2008:	8082                	ret
      printf("%s: fork failed\n", s);
    200a:	85d2                	mv	a1,s4
    200c:	00004517          	auipc	a0,0x4
    2010:	55450513          	addi	a0,a0,1364 # 6560 <malloc+0xc64>
    2014:	00004097          	auipc	ra,0x4
    2018:	82a080e7          	jalr	-2006(ra) # 583e <printf>
      exit(1);
    201c:	4505                	li	a0,1
    201e:	00003097          	auipc	ra,0x3
    2022:	4a8080e7          	jalr	1192(ra) # 54c6 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    2026:	0004c683          	lbu	a3,0(s1)
    202a:	8626                	mv	a2,s1
    202c:	85d2                	mv	a1,s4
    202e:	00005517          	auipc	a0,0x5
    2032:	80250513          	addi	a0,a0,-2046 # 6830 <malloc+0xf34>
    2036:	00004097          	auipc	ra,0x4
    203a:	808080e7          	jalr	-2040(ra) # 583e <printf>
      exit(1);
    203e:	4505                	li	a0,1
    2040:	00003097          	auipc	ra,0x3
    2044:	486080e7          	jalr	1158(ra) # 54c6 <exit>
      exit(1);
    2048:	4505                	li	a0,1
    204a:	00003097          	auipc	ra,0x3
    204e:	47c080e7          	jalr	1148(ra) # 54c6 <exit>

0000000000002052 <bigargtest>:
{
    2052:	7179                	addi	sp,sp,-48
    2054:	f406                	sd	ra,40(sp)
    2056:	f022                	sd	s0,32(sp)
    2058:	ec26                	sd	s1,24(sp)
    205a:	1800                	addi	s0,sp,48
    205c:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    205e:	00004517          	auipc	a0,0x4
    2062:	7f250513          	addi	a0,a0,2034 # 6850 <malloc+0xf54>
    2066:	00003097          	auipc	ra,0x3
    206a:	4b0080e7          	jalr	1200(ra) # 5516 <unlink>
  pid = fork();
    206e:	00003097          	auipc	ra,0x3
    2072:	450080e7          	jalr	1104(ra) # 54be <fork>
  if(pid == 0){
    2076:	c121                	beqz	a0,20b6 <bigargtest+0x64>
  } else if(pid < 0){
    2078:	0a054063          	bltz	a0,2118 <bigargtest+0xc6>
  wait(&xstatus);
    207c:	fdc40513          	addi	a0,s0,-36
    2080:	00003097          	auipc	ra,0x3
    2084:	44e080e7          	jalr	1102(ra) # 54ce <wait>
  if(xstatus != 0)
    2088:	fdc42503          	lw	a0,-36(s0)
    208c:	e545                	bnez	a0,2134 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    208e:	4581                	li	a1,0
    2090:	00004517          	auipc	a0,0x4
    2094:	7c050513          	addi	a0,a0,1984 # 6850 <malloc+0xf54>
    2098:	00003097          	auipc	ra,0x3
    209c:	46e080e7          	jalr	1134(ra) # 5506 <open>
  if(fd < 0){
    20a0:	08054e63          	bltz	a0,213c <bigargtest+0xea>
  close(fd);
    20a4:	00003097          	auipc	ra,0x3
    20a8:	44a080e7          	jalr	1098(ra) # 54ee <close>
}
    20ac:	70a2                	ld	ra,40(sp)
    20ae:	7402                	ld	s0,32(sp)
    20b0:	64e2                	ld	s1,24(sp)
    20b2:	6145                	addi	sp,sp,48
    20b4:	8082                	ret
    20b6:	00006797          	auipc	a5,0x6
    20ba:	05278793          	addi	a5,a5,82 # 8108 <args.1>
    20be:	00006697          	auipc	a3,0x6
    20c2:	14268693          	addi	a3,a3,322 # 8200 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    20c6:	00004717          	auipc	a4,0x4
    20ca:	79a70713          	addi	a4,a4,1946 # 6860 <malloc+0xf64>
    20ce:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    20d0:	07a1                	addi	a5,a5,8
    20d2:	fed79ee3          	bne	a5,a3,20ce <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    20d6:	00006597          	auipc	a1,0x6
    20da:	03258593          	addi	a1,a1,50 # 8108 <args.1>
    20de:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    20e2:	00004517          	auipc	a0,0x4
    20e6:	c4650513          	addi	a0,a0,-954 # 5d28 <malloc+0x42c>
    20ea:	00003097          	auipc	ra,0x3
    20ee:	414080e7          	jalr	1044(ra) # 54fe <exec>
    fd = open("bigarg-ok", O_CREATE);
    20f2:	20000593          	li	a1,512
    20f6:	00004517          	auipc	a0,0x4
    20fa:	75a50513          	addi	a0,a0,1882 # 6850 <malloc+0xf54>
    20fe:	00003097          	auipc	ra,0x3
    2102:	408080e7          	jalr	1032(ra) # 5506 <open>
    close(fd);
    2106:	00003097          	auipc	ra,0x3
    210a:	3e8080e7          	jalr	1000(ra) # 54ee <close>
    exit(0);
    210e:	4501                	li	a0,0
    2110:	00003097          	auipc	ra,0x3
    2114:	3b6080e7          	jalr	950(ra) # 54c6 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    2118:	85a6                	mv	a1,s1
    211a:	00005517          	auipc	a0,0x5
    211e:	82650513          	addi	a0,a0,-2010 # 6940 <malloc+0x1044>
    2122:	00003097          	auipc	ra,0x3
    2126:	71c080e7          	jalr	1820(ra) # 583e <printf>
    exit(1);
    212a:	4505                	li	a0,1
    212c:	00003097          	auipc	ra,0x3
    2130:	39a080e7          	jalr	922(ra) # 54c6 <exit>
    exit(xstatus);
    2134:	00003097          	auipc	ra,0x3
    2138:	392080e7          	jalr	914(ra) # 54c6 <exit>
    printf("%s: bigarg test failed!\n", s);
    213c:	85a6                	mv	a1,s1
    213e:	00005517          	auipc	a0,0x5
    2142:	82250513          	addi	a0,a0,-2014 # 6960 <malloc+0x1064>
    2146:	00003097          	auipc	ra,0x3
    214a:	6f8080e7          	jalr	1784(ra) # 583e <printf>
    exit(1);
    214e:	4505                	li	a0,1
    2150:	00003097          	auipc	ra,0x3
    2154:	376080e7          	jalr	886(ra) # 54c6 <exit>

0000000000002158 <stacktest>:
{
    2158:	7179                	addi	sp,sp,-48
    215a:	f406                	sd	ra,40(sp)
    215c:	f022                	sd	s0,32(sp)
    215e:	ec26                	sd	s1,24(sp)
    2160:	1800                	addi	s0,sp,48
    2162:	84aa                	mv	s1,a0
  pid = fork();
    2164:	00003097          	auipc	ra,0x3
    2168:	35a080e7          	jalr	858(ra) # 54be <fork>
  if(pid == 0) {
    216c:	c115                	beqz	a0,2190 <stacktest+0x38>
  } else if(pid < 0){
    216e:	04054463          	bltz	a0,21b6 <stacktest+0x5e>
  wait(&xstatus);
    2172:	fdc40513          	addi	a0,s0,-36
    2176:	00003097          	auipc	ra,0x3
    217a:	358080e7          	jalr	856(ra) # 54ce <wait>
  if(xstatus == -1)  // kernel killed child?
    217e:	fdc42503          	lw	a0,-36(s0)
    2182:	57fd                	li	a5,-1
    2184:	04f50763          	beq	a0,a5,21d2 <stacktest+0x7a>
    exit(xstatus);
    2188:	00003097          	auipc	ra,0x3
    218c:	33e080e7          	jalr	830(ra) # 54c6 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    2190:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    2192:	77fd                	lui	a5,0xfffff
    2194:	97ba                	add	a5,a5,a4
    2196:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff06d0>
    219a:	85a6                	mv	a1,s1
    219c:	00004517          	auipc	a0,0x4
    21a0:	7e450513          	addi	a0,a0,2020 # 6980 <malloc+0x1084>
    21a4:	00003097          	auipc	ra,0x3
    21a8:	69a080e7          	jalr	1690(ra) # 583e <printf>
    exit(1);
    21ac:	4505                	li	a0,1
    21ae:	00003097          	auipc	ra,0x3
    21b2:	318080e7          	jalr	792(ra) # 54c6 <exit>
    printf("%s: fork failed\n", s);
    21b6:	85a6                	mv	a1,s1
    21b8:	00004517          	auipc	a0,0x4
    21bc:	3a850513          	addi	a0,a0,936 # 6560 <malloc+0xc64>
    21c0:	00003097          	auipc	ra,0x3
    21c4:	67e080e7          	jalr	1662(ra) # 583e <printf>
    exit(1);
    21c8:	4505                	li	a0,1
    21ca:	00003097          	auipc	ra,0x3
    21ce:	2fc080e7          	jalr	764(ra) # 54c6 <exit>
    exit(0);
    21d2:	4501                	li	a0,0
    21d4:	00003097          	auipc	ra,0x3
    21d8:	2f2080e7          	jalr	754(ra) # 54c6 <exit>

00000000000021dc <copyinstr3>:
{
    21dc:	7179                	addi	sp,sp,-48
    21de:	f406                	sd	ra,40(sp)
    21e0:	f022                	sd	s0,32(sp)
    21e2:	ec26                	sd	s1,24(sp)
    21e4:	1800                	addi	s0,sp,48
  sbrk(8192);
    21e6:	6509                	lui	a0,0x2
    21e8:	00003097          	auipc	ra,0x3
    21ec:	366080e7          	jalr	870(ra) # 554e <sbrk>
  uint64 top = (uint64) sbrk(0);
    21f0:	4501                	li	a0,0
    21f2:	00003097          	auipc	ra,0x3
    21f6:	35c080e7          	jalr	860(ra) # 554e <sbrk>
  if((top % PGSIZE) != 0){
    21fa:	03451793          	slli	a5,a0,0x34
    21fe:	e3c9                	bnez	a5,2280 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2200:	4501                	li	a0,0
    2202:	00003097          	auipc	ra,0x3
    2206:	34c080e7          	jalr	844(ra) # 554e <sbrk>
  if(top % PGSIZE){
    220a:	03451793          	slli	a5,a0,0x34
    220e:	e3d9                	bnez	a5,2294 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2210:	fff50493          	addi	s1,a0,-1 # 1fff <kernmem+0x59>
  *b = 'x';
    2214:	07800793          	li	a5,120
    2218:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    221c:	8526                	mv	a0,s1
    221e:	00003097          	auipc	ra,0x3
    2222:	2f8080e7          	jalr	760(ra) # 5516 <unlink>
  if(ret != -1){
    2226:	57fd                	li	a5,-1
    2228:	08f51363          	bne	a0,a5,22ae <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    222c:	20100593          	li	a1,513
    2230:	8526                	mv	a0,s1
    2232:	00003097          	auipc	ra,0x3
    2236:	2d4080e7          	jalr	724(ra) # 5506 <open>
  if(fd != -1){
    223a:	57fd                	li	a5,-1
    223c:	08f51863          	bne	a0,a5,22cc <copyinstr3+0xf0>
  ret = link(b, b);
    2240:	85a6                	mv	a1,s1
    2242:	8526                	mv	a0,s1
    2244:	00003097          	auipc	ra,0x3
    2248:	2e2080e7          	jalr	738(ra) # 5526 <link>
  if(ret != -1){
    224c:	57fd                	li	a5,-1
    224e:	08f51e63          	bne	a0,a5,22ea <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2252:	00005797          	auipc	a5,0x5
    2256:	3c678793          	addi	a5,a5,966 # 7618 <malloc+0x1d1c>
    225a:	fcf43823          	sd	a5,-48(s0)
    225e:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2262:	fd040593          	addi	a1,s0,-48
    2266:	8526                	mv	a0,s1
    2268:	00003097          	auipc	ra,0x3
    226c:	296080e7          	jalr	662(ra) # 54fe <exec>
  if(ret != -1){
    2270:	57fd                	li	a5,-1
    2272:	08f51c63          	bne	a0,a5,230a <copyinstr3+0x12e>
}
    2276:	70a2                	ld	ra,40(sp)
    2278:	7402                	ld	s0,32(sp)
    227a:	64e2                	ld	s1,24(sp)
    227c:	6145                	addi	sp,sp,48
    227e:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2280:	0347d513          	srli	a0,a5,0x34
    2284:	6785                	lui	a5,0x1
    2286:	40a7853b          	subw	a0,a5,a0
    228a:	00003097          	auipc	ra,0x3
    228e:	2c4080e7          	jalr	708(ra) # 554e <sbrk>
    2292:	b7bd                	j	2200 <copyinstr3+0x24>
    printf("oops\n");
    2294:	00004517          	auipc	a0,0x4
    2298:	71450513          	addi	a0,a0,1812 # 69a8 <malloc+0x10ac>
    229c:	00003097          	auipc	ra,0x3
    22a0:	5a2080e7          	jalr	1442(ra) # 583e <printf>
    exit(1);
    22a4:	4505                	li	a0,1
    22a6:	00003097          	auipc	ra,0x3
    22aa:	220080e7          	jalr	544(ra) # 54c6 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    22ae:	862a                	mv	a2,a0
    22b0:	85a6                	mv	a1,s1
    22b2:	00004517          	auipc	a0,0x4
    22b6:	1ce50513          	addi	a0,a0,462 # 6480 <malloc+0xb84>
    22ba:	00003097          	auipc	ra,0x3
    22be:	584080e7          	jalr	1412(ra) # 583e <printf>
    exit(1);
    22c2:	4505                	li	a0,1
    22c4:	00003097          	auipc	ra,0x3
    22c8:	202080e7          	jalr	514(ra) # 54c6 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    22cc:	862a                	mv	a2,a0
    22ce:	85a6                	mv	a1,s1
    22d0:	00004517          	auipc	a0,0x4
    22d4:	1d050513          	addi	a0,a0,464 # 64a0 <malloc+0xba4>
    22d8:	00003097          	auipc	ra,0x3
    22dc:	566080e7          	jalr	1382(ra) # 583e <printf>
    exit(1);
    22e0:	4505                	li	a0,1
    22e2:	00003097          	auipc	ra,0x3
    22e6:	1e4080e7          	jalr	484(ra) # 54c6 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    22ea:	86aa                	mv	a3,a0
    22ec:	8626                	mv	a2,s1
    22ee:	85a6                	mv	a1,s1
    22f0:	00004517          	auipc	a0,0x4
    22f4:	1d050513          	addi	a0,a0,464 # 64c0 <malloc+0xbc4>
    22f8:	00003097          	auipc	ra,0x3
    22fc:	546080e7          	jalr	1350(ra) # 583e <printf>
    exit(1);
    2300:	4505                	li	a0,1
    2302:	00003097          	auipc	ra,0x3
    2306:	1c4080e7          	jalr	452(ra) # 54c6 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    230a:	567d                	li	a2,-1
    230c:	85a6                	mv	a1,s1
    230e:	00004517          	auipc	a0,0x4
    2312:	1da50513          	addi	a0,a0,474 # 64e8 <malloc+0xbec>
    2316:	00003097          	auipc	ra,0x3
    231a:	528080e7          	jalr	1320(ra) # 583e <printf>
    exit(1);
    231e:	4505                	li	a0,1
    2320:	00003097          	auipc	ra,0x3
    2324:	1a6080e7          	jalr	422(ra) # 54c6 <exit>

0000000000002328 <rwsbrk>:
{
    2328:	1101                	addi	sp,sp,-32
    232a:	ec06                	sd	ra,24(sp)
    232c:	e822                	sd	s0,16(sp)
    232e:	e426                	sd	s1,8(sp)
    2330:	e04a                	sd	s2,0(sp)
    2332:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2334:	6509                	lui	a0,0x2
    2336:	00003097          	auipc	ra,0x3
    233a:	218080e7          	jalr	536(ra) # 554e <sbrk>
  if(a == 0xffffffffffffffffLL) {
    233e:	57fd                	li	a5,-1
    2340:	06f50363          	beq	a0,a5,23a6 <rwsbrk+0x7e>
    2344:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2346:	7579                	lui	a0,0xffffe
    2348:	00003097          	auipc	ra,0x3
    234c:	206080e7          	jalr	518(ra) # 554e <sbrk>
    2350:	57fd                	li	a5,-1
    2352:	06f50763          	beq	a0,a5,23c0 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    2356:	20100593          	li	a1,513
    235a:	00003517          	auipc	a0,0x3
    235e:	6ee50513          	addi	a0,a0,1774 # 5a48 <malloc+0x14c>
    2362:	00003097          	auipc	ra,0x3
    2366:	1a4080e7          	jalr	420(ra) # 5506 <open>
    236a:	892a                	mv	s2,a0
  if(fd < 0){
    236c:	06054763          	bltz	a0,23da <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    2370:	6505                	lui	a0,0x1
    2372:	94aa                	add	s1,s1,a0
    2374:	40000613          	li	a2,1024
    2378:	85a6                	mv	a1,s1
    237a:	854a                	mv	a0,s2
    237c:	00003097          	auipc	ra,0x3
    2380:	16a080e7          	jalr	362(ra) # 54e6 <write>
    2384:	862a                	mv	a2,a0
  if(n >= 0){
    2386:	06054763          	bltz	a0,23f4 <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    238a:	85a6                	mv	a1,s1
    238c:	00004517          	auipc	a0,0x4
    2390:	67450513          	addi	a0,a0,1652 # 6a00 <malloc+0x1104>
    2394:	00003097          	auipc	ra,0x3
    2398:	4aa080e7          	jalr	1194(ra) # 583e <printf>
    exit(1);
    239c:	4505                	li	a0,1
    239e:	00003097          	auipc	ra,0x3
    23a2:	128080e7          	jalr	296(ra) # 54c6 <exit>
    printf("sbrk(rwsbrk) failed\n");
    23a6:	00004517          	auipc	a0,0x4
    23aa:	60a50513          	addi	a0,a0,1546 # 69b0 <malloc+0x10b4>
    23ae:	00003097          	auipc	ra,0x3
    23b2:	490080e7          	jalr	1168(ra) # 583e <printf>
    exit(1);
    23b6:	4505                	li	a0,1
    23b8:	00003097          	auipc	ra,0x3
    23bc:	10e080e7          	jalr	270(ra) # 54c6 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    23c0:	00004517          	auipc	a0,0x4
    23c4:	60850513          	addi	a0,a0,1544 # 69c8 <malloc+0x10cc>
    23c8:	00003097          	auipc	ra,0x3
    23cc:	476080e7          	jalr	1142(ra) # 583e <printf>
    exit(1);
    23d0:	4505                	li	a0,1
    23d2:	00003097          	auipc	ra,0x3
    23d6:	0f4080e7          	jalr	244(ra) # 54c6 <exit>
    printf("open(rwsbrk) failed\n");
    23da:	00004517          	auipc	a0,0x4
    23de:	60e50513          	addi	a0,a0,1550 # 69e8 <malloc+0x10ec>
    23e2:	00003097          	auipc	ra,0x3
    23e6:	45c080e7          	jalr	1116(ra) # 583e <printf>
    exit(1);
    23ea:	4505                	li	a0,1
    23ec:	00003097          	auipc	ra,0x3
    23f0:	0da080e7          	jalr	218(ra) # 54c6 <exit>
  close(fd);
    23f4:	854a                	mv	a0,s2
    23f6:	00003097          	auipc	ra,0x3
    23fa:	0f8080e7          	jalr	248(ra) # 54ee <close>
  unlink("rwsbrk");
    23fe:	00003517          	auipc	a0,0x3
    2402:	64a50513          	addi	a0,a0,1610 # 5a48 <malloc+0x14c>
    2406:	00003097          	auipc	ra,0x3
    240a:	110080e7          	jalr	272(ra) # 5516 <unlink>
  fd = open("README", O_RDONLY);
    240e:	4581                	li	a1,0
    2410:	00004517          	auipc	a0,0x4
    2414:	ab050513          	addi	a0,a0,-1360 # 5ec0 <malloc+0x5c4>
    2418:	00003097          	auipc	ra,0x3
    241c:	0ee080e7          	jalr	238(ra) # 5506 <open>
    2420:	892a                	mv	s2,a0
  if(fd < 0){
    2422:	02054963          	bltz	a0,2454 <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    2426:	4629                	li	a2,10
    2428:	85a6                	mv	a1,s1
    242a:	00003097          	auipc	ra,0x3
    242e:	0b4080e7          	jalr	180(ra) # 54de <read>
    2432:	862a                	mv	a2,a0
  if(n >= 0){
    2434:	02054d63          	bltz	a0,246e <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2438:	85a6                	mv	a1,s1
    243a:	00004517          	auipc	a0,0x4
    243e:	5f650513          	addi	a0,a0,1526 # 6a30 <malloc+0x1134>
    2442:	00003097          	auipc	ra,0x3
    2446:	3fc080e7          	jalr	1020(ra) # 583e <printf>
    exit(1);
    244a:	4505                	li	a0,1
    244c:	00003097          	auipc	ra,0x3
    2450:	07a080e7          	jalr	122(ra) # 54c6 <exit>
    printf("open(rwsbrk) failed\n");
    2454:	00004517          	auipc	a0,0x4
    2458:	59450513          	addi	a0,a0,1428 # 69e8 <malloc+0x10ec>
    245c:	00003097          	auipc	ra,0x3
    2460:	3e2080e7          	jalr	994(ra) # 583e <printf>
    exit(1);
    2464:	4505                	li	a0,1
    2466:	00003097          	auipc	ra,0x3
    246a:	060080e7          	jalr	96(ra) # 54c6 <exit>
  close(fd);
    246e:	854a                	mv	a0,s2
    2470:	00003097          	auipc	ra,0x3
    2474:	07e080e7          	jalr	126(ra) # 54ee <close>
  exit(0);
    2478:	4501                	li	a0,0
    247a:	00003097          	auipc	ra,0x3
    247e:	04c080e7          	jalr	76(ra) # 54c6 <exit>

0000000000002482 <sbrkbasic>:
{
    2482:	7139                	addi	sp,sp,-64
    2484:	fc06                	sd	ra,56(sp)
    2486:	f822                	sd	s0,48(sp)
    2488:	f426                	sd	s1,40(sp)
    248a:	f04a                	sd	s2,32(sp)
    248c:	ec4e                	sd	s3,24(sp)
    248e:	e852                	sd	s4,16(sp)
    2490:	0080                	addi	s0,sp,64
    2492:	8a2a                	mv	s4,a0
  pid = fork();
    2494:	00003097          	auipc	ra,0x3
    2498:	02a080e7          	jalr	42(ra) # 54be <fork>
  if(pid < 0){
    249c:	02054c63          	bltz	a0,24d4 <sbrkbasic+0x52>
  if(pid == 0){
    24a0:	ed21                	bnez	a0,24f8 <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    24a2:	40000537          	lui	a0,0x40000
    24a6:	00003097          	auipc	ra,0x3
    24aa:	0a8080e7          	jalr	168(ra) # 554e <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    24ae:	57fd                	li	a5,-1
    24b0:	02f50f63          	beq	a0,a5,24ee <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    24b4:	400007b7          	lui	a5,0x40000
    24b8:	97aa                	add	a5,a5,a0
      *b = 99;
    24ba:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    24be:	6705                	lui	a4,0x1
      *b = 99;
    24c0:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff16d0>
    for(b = a; b < a+TOOMUCH; b += 4096){
    24c4:	953a                	add	a0,a0,a4
    24c6:	fef51de3          	bne	a0,a5,24c0 <sbrkbasic+0x3e>
    exit(1);
    24ca:	4505                	li	a0,1
    24cc:	00003097          	auipc	ra,0x3
    24d0:	ffa080e7          	jalr	-6(ra) # 54c6 <exit>
    printf("fork failed in sbrkbasic\n");
    24d4:	00004517          	auipc	a0,0x4
    24d8:	58450513          	addi	a0,a0,1412 # 6a58 <malloc+0x115c>
    24dc:	00003097          	auipc	ra,0x3
    24e0:	362080e7          	jalr	866(ra) # 583e <printf>
    exit(1);
    24e4:	4505                	li	a0,1
    24e6:	00003097          	auipc	ra,0x3
    24ea:	fe0080e7          	jalr	-32(ra) # 54c6 <exit>
      exit(0);
    24ee:	4501                	li	a0,0
    24f0:	00003097          	auipc	ra,0x3
    24f4:	fd6080e7          	jalr	-42(ra) # 54c6 <exit>
  wait(&xstatus);
    24f8:	fcc40513          	addi	a0,s0,-52
    24fc:	00003097          	auipc	ra,0x3
    2500:	fd2080e7          	jalr	-46(ra) # 54ce <wait>
  if(xstatus == 1){
    2504:	fcc42703          	lw	a4,-52(s0)
    2508:	4785                	li	a5,1
    250a:	00f70d63          	beq	a4,a5,2524 <sbrkbasic+0xa2>
  a = sbrk(0);
    250e:	4501                	li	a0,0
    2510:	00003097          	auipc	ra,0x3
    2514:	03e080e7          	jalr	62(ra) # 554e <sbrk>
    2518:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    251a:	4901                	li	s2,0
    251c:	6985                	lui	s3,0x1
    251e:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1c2>
    2522:	a005                	j	2542 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    2524:	85d2                	mv	a1,s4
    2526:	00004517          	auipc	a0,0x4
    252a:	55250513          	addi	a0,a0,1362 # 6a78 <malloc+0x117c>
    252e:	00003097          	auipc	ra,0x3
    2532:	310080e7          	jalr	784(ra) # 583e <printf>
    exit(1);
    2536:	4505                	li	a0,1
    2538:	00003097          	auipc	ra,0x3
    253c:	f8e080e7          	jalr	-114(ra) # 54c6 <exit>
    a = b + 1;
    2540:	84be                	mv	s1,a5
    b = sbrk(1);
    2542:	4505                	li	a0,1
    2544:	00003097          	auipc	ra,0x3
    2548:	00a080e7          	jalr	10(ra) # 554e <sbrk>
    if(b != a){
    254c:	04951c63          	bne	a0,s1,25a4 <sbrkbasic+0x122>
    *b = 1;
    2550:	4785                	li	a5,1
    2552:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2556:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    255a:	2905                	addiw	s2,s2,1
    255c:	ff3912e3          	bne	s2,s3,2540 <sbrkbasic+0xbe>
  pid = fork();
    2560:	00003097          	auipc	ra,0x3
    2564:	f5e080e7          	jalr	-162(ra) # 54be <fork>
    2568:	892a                	mv	s2,a0
  if(pid < 0){
    256a:	04054d63          	bltz	a0,25c4 <sbrkbasic+0x142>
  c = sbrk(1);
    256e:	4505                	li	a0,1
    2570:	00003097          	auipc	ra,0x3
    2574:	fde080e7          	jalr	-34(ra) # 554e <sbrk>
  c = sbrk(1);
    2578:	4505                	li	a0,1
    257a:	00003097          	auipc	ra,0x3
    257e:	fd4080e7          	jalr	-44(ra) # 554e <sbrk>
  if(c != a + 1){
    2582:	0489                	addi	s1,s1,2
    2584:	04a48e63          	beq	s1,a0,25e0 <sbrkbasic+0x15e>
    printf("%s: sbrk test failed post-fork\n", s);
    2588:	85d2                	mv	a1,s4
    258a:	00004517          	auipc	a0,0x4
    258e:	54e50513          	addi	a0,a0,1358 # 6ad8 <malloc+0x11dc>
    2592:	00003097          	auipc	ra,0x3
    2596:	2ac080e7          	jalr	684(ra) # 583e <printf>
    exit(1);
    259a:	4505                	li	a0,1
    259c:	00003097          	auipc	ra,0x3
    25a0:	f2a080e7          	jalr	-214(ra) # 54c6 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    25a4:	86aa                	mv	a3,a0
    25a6:	8626                	mv	a2,s1
    25a8:	85ca                	mv	a1,s2
    25aa:	00004517          	auipc	a0,0x4
    25ae:	4ee50513          	addi	a0,a0,1262 # 6a98 <malloc+0x119c>
    25b2:	00003097          	auipc	ra,0x3
    25b6:	28c080e7          	jalr	652(ra) # 583e <printf>
      exit(1);
    25ba:	4505                	li	a0,1
    25bc:	00003097          	auipc	ra,0x3
    25c0:	f0a080e7          	jalr	-246(ra) # 54c6 <exit>
    printf("%s: sbrk test fork failed\n", s);
    25c4:	85d2                	mv	a1,s4
    25c6:	00004517          	auipc	a0,0x4
    25ca:	4f250513          	addi	a0,a0,1266 # 6ab8 <malloc+0x11bc>
    25ce:	00003097          	auipc	ra,0x3
    25d2:	270080e7          	jalr	624(ra) # 583e <printf>
    exit(1);
    25d6:	4505                	li	a0,1
    25d8:	00003097          	auipc	ra,0x3
    25dc:	eee080e7          	jalr	-274(ra) # 54c6 <exit>
  if(pid == 0)
    25e0:	00091763          	bnez	s2,25ee <sbrkbasic+0x16c>
    exit(0);
    25e4:	4501                	li	a0,0
    25e6:	00003097          	auipc	ra,0x3
    25ea:	ee0080e7          	jalr	-288(ra) # 54c6 <exit>
  wait(&xstatus);
    25ee:	fcc40513          	addi	a0,s0,-52
    25f2:	00003097          	auipc	ra,0x3
    25f6:	edc080e7          	jalr	-292(ra) # 54ce <wait>
  exit(xstatus);
    25fa:	fcc42503          	lw	a0,-52(s0)
    25fe:	00003097          	auipc	ra,0x3
    2602:	ec8080e7          	jalr	-312(ra) # 54c6 <exit>

0000000000002606 <sbrkmuch>:
{
    2606:	7179                	addi	sp,sp,-48
    2608:	f406                	sd	ra,40(sp)
    260a:	f022                	sd	s0,32(sp)
    260c:	ec26                	sd	s1,24(sp)
    260e:	e84a                	sd	s2,16(sp)
    2610:	e44e                	sd	s3,8(sp)
    2612:	e052                	sd	s4,0(sp)
    2614:	1800                	addi	s0,sp,48
    2616:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2618:	4501                	li	a0,0
    261a:	00003097          	auipc	ra,0x3
    261e:	f34080e7          	jalr	-204(ra) # 554e <sbrk>
    2622:	892a                	mv	s2,a0
  a = sbrk(0);
    2624:	4501                	li	a0,0
    2626:	00003097          	auipc	ra,0x3
    262a:	f28080e7          	jalr	-216(ra) # 554e <sbrk>
    262e:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2630:	06400537          	lui	a0,0x6400
    2634:	9d05                	subw	a0,a0,s1
    2636:	00003097          	auipc	ra,0x3
    263a:	f18080e7          	jalr	-232(ra) # 554e <sbrk>
  if (p != a) {
    263e:	0ca49863          	bne	s1,a0,270e <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2642:	4501                	li	a0,0
    2644:	00003097          	auipc	ra,0x3
    2648:	f0a080e7          	jalr	-246(ra) # 554e <sbrk>
    264c:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    264e:	00a4f963          	bgeu	s1,a0,2660 <sbrkmuch+0x5a>
    *pp = 1;
    2652:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2654:	6705                	lui	a4,0x1
    *pp = 1;
    2656:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    265a:	94ba                	add	s1,s1,a4
    265c:	fef4ede3          	bltu	s1,a5,2656 <sbrkmuch+0x50>
  *lastaddr = 99;
    2660:	064007b7          	lui	a5,0x6400
    2664:	06300713          	li	a4,99
    2668:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f16cf>
  a = sbrk(0);
    266c:	4501                	li	a0,0
    266e:	00003097          	auipc	ra,0x3
    2672:	ee0080e7          	jalr	-288(ra) # 554e <sbrk>
    2676:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2678:	757d                	lui	a0,0xfffff
    267a:	00003097          	auipc	ra,0x3
    267e:	ed4080e7          	jalr	-300(ra) # 554e <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2682:	57fd                	li	a5,-1
    2684:	0af50363          	beq	a0,a5,272a <sbrkmuch+0x124>
  c = sbrk(0);
    2688:	4501                	li	a0,0
    268a:	00003097          	auipc	ra,0x3
    268e:	ec4080e7          	jalr	-316(ra) # 554e <sbrk>
  if(c != a - PGSIZE){
    2692:	77fd                	lui	a5,0xfffff
    2694:	97a6                	add	a5,a5,s1
    2696:	0af51863          	bne	a0,a5,2746 <sbrkmuch+0x140>
  a = sbrk(0);
    269a:	4501                	li	a0,0
    269c:	00003097          	auipc	ra,0x3
    26a0:	eb2080e7          	jalr	-334(ra) # 554e <sbrk>
    26a4:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    26a6:	6505                	lui	a0,0x1
    26a8:	00003097          	auipc	ra,0x3
    26ac:	ea6080e7          	jalr	-346(ra) # 554e <sbrk>
    26b0:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    26b2:	0aa49a63          	bne	s1,a0,2766 <sbrkmuch+0x160>
    26b6:	4501                	li	a0,0
    26b8:	00003097          	auipc	ra,0x3
    26bc:	e96080e7          	jalr	-362(ra) # 554e <sbrk>
    26c0:	6785                	lui	a5,0x1
    26c2:	97a6                	add	a5,a5,s1
    26c4:	0af51163          	bne	a0,a5,2766 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    26c8:	064007b7          	lui	a5,0x6400
    26cc:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f16cf>
    26d0:	06300793          	li	a5,99
    26d4:	0af70963          	beq	a4,a5,2786 <sbrkmuch+0x180>
  a = sbrk(0);
    26d8:	4501                	li	a0,0
    26da:	00003097          	auipc	ra,0x3
    26de:	e74080e7          	jalr	-396(ra) # 554e <sbrk>
    26e2:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    26e4:	4501                	li	a0,0
    26e6:	00003097          	auipc	ra,0x3
    26ea:	e68080e7          	jalr	-408(ra) # 554e <sbrk>
    26ee:	40a9053b          	subw	a0,s2,a0
    26f2:	00003097          	auipc	ra,0x3
    26f6:	e5c080e7          	jalr	-420(ra) # 554e <sbrk>
  if(c != a){
    26fa:	0aa49463          	bne	s1,a0,27a2 <sbrkmuch+0x19c>
}
    26fe:	70a2                	ld	ra,40(sp)
    2700:	7402                	ld	s0,32(sp)
    2702:	64e2                	ld	s1,24(sp)
    2704:	6942                	ld	s2,16(sp)
    2706:	69a2                	ld	s3,8(sp)
    2708:	6a02                	ld	s4,0(sp)
    270a:	6145                	addi	sp,sp,48
    270c:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    270e:	85ce                	mv	a1,s3
    2710:	00004517          	auipc	a0,0x4
    2714:	3e850513          	addi	a0,a0,1000 # 6af8 <malloc+0x11fc>
    2718:	00003097          	auipc	ra,0x3
    271c:	126080e7          	jalr	294(ra) # 583e <printf>
    exit(1);
    2720:	4505                	li	a0,1
    2722:	00003097          	auipc	ra,0x3
    2726:	da4080e7          	jalr	-604(ra) # 54c6 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    272a:	85ce                	mv	a1,s3
    272c:	00004517          	auipc	a0,0x4
    2730:	41450513          	addi	a0,a0,1044 # 6b40 <malloc+0x1244>
    2734:	00003097          	auipc	ra,0x3
    2738:	10a080e7          	jalr	266(ra) # 583e <printf>
    exit(1);
    273c:	4505                	li	a0,1
    273e:	00003097          	auipc	ra,0x3
    2742:	d88080e7          	jalr	-632(ra) # 54c6 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2746:	86aa                	mv	a3,a0
    2748:	8626                	mv	a2,s1
    274a:	85ce                	mv	a1,s3
    274c:	00004517          	auipc	a0,0x4
    2750:	41450513          	addi	a0,a0,1044 # 6b60 <malloc+0x1264>
    2754:	00003097          	auipc	ra,0x3
    2758:	0ea080e7          	jalr	234(ra) # 583e <printf>
    exit(1);
    275c:	4505                	li	a0,1
    275e:	00003097          	auipc	ra,0x3
    2762:	d68080e7          	jalr	-664(ra) # 54c6 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2766:	86d2                	mv	a3,s4
    2768:	8626                	mv	a2,s1
    276a:	85ce                	mv	a1,s3
    276c:	00004517          	auipc	a0,0x4
    2770:	43450513          	addi	a0,a0,1076 # 6ba0 <malloc+0x12a4>
    2774:	00003097          	auipc	ra,0x3
    2778:	0ca080e7          	jalr	202(ra) # 583e <printf>
    exit(1);
    277c:	4505                	li	a0,1
    277e:	00003097          	auipc	ra,0x3
    2782:	d48080e7          	jalr	-696(ra) # 54c6 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2786:	85ce                	mv	a1,s3
    2788:	00004517          	auipc	a0,0x4
    278c:	44850513          	addi	a0,a0,1096 # 6bd0 <malloc+0x12d4>
    2790:	00003097          	auipc	ra,0x3
    2794:	0ae080e7          	jalr	174(ra) # 583e <printf>
    exit(1);
    2798:	4505                	li	a0,1
    279a:	00003097          	auipc	ra,0x3
    279e:	d2c080e7          	jalr	-724(ra) # 54c6 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    27a2:	86aa                	mv	a3,a0
    27a4:	8626                	mv	a2,s1
    27a6:	85ce                	mv	a1,s3
    27a8:	00004517          	auipc	a0,0x4
    27ac:	46050513          	addi	a0,a0,1120 # 6c08 <malloc+0x130c>
    27b0:	00003097          	auipc	ra,0x3
    27b4:	08e080e7          	jalr	142(ra) # 583e <printf>
    exit(1);
    27b8:	4505                	li	a0,1
    27ba:	00003097          	auipc	ra,0x3
    27be:	d0c080e7          	jalr	-756(ra) # 54c6 <exit>

00000000000027c2 <sbrkarg>:
{
    27c2:	7179                	addi	sp,sp,-48
    27c4:	f406                	sd	ra,40(sp)
    27c6:	f022                	sd	s0,32(sp)
    27c8:	ec26                	sd	s1,24(sp)
    27ca:	e84a                	sd	s2,16(sp)
    27cc:	e44e                	sd	s3,8(sp)
    27ce:	1800                	addi	s0,sp,48
    27d0:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    27d2:	6505                	lui	a0,0x1
    27d4:	00003097          	auipc	ra,0x3
    27d8:	d7a080e7          	jalr	-646(ra) # 554e <sbrk>
    27dc:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    27de:	20100593          	li	a1,513
    27e2:	00004517          	auipc	a0,0x4
    27e6:	44e50513          	addi	a0,a0,1102 # 6c30 <malloc+0x1334>
    27ea:	00003097          	auipc	ra,0x3
    27ee:	d1c080e7          	jalr	-740(ra) # 5506 <open>
    27f2:	84aa                	mv	s1,a0
  unlink("sbrk");
    27f4:	00004517          	auipc	a0,0x4
    27f8:	43c50513          	addi	a0,a0,1084 # 6c30 <malloc+0x1334>
    27fc:	00003097          	auipc	ra,0x3
    2800:	d1a080e7          	jalr	-742(ra) # 5516 <unlink>
  if(fd < 0)  {
    2804:	0404c163          	bltz	s1,2846 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2808:	6605                	lui	a2,0x1
    280a:	85ca                	mv	a1,s2
    280c:	8526                	mv	a0,s1
    280e:	00003097          	auipc	ra,0x3
    2812:	cd8080e7          	jalr	-808(ra) # 54e6 <write>
    2816:	04054663          	bltz	a0,2862 <sbrkarg+0xa0>
  close(fd);
    281a:	8526                	mv	a0,s1
    281c:	00003097          	auipc	ra,0x3
    2820:	cd2080e7          	jalr	-814(ra) # 54ee <close>
  a = sbrk(PGSIZE);
    2824:	6505                	lui	a0,0x1
    2826:	00003097          	auipc	ra,0x3
    282a:	d28080e7          	jalr	-728(ra) # 554e <sbrk>
  if(pipe((int *) a) != 0){
    282e:	00003097          	auipc	ra,0x3
    2832:	ca8080e7          	jalr	-856(ra) # 54d6 <pipe>
    2836:	e521                	bnez	a0,287e <sbrkarg+0xbc>
}
    2838:	70a2                	ld	ra,40(sp)
    283a:	7402                	ld	s0,32(sp)
    283c:	64e2                	ld	s1,24(sp)
    283e:	6942                	ld	s2,16(sp)
    2840:	69a2                	ld	s3,8(sp)
    2842:	6145                	addi	sp,sp,48
    2844:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2846:	85ce                	mv	a1,s3
    2848:	00004517          	auipc	a0,0x4
    284c:	3f050513          	addi	a0,a0,1008 # 6c38 <malloc+0x133c>
    2850:	00003097          	auipc	ra,0x3
    2854:	fee080e7          	jalr	-18(ra) # 583e <printf>
    exit(1);
    2858:	4505                	li	a0,1
    285a:	00003097          	auipc	ra,0x3
    285e:	c6c080e7          	jalr	-916(ra) # 54c6 <exit>
    printf("%s: write sbrk failed\n", s);
    2862:	85ce                	mv	a1,s3
    2864:	00004517          	auipc	a0,0x4
    2868:	3ec50513          	addi	a0,a0,1004 # 6c50 <malloc+0x1354>
    286c:	00003097          	auipc	ra,0x3
    2870:	fd2080e7          	jalr	-46(ra) # 583e <printf>
    exit(1);
    2874:	4505                	li	a0,1
    2876:	00003097          	auipc	ra,0x3
    287a:	c50080e7          	jalr	-944(ra) # 54c6 <exit>
    printf("%s: pipe() failed\n", s);
    287e:	85ce                	mv	a1,s3
    2880:	00004517          	auipc	a0,0x4
    2884:	de850513          	addi	a0,a0,-536 # 6668 <malloc+0xd6c>
    2888:	00003097          	auipc	ra,0x3
    288c:	fb6080e7          	jalr	-74(ra) # 583e <printf>
    exit(1);
    2890:	4505                	li	a0,1
    2892:	00003097          	auipc	ra,0x3
    2896:	c34080e7          	jalr	-972(ra) # 54c6 <exit>

000000000000289a <argptest>:
{
    289a:	1101                	addi	sp,sp,-32
    289c:	ec06                	sd	ra,24(sp)
    289e:	e822                	sd	s0,16(sp)
    28a0:	e426                	sd	s1,8(sp)
    28a2:	e04a                	sd	s2,0(sp)
    28a4:	1000                	addi	s0,sp,32
    28a6:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    28a8:	4581                	li	a1,0
    28aa:	00004517          	auipc	a0,0x4
    28ae:	3be50513          	addi	a0,a0,958 # 6c68 <malloc+0x136c>
    28b2:	00003097          	auipc	ra,0x3
    28b6:	c54080e7          	jalr	-940(ra) # 5506 <open>
  if (fd < 0) {
    28ba:	02054b63          	bltz	a0,28f0 <argptest+0x56>
    28be:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    28c0:	4501                	li	a0,0
    28c2:	00003097          	auipc	ra,0x3
    28c6:	c8c080e7          	jalr	-884(ra) # 554e <sbrk>
    28ca:	567d                	li	a2,-1
    28cc:	fff50593          	addi	a1,a0,-1
    28d0:	8526                	mv	a0,s1
    28d2:	00003097          	auipc	ra,0x3
    28d6:	c0c080e7          	jalr	-1012(ra) # 54de <read>
  close(fd);
    28da:	8526                	mv	a0,s1
    28dc:	00003097          	auipc	ra,0x3
    28e0:	c12080e7          	jalr	-1006(ra) # 54ee <close>
}
    28e4:	60e2                	ld	ra,24(sp)
    28e6:	6442                	ld	s0,16(sp)
    28e8:	64a2                	ld	s1,8(sp)
    28ea:	6902                	ld	s2,0(sp)
    28ec:	6105                	addi	sp,sp,32
    28ee:	8082                	ret
    printf("%s: open failed\n", s);
    28f0:	85ca                	mv	a1,s2
    28f2:	00004517          	auipc	a0,0x4
    28f6:	c8650513          	addi	a0,a0,-890 # 6578 <malloc+0xc7c>
    28fa:	00003097          	auipc	ra,0x3
    28fe:	f44080e7          	jalr	-188(ra) # 583e <printf>
    exit(1);
    2902:	4505                	li	a0,1
    2904:	00003097          	auipc	ra,0x3
    2908:	bc2080e7          	jalr	-1086(ra) # 54c6 <exit>

000000000000290c <sbrkbugs>:
{
    290c:	1141                	addi	sp,sp,-16
    290e:	e406                	sd	ra,8(sp)
    2910:	e022                	sd	s0,0(sp)
    2912:	0800                	addi	s0,sp,16
  int pid = fork();
    2914:	00003097          	auipc	ra,0x3
    2918:	baa080e7          	jalr	-1110(ra) # 54be <fork>
  if(pid < 0){
    291c:	02054263          	bltz	a0,2940 <sbrkbugs+0x34>
  if(pid == 0){
    2920:	ed0d                	bnez	a0,295a <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2922:	00003097          	auipc	ra,0x3
    2926:	c2c080e7          	jalr	-980(ra) # 554e <sbrk>
    sbrk(-sz);
    292a:	40a0053b          	negw	a0,a0
    292e:	00003097          	auipc	ra,0x3
    2932:	c20080e7          	jalr	-992(ra) # 554e <sbrk>
    exit(0);
    2936:	4501                	li	a0,0
    2938:	00003097          	auipc	ra,0x3
    293c:	b8e080e7          	jalr	-1138(ra) # 54c6 <exit>
    printf("fork failed\n");
    2940:	00004517          	auipc	a0,0x4
    2944:	01050513          	addi	a0,a0,16 # 6950 <malloc+0x1054>
    2948:	00003097          	auipc	ra,0x3
    294c:	ef6080e7          	jalr	-266(ra) # 583e <printf>
    exit(1);
    2950:	4505                	li	a0,1
    2952:	00003097          	auipc	ra,0x3
    2956:	b74080e7          	jalr	-1164(ra) # 54c6 <exit>
  wait(0);
    295a:	4501                	li	a0,0
    295c:	00003097          	auipc	ra,0x3
    2960:	b72080e7          	jalr	-1166(ra) # 54ce <wait>
  pid = fork();
    2964:	00003097          	auipc	ra,0x3
    2968:	b5a080e7          	jalr	-1190(ra) # 54be <fork>
  if(pid < 0){
    296c:	02054563          	bltz	a0,2996 <sbrkbugs+0x8a>
  if(pid == 0){
    2970:	e121                	bnez	a0,29b0 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2972:	00003097          	auipc	ra,0x3
    2976:	bdc080e7          	jalr	-1060(ra) # 554e <sbrk>
    sbrk(-(sz - 3500));
    297a:	6785                	lui	a5,0x1
    297c:	dac7879b          	addiw	a5,a5,-596
    2980:	40a7853b          	subw	a0,a5,a0
    2984:	00003097          	auipc	ra,0x3
    2988:	bca080e7          	jalr	-1078(ra) # 554e <sbrk>
    exit(0);
    298c:	4501                	li	a0,0
    298e:	00003097          	auipc	ra,0x3
    2992:	b38080e7          	jalr	-1224(ra) # 54c6 <exit>
    printf("fork failed\n");
    2996:	00004517          	auipc	a0,0x4
    299a:	fba50513          	addi	a0,a0,-70 # 6950 <malloc+0x1054>
    299e:	00003097          	auipc	ra,0x3
    29a2:	ea0080e7          	jalr	-352(ra) # 583e <printf>
    exit(1);
    29a6:	4505                	li	a0,1
    29a8:	00003097          	auipc	ra,0x3
    29ac:	b1e080e7          	jalr	-1250(ra) # 54c6 <exit>
  wait(0);
    29b0:	4501                	li	a0,0
    29b2:	00003097          	auipc	ra,0x3
    29b6:	b1c080e7          	jalr	-1252(ra) # 54ce <wait>
  pid = fork();
    29ba:	00003097          	auipc	ra,0x3
    29be:	b04080e7          	jalr	-1276(ra) # 54be <fork>
  if(pid < 0){
    29c2:	02054a63          	bltz	a0,29f6 <sbrkbugs+0xea>
  if(pid == 0){
    29c6:	e529                	bnez	a0,2a10 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    29c8:	00003097          	auipc	ra,0x3
    29cc:	b86080e7          	jalr	-1146(ra) # 554e <sbrk>
    29d0:	67ad                	lui	a5,0xb
    29d2:	8007879b          	addiw	a5,a5,-2048
    29d6:	40a7853b          	subw	a0,a5,a0
    29da:	00003097          	auipc	ra,0x3
    29de:	b74080e7          	jalr	-1164(ra) # 554e <sbrk>
    sbrk(-10);
    29e2:	5559                	li	a0,-10
    29e4:	00003097          	auipc	ra,0x3
    29e8:	b6a080e7          	jalr	-1174(ra) # 554e <sbrk>
    exit(0);
    29ec:	4501                	li	a0,0
    29ee:	00003097          	auipc	ra,0x3
    29f2:	ad8080e7          	jalr	-1320(ra) # 54c6 <exit>
    printf("fork failed\n");
    29f6:	00004517          	auipc	a0,0x4
    29fa:	f5a50513          	addi	a0,a0,-166 # 6950 <malloc+0x1054>
    29fe:	00003097          	auipc	ra,0x3
    2a02:	e40080e7          	jalr	-448(ra) # 583e <printf>
    exit(1);
    2a06:	4505                	li	a0,1
    2a08:	00003097          	auipc	ra,0x3
    2a0c:	abe080e7          	jalr	-1346(ra) # 54c6 <exit>
  wait(0);
    2a10:	4501                	li	a0,0
    2a12:	00003097          	auipc	ra,0x3
    2a16:	abc080e7          	jalr	-1348(ra) # 54ce <wait>
  exit(0);
    2a1a:	4501                	li	a0,0
    2a1c:	00003097          	auipc	ra,0x3
    2a20:	aaa080e7          	jalr	-1366(ra) # 54c6 <exit>

0000000000002a24 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2a24:	715d                	addi	sp,sp,-80
    2a26:	e486                	sd	ra,72(sp)
    2a28:	e0a2                	sd	s0,64(sp)
    2a2a:	fc26                	sd	s1,56(sp)
    2a2c:	f84a                	sd	s2,48(sp)
    2a2e:	f44e                	sd	s3,40(sp)
    2a30:	f052                	sd	s4,32(sp)
    2a32:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2a34:	4901                	li	s2,0
    2a36:	49bd                	li	s3,15
    int pid = fork();
    2a38:	00003097          	auipc	ra,0x3
    2a3c:	a86080e7          	jalr	-1402(ra) # 54be <fork>
    2a40:	84aa                	mv	s1,a0
    if(pid < 0){
    2a42:	02054063          	bltz	a0,2a62 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2a46:	c91d                	beqz	a0,2a7c <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2a48:	4501                	li	a0,0
    2a4a:	00003097          	auipc	ra,0x3
    2a4e:	a84080e7          	jalr	-1404(ra) # 54ce <wait>
  for(int avail = 0; avail < 15; avail++){
    2a52:	2905                	addiw	s2,s2,1
    2a54:	ff3912e3          	bne	s2,s3,2a38 <execout+0x14>
    }
  }

  exit(0);
    2a58:	4501                	li	a0,0
    2a5a:	00003097          	auipc	ra,0x3
    2a5e:	a6c080e7          	jalr	-1428(ra) # 54c6 <exit>
      printf("fork failed\n");
    2a62:	00004517          	auipc	a0,0x4
    2a66:	eee50513          	addi	a0,a0,-274 # 6950 <malloc+0x1054>
    2a6a:	00003097          	auipc	ra,0x3
    2a6e:	dd4080e7          	jalr	-556(ra) # 583e <printf>
      exit(1);
    2a72:	4505                	li	a0,1
    2a74:	00003097          	auipc	ra,0x3
    2a78:	a52080e7          	jalr	-1454(ra) # 54c6 <exit>
        if(a == 0xffffffffffffffffLL)
    2a7c:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2a7e:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2a80:	6505                	lui	a0,0x1
    2a82:	00003097          	auipc	ra,0x3
    2a86:	acc080e7          	jalr	-1332(ra) # 554e <sbrk>
        if(a == 0xffffffffffffffffLL)
    2a8a:	01350763          	beq	a0,s3,2a98 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2a8e:	6785                	lui	a5,0x1
    2a90:	953e                	add	a0,a0,a5
    2a92:	ff450fa3          	sb	s4,-1(a0) # fff <bigdir+0x89>
      while(1){
    2a96:	b7ed                	j	2a80 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2a98:	01205a63          	blez	s2,2aac <execout+0x88>
        sbrk(-4096);
    2a9c:	757d                	lui	a0,0xfffff
    2a9e:	00003097          	auipc	ra,0x3
    2aa2:	ab0080e7          	jalr	-1360(ra) # 554e <sbrk>
      for(int i = 0; i < avail; i++)
    2aa6:	2485                	addiw	s1,s1,1
    2aa8:	ff249ae3          	bne	s1,s2,2a9c <execout+0x78>
      close(1);
    2aac:	4505                	li	a0,1
    2aae:	00003097          	auipc	ra,0x3
    2ab2:	a40080e7          	jalr	-1472(ra) # 54ee <close>
      char *args[] = { "echo", "x", 0 };
    2ab6:	00003517          	auipc	a0,0x3
    2aba:	27250513          	addi	a0,a0,626 # 5d28 <malloc+0x42c>
    2abe:	faa43c23          	sd	a0,-72(s0)
    2ac2:	00003797          	auipc	a5,0x3
    2ac6:	2d678793          	addi	a5,a5,726 # 5d98 <malloc+0x49c>
    2aca:	fcf43023          	sd	a5,-64(s0)
    2ace:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2ad2:	fb840593          	addi	a1,s0,-72
    2ad6:	00003097          	auipc	ra,0x3
    2ada:	a28080e7          	jalr	-1496(ra) # 54fe <exec>
      exit(0);
    2ade:	4501                	li	a0,0
    2ae0:	00003097          	auipc	ra,0x3
    2ae4:	9e6080e7          	jalr	-1562(ra) # 54c6 <exit>

0000000000002ae8 <fourteen>:
{
    2ae8:	1101                	addi	sp,sp,-32
    2aea:	ec06                	sd	ra,24(sp)
    2aec:	e822                	sd	s0,16(sp)
    2aee:	e426                	sd	s1,8(sp)
    2af0:	1000                	addi	s0,sp,32
    2af2:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2af4:	00004517          	auipc	a0,0x4
    2af8:	34c50513          	addi	a0,a0,844 # 6e40 <malloc+0x1544>
    2afc:	00003097          	auipc	ra,0x3
    2b00:	a32080e7          	jalr	-1486(ra) # 552e <mkdir>
    2b04:	e165                	bnez	a0,2be4 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2b06:	00004517          	auipc	a0,0x4
    2b0a:	19250513          	addi	a0,a0,402 # 6c98 <malloc+0x139c>
    2b0e:	00003097          	auipc	ra,0x3
    2b12:	a20080e7          	jalr	-1504(ra) # 552e <mkdir>
    2b16:	e56d                	bnez	a0,2c00 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2b18:	20000593          	li	a1,512
    2b1c:	00004517          	auipc	a0,0x4
    2b20:	1d450513          	addi	a0,a0,468 # 6cf0 <malloc+0x13f4>
    2b24:	00003097          	auipc	ra,0x3
    2b28:	9e2080e7          	jalr	-1566(ra) # 5506 <open>
  if(fd < 0){
    2b2c:	0e054863          	bltz	a0,2c1c <fourteen+0x134>
  close(fd);
    2b30:	00003097          	auipc	ra,0x3
    2b34:	9be080e7          	jalr	-1602(ra) # 54ee <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2b38:	4581                	li	a1,0
    2b3a:	00004517          	auipc	a0,0x4
    2b3e:	22e50513          	addi	a0,a0,558 # 6d68 <malloc+0x146c>
    2b42:	00003097          	auipc	ra,0x3
    2b46:	9c4080e7          	jalr	-1596(ra) # 5506 <open>
  if(fd < 0){
    2b4a:	0e054763          	bltz	a0,2c38 <fourteen+0x150>
  close(fd);
    2b4e:	00003097          	auipc	ra,0x3
    2b52:	9a0080e7          	jalr	-1632(ra) # 54ee <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2b56:	00004517          	auipc	a0,0x4
    2b5a:	28250513          	addi	a0,a0,642 # 6dd8 <malloc+0x14dc>
    2b5e:	00003097          	auipc	ra,0x3
    2b62:	9d0080e7          	jalr	-1584(ra) # 552e <mkdir>
    2b66:	c57d                	beqz	a0,2c54 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2b68:	00004517          	auipc	a0,0x4
    2b6c:	2c850513          	addi	a0,a0,712 # 6e30 <malloc+0x1534>
    2b70:	00003097          	auipc	ra,0x3
    2b74:	9be080e7          	jalr	-1602(ra) # 552e <mkdir>
    2b78:	cd65                	beqz	a0,2c70 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2b7a:	00004517          	auipc	a0,0x4
    2b7e:	2b650513          	addi	a0,a0,694 # 6e30 <malloc+0x1534>
    2b82:	00003097          	auipc	ra,0x3
    2b86:	994080e7          	jalr	-1644(ra) # 5516 <unlink>
  unlink("12345678901234/12345678901234");
    2b8a:	00004517          	auipc	a0,0x4
    2b8e:	24e50513          	addi	a0,a0,590 # 6dd8 <malloc+0x14dc>
    2b92:	00003097          	auipc	ra,0x3
    2b96:	984080e7          	jalr	-1660(ra) # 5516 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2b9a:	00004517          	auipc	a0,0x4
    2b9e:	1ce50513          	addi	a0,a0,462 # 6d68 <malloc+0x146c>
    2ba2:	00003097          	auipc	ra,0x3
    2ba6:	974080e7          	jalr	-1676(ra) # 5516 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2baa:	00004517          	auipc	a0,0x4
    2bae:	14650513          	addi	a0,a0,326 # 6cf0 <malloc+0x13f4>
    2bb2:	00003097          	auipc	ra,0x3
    2bb6:	964080e7          	jalr	-1692(ra) # 5516 <unlink>
  unlink("12345678901234/123456789012345");
    2bba:	00004517          	auipc	a0,0x4
    2bbe:	0de50513          	addi	a0,a0,222 # 6c98 <malloc+0x139c>
    2bc2:	00003097          	auipc	ra,0x3
    2bc6:	954080e7          	jalr	-1708(ra) # 5516 <unlink>
  unlink("12345678901234");
    2bca:	00004517          	auipc	a0,0x4
    2bce:	27650513          	addi	a0,a0,630 # 6e40 <malloc+0x1544>
    2bd2:	00003097          	auipc	ra,0x3
    2bd6:	944080e7          	jalr	-1724(ra) # 5516 <unlink>
}
    2bda:	60e2                	ld	ra,24(sp)
    2bdc:	6442                	ld	s0,16(sp)
    2bde:	64a2                	ld	s1,8(sp)
    2be0:	6105                	addi	sp,sp,32
    2be2:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2be4:	85a6                	mv	a1,s1
    2be6:	00004517          	auipc	a0,0x4
    2bea:	08a50513          	addi	a0,a0,138 # 6c70 <malloc+0x1374>
    2bee:	00003097          	auipc	ra,0x3
    2bf2:	c50080e7          	jalr	-944(ra) # 583e <printf>
    exit(1);
    2bf6:	4505                	li	a0,1
    2bf8:	00003097          	auipc	ra,0x3
    2bfc:	8ce080e7          	jalr	-1842(ra) # 54c6 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2c00:	85a6                	mv	a1,s1
    2c02:	00004517          	auipc	a0,0x4
    2c06:	0b650513          	addi	a0,a0,182 # 6cb8 <malloc+0x13bc>
    2c0a:	00003097          	auipc	ra,0x3
    2c0e:	c34080e7          	jalr	-972(ra) # 583e <printf>
    exit(1);
    2c12:	4505                	li	a0,1
    2c14:	00003097          	auipc	ra,0x3
    2c18:	8b2080e7          	jalr	-1870(ra) # 54c6 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2c1c:	85a6                	mv	a1,s1
    2c1e:	00004517          	auipc	a0,0x4
    2c22:	10250513          	addi	a0,a0,258 # 6d20 <malloc+0x1424>
    2c26:	00003097          	auipc	ra,0x3
    2c2a:	c18080e7          	jalr	-1000(ra) # 583e <printf>
    exit(1);
    2c2e:	4505                	li	a0,1
    2c30:	00003097          	auipc	ra,0x3
    2c34:	896080e7          	jalr	-1898(ra) # 54c6 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2c38:	85a6                	mv	a1,s1
    2c3a:	00004517          	auipc	a0,0x4
    2c3e:	15e50513          	addi	a0,a0,350 # 6d98 <malloc+0x149c>
    2c42:	00003097          	auipc	ra,0x3
    2c46:	bfc080e7          	jalr	-1028(ra) # 583e <printf>
    exit(1);
    2c4a:	4505                	li	a0,1
    2c4c:	00003097          	auipc	ra,0x3
    2c50:	87a080e7          	jalr	-1926(ra) # 54c6 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2c54:	85a6                	mv	a1,s1
    2c56:	00004517          	auipc	a0,0x4
    2c5a:	1a250513          	addi	a0,a0,418 # 6df8 <malloc+0x14fc>
    2c5e:	00003097          	auipc	ra,0x3
    2c62:	be0080e7          	jalr	-1056(ra) # 583e <printf>
    exit(1);
    2c66:	4505                	li	a0,1
    2c68:	00003097          	auipc	ra,0x3
    2c6c:	85e080e7          	jalr	-1954(ra) # 54c6 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2c70:	85a6                	mv	a1,s1
    2c72:	00004517          	auipc	a0,0x4
    2c76:	1de50513          	addi	a0,a0,478 # 6e50 <malloc+0x1554>
    2c7a:	00003097          	auipc	ra,0x3
    2c7e:	bc4080e7          	jalr	-1084(ra) # 583e <printf>
    exit(1);
    2c82:	4505                	li	a0,1
    2c84:	00003097          	auipc	ra,0x3
    2c88:	842080e7          	jalr	-1982(ra) # 54c6 <exit>

0000000000002c8c <iputtest>:
{
    2c8c:	1101                	addi	sp,sp,-32
    2c8e:	ec06                	sd	ra,24(sp)
    2c90:	e822                	sd	s0,16(sp)
    2c92:	e426                	sd	s1,8(sp)
    2c94:	1000                	addi	s0,sp,32
    2c96:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2c98:	00004517          	auipc	a0,0x4
    2c9c:	1f050513          	addi	a0,a0,496 # 6e88 <malloc+0x158c>
    2ca0:	00003097          	auipc	ra,0x3
    2ca4:	88e080e7          	jalr	-1906(ra) # 552e <mkdir>
    2ca8:	04054563          	bltz	a0,2cf2 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2cac:	00004517          	auipc	a0,0x4
    2cb0:	1dc50513          	addi	a0,a0,476 # 6e88 <malloc+0x158c>
    2cb4:	00003097          	auipc	ra,0x3
    2cb8:	882080e7          	jalr	-1918(ra) # 5536 <chdir>
    2cbc:	04054963          	bltz	a0,2d0e <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2cc0:	00004517          	auipc	a0,0x4
    2cc4:	20850513          	addi	a0,a0,520 # 6ec8 <malloc+0x15cc>
    2cc8:	00003097          	auipc	ra,0x3
    2ccc:	84e080e7          	jalr	-1970(ra) # 5516 <unlink>
    2cd0:	04054d63          	bltz	a0,2d2a <iputtest+0x9e>
  if(chdir("/") < 0){
    2cd4:	00004517          	auipc	a0,0x4
    2cd8:	22450513          	addi	a0,a0,548 # 6ef8 <malloc+0x15fc>
    2cdc:	00003097          	auipc	ra,0x3
    2ce0:	85a080e7          	jalr	-1958(ra) # 5536 <chdir>
    2ce4:	06054163          	bltz	a0,2d46 <iputtest+0xba>
}
    2ce8:	60e2                	ld	ra,24(sp)
    2cea:	6442                	ld	s0,16(sp)
    2cec:	64a2                	ld	s1,8(sp)
    2cee:	6105                	addi	sp,sp,32
    2cf0:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2cf2:	85a6                	mv	a1,s1
    2cf4:	00004517          	auipc	a0,0x4
    2cf8:	19c50513          	addi	a0,a0,412 # 6e90 <malloc+0x1594>
    2cfc:	00003097          	auipc	ra,0x3
    2d00:	b42080e7          	jalr	-1214(ra) # 583e <printf>
    exit(1);
    2d04:	4505                	li	a0,1
    2d06:	00002097          	auipc	ra,0x2
    2d0a:	7c0080e7          	jalr	1984(ra) # 54c6 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2d0e:	85a6                	mv	a1,s1
    2d10:	00004517          	auipc	a0,0x4
    2d14:	19850513          	addi	a0,a0,408 # 6ea8 <malloc+0x15ac>
    2d18:	00003097          	auipc	ra,0x3
    2d1c:	b26080e7          	jalr	-1242(ra) # 583e <printf>
    exit(1);
    2d20:	4505                	li	a0,1
    2d22:	00002097          	auipc	ra,0x2
    2d26:	7a4080e7          	jalr	1956(ra) # 54c6 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2d2a:	85a6                	mv	a1,s1
    2d2c:	00004517          	auipc	a0,0x4
    2d30:	1ac50513          	addi	a0,a0,428 # 6ed8 <malloc+0x15dc>
    2d34:	00003097          	auipc	ra,0x3
    2d38:	b0a080e7          	jalr	-1270(ra) # 583e <printf>
    exit(1);
    2d3c:	4505                	li	a0,1
    2d3e:	00002097          	auipc	ra,0x2
    2d42:	788080e7          	jalr	1928(ra) # 54c6 <exit>
    printf("%s: chdir / failed\n", s);
    2d46:	85a6                	mv	a1,s1
    2d48:	00004517          	auipc	a0,0x4
    2d4c:	1b850513          	addi	a0,a0,440 # 6f00 <malloc+0x1604>
    2d50:	00003097          	auipc	ra,0x3
    2d54:	aee080e7          	jalr	-1298(ra) # 583e <printf>
    exit(1);
    2d58:	4505                	li	a0,1
    2d5a:	00002097          	auipc	ra,0x2
    2d5e:	76c080e7          	jalr	1900(ra) # 54c6 <exit>

0000000000002d62 <exitiputtest>:
{
    2d62:	7179                	addi	sp,sp,-48
    2d64:	f406                	sd	ra,40(sp)
    2d66:	f022                	sd	s0,32(sp)
    2d68:	ec26                	sd	s1,24(sp)
    2d6a:	1800                	addi	s0,sp,48
    2d6c:	84aa                	mv	s1,a0
  pid = fork();
    2d6e:	00002097          	auipc	ra,0x2
    2d72:	750080e7          	jalr	1872(ra) # 54be <fork>
  if(pid < 0){
    2d76:	04054663          	bltz	a0,2dc2 <exitiputtest+0x60>
  if(pid == 0){
    2d7a:	ed45                	bnez	a0,2e32 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2d7c:	00004517          	auipc	a0,0x4
    2d80:	10c50513          	addi	a0,a0,268 # 6e88 <malloc+0x158c>
    2d84:	00002097          	auipc	ra,0x2
    2d88:	7aa080e7          	jalr	1962(ra) # 552e <mkdir>
    2d8c:	04054963          	bltz	a0,2dde <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2d90:	00004517          	auipc	a0,0x4
    2d94:	0f850513          	addi	a0,a0,248 # 6e88 <malloc+0x158c>
    2d98:	00002097          	auipc	ra,0x2
    2d9c:	79e080e7          	jalr	1950(ra) # 5536 <chdir>
    2da0:	04054d63          	bltz	a0,2dfa <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2da4:	00004517          	auipc	a0,0x4
    2da8:	12450513          	addi	a0,a0,292 # 6ec8 <malloc+0x15cc>
    2dac:	00002097          	auipc	ra,0x2
    2db0:	76a080e7          	jalr	1898(ra) # 5516 <unlink>
    2db4:	06054163          	bltz	a0,2e16 <exitiputtest+0xb4>
    exit(0);
    2db8:	4501                	li	a0,0
    2dba:	00002097          	auipc	ra,0x2
    2dbe:	70c080e7          	jalr	1804(ra) # 54c6 <exit>
    printf("%s: fork failed\n", s);
    2dc2:	85a6                	mv	a1,s1
    2dc4:	00003517          	auipc	a0,0x3
    2dc8:	79c50513          	addi	a0,a0,1948 # 6560 <malloc+0xc64>
    2dcc:	00003097          	auipc	ra,0x3
    2dd0:	a72080e7          	jalr	-1422(ra) # 583e <printf>
    exit(1);
    2dd4:	4505                	li	a0,1
    2dd6:	00002097          	auipc	ra,0x2
    2dda:	6f0080e7          	jalr	1776(ra) # 54c6 <exit>
      printf("%s: mkdir failed\n", s);
    2dde:	85a6                	mv	a1,s1
    2de0:	00004517          	auipc	a0,0x4
    2de4:	0b050513          	addi	a0,a0,176 # 6e90 <malloc+0x1594>
    2de8:	00003097          	auipc	ra,0x3
    2dec:	a56080e7          	jalr	-1450(ra) # 583e <printf>
      exit(1);
    2df0:	4505                	li	a0,1
    2df2:	00002097          	auipc	ra,0x2
    2df6:	6d4080e7          	jalr	1748(ra) # 54c6 <exit>
      printf("%s: child chdir failed\n", s);
    2dfa:	85a6                	mv	a1,s1
    2dfc:	00004517          	auipc	a0,0x4
    2e00:	11c50513          	addi	a0,a0,284 # 6f18 <malloc+0x161c>
    2e04:	00003097          	auipc	ra,0x3
    2e08:	a3a080e7          	jalr	-1478(ra) # 583e <printf>
      exit(1);
    2e0c:	4505                	li	a0,1
    2e0e:	00002097          	auipc	ra,0x2
    2e12:	6b8080e7          	jalr	1720(ra) # 54c6 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2e16:	85a6                	mv	a1,s1
    2e18:	00004517          	auipc	a0,0x4
    2e1c:	0c050513          	addi	a0,a0,192 # 6ed8 <malloc+0x15dc>
    2e20:	00003097          	auipc	ra,0x3
    2e24:	a1e080e7          	jalr	-1506(ra) # 583e <printf>
      exit(1);
    2e28:	4505                	li	a0,1
    2e2a:	00002097          	auipc	ra,0x2
    2e2e:	69c080e7          	jalr	1692(ra) # 54c6 <exit>
  wait(&xstatus);
    2e32:	fdc40513          	addi	a0,s0,-36
    2e36:	00002097          	auipc	ra,0x2
    2e3a:	698080e7          	jalr	1688(ra) # 54ce <wait>
  exit(xstatus);
    2e3e:	fdc42503          	lw	a0,-36(s0)
    2e42:	00002097          	auipc	ra,0x2
    2e46:	684080e7          	jalr	1668(ra) # 54c6 <exit>

0000000000002e4a <dirtest>:
{
    2e4a:	1101                	addi	sp,sp,-32
    2e4c:	ec06                	sd	ra,24(sp)
    2e4e:	e822                	sd	s0,16(sp)
    2e50:	e426                	sd	s1,8(sp)
    2e52:	1000                	addi	s0,sp,32
    2e54:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2e56:	00004517          	auipc	a0,0x4
    2e5a:	0da50513          	addi	a0,a0,218 # 6f30 <malloc+0x1634>
    2e5e:	00002097          	auipc	ra,0x2
    2e62:	6d0080e7          	jalr	1744(ra) # 552e <mkdir>
    2e66:	04054563          	bltz	a0,2eb0 <dirtest+0x66>
  if(chdir("dir0") < 0){
    2e6a:	00004517          	auipc	a0,0x4
    2e6e:	0c650513          	addi	a0,a0,198 # 6f30 <malloc+0x1634>
    2e72:	00002097          	auipc	ra,0x2
    2e76:	6c4080e7          	jalr	1732(ra) # 5536 <chdir>
    2e7a:	04054963          	bltz	a0,2ecc <dirtest+0x82>
  if(chdir("..") < 0){
    2e7e:	00004517          	auipc	a0,0x4
    2e82:	0d250513          	addi	a0,a0,210 # 6f50 <malloc+0x1654>
    2e86:	00002097          	auipc	ra,0x2
    2e8a:	6b0080e7          	jalr	1712(ra) # 5536 <chdir>
    2e8e:	04054d63          	bltz	a0,2ee8 <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2e92:	00004517          	auipc	a0,0x4
    2e96:	09e50513          	addi	a0,a0,158 # 6f30 <malloc+0x1634>
    2e9a:	00002097          	auipc	ra,0x2
    2e9e:	67c080e7          	jalr	1660(ra) # 5516 <unlink>
    2ea2:	06054163          	bltz	a0,2f04 <dirtest+0xba>
}
    2ea6:	60e2                	ld	ra,24(sp)
    2ea8:	6442                	ld	s0,16(sp)
    2eaa:	64a2                	ld	s1,8(sp)
    2eac:	6105                	addi	sp,sp,32
    2eae:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2eb0:	85a6                	mv	a1,s1
    2eb2:	00004517          	auipc	a0,0x4
    2eb6:	fde50513          	addi	a0,a0,-34 # 6e90 <malloc+0x1594>
    2eba:	00003097          	auipc	ra,0x3
    2ebe:	984080e7          	jalr	-1660(ra) # 583e <printf>
    exit(1);
    2ec2:	4505                	li	a0,1
    2ec4:	00002097          	auipc	ra,0x2
    2ec8:	602080e7          	jalr	1538(ra) # 54c6 <exit>
    printf("%s: chdir dir0 failed\n", s);
    2ecc:	85a6                	mv	a1,s1
    2ece:	00004517          	auipc	a0,0x4
    2ed2:	06a50513          	addi	a0,a0,106 # 6f38 <malloc+0x163c>
    2ed6:	00003097          	auipc	ra,0x3
    2eda:	968080e7          	jalr	-1688(ra) # 583e <printf>
    exit(1);
    2ede:	4505                	li	a0,1
    2ee0:	00002097          	auipc	ra,0x2
    2ee4:	5e6080e7          	jalr	1510(ra) # 54c6 <exit>
    printf("%s: chdir .. failed\n", s);
    2ee8:	85a6                	mv	a1,s1
    2eea:	00004517          	auipc	a0,0x4
    2eee:	06e50513          	addi	a0,a0,110 # 6f58 <malloc+0x165c>
    2ef2:	00003097          	auipc	ra,0x3
    2ef6:	94c080e7          	jalr	-1716(ra) # 583e <printf>
    exit(1);
    2efa:	4505                	li	a0,1
    2efc:	00002097          	auipc	ra,0x2
    2f00:	5ca080e7          	jalr	1482(ra) # 54c6 <exit>
    printf("%s: unlink dir0 failed\n", s);
    2f04:	85a6                	mv	a1,s1
    2f06:	00004517          	auipc	a0,0x4
    2f0a:	06a50513          	addi	a0,a0,106 # 6f70 <malloc+0x1674>
    2f0e:	00003097          	auipc	ra,0x3
    2f12:	930080e7          	jalr	-1744(ra) # 583e <printf>
    exit(1);
    2f16:	4505                	li	a0,1
    2f18:	00002097          	auipc	ra,0x2
    2f1c:	5ae080e7          	jalr	1454(ra) # 54c6 <exit>

0000000000002f20 <subdir>:
{
    2f20:	1101                	addi	sp,sp,-32
    2f22:	ec06                	sd	ra,24(sp)
    2f24:	e822                	sd	s0,16(sp)
    2f26:	e426                	sd	s1,8(sp)
    2f28:	e04a                	sd	s2,0(sp)
    2f2a:	1000                	addi	s0,sp,32
    2f2c:	892a                	mv	s2,a0
  unlink("ff");
    2f2e:	00004517          	auipc	a0,0x4
    2f32:	18a50513          	addi	a0,a0,394 # 70b8 <malloc+0x17bc>
    2f36:	00002097          	auipc	ra,0x2
    2f3a:	5e0080e7          	jalr	1504(ra) # 5516 <unlink>
  if(mkdir("dd") != 0){
    2f3e:	00004517          	auipc	a0,0x4
    2f42:	04a50513          	addi	a0,a0,74 # 6f88 <malloc+0x168c>
    2f46:	00002097          	auipc	ra,0x2
    2f4a:	5e8080e7          	jalr	1512(ra) # 552e <mkdir>
    2f4e:	38051663          	bnez	a0,32da <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2f52:	20200593          	li	a1,514
    2f56:	00004517          	auipc	a0,0x4
    2f5a:	05250513          	addi	a0,a0,82 # 6fa8 <malloc+0x16ac>
    2f5e:	00002097          	auipc	ra,0x2
    2f62:	5a8080e7          	jalr	1448(ra) # 5506 <open>
    2f66:	84aa                	mv	s1,a0
  if(fd < 0){
    2f68:	38054763          	bltz	a0,32f6 <subdir+0x3d6>
  write(fd, "ff", 2);
    2f6c:	4609                	li	a2,2
    2f6e:	00004597          	auipc	a1,0x4
    2f72:	14a58593          	addi	a1,a1,330 # 70b8 <malloc+0x17bc>
    2f76:	00002097          	auipc	ra,0x2
    2f7a:	570080e7          	jalr	1392(ra) # 54e6 <write>
  close(fd);
    2f7e:	8526                	mv	a0,s1
    2f80:	00002097          	auipc	ra,0x2
    2f84:	56e080e7          	jalr	1390(ra) # 54ee <close>
  if(unlink("dd") >= 0){
    2f88:	00004517          	auipc	a0,0x4
    2f8c:	00050513          	mv	a0,a0
    2f90:	00002097          	auipc	ra,0x2
    2f94:	586080e7          	jalr	1414(ra) # 5516 <unlink>
    2f98:	36055d63          	bgez	a0,3312 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2f9c:	00004517          	auipc	a0,0x4
    2fa0:	06450513          	addi	a0,a0,100 # 7000 <malloc+0x1704>
    2fa4:	00002097          	auipc	ra,0x2
    2fa8:	58a080e7          	jalr	1418(ra) # 552e <mkdir>
    2fac:	38051163          	bnez	a0,332e <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2fb0:	20200593          	li	a1,514
    2fb4:	00004517          	auipc	a0,0x4
    2fb8:	07450513          	addi	a0,a0,116 # 7028 <malloc+0x172c>
    2fbc:	00002097          	auipc	ra,0x2
    2fc0:	54a080e7          	jalr	1354(ra) # 5506 <open>
    2fc4:	84aa                	mv	s1,a0
  if(fd < 0){
    2fc6:	38054263          	bltz	a0,334a <subdir+0x42a>
  write(fd, "FF", 2);
    2fca:	4609                	li	a2,2
    2fcc:	00004597          	auipc	a1,0x4
    2fd0:	08c58593          	addi	a1,a1,140 # 7058 <malloc+0x175c>
    2fd4:	00002097          	auipc	ra,0x2
    2fd8:	512080e7          	jalr	1298(ra) # 54e6 <write>
  close(fd);
    2fdc:	8526                	mv	a0,s1
    2fde:	00002097          	auipc	ra,0x2
    2fe2:	510080e7          	jalr	1296(ra) # 54ee <close>
  fd = open("dd/dd/../ff", 0);
    2fe6:	4581                	li	a1,0
    2fe8:	00004517          	auipc	a0,0x4
    2fec:	07850513          	addi	a0,a0,120 # 7060 <malloc+0x1764>
    2ff0:	00002097          	auipc	ra,0x2
    2ff4:	516080e7          	jalr	1302(ra) # 5506 <open>
    2ff8:	84aa                	mv	s1,a0
  if(fd < 0){
    2ffa:	36054663          	bltz	a0,3366 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    2ffe:	660d                	lui	a2,0x3
    3000:	00009597          	auipc	a1,0x9
    3004:	92058593          	addi	a1,a1,-1760 # b920 <buf>
    3008:	00002097          	auipc	ra,0x2
    300c:	4d6080e7          	jalr	1238(ra) # 54de <read>
  if(cc != 2 || buf[0] != 'f'){
    3010:	4789                	li	a5,2
    3012:	36f51863          	bne	a0,a5,3382 <subdir+0x462>
    3016:	00009717          	auipc	a4,0x9
    301a:	90a74703          	lbu	a4,-1782(a4) # b920 <buf>
    301e:	06600793          	li	a5,102
    3022:	36f71063          	bne	a4,a5,3382 <subdir+0x462>
  close(fd);
    3026:	8526                	mv	a0,s1
    3028:	00002097          	auipc	ra,0x2
    302c:	4c6080e7          	jalr	1222(ra) # 54ee <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3030:	00004597          	auipc	a1,0x4
    3034:	08058593          	addi	a1,a1,128 # 70b0 <malloc+0x17b4>
    3038:	00004517          	auipc	a0,0x4
    303c:	ff050513          	addi	a0,a0,-16 # 7028 <malloc+0x172c>
    3040:	00002097          	auipc	ra,0x2
    3044:	4e6080e7          	jalr	1254(ra) # 5526 <link>
    3048:	34051b63          	bnez	a0,339e <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    304c:	00004517          	auipc	a0,0x4
    3050:	fdc50513          	addi	a0,a0,-36 # 7028 <malloc+0x172c>
    3054:	00002097          	auipc	ra,0x2
    3058:	4c2080e7          	jalr	1218(ra) # 5516 <unlink>
    305c:	34051f63          	bnez	a0,33ba <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3060:	4581                	li	a1,0
    3062:	00004517          	auipc	a0,0x4
    3066:	fc650513          	addi	a0,a0,-58 # 7028 <malloc+0x172c>
    306a:	00002097          	auipc	ra,0x2
    306e:	49c080e7          	jalr	1180(ra) # 5506 <open>
    3072:	36055263          	bgez	a0,33d6 <subdir+0x4b6>
  if(chdir("dd") != 0){
    3076:	00004517          	auipc	a0,0x4
    307a:	f1250513          	addi	a0,a0,-238 # 6f88 <malloc+0x168c>
    307e:	00002097          	auipc	ra,0x2
    3082:	4b8080e7          	jalr	1208(ra) # 5536 <chdir>
    3086:	36051663          	bnez	a0,33f2 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    308a:	00004517          	auipc	a0,0x4
    308e:	0be50513          	addi	a0,a0,190 # 7148 <malloc+0x184c>
    3092:	00002097          	auipc	ra,0x2
    3096:	4a4080e7          	jalr	1188(ra) # 5536 <chdir>
    309a:	36051a63          	bnez	a0,340e <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    309e:	00004517          	auipc	a0,0x4
    30a2:	0da50513          	addi	a0,a0,218 # 7178 <malloc+0x187c>
    30a6:	00002097          	auipc	ra,0x2
    30aa:	490080e7          	jalr	1168(ra) # 5536 <chdir>
    30ae:	36051e63          	bnez	a0,342a <subdir+0x50a>
  if(chdir("./..") != 0){
    30b2:	00004517          	auipc	a0,0x4
    30b6:	0f650513          	addi	a0,a0,246 # 71a8 <malloc+0x18ac>
    30ba:	00002097          	auipc	ra,0x2
    30be:	47c080e7          	jalr	1148(ra) # 5536 <chdir>
    30c2:	38051263          	bnez	a0,3446 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    30c6:	4581                	li	a1,0
    30c8:	00004517          	auipc	a0,0x4
    30cc:	fe850513          	addi	a0,a0,-24 # 70b0 <malloc+0x17b4>
    30d0:	00002097          	auipc	ra,0x2
    30d4:	436080e7          	jalr	1078(ra) # 5506 <open>
    30d8:	84aa                	mv	s1,a0
  if(fd < 0){
    30da:	38054463          	bltz	a0,3462 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    30de:	660d                	lui	a2,0x3
    30e0:	00009597          	auipc	a1,0x9
    30e4:	84058593          	addi	a1,a1,-1984 # b920 <buf>
    30e8:	00002097          	auipc	ra,0x2
    30ec:	3f6080e7          	jalr	1014(ra) # 54de <read>
    30f0:	4789                	li	a5,2
    30f2:	38f51663          	bne	a0,a5,347e <subdir+0x55e>
  close(fd);
    30f6:	8526                	mv	a0,s1
    30f8:	00002097          	auipc	ra,0x2
    30fc:	3f6080e7          	jalr	1014(ra) # 54ee <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3100:	4581                	li	a1,0
    3102:	00004517          	auipc	a0,0x4
    3106:	f2650513          	addi	a0,a0,-218 # 7028 <malloc+0x172c>
    310a:	00002097          	auipc	ra,0x2
    310e:	3fc080e7          	jalr	1020(ra) # 5506 <open>
    3112:	38055463          	bgez	a0,349a <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3116:	20200593          	li	a1,514
    311a:	00004517          	auipc	a0,0x4
    311e:	11e50513          	addi	a0,a0,286 # 7238 <malloc+0x193c>
    3122:	00002097          	auipc	ra,0x2
    3126:	3e4080e7          	jalr	996(ra) # 5506 <open>
    312a:	38055663          	bgez	a0,34b6 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    312e:	20200593          	li	a1,514
    3132:	00004517          	auipc	a0,0x4
    3136:	13650513          	addi	a0,a0,310 # 7268 <malloc+0x196c>
    313a:	00002097          	auipc	ra,0x2
    313e:	3cc080e7          	jalr	972(ra) # 5506 <open>
    3142:	38055863          	bgez	a0,34d2 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3146:	20000593          	li	a1,512
    314a:	00004517          	auipc	a0,0x4
    314e:	e3e50513          	addi	a0,a0,-450 # 6f88 <malloc+0x168c>
    3152:	00002097          	auipc	ra,0x2
    3156:	3b4080e7          	jalr	948(ra) # 5506 <open>
    315a:	38055a63          	bgez	a0,34ee <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    315e:	4589                	li	a1,2
    3160:	00004517          	auipc	a0,0x4
    3164:	e2850513          	addi	a0,a0,-472 # 6f88 <malloc+0x168c>
    3168:	00002097          	auipc	ra,0x2
    316c:	39e080e7          	jalr	926(ra) # 5506 <open>
    3170:	38055d63          	bgez	a0,350a <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    3174:	4585                	li	a1,1
    3176:	00004517          	auipc	a0,0x4
    317a:	e1250513          	addi	a0,a0,-494 # 6f88 <malloc+0x168c>
    317e:	00002097          	auipc	ra,0x2
    3182:	388080e7          	jalr	904(ra) # 5506 <open>
    3186:	3a055063          	bgez	a0,3526 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    318a:	00004597          	auipc	a1,0x4
    318e:	16e58593          	addi	a1,a1,366 # 72f8 <malloc+0x19fc>
    3192:	00004517          	auipc	a0,0x4
    3196:	0a650513          	addi	a0,a0,166 # 7238 <malloc+0x193c>
    319a:	00002097          	auipc	ra,0x2
    319e:	38c080e7          	jalr	908(ra) # 5526 <link>
    31a2:	3a050063          	beqz	a0,3542 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    31a6:	00004597          	auipc	a1,0x4
    31aa:	15258593          	addi	a1,a1,338 # 72f8 <malloc+0x19fc>
    31ae:	00004517          	auipc	a0,0x4
    31b2:	0ba50513          	addi	a0,a0,186 # 7268 <malloc+0x196c>
    31b6:	00002097          	auipc	ra,0x2
    31ba:	370080e7          	jalr	880(ra) # 5526 <link>
    31be:	3a050063          	beqz	a0,355e <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    31c2:	00004597          	auipc	a1,0x4
    31c6:	eee58593          	addi	a1,a1,-274 # 70b0 <malloc+0x17b4>
    31ca:	00004517          	auipc	a0,0x4
    31ce:	dde50513          	addi	a0,a0,-546 # 6fa8 <malloc+0x16ac>
    31d2:	00002097          	auipc	ra,0x2
    31d6:	354080e7          	jalr	852(ra) # 5526 <link>
    31da:	3a050063          	beqz	a0,357a <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    31de:	00004517          	auipc	a0,0x4
    31e2:	05a50513          	addi	a0,a0,90 # 7238 <malloc+0x193c>
    31e6:	00002097          	auipc	ra,0x2
    31ea:	348080e7          	jalr	840(ra) # 552e <mkdir>
    31ee:	3a050463          	beqz	a0,3596 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    31f2:	00004517          	auipc	a0,0x4
    31f6:	07650513          	addi	a0,a0,118 # 7268 <malloc+0x196c>
    31fa:	00002097          	auipc	ra,0x2
    31fe:	334080e7          	jalr	820(ra) # 552e <mkdir>
    3202:	3a050863          	beqz	a0,35b2 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3206:	00004517          	auipc	a0,0x4
    320a:	eaa50513          	addi	a0,a0,-342 # 70b0 <malloc+0x17b4>
    320e:	00002097          	auipc	ra,0x2
    3212:	320080e7          	jalr	800(ra) # 552e <mkdir>
    3216:	3a050c63          	beqz	a0,35ce <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    321a:	00004517          	auipc	a0,0x4
    321e:	04e50513          	addi	a0,a0,78 # 7268 <malloc+0x196c>
    3222:	00002097          	auipc	ra,0x2
    3226:	2f4080e7          	jalr	756(ra) # 5516 <unlink>
    322a:	3c050063          	beqz	a0,35ea <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    322e:	00004517          	auipc	a0,0x4
    3232:	00a50513          	addi	a0,a0,10 # 7238 <malloc+0x193c>
    3236:	00002097          	auipc	ra,0x2
    323a:	2e0080e7          	jalr	736(ra) # 5516 <unlink>
    323e:	3c050463          	beqz	a0,3606 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3242:	00004517          	auipc	a0,0x4
    3246:	d6650513          	addi	a0,a0,-666 # 6fa8 <malloc+0x16ac>
    324a:	00002097          	auipc	ra,0x2
    324e:	2ec080e7          	jalr	748(ra) # 5536 <chdir>
    3252:	3c050863          	beqz	a0,3622 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3256:	00004517          	auipc	a0,0x4
    325a:	1f250513          	addi	a0,a0,498 # 7448 <malloc+0x1b4c>
    325e:	00002097          	auipc	ra,0x2
    3262:	2d8080e7          	jalr	728(ra) # 5536 <chdir>
    3266:	3c050c63          	beqz	a0,363e <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    326a:	00004517          	auipc	a0,0x4
    326e:	e4650513          	addi	a0,a0,-442 # 70b0 <malloc+0x17b4>
    3272:	00002097          	auipc	ra,0x2
    3276:	2a4080e7          	jalr	676(ra) # 5516 <unlink>
    327a:	3e051063          	bnez	a0,365a <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    327e:	00004517          	auipc	a0,0x4
    3282:	d2a50513          	addi	a0,a0,-726 # 6fa8 <malloc+0x16ac>
    3286:	00002097          	auipc	ra,0x2
    328a:	290080e7          	jalr	656(ra) # 5516 <unlink>
    328e:	3e051463          	bnez	a0,3676 <subdir+0x756>
  if(unlink("dd") == 0){
    3292:	00004517          	auipc	a0,0x4
    3296:	cf650513          	addi	a0,a0,-778 # 6f88 <malloc+0x168c>
    329a:	00002097          	auipc	ra,0x2
    329e:	27c080e7          	jalr	636(ra) # 5516 <unlink>
    32a2:	3e050863          	beqz	a0,3692 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    32a6:	00004517          	auipc	a0,0x4
    32aa:	21250513          	addi	a0,a0,530 # 74b8 <malloc+0x1bbc>
    32ae:	00002097          	auipc	ra,0x2
    32b2:	268080e7          	jalr	616(ra) # 5516 <unlink>
    32b6:	3e054c63          	bltz	a0,36ae <subdir+0x78e>
  if(unlink("dd") < 0){
    32ba:	00004517          	auipc	a0,0x4
    32be:	cce50513          	addi	a0,a0,-818 # 6f88 <malloc+0x168c>
    32c2:	00002097          	auipc	ra,0x2
    32c6:	254080e7          	jalr	596(ra) # 5516 <unlink>
    32ca:	40054063          	bltz	a0,36ca <subdir+0x7aa>
}
    32ce:	60e2                	ld	ra,24(sp)
    32d0:	6442                	ld	s0,16(sp)
    32d2:	64a2                	ld	s1,8(sp)
    32d4:	6902                	ld	s2,0(sp)
    32d6:	6105                	addi	sp,sp,32
    32d8:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    32da:	85ca                	mv	a1,s2
    32dc:	00004517          	auipc	a0,0x4
    32e0:	cb450513          	addi	a0,a0,-844 # 6f90 <malloc+0x1694>
    32e4:	00002097          	auipc	ra,0x2
    32e8:	55a080e7          	jalr	1370(ra) # 583e <printf>
    exit(1);
    32ec:	4505                	li	a0,1
    32ee:	00002097          	auipc	ra,0x2
    32f2:	1d8080e7          	jalr	472(ra) # 54c6 <exit>
    printf("%s: create dd/ff failed\n", s);
    32f6:	85ca                	mv	a1,s2
    32f8:	00004517          	auipc	a0,0x4
    32fc:	cb850513          	addi	a0,a0,-840 # 6fb0 <malloc+0x16b4>
    3300:	00002097          	auipc	ra,0x2
    3304:	53e080e7          	jalr	1342(ra) # 583e <printf>
    exit(1);
    3308:	4505                	li	a0,1
    330a:	00002097          	auipc	ra,0x2
    330e:	1bc080e7          	jalr	444(ra) # 54c6 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3312:	85ca                	mv	a1,s2
    3314:	00004517          	auipc	a0,0x4
    3318:	cbc50513          	addi	a0,a0,-836 # 6fd0 <malloc+0x16d4>
    331c:	00002097          	auipc	ra,0x2
    3320:	522080e7          	jalr	1314(ra) # 583e <printf>
    exit(1);
    3324:	4505                	li	a0,1
    3326:	00002097          	auipc	ra,0x2
    332a:	1a0080e7          	jalr	416(ra) # 54c6 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    332e:	85ca                	mv	a1,s2
    3330:	00004517          	auipc	a0,0x4
    3334:	cd850513          	addi	a0,a0,-808 # 7008 <malloc+0x170c>
    3338:	00002097          	auipc	ra,0x2
    333c:	506080e7          	jalr	1286(ra) # 583e <printf>
    exit(1);
    3340:	4505                	li	a0,1
    3342:	00002097          	auipc	ra,0x2
    3346:	184080e7          	jalr	388(ra) # 54c6 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    334a:	85ca                	mv	a1,s2
    334c:	00004517          	auipc	a0,0x4
    3350:	cec50513          	addi	a0,a0,-788 # 7038 <malloc+0x173c>
    3354:	00002097          	auipc	ra,0x2
    3358:	4ea080e7          	jalr	1258(ra) # 583e <printf>
    exit(1);
    335c:	4505                	li	a0,1
    335e:	00002097          	auipc	ra,0x2
    3362:	168080e7          	jalr	360(ra) # 54c6 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3366:	85ca                	mv	a1,s2
    3368:	00004517          	auipc	a0,0x4
    336c:	d0850513          	addi	a0,a0,-760 # 7070 <malloc+0x1774>
    3370:	00002097          	auipc	ra,0x2
    3374:	4ce080e7          	jalr	1230(ra) # 583e <printf>
    exit(1);
    3378:	4505                	li	a0,1
    337a:	00002097          	auipc	ra,0x2
    337e:	14c080e7          	jalr	332(ra) # 54c6 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3382:	85ca                	mv	a1,s2
    3384:	00004517          	auipc	a0,0x4
    3388:	d0c50513          	addi	a0,a0,-756 # 7090 <malloc+0x1794>
    338c:	00002097          	auipc	ra,0x2
    3390:	4b2080e7          	jalr	1202(ra) # 583e <printf>
    exit(1);
    3394:	4505                	li	a0,1
    3396:	00002097          	auipc	ra,0x2
    339a:	130080e7          	jalr	304(ra) # 54c6 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    339e:	85ca                	mv	a1,s2
    33a0:	00004517          	auipc	a0,0x4
    33a4:	d2050513          	addi	a0,a0,-736 # 70c0 <malloc+0x17c4>
    33a8:	00002097          	auipc	ra,0x2
    33ac:	496080e7          	jalr	1174(ra) # 583e <printf>
    exit(1);
    33b0:	4505                	li	a0,1
    33b2:	00002097          	auipc	ra,0x2
    33b6:	114080e7          	jalr	276(ra) # 54c6 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    33ba:	85ca                	mv	a1,s2
    33bc:	00004517          	auipc	a0,0x4
    33c0:	d2c50513          	addi	a0,a0,-724 # 70e8 <malloc+0x17ec>
    33c4:	00002097          	auipc	ra,0x2
    33c8:	47a080e7          	jalr	1146(ra) # 583e <printf>
    exit(1);
    33cc:	4505                	li	a0,1
    33ce:	00002097          	auipc	ra,0x2
    33d2:	0f8080e7          	jalr	248(ra) # 54c6 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    33d6:	85ca                	mv	a1,s2
    33d8:	00004517          	auipc	a0,0x4
    33dc:	d3050513          	addi	a0,a0,-720 # 7108 <malloc+0x180c>
    33e0:	00002097          	auipc	ra,0x2
    33e4:	45e080e7          	jalr	1118(ra) # 583e <printf>
    exit(1);
    33e8:	4505                	li	a0,1
    33ea:	00002097          	auipc	ra,0x2
    33ee:	0dc080e7          	jalr	220(ra) # 54c6 <exit>
    printf("%s: chdir dd failed\n", s);
    33f2:	85ca                	mv	a1,s2
    33f4:	00004517          	auipc	a0,0x4
    33f8:	d3c50513          	addi	a0,a0,-708 # 7130 <malloc+0x1834>
    33fc:	00002097          	auipc	ra,0x2
    3400:	442080e7          	jalr	1090(ra) # 583e <printf>
    exit(1);
    3404:	4505                	li	a0,1
    3406:	00002097          	auipc	ra,0x2
    340a:	0c0080e7          	jalr	192(ra) # 54c6 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    340e:	85ca                	mv	a1,s2
    3410:	00004517          	auipc	a0,0x4
    3414:	d4850513          	addi	a0,a0,-696 # 7158 <malloc+0x185c>
    3418:	00002097          	auipc	ra,0x2
    341c:	426080e7          	jalr	1062(ra) # 583e <printf>
    exit(1);
    3420:	4505                	li	a0,1
    3422:	00002097          	auipc	ra,0x2
    3426:	0a4080e7          	jalr	164(ra) # 54c6 <exit>
    printf("chdir dd/../../dd failed\n", s);
    342a:	85ca                	mv	a1,s2
    342c:	00004517          	auipc	a0,0x4
    3430:	d5c50513          	addi	a0,a0,-676 # 7188 <malloc+0x188c>
    3434:	00002097          	auipc	ra,0x2
    3438:	40a080e7          	jalr	1034(ra) # 583e <printf>
    exit(1);
    343c:	4505                	li	a0,1
    343e:	00002097          	auipc	ra,0x2
    3442:	088080e7          	jalr	136(ra) # 54c6 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3446:	85ca                	mv	a1,s2
    3448:	00004517          	auipc	a0,0x4
    344c:	d6850513          	addi	a0,a0,-664 # 71b0 <malloc+0x18b4>
    3450:	00002097          	auipc	ra,0x2
    3454:	3ee080e7          	jalr	1006(ra) # 583e <printf>
    exit(1);
    3458:	4505                	li	a0,1
    345a:	00002097          	auipc	ra,0x2
    345e:	06c080e7          	jalr	108(ra) # 54c6 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3462:	85ca                	mv	a1,s2
    3464:	00004517          	auipc	a0,0x4
    3468:	d6450513          	addi	a0,a0,-668 # 71c8 <malloc+0x18cc>
    346c:	00002097          	auipc	ra,0x2
    3470:	3d2080e7          	jalr	978(ra) # 583e <printf>
    exit(1);
    3474:	4505                	li	a0,1
    3476:	00002097          	auipc	ra,0x2
    347a:	050080e7          	jalr	80(ra) # 54c6 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    347e:	85ca                	mv	a1,s2
    3480:	00004517          	auipc	a0,0x4
    3484:	d6850513          	addi	a0,a0,-664 # 71e8 <malloc+0x18ec>
    3488:	00002097          	auipc	ra,0x2
    348c:	3b6080e7          	jalr	950(ra) # 583e <printf>
    exit(1);
    3490:	4505                	li	a0,1
    3492:	00002097          	auipc	ra,0x2
    3496:	034080e7          	jalr	52(ra) # 54c6 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    349a:	85ca                	mv	a1,s2
    349c:	00004517          	auipc	a0,0x4
    34a0:	d6c50513          	addi	a0,a0,-660 # 7208 <malloc+0x190c>
    34a4:	00002097          	auipc	ra,0x2
    34a8:	39a080e7          	jalr	922(ra) # 583e <printf>
    exit(1);
    34ac:	4505                	li	a0,1
    34ae:	00002097          	auipc	ra,0x2
    34b2:	018080e7          	jalr	24(ra) # 54c6 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    34b6:	85ca                	mv	a1,s2
    34b8:	00004517          	auipc	a0,0x4
    34bc:	d9050513          	addi	a0,a0,-624 # 7248 <malloc+0x194c>
    34c0:	00002097          	auipc	ra,0x2
    34c4:	37e080e7          	jalr	894(ra) # 583e <printf>
    exit(1);
    34c8:	4505                	li	a0,1
    34ca:	00002097          	auipc	ra,0x2
    34ce:	ffc080e7          	jalr	-4(ra) # 54c6 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    34d2:	85ca                	mv	a1,s2
    34d4:	00004517          	auipc	a0,0x4
    34d8:	da450513          	addi	a0,a0,-604 # 7278 <malloc+0x197c>
    34dc:	00002097          	auipc	ra,0x2
    34e0:	362080e7          	jalr	866(ra) # 583e <printf>
    exit(1);
    34e4:	4505                	li	a0,1
    34e6:	00002097          	auipc	ra,0x2
    34ea:	fe0080e7          	jalr	-32(ra) # 54c6 <exit>
    printf("%s: create dd succeeded!\n", s);
    34ee:	85ca                	mv	a1,s2
    34f0:	00004517          	auipc	a0,0x4
    34f4:	da850513          	addi	a0,a0,-600 # 7298 <malloc+0x199c>
    34f8:	00002097          	auipc	ra,0x2
    34fc:	346080e7          	jalr	838(ra) # 583e <printf>
    exit(1);
    3500:	4505                	li	a0,1
    3502:	00002097          	auipc	ra,0x2
    3506:	fc4080e7          	jalr	-60(ra) # 54c6 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    350a:	85ca                	mv	a1,s2
    350c:	00004517          	auipc	a0,0x4
    3510:	dac50513          	addi	a0,a0,-596 # 72b8 <malloc+0x19bc>
    3514:	00002097          	auipc	ra,0x2
    3518:	32a080e7          	jalr	810(ra) # 583e <printf>
    exit(1);
    351c:	4505                	li	a0,1
    351e:	00002097          	auipc	ra,0x2
    3522:	fa8080e7          	jalr	-88(ra) # 54c6 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3526:	85ca                	mv	a1,s2
    3528:	00004517          	auipc	a0,0x4
    352c:	db050513          	addi	a0,a0,-592 # 72d8 <malloc+0x19dc>
    3530:	00002097          	auipc	ra,0x2
    3534:	30e080e7          	jalr	782(ra) # 583e <printf>
    exit(1);
    3538:	4505                	li	a0,1
    353a:	00002097          	auipc	ra,0x2
    353e:	f8c080e7          	jalr	-116(ra) # 54c6 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3542:	85ca                	mv	a1,s2
    3544:	00004517          	auipc	a0,0x4
    3548:	dc450513          	addi	a0,a0,-572 # 7308 <malloc+0x1a0c>
    354c:	00002097          	auipc	ra,0x2
    3550:	2f2080e7          	jalr	754(ra) # 583e <printf>
    exit(1);
    3554:	4505                	li	a0,1
    3556:	00002097          	auipc	ra,0x2
    355a:	f70080e7          	jalr	-144(ra) # 54c6 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    355e:	85ca                	mv	a1,s2
    3560:	00004517          	auipc	a0,0x4
    3564:	dd050513          	addi	a0,a0,-560 # 7330 <malloc+0x1a34>
    3568:	00002097          	auipc	ra,0x2
    356c:	2d6080e7          	jalr	726(ra) # 583e <printf>
    exit(1);
    3570:	4505                	li	a0,1
    3572:	00002097          	auipc	ra,0x2
    3576:	f54080e7          	jalr	-172(ra) # 54c6 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    357a:	85ca                	mv	a1,s2
    357c:	00004517          	auipc	a0,0x4
    3580:	ddc50513          	addi	a0,a0,-548 # 7358 <malloc+0x1a5c>
    3584:	00002097          	auipc	ra,0x2
    3588:	2ba080e7          	jalr	698(ra) # 583e <printf>
    exit(1);
    358c:	4505                	li	a0,1
    358e:	00002097          	auipc	ra,0x2
    3592:	f38080e7          	jalr	-200(ra) # 54c6 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3596:	85ca                	mv	a1,s2
    3598:	00004517          	auipc	a0,0x4
    359c:	de850513          	addi	a0,a0,-536 # 7380 <malloc+0x1a84>
    35a0:	00002097          	auipc	ra,0x2
    35a4:	29e080e7          	jalr	670(ra) # 583e <printf>
    exit(1);
    35a8:	4505                	li	a0,1
    35aa:	00002097          	auipc	ra,0x2
    35ae:	f1c080e7          	jalr	-228(ra) # 54c6 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    35b2:	85ca                	mv	a1,s2
    35b4:	00004517          	auipc	a0,0x4
    35b8:	dec50513          	addi	a0,a0,-532 # 73a0 <malloc+0x1aa4>
    35bc:	00002097          	auipc	ra,0x2
    35c0:	282080e7          	jalr	642(ra) # 583e <printf>
    exit(1);
    35c4:	4505                	li	a0,1
    35c6:	00002097          	auipc	ra,0x2
    35ca:	f00080e7          	jalr	-256(ra) # 54c6 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    35ce:	85ca                	mv	a1,s2
    35d0:	00004517          	auipc	a0,0x4
    35d4:	df050513          	addi	a0,a0,-528 # 73c0 <malloc+0x1ac4>
    35d8:	00002097          	auipc	ra,0x2
    35dc:	266080e7          	jalr	614(ra) # 583e <printf>
    exit(1);
    35e0:	4505                	li	a0,1
    35e2:	00002097          	auipc	ra,0x2
    35e6:	ee4080e7          	jalr	-284(ra) # 54c6 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    35ea:	85ca                	mv	a1,s2
    35ec:	00004517          	auipc	a0,0x4
    35f0:	dfc50513          	addi	a0,a0,-516 # 73e8 <malloc+0x1aec>
    35f4:	00002097          	auipc	ra,0x2
    35f8:	24a080e7          	jalr	586(ra) # 583e <printf>
    exit(1);
    35fc:	4505                	li	a0,1
    35fe:	00002097          	auipc	ra,0x2
    3602:	ec8080e7          	jalr	-312(ra) # 54c6 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3606:	85ca                	mv	a1,s2
    3608:	00004517          	auipc	a0,0x4
    360c:	e0050513          	addi	a0,a0,-512 # 7408 <malloc+0x1b0c>
    3610:	00002097          	auipc	ra,0x2
    3614:	22e080e7          	jalr	558(ra) # 583e <printf>
    exit(1);
    3618:	4505                	li	a0,1
    361a:	00002097          	auipc	ra,0x2
    361e:	eac080e7          	jalr	-340(ra) # 54c6 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3622:	85ca                	mv	a1,s2
    3624:	00004517          	auipc	a0,0x4
    3628:	e0450513          	addi	a0,a0,-508 # 7428 <malloc+0x1b2c>
    362c:	00002097          	auipc	ra,0x2
    3630:	212080e7          	jalr	530(ra) # 583e <printf>
    exit(1);
    3634:	4505                	li	a0,1
    3636:	00002097          	auipc	ra,0x2
    363a:	e90080e7          	jalr	-368(ra) # 54c6 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    363e:	85ca                	mv	a1,s2
    3640:	00004517          	auipc	a0,0x4
    3644:	e1050513          	addi	a0,a0,-496 # 7450 <malloc+0x1b54>
    3648:	00002097          	auipc	ra,0x2
    364c:	1f6080e7          	jalr	502(ra) # 583e <printf>
    exit(1);
    3650:	4505                	li	a0,1
    3652:	00002097          	auipc	ra,0x2
    3656:	e74080e7          	jalr	-396(ra) # 54c6 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    365a:	85ca                	mv	a1,s2
    365c:	00004517          	auipc	a0,0x4
    3660:	a8c50513          	addi	a0,a0,-1396 # 70e8 <malloc+0x17ec>
    3664:	00002097          	auipc	ra,0x2
    3668:	1da080e7          	jalr	474(ra) # 583e <printf>
    exit(1);
    366c:	4505                	li	a0,1
    366e:	00002097          	auipc	ra,0x2
    3672:	e58080e7          	jalr	-424(ra) # 54c6 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3676:	85ca                	mv	a1,s2
    3678:	00004517          	auipc	a0,0x4
    367c:	df850513          	addi	a0,a0,-520 # 7470 <malloc+0x1b74>
    3680:	00002097          	auipc	ra,0x2
    3684:	1be080e7          	jalr	446(ra) # 583e <printf>
    exit(1);
    3688:	4505                	li	a0,1
    368a:	00002097          	auipc	ra,0x2
    368e:	e3c080e7          	jalr	-452(ra) # 54c6 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3692:	85ca                	mv	a1,s2
    3694:	00004517          	auipc	a0,0x4
    3698:	dfc50513          	addi	a0,a0,-516 # 7490 <malloc+0x1b94>
    369c:	00002097          	auipc	ra,0x2
    36a0:	1a2080e7          	jalr	418(ra) # 583e <printf>
    exit(1);
    36a4:	4505                	li	a0,1
    36a6:	00002097          	auipc	ra,0x2
    36aa:	e20080e7          	jalr	-480(ra) # 54c6 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    36ae:	85ca                	mv	a1,s2
    36b0:	00004517          	auipc	a0,0x4
    36b4:	e1050513          	addi	a0,a0,-496 # 74c0 <malloc+0x1bc4>
    36b8:	00002097          	auipc	ra,0x2
    36bc:	186080e7          	jalr	390(ra) # 583e <printf>
    exit(1);
    36c0:	4505                	li	a0,1
    36c2:	00002097          	auipc	ra,0x2
    36c6:	e04080e7          	jalr	-508(ra) # 54c6 <exit>
    printf("%s: unlink dd failed\n", s);
    36ca:	85ca                	mv	a1,s2
    36cc:	00004517          	auipc	a0,0x4
    36d0:	e1450513          	addi	a0,a0,-492 # 74e0 <malloc+0x1be4>
    36d4:	00002097          	auipc	ra,0x2
    36d8:	16a080e7          	jalr	362(ra) # 583e <printf>
    exit(1);
    36dc:	4505                	li	a0,1
    36de:	00002097          	auipc	ra,0x2
    36e2:	de8080e7          	jalr	-536(ra) # 54c6 <exit>

00000000000036e6 <rmdot>:
{
    36e6:	1101                	addi	sp,sp,-32
    36e8:	ec06                	sd	ra,24(sp)
    36ea:	e822                	sd	s0,16(sp)
    36ec:	e426                	sd	s1,8(sp)
    36ee:	1000                	addi	s0,sp,32
    36f0:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    36f2:	00004517          	auipc	a0,0x4
    36f6:	e0650513          	addi	a0,a0,-506 # 74f8 <malloc+0x1bfc>
    36fa:	00002097          	auipc	ra,0x2
    36fe:	e34080e7          	jalr	-460(ra) # 552e <mkdir>
    3702:	e549                	bnez	a0,378c <rmdot+0xa6>
  if(chdir("dots") != 0){
    3704:	00004517          	auipc	a0,0x4
    3708:	df450513          	addi	a0,a0,-524 # 74f8 <malloc+0x1bfc>
    370c:	00002097          	auipc	ra,0x2
    3710:	e2a080e7          	jalr	-470(ra) # 5536 <chdir>
    3714:	e951                	bnez	a0,37a8 <rmdot+0xc2>
  if(unlink(".") == 0){
    3716:	00003517          	auipc	a0,0x3
    371a:	caa50513          	addi	a0,a0,-854 # 63c0 <malloc+0xac4>
    371e:	00002097          	auipc	ra,0x2
    3722:	df8080e7          	jalr	-520(ra) # 5516 <unlink>
    3726:	cd59                	beqz	a0,37c4 <rmdot+0xde>
  if(unlink("..") == 0){
    3728:	00004517          	auipc	a0,0x4
    372c:	82850513          	addi	a0,a0,-2008 # 6f50 <malloc+0x1654>
    3730:	00002097          	auipc	ra,0x2
    3734:	de6080e7          	jalr	-538(ra) # 5516 <unlink>
    3738:	c545                	beqz	a0,37e0 <rmdot+0xfa>
  if(chdir("/") != 0){
    373a:	00003517          	auipc	a0,0x3
    373e:	7be50513          	addi	a0,a0,1982 # 6ef8 <malloc+0x15fc>
    3742:	00002097          	auipc	ra,0x2
    3746:	df4080e7          	jalr	-524(ra) # 5536 <chdir>
    374a:	e94d                	bnez	a0,37fc <rmdot+0x116>
  if(unlink("dots/.") == 0){
    374c:	00004517          	auipc	a0,0x4
    3750:	e1450513          	addi	a0,a0,-492 # 7560 <malloc+0x1c64>
    3754:	00002097          	auipc	ra,0x2
    3758:	dc2080e7          	jalr	-574(ra) # 5516 <unlink>
    375c:	cd55                	beqz	a0,3818 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    375e:	00004517          	auipc	a0,0x4
    3762:	e2a50513          	addi	a0,a0,-470 # 7588 <malloc+0x1c8c>
    3766:	00002097          	auipc	ra,0x2
    376a:	db0080e7          	jalr	-592(ra) # 5516 <unlink>
    376e:	c179                	beqz	a0,3834 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3770:	00004517          	auipc	a0,0x4
    3774:	d8850513          	addi	a0,a0,-632 # 74f8 <malloc+0x1bfc>
    3778:	00002097          	auipc	ra,0x2
    377c:	d9e080e7          	jalr	-610(ra) # 5516 <unlink>
    3780:	e961                	bnez	a0,3850 <rmdot+0x16a>
}
    3782:	60e2                	ld	ra,24(sp)
    3784:	6442                	ld	s0,16(sp)
    3786:	64a2                	ld	s1,8(sp)
    3788:	6105                	addi	sp,sp,32
    378a:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    378c:	85a6                	mv	a1,s1
    378e:	00004517          	auipc	a0,0x4
    3792:	d7250513          	addi	a0,a0,-654 # 7500 <malloc+0x1c04>
    3796:	00002097          	auipc	ra,0x2
    379a:	0a8080e7          	jalr	168(ra) # 583e <printf>
    exit(1);
    379e:	4505                	li	a0,1
    37a0:	00002097          	auipc	ra,0x2
    37a4:	d26080e7          	jalr	-730(ra) # 54c6 <exit>
    printf("%s: chdir dots failed\n", s);
    37a8:	85a6                	mv	a1,s1
    37aa:	00004517          	auipc	a0,0x4
    37ae:	d6e50513          	addi	a0,a0,-658 # 7518 <malloc+0x1c1c>
    37b2:	00002097          	auipc	ra,0x2
    37b6:	08c080e7          	jalr	140(ra) # 583e <printf>
    exit(1);
    37ba:	4505                	li	a0,1
    37bc:	00002097          	auipc	ra,0x2
    37c0:	d0a080e7          	jalr	-758(ra) # 54c6 <exit>
    printf("%s: rm . worked!\n", s);
    37c4:	85a6                	mv	a1,s1
    37c6:	00004517          	auipc	a0,0x4
    37ca:	d6a50513          	addi	a0,a0,-662 # 7530 <malloc+0x1c34>
    37ce:	00002097          	auipc	ra,0x2
    37d2:	070080e7          	jalr	112(ra) # 583e <printf>
    exit(1);
    37d6:	4505                	li	a0,1
    37d8:	00002097          	auipc	ra,0x2
    37dc:	cee080e7          	jalr	-786(ra) # 54c6 <exit>
    printf("%s: rm .. worked!\n", s);
    37e0:	85a6                	mv	a1,s1
    37e2:	00004517          	auipc	a0,0x4
    37e6:	d6650513          	addi	a0,a0,-666 # 7548 <malloc+0x1c4c>
    37ea:	00002097          	auipc	ra,0x2
    37ee:	054080e7          	jalr	84(ra) # 583e <printf>
    exit(1);
    37f2:	4505                	li	a0,1
    37f4:	00002097          	auipc	ra,0x2
    37f8:	cd2080e7          	jalr	-814(ra) # 54c6 <exit>
    printf("%s: chdir / failed\n", s);
    37fc:	85a6                	mv	a1,s1
    37fe:	00003517          	auipc	a0,0x3
    3802:	70250513          	addi	a0,a0,1794 # 6f00 <malloc+0x1604>
    3806:	00002097          	auipc	ra,0x2
    380a:	038080e7          	jalr	56(ra) # 583e <printf>
    exit(1);
    380e:	4505                	li	a0,1
    3810:	00002097          	auipc	ra,0x2
    3814:	cb6080e7          	jalr	-842(ra) # 54c6 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3818:	85a6                	mv	a1,s1
    381a:	00004517          	auipc	a0,0x4
    381e:	d4e50513          	addi	a0,a0,-690 # 7568 <malloc+0x1c6c>
    3822:	00002097          	auipc	ra,0x2
    3826:	01c080e7          	jalr	28(ra) # 583e <printf>
    exit(1);
    382a:	4505                	li	a0,1
    382c:	00002097          	auipc	ra,0x2
    3830:	c9a080e7          	jalr	-870(ra) # 54c6 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3834:	85a6                	mv	a1,s1
    3836:	00004517          	auipc	a0,0x4
    383a:	d5a50513          	addi	a0,a0,-678 # 7590 <malloc+0x1c94>
    383e:	00002097          	auipc	ra,0x2
    3842:	000080e7          	jalr	ra # 583e <printf>
    exit(1);
    3846:	4505                	li	a0,1
    3848:	00002097          	auipc	ra,0x2
    384c:	c7e080e7          	jalr	-898(ra) # 54c6 <exit>
    printf("%s: unlink dots failed!\n", s);
    3850:	85a6                	mv	a1,s1
    3852:	00004517          	auipc	a0,0x4
    3856:	d5e50513          	addi	a0,a0,-674 # 75b0 <malloc+0x1cb4>
    385a:	00002097          	auipc	ra,0x2
    385e:	fe4080e7          	jalr	-28(ra) # 583e <printf>
    exit(1);
    3862:	4505                	li	a0,1
    3864:	00002097          	auipc	ra,0x2
    3868:	c62080e7          	jalr	-926(ra) # 54c6 <exit>

000000000000386c <dirfile>:
{
    386c:	1101                	addi	sp,sp,-32
    386e:	ec06                	sd	ra,24(sp)
    3870:	e822                	sd	s0,16(sp)
    3872:	e426                	sd	s1,8(sp)
    3874:	e04a                	sd	s2,0(sp)
    3876:	1000                	addi	s0,sp,32
    3878:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    387a:	20000593          	li	a1,512
    387e:	00002517          	auipc	a0,0x2
    3882:	44a50513          	addi	a0,a0,1098 # 5cc8 <malloc+0x3cc>
    3886:	00002097          	auipc	ra,0x2
    388a:	c80080e7          	jalr	-896(ra) # 5506 <open>
  if(fd < 0){
    388e:	0e054d63          	bltz	a0,3988 <dirfile+0x11c>
  close(fd);
    3892:	00002097          	auipc	ra,0x2
    3896:	c5c080e7          	jalr	-932(ra) # 54ee <close>
  if(chdir("dirfile") == 0){
    389a:	00002517          	auipc	a0,0x2
    389e:	42e50513          	addi	a0,a0,1070 # 5cc8 <malloc+0x3cc>
    38a2:	00002097          	auipc	ra,0x2
    38a6:	c94080e7          	jalr	-876(ra) # 5536 <chdir>
    38aa:	cd6d                	beqz	a0,39a4 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    38ac:	4581                	li	a1,0
    38ae:	00004517          	auipc	a0,0x4
    38b2:	d6250513          	addi	a0,a0,-670 # 7610 <malloc+0x1d14>
    38b6:	00002097          	auipc	ra,0x2
    38ba:	c50080e7          	jalr	-944(ra) # 5506 <open>
  if(fd >= 0){
    38be:	10055163          	bgez	a0,39c0 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    38c2:	20000593          	li	a1,512
    38c6:	00004517          	auipc	a0,0x4
    38ca:	d4a50513          	addi	a0,a0,-694 # 7610 <malloc+0x1d14>
    38ce:	00002097          	auipc	ra,0x2
    38d2:	c38080e7          	jalr	-968(ra) # 5506 <open>
  if(fd >= 0){
    38d6:	10055363          	bgez	a0,39dc <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    38da:	00004517          	auipc	a0,0x4
    38de:	d3650513          	addi	a0,a0,-714 # 7610 <malloc+0x1d14>
    38e2:	00002097          	auipc	ra,0x2
    38e6:	c4c080e7          	jalr	-948(ra) # 552e <mkdir>
    38ea:	10050763          	beqz	a0,39f8 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    38ee:	00004517          	auipc	a0,0x4
    38f2:	d2250513          	addi	a0,a0,-734 # 7610 <malloc+0x1d14>
    38f6:	00002097          	auipc	ra,0x2
    38fa:	c20080e7          	jalr	-992(ra) # 5516 <unlink>
    38fe:	10050b63          	beqz	a0,3a14 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3902:	00004597          	auipc	a1,0x4
    3906:	d0e58593          	addi	a1,a1,-754 # 7610 <malloc+0x1d14>
    390a:	00002517          	auipc	a0,0x2
    390e:	5b650513          	addi	a0,a0,1462 # 5ec0 <malloc+0x5c4>
    3912:	00002097          	auipc	ra,0x2
    3916:	c14080e7          	jalr	-1004(ra) # 5526 <link>
    391a:	10050b63          	beqz	a0,3a30 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    391e:	00002517          	auipc	a0,0x2
    3922:	3aa50513          	addi	a0,a0,938 # 5cc8 <malloc+0x3cc>
    3926:	00002097          	auipc	ra,0x2
    392a:	bf0080e7          	jalr	-1040(ra) # 5516 <unlink>
    392e:	10051f63          	bnez	a0,3a4c <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3932:	4589                	li	a1,2
    3934:	00003517          	auipc	a0,0x3
    3938:	a8c50513          	addi	a0,a0,-1396 # 63c0 <malloc+0xac4>
    393c:	00002097          	auipc	ra,0x2
    3940:	bca080e7          	jalr	-1078(ra) # 5506 <open>
  if(fd >= 0){
    3944:	12055263          	bgez	a0,3a68 <dirfile+0x1fc>
  fd = open(".", 0);
    3948:	4581                	li	a1,0
    394a:	00003517          	auipc	a0,0x3
    394e:	a7650513          	addi	a0,a0,-1418 # 63c0 <malloc+0xac4>
    3952:	00002097          	auipc	ra,0x2
    3956:	bb4080e7          	jalr	-1100(ra) # 5506 <open>
    395a:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    395c:	4605                	li	a2,1
    395e:	00002597          	auipc	a1,0x2
    3962:	43a58593          	addi	a1,a1,1082 # 5d98 <malloc+0x49c>
    3966:	00002097          	auipc	ra,0x2
    396a:	b80080e7          	jalr	-1152(ra) # 54e6 <write>
    396e:	10a04b63          	bgtz	a0,3a84 <dirfile+0x218>
  close(fd);
    3972:	8526                	mv	a0,s1
    3974:	00002097          	auipc	ra,0x2
    3978:	b7a080e7          	jalr	-1158(ra) # 54ee <close>
}
    397c:	60e2                	ld	ra,24(sp)
    397e:	6442                	ld	s0,16(sp)
    3980:	64a2                	ld	s1,8(sp)
    3982:	6902                	ld	s2,0(sp)
    3984:	6105                	addi	sp,sp,32
    3986:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3988:	85ca                	mv	a1,s2
    398a:	00004517          	auipc	a0,0x4
    398e:	c4650513          	addi	a0,a0,-954 # 75d0 <malloc+0x1cd4>
    3992:	00002097          	auipc	ra,0x2
    3996:	eac080e7          	jalr	-340(ra) # 583e <printf>
    exit(1);
    399a:	4505                	li	a0,1
    399c:	00002097          	auipc	ra,0x2
    39a0:	b2a080e7          	jalr	-1238(ra) # 54c6 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    39a4:	85ca                	mv	a1,s2
    39a6:	00004517          	auipc	a0,0x4
    39aa:	c4a50513          	addi	a0,a0,-950 # 75f0 <malloc+0x1cf4>
    39ae:	00002097          	auipc	ra,0x2
    39b2:	e90080e7          	jalr	-368(ra) # 583e <printf>
    exit(1);
    39b6:	4505                	li	a0,1
    39b8:	00002097          	auipc	ra,0x2
    39bc:	b0e080e7          	jalr	-1266(ra) # 54c6 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    39c0:	85ca                	mv	a1,s2
    39c2:	00004517          	auipc	a0,0x4
    39c6:	c5e50513          	addi	a0,a0,-930 # 7620 <malloc+0x1d24>
    39ca:	00002097          	auipc	ra,0x2
    39ce:	e74080e7          	jalr	-396(ra) # 583e <printf>
    exit(1);
    39d2:	4505                	li	a0,1
    39d4:	00002097          	auipc	ra,0x2
    39d8:	af2080e7          	jalr	-1294(ra) # 54c6 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    39dc:	85ca                	mv	a1,s2
    39de:	00004517          	auipc	a0,0x4
    39e2:	c4250513          	addi	a0,a0,-958 # 7620 <malloc+0x1d24>
    39e6:	00002097          	auipc	ra,0x2
    39ea:	e58080e7          	jalr	-424(ra) # 583e <printf>
    exit(1);
    39ee:	4505                	li	a0,1
    39f0:	00002097          	auipc	ra,0x2
    39f4:	ad6080e7          	jalr	-1322(ra) # 54c6 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    39f8:	85ca                	mv	a1,s2
    39fa:	00004517          	auipc	a0,0x4
    39fe:	c4e50513          	addi	a0,a0,-946 # 7648 <malloc+0x1d4c>
    3a02:	00002097          	auipc	ra,0x2
    3a06:	e3c080e7          	jalr	-452(ra) # 583e <printf>
    exit(1);
    3a0a:	4505                	li	a0,1
    3a0c:	00002097          	auipc	ra,0x2
    3a10:	aba080e7          	jalr	-1350(ra) # 54c6 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3a14:	85ca                	mv	a1,s2
    3a16:	00004517          	auipc	a0,0x4
    3a1a:	c5a50513          	addi	a0,a0,-934 # 7670 <malloc+0x1d74>
    3a1e:	00002097          	auipc	ra,0x2
    3a22:	e20080e7          	jalr	-480(ra) # 583e <printf>
    exit(1);
    3a26:	4505                	li	a0,1
    3a28:	00002097          	auipc	ra,0x2
    3a2c:	a9e080e7          	jalr	-1378(ra) # 54c6 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3a30:	85ca                	mv	a1,s2
    3a32:	00004517          	auipc	a0,0x4
    3a36:	c6650513          	addi	a0,a0,-922 # 7698 <malloc+0x1d9c>
    3a3a:	00002097          	auipc	ra,0x2
    3a3e:	e04080e7          	jalr	-508(ra) # 583e <printf>
    exit(1);
    3a42:	4505                	li	a0,1
    3a44:	00002097          	auipc	ra,0x2
    3a48:	a82080e7          	jalr	-1406(ra) # 54c6 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3a4c:	85ca                	mv	a1,s2
    3a4e:	00004517          	auipc	a0,0x4
    3a52:	c7250513          	addi	a0,a0,-910 # 76c0 <malloc+0x1dc4>
    3a56:	00002097          	auipc	ra,0x2
    3a5a:	de8080e7          	jalr	-536(ra) # 583e <printf>
    exit(1);
    3a5e:	4505                	li	a0,1
    3a60:	00002097          	auipc	ra,0x2
    3a64:	a66080e7          	jalr	-1434(ra) # 54c6 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3a68:	85ca                	mv	a1,s2
    3a6a:	00004517          	auipc	a0,0x4
    3a6e:	c7650513          	addi	a0,a0,-906 # 76e0 <malloc+0x1de4>
    3a72:	00002097          	auipc	ra,0x2
    3a76:	dcc080e7          	jalr	-564(ra) # 583e <printf>
    exit(1);
    3a7a:	4505                	li	a0,1
    3a7c:	00002097          	auipc	ra,0x2
    3a80:	a4a080e7          	jalr	-1462(ra) # 54c6 <exit>
    printf("%s: write . succeeded!\n", s);
    3a84:	85ca                	mv	a1,s2
    3a86:	00004517          	auipc	a0,0x4
    3a8a:	c8250513          	addi	a0,a0,-894 # 7708 <malloc+0x1e0c>
    3a8e:	00002097          	auipc	ra,0x2
    3a92:	db0080e7          	jalr	-592(ra) # 583e <printf>
    exit(1);
    3a96:	4505                	li	a0,1
    3a98:	00002097          	auipc	ra,0x2
    3a9c:	a2e080e7          	jalr	-1490(ra) # 54c6 <exit>

0000000000003aa0 <iref>:
{
    3aa0:	7139                	addi	sp,sp,-64
    3aa2:	fc06                	sd	ra,56(sp)
    3aa4:	f822                	sd	s0,48(sp)
    3aa6:	f426                	sd	s1,40(sp)
    3aa8:	f04a                	sd	s2,32(sp)
    3aaa:	ec4e                	sd	s3,24(sp)
    3aac:	e852                	sd	s4,16(sp)
    3aae:	e456                	sd	s5,8(sp)
    3ab0:	e05a                	sd	s6,0(sp)
    3ab2:	0080                	addi	s0,sp,64
    3ab4:	8b2a                	mv	s6,a0
    3ab6:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3aba:	00004a17          	auipc	s4,0x4
    3abe:	c66a0a13          	addi	s4,s4,-922 # 7720 <malloc+0x1e24>
    mkdir("");
    3ac2:	00003497          	auipc	s1,0x3
    3ac6:	76e48493          	addi	s1,s1,1902 # 7230 <malloc+0x1934>
    link("README", "");
    3aca:	00002a97          	auipc	s5,0x2
    3ace:	3f6a8a93          	addi	s5,s5,1014 # 5ec0 <malloc+0x5c4>
    fd = open("xx", O_CREATE);
    3ad2:	00004997          	auipc	s3,0x4
    3ad6:	b4698993          	addi	s3,s3,-1210 # 7618 <malloc+0x1d1c>
    3ada:	a891                	j	3b2e <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3adc:	85da                	mv	a1,s6
    3ade:	00004517          	auipc	a0,0x4
    3ae2:	c4a50513          	addi	a0,a0,-950 # 7728 <malloc+0x1e2c>
    3ae6:	00002097          	auipc	ra,0x2
    3aea:	d58080e7          	jalr	-680(ra) # 583e <printf>
      exit(1);
    3aee:	4505                	li	a0,1
    3af0:	00002097          	auipc	ra,0x2
    3af4:	9d6080e7          	jalr	-1578(ra) # 54c6 <exit>
      printf("%s: chdir irefd failed\n", s);
    3af8:	85da                	mv	a1,s6
    3afa:	00004517          	auipc	a0,0x4
    3afe:	c4650513          	addi	a0,a0,-954 # 7740 <malloc+0x1e44>
    3b02:	00002097          	auipc	ra,0x2
    3b06:	d3c080e7          	jalr	-708(ra) # 583e <printf>
      exit(1);
    3b0a:	4505                	li	a0,1
    3b0c:	00002097          	auipc	ra,0x2
    3b10:	9ba080e7          	jalr	-1606(ra) # 54c6 <exit>
      close(fd);
    3b14:	00002097          	auipc	ra,0x2
    3b18:	9da080e7          	jalr	-1574(ra) # 54ee <close>
    3b1c:	a889                	j	3b6e <iref+0xce>
    unlink("xx");
    3b1e:	854e                	mv	a0,s3
    3b20:	00002097          	auipc	ra,0x2
    3b24:	9f6080e7          	jalr	-1546(ra) # 5516 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3b28:	397d                	addiw	s2,s2,-1
    3b2a:	06090063          	beqz	s2,3b8a <iref+0xea>
    if(mkdir("irefd") != 0){
    3b2e:	8552                	mv	a0,s4
    3b30:	00002097          	auipc	ra,0x2
    3b34:	9fe080e7          	jalr	-1538(ra) # 552e <mkdir>
    3b38:	f155                	bnez	a0,3adc <iref+0x3c>
    if(chdir("irefd") != 0){
    3b3a:	8552                	mv	a0,s4
    3b3c:	00002097          	auipc	ra,0x2
    3b40:	9fa080e7          	jalr	-1542(ra) # 5536 <chdir>
    3b44:	f955                	bnez	a0,3af8 <iref+0x58>
    mkdir("");
    3b46:	8526                	mv	a0,s1
    3b48:	00002097          	auipc	ra,0x2
    3b4c:	9e6080e7          	jalr	-1562(ra) # 552e <mkdir>
    link("README", "");
    3b50:	85a6                	mv	a1,s1
    3b52:	8556                	mv	a0,s5
    3b54:	00002097          	auipc	ra,0x2
    3b58:	9d2080e7          	jalr	-1582(ra) # 5526 <link>
    fd = open("", O_CREATE);
    3b5c:	20000593          	li	a1,512
    3b60:	8526                	mv	a0,s1
    3b62:	00002097          	auipc	ra,0x2
    3b66:	9a4080e7          	jalr	-1628(ra) # 5506 <open>
    if(fd >= 0)
    3b6a:	fa0555e3          	bgez	a0,3b14 <iref+0x74>
    fd = open("xx", O_CREATE);
    3b6e:	20000593          	li	a1,512
    3b72:	854e                	mv	a0,s3
    3b74:	00002097          	auipc	ra,0x2
    3b78:	992080e7          	jalr	-1646(ra) # 5506 <open>
    if(fd >= 0)
    3b7c:	fa0541e3          	bltz	a0,3b1e <iref+0x7e>
      close(fd);
    3b80:	00002097          	auipc	ra,0x2
    3b84:	96e080e7          	jalr	-1682(ra) # 54ee <close>
    3b88:	bf59                	j	3b1e <iref+0x7e>
    3b8a:	03300493          	li	s1,51
    chdir("..");
    3b8e:	00003997          	auipc	s3,0x3
    3b92:	3c298993          	addi	s3,s3,962 # 6f50 <malloc+0x1654>
    unlink("irefd");
    3b96:	00004917          	auipc	s2,0x4
    3b9a:	b8a90913          	addi	s2,s2,-1142 # 7720 <malloc+0x1e24>
    chdir("..");
    3b9e:	854e                	mv	a0,s3
    3ba0:	00002097          	auipc	ra,0x2
    3ba4:	996080e7          	jalr	-1642(ra) # 5536 <chdir>
    unlink("irefd");
    3ba8:	854a                	mv	a0,s2
    3baa:	00002097          	auipc	ra,0x2
    3bae:	96c080e7          	jalr	-1684(ra) # 5516 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3bb2:	34fd                	addiw	s1,s1,-1
    3bb4:	f4ed                	bnez	s1,3b9e <iref+0xfe>
  chdir("/");
    3bb6:	00003517          	auipc	a0,0x3
    3bba:	34250513          	addi	a0,a0,834 # 6ef8 <malloc+0x15fc>
    3bbe:	00002097          	auipc	ra,0x2
    3bc2:	978080e7          	jalr	-1672(ra) # 5536 <chdir>
}
    3bc6:	70e2                	ld	ra,56(sp)
    3bc8:	7442                	ld	s0,48(sp)
    3bca:	74a2                	ld	s1,40(sp)
    3bcc:	7902                	ld	s2,32(sp)
    3bce:	69e2                	ld	s3,24(sp)
    3bd0:	6a42                	ld	s4,16(sp)
    3bd2:	6aa2                	ld	s5,8(sp)
    3bd4:	6b02                	ld	s6,0(sp)
    3bd6:	6121                	addi	sp,sp,64
    3bd8:	8082                	ret

0000000000003bda <openiputtest>:
{
    3bda:	7179                	addi	sp,sp,-48
    3bdc:	f406                	sd	ra,40(sp)
    3bde:	f022                	sd	s0,32(sp)
    3be0:	ec26                	sd	s1,24(sp)
    3be2:	1800                	addi	s0,sp,48
    3be4:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3be6:	00004517          	auipc	a0,0x4
    3bea:	b7250513          	addi	a0,a0,-1166 # 7758 <malloc+0x1e5c>
    3bee:	00002097          	auipc	ra,0x2
    3bf2:	940080e7          	jalr	-1728(ra) # 552e <mkdir>
    3bf6:	04054263          	bltz	a0,3c3a <openiputtest+0x60>
  pid = fork();
    3bfa:	00002097          	auipc	ra,0x2
    3bfe:	8c4080e7          	jalr	-1852(ra) # 54be <fork>
  if(pid < 0){
    3c02:	04054a63          	bltz	a0,3c56 <openiputtest+0x7c>
  if(pid == 0){
    3c06:	e93d                	bnez	a0,3c7c <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3c08:	4589                	li	a1,2
    3c0a:	00004517          	auipc	a0,0x4
    3c0e:	b4e50513          	addi	a0,a0,-1202 # 7758 <malloc+0x1e5c>
    3c12:	00002097          	auipc	ra,0x2
    3c16:	8f4080e7          	jalr	-1804(ra) # 5506 <open>
    if(fd >= 0){
    3c1a:	04054c63          	bltz	a0,3c72 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3c1e:	85a6                	mv	a1,s1
    3c20:	00004517          	auipc	a0,0x4
    3c24:	b5850513          	addi	a0,a0,-1192 # 7778 <malloc+0x1e7c>
    3c28:	00002097          	auipc	ra,0x2
    3c2c:	c16080e7          	jalr	-1002(ra) # 583e <printf>
      exit(1);
    3c30:	4505                	li	a0,1
    3c32:	00002097          	auipc	ra,0x2
    3c36:	894080e7          	jalr	-1900(ra) # 54c6 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3c3a:	85a6                	mv	a1,s1
    3c3c:	00004517          	auipc	a0,0x4
    3c40:	b2450513          	addi	a0,a0,-1244 # 7760 <malloc+0x1e64>
    3c44:	00002097          	auipc	ra,0x2
    3c48:	bfa080e7          	jalr	-1030(ra) # 583e <printf>
    exit(1);
    3c4c:	4505                	li	a0,1
    3c4e:	00002097          	auipc	ra,0x2
    3c52:	878080e7          	jalr	-1928(ra) # 54c6 <exit>
    printf("%s: fork failed\n", s);
    3c56:	85a6                	mv	a1,s1
    3c58:	00003517          	auipc	a0,0x3
    3c5c:	90850513          	addi	a0,a0,-1784 # 6560 <malloc+0xc64>
    3c60:	00002097          	auipc	ra,0x2
    3c64:	bde080e7          	jalr	-1058(ra) # 583e <printf>
    exit(1);
    3c68:	4505                	li	a0,1
    3c6a:	00002097          	auipc	ra,0x2
    3c6e:	85c080e7          	jalr	-1956(ra) # 54c6 <exit>
    exit(0);
    3c72:	4501                	li	a0,0
    3c74:	00002097          	auipc	ra,0x2
    3c78:	852080e7          	jalr	-1966(ra) # 54c6 <exit>
  sleep(1);
    3c7c:	4505                	li	a0,1
    3c7e:	00002097          	auipc	ra,0x2
    3c82:	8d8080e7          	jalr	-1832(ra) # 5556 <sleep>
  if(unlink("oidir") != 0){
    3c86:	00004517          	auipc	a0,0x4
    3c8a:	ad250513          	addi	a0,a0,-1326 # 7758 <malloc+0x1e5c>
    3c8e:	00002097          	auipc	ra,0x2
    3c92:	888080e7          	jalr	-1912(ra) # 5516 <unlink>
    3c96:	cd19                	beqz	a0,3cb4 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3c98:	85a6                	mv	a1,s1
    3c9a:	00003517          	auipc	a0,0x3
    3c9e:	ab650513          	addi	a0,a0,-1354 # 6750 <malloc+0xe54>
    3ca2:	00002097          	auipc	ra,0x2
    3ca6:	b9c080e7          	jalr	-1124(ra) # 583e <printf>
    exit(1);
    3caa:	4505                	li	a0,1
    3cac:	00002097          	auipc	ra,0x2
    3cb0:	81a080e7          	jalr	-2022(ra) # 54c6 <exit>
  wait(&xstatus);
    3cb4:	fdc40513          	addi	a0,s0,-36
    3cb8:	00002097          	auipc	ra,0x2
    3cbc:	816080e7          	jalr	-2026(ra) # 54ce <wait>
  exit(xstatus);
    3cc0:	fdc42503          	lw	a0,-36(s0)
    3cc4:	00002097          	auipc	ra,0x2
    3cc8:	802080e7          	jalr	-2046(ra) # 54c6 <exit>

0000000000003ccc <forkforkfork>:
{
    3ccc:	1101                	addi	sp,sp,-32
    3cce:	ec06                	sd	ra,24(sp)
    3cd0:	e822                	sd	s0,16(sp)
    3cd2:	e426                	sd	s1,8(sp)
    3cd4:	1000                	addi	s0,sp,32
    3cd6:	84aa                	mv	s1,a0
  unlink("stopforking");
    3cd8:	00004517          	auipc	a0,0x4
    3cdc:	ac850513          	addi	a0,a0,-1336 # 77a0 <malloc+0x1ea4>
    3ce0:	00002097          	auipc	ra,0x2
    3ce4:	836080e7          	jalr	-1994(ra) # 5516 <unlink>
  int pid = fork();
    3ce8:	00001097          	auipc	ra,0x1
    3cec:	7d6080e7          	jalr	2006(ra) # 54be <fork>
  if(pid < 0){
    3cf0:	04054563          	bltz	a0,3d3a <forkforkfork+0x6e>
  if(pid == 0){
    3cf4:	c12d                	beqz	a0,3d56 <forkforkfork+0x8a>
  sleep(20); // two seconds
    3cf6:	4551                	li	a0,20
    3cf8:	00002097          	auipc	ra,0x2
    3cfc:	85e080e7          	jalr	-1954(ra) # 5556 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3d00:	20200593          	li	a1,514
    3d04:	00004517          	auipc	a0,0x4
    3d08:	a9c50513          	addi	a0,a0,-1380 # 77a0 <malloc+0x1ea4>
    3d0c:	00001097          	auipc	ra,0x1
    3d10:	7fa080e7          	jalr	2042(ra) # 5506 <open>
    3d14:	00001097          	auipc	ra,0x1
    3d18:	7da080e7          	jalr	2010(ra) # 54ee <close>
  wait(0);
    3d1c:	4501                	li	a0,0
    3d1e:	00001097          	auipc	ra,0x1
    3d22:	7b0080e7          	jalr	1968(ra) # 54ce <wait>
  sleep(10); // one second
    3d26:	4529                	li	a0,10
    3d28:	00002097          	auipc	ra,0x2
    3d2c:	82e080e7          	jalr	-2002(ra) # 5556 <sleep>
}
    3d30:	60e2                	ld	ra,24(sp)
    3d32:	6442                	ld	s0,16(sp)
    3d34:	64a2                	ld	s1,8(sp)
    3d36:	6105                	addi	sp,sp,32
    3d38:	8082                	ret
    printf("%s: fork failed", s);
    3d3a:	85a6                	mv	a1,s1
    3d3c:	00003517          	auipc	a0,0x3
    3d40:	9e450513          	addi	a0,a0,-1564 # 6720 <malloc+0xe24>
    3d44:	00002097          	auipc	ra,0x2
    3d48:	afa080e7          	jalr	-1286(ra) # 583e <printf>
    exit(1);
    3d4c:	4505                	li	a0,1
    3d4e:	00001097          	auipc	ra,0x1
    3d52:	778080e7          	jalr	1912(ra) # 54c6 <exit>
      int fd = open("stopforking", 0);
    3d56:	00004497          	auipc	s1,0x4
    3d5a:	a4a48493          	addi	s1,s1,-1462 # 77a0 <malloc+0x1ea4>
    3d5e:	4581                	li	a1,0
    3d60:	8526                	mv	a0,s1
    3d62:	00001097          	auipc	ra,0x1
    3d66:	7a4080e7          	jalr	1956(ra) # 5506 <open>
      if(fd >= 0){
    3d6a:	02055463          	bgez	a0,3d92 <forkforkfork+0xc6>
      if(fork() < 0){
    3d6e:	00001097          	auipc	ra,0x1
    3d72:	750080e7          	jalr	1872(ra) # 54be <fork>
    3d76:	fe0554e3          	bgez	a0,3d5e <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3d7a:	20200593          	li	a1,514
    3d7e:	8526                	mv	a0,s1
    3d80:	00001097          	auipc	ra,0x1
    3d84:	786080e7          	jalr	1926(ra) # 5506 <open>
    3d88:	00001097          	auipc	ra,0x1
    3d8c:	766080e7          	jalr	1894(ra) # 54ee <close>
    3d90:	b7f9                	j	3d5e <forkforkfork+0x92>
        exit(0);
    3d92:	4501                	li	a0,0
    3d94:	00001097          	auipc	ra,0x1
    3d98:	732080e7          	jalr	1842(ra) # 54c6 <exit>

0000000000003d9c <preempt>:
{
    3d9c:	7139                	addi	sp,sp,-64
    3d9e:	fc06                	sd	ra,56(sp)
    3da0:	f822                	sd	s0,48(sp)
    3da2:	f426                	sd	s1,40(sp)
    3da4:	f04a                	sd	s2,32(sp)
    3da6:	ec4e                	sd	s3,24(sp)
    3da8:	e852                	sd	s4,16(sp)
    3daa:	0080                	addi	s0,sp,64
    3dac:	892a                	mv	s2,a0
  pid1 = fork();
    3dae:	00001097          	auipc	ra,0x1
    3db2:	710080e7          	jalr	1808(ra) # 54be <fork>
  if(pid1 < 0) {
    3db6:	00054563          	bltz	a0,3dc0 <preempt+0x24>
    3dba:	84aa                	mv	s1,a0
  if(pid1 == 0)
    3dbc:	e105                	bnez	a0,3ddc <preempt+0x40>
    for(;;)
    3dbe:	a001                	j	3dbe <preempt+0x22>
    printf("%s: fork failed", s);
    3dc0:	85ca                	mv	a1,s2
    3dc2:	00003517          	auipc	a0,0x3
    3dc6:	95e50513          	addi	a0,a0,-1698 # 6720 <malloc+0xe24>
    3dca:	00002097          	auipc	ra,0x2
    3dce:	a74080e7          	jalr	-1420(ra) # 583e <printf>
    exit(1);
    3dd2:	4505                	li	a0,1
    3dd4:	00001097          	auipc	ra,0x1
    3dd8:	6f2080e7          	jalr	1778(ra) # 54c6 <exit>
  pid2 = fork();
    3ddc:	00001097          	auipc	ra,0x1
    3de0:	6e2080e7          	jalr	1762(ra) # 54be <fork>
    3de4:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3de6:	00054463          	bltz	a0,3dee <preempt+0x52>
  if(pid2 == 0)
    3dea:	e105                	bnez	a0,3e0a <preempt+0x6e>
    for(;;)
    3dec:	a001                	j	3dec <preempt+0x50>
    printf("%s: fork failed\n", s);
    3dee:	85ca                	mv	a1,s2
    3df0:	00002517          	auipc	a0,0x2
    3df4:	77050513          	addi	a0,a0,1904 # 6560 <malloc+0xc64>
    3df8:	00002097          	auipc	ra,0x2
    3dfc:	a46080e7          	jalr	-1466(ra) # 583e <printf>
    exit(1);
    3e00:	4505                	li	a0,1
    3e02:	00001097          	auipc	ra,0x1
    3e06:	6c4080e7          	jalr	1732(ra) # 54c6 <exit>
  pipe(pfds);
    3e0a:	fc840513          	addi	a0,s0,-56
    3e0e:	00001097          	auipc	ra,0x1
    3e12:	6c8080e7          	jalr	1736(ra) # 54d6 <pipe>
  pid3 = fork();
    3e16:	00001097          	auipc	ra,0x1
    3e1a:	6a8080e7          	jalr	1704(ra) # 54be <fork>
    3e1e:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    3e20:	02054e63          	bltz	a0,3e5c <preempt+0xc0>
  if(pid3 == 0){
    3e24:	e525                	bnez	a0,3e8c <preempt+0xf0>
    close(pfds[0]);
    3e26:	fc842503          	lw	a0,-56(s0)
    3e2a:	00001097          	auipc	ra,0x1
    3e2e:	6c4080e7          	jalr	1732(ra) # 54ee <close>
    if(write(pfds[1], "x", 1) != 1)
    3e32:	4605                	li	a2,1
    3e34:	00002597          	auipc	a1,0x2
    3e38:	f6458593          	addi	a1,a1,-156 # 5d98 <malloc+0x49c>
    3e3c:	fcc42503          	lw	a0,-52(s0)
    3e40:	00001097          	auipc	ra,0x1
    3e44:	6a6080e7          	jalr	1702(ra) # 54e6 <write>
    3e48:	4785                	li	a5,1
    3e4a:	02f51763          	bne	a0,a5,3e78 <preempt+0xdc>
    close(pfds[1]);
    3e4e:	fcc42503          	lw	a0,-52(s0)
    3e52:	00001097          	auipc	ra,0x1
    3e56:	69c080e7          	jalr	1692(ra) # 54ee <close>
    for(;;)
    3e5a:	a001                	j	3e5a <preempt+0xbe>
     printf("%s: fork failed\n", s);
    3e5c:	85ca                	mv	a1,s2
    3e5e:	00002517          	auipc	a0,0x2
    3e62:	70250513          	addi	a0,a0,1794 # 6560 <malloc+0xc64>
    3e66:	00002097          	auipc	ra,0x2
    3e6a:	9d8080e7          	jalr	-1576(ra) # 583e <printf>
     exit(1);
    3e6e:	4505                	li	a0,1
    3e70:	00001097          	auipc	ra,0x1
    3e74:	656080e7          	jalr	1622(ra) # 54c6 <exit>
      printf("%s: preempt write error", s);
    3e78:	85ca                	mv	a1,s2
    3e7a:	00004517          	auipc	a0,0x4
    3e7e:	93650513          	addi	a0,a0,-1738 # 77b0 <malloc+0x1eb4>
    3e82:	00002097          	auipc	ra,0x2
    3e86:	9bc080e7          	jalr	-1604(ra) # 583e <printf>
    3e8a:	b7d1                	j	3e4e <preempt+0xb2>
  close(pfds[1]);
    3e8c:	fcc42503          	lw	a0,-52(s0)
    3e90:	00001097          	auipc	ra,0x1
    3e94:	65e080e7          	jalr	1630(ra) # 54ee <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3e98:	660d                	lui	a2,0x3
    3e9a:	00008597          	auipc	a1,0x8
    3e9e:	a8658593          	addi	a1,a1,-1402 # b920 <buf>
    3ea2:	fc842503          	lw	a0,-56(s0)
    3ea6:	00001097          	auipc	ra,0x1
    3eaa:	638080e7          	jalr	1592(ra) # 54de <read>
    3eae:	4785                	li	a5,1
    3eb0:	02f50363          	beq	a0,a5,3ed6 <preempt+0x13a>
    printf("%s: preempt read error", s);
    3eb4:	85ca                	mv	a1,s2
    3eb6:	00004517          	auipc	a0,0x4
    3eba:	91250513          	addi	a0,a0,-1774 # 77c8 <malloc+0x1ecc>
    3ebe:	00002097          	auipc	ra,0x2
    3ec2:	980080e7          	jalr	-1664(ra) # 583e <printf>
}
    3ec6:	70e2                	ld	ra,56(sp)
    3ec8:	7442                	ld	s0,48(sp)
    3eca:	74a2                	ld	s1,40(sp)
    3ecc:	7902                	ld	s2,32(sp)
    3ece:	69e2                	ld	s3,24(sp)
    3ed0:	6a42                	ld	s4,16(sp)
    3ed2:	6121                	addi	sp,sp,64
    3ed4:	8082                	ret
  close(pfds[0]);
    3ed6:	fc842503          	lw	a0,-56(s0)
    3eda:	00001097          	auipc	ra,0x1
    3ede:	614080e7          	jalr	1556(ra) # 54ee <close>
  printf("kill... ");
    3ee2:	00004517          	auipc	a0,0x4
    3ee6:	8fe50513          	addi	a0,a0,-1794 # 77e0 <malloc+0x1ee4>
    3eea:	00002097          	auipc	ra,0x2
    3eee:	954080e7          	jalr	-1708(ra) # 583e <printf>
  kill(pid1);
    3ef2:	8526                	mv	a0,s1
    3ef4:	00001097          	auipc	ra,0x1
    3ef8:	602080e7          	jalr	1538(ra) # 54f6 <kill>
  kill(pid2);
    3efc:	854e                	mv	a0,s3
    3efe:	00001097          	auipc	ra,0x1
    3f02:	5f8080e7          	jalr	1528(ra) # 54f6 <kill>
  kill(pid3);
    3f06:	8552                	mv	a0,s4
    3f08:	00001097          	auipc	ra,0x1
    3f0c:	5ee080e7          	jalr	1518(ra) # 54f6 <kill>
  printf("wait... ");
    3f10:	00004517          	auipc	a0,0x4
    3f14:	8e050513          	addi	a0,a0,-1824 # 77f0 <malloc+0x1ef4>
    3f18:	00002097          	auipc	ra,0x2
    3f1c:	926080e7          	jalr	-1754(ra) # 583e <printf>
  wait(0);
    3f20:	4501                	li	a0,0
    3f22:	00001097          	auipc	ra,0x1
    3f26:	5ac080e7          	jalr	1452(ra) # 54ce <wait>
  wait(0);
    3f2a:	4501                	li	a0,0
    3f2c:	00001097          	auipc	ra,0x1
    3f30:	5a2080e7          	jalr	1442(ra) # 54ce <wait>
  wait(0);
    3f34:	4501                	li	a0,0
    3f36:	00001097          	auipc	ra,0x1
    3f3a:	598080e7          	jalr	1432(ra) # 54ce <wait>
    3f3e:	b761                	j	3ec6 <preempt+0x12a>

0000000000003f40 <sbrkfail>:
{
    3f40:	7119                	addi	sp,sp,-128
    3f42:	fc86                	sd	ra,120(sp)
    3f44:	f8a2                	sd	s0,112(sp)
    3f46:	f4a6                	sd	s1,104(sp)
    3f48:	f0ca                	sd	s2,96(sp)
    3f4a:	ecce                	sd	s3,88(sp)
    3f4c:	e8d2                	sd	s4,80(sp)
    3f4e:	e4d6                	sd	s5,72(sp)
    3f50:	0100                	addi	s0,sp,128
    3f52:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    3f54:	fb040513          	addi	a0,s0,-80
    3f58:	00001097          	auipc	ra,0x1
    3f5c:	57e080e7          	jalr	1406(ra) # 54d6 <pipe>
    3f60:	e901                	bnez	a0,3f70 <sbrkfail+0x30>
    3f62:	f8040493          	addi	s1,s0,-128
    3f66:	fa840993          	addi	s3,s0,-88
    3f6a:	8926                	mv	s2,s1
    if(pids[i] != -1)
    3f6c:	5a7d                	li	s4,-1
    3f6e:	a085                	j	3fce <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    3f70:	85d6                	mv	a1,s5
    3f72:	00002517          	auipc	a0,0x2
    3f76:	6f650513          	addi	a0,a0,1782 # 6668 <malloc+0xd6c>
    3f7a:	00002097          	auipc	ra,0x2
    3f7e:	8c4080e7          	jalr	-1852(ra) # 583e <printf>
    exit(1);
    3f82:	4505                	li	a0,1
    3f84:	00001097          	auipc	ra,0x1
    3f88:	542080e7          	jalr	1346(ra) # 54c6 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    3f8c:	00001097          	auipc	ra,0x1
    3f90:	5c2080e7          	jalr	1474(ra) # 554e <sbrk>
    3f94:	064007b7          	lui	a5,0x6400
    3f98:	40a7853b          	subw	a0,a5,a0
    3f9c:	00001097          	auipc	ra,0x1
    3fa0:	5b2080e7          	jalr	1458(ra) # 554e <sbrk>
      write(fds[1], "x", 1);
    3fa4:	4605                	li	a2,1
    3fa6:	00002597          	auipc	a1,0x2
    3faa:	df258593          	addi	a1,a1,-526 # 5d98 <malloc+0x49c>
    3fae:	fb442503          	lw	a0,-76(s0)
    3fb2:	00001097          	auipc	ra,0x1
    3fb6:	534080e7          	jalr	1332(ra) # 54e6 <write>
      for(;;) sleep(1000);
    3fba:	3e800513          	li	a0,1000
    3fbe:	00001097          	auipc	ra,0x1
    3fc2:	598080e7          	jalr	1432(ra) # 5556 <sleep>
    3fc6:	bfd5                	j	3fba <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3fc8:	0911                	addi	s2,s2,4
    3fca:	03390563          	beq	s2,s3,3ff4 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    3fce:	00001097          	auipc	ra,0x1
    3fd2:	4f0080e7          	jalr	1264(ra) # 54be <fork>
    3fd6:	00a92023          	sw	a0,0(s2)
    3fda:	d94d                	beqz	a0,3f8c <sbrkfail+0x4c>
    if(pids[i] != -1)
    3fdc:	ff4506e3          	beq	a0,s4,3fc8 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    3fe0:	4605                	li	a2,1
    3fe2:	faf40593          	addi	a1,s0,-81
    3fe6:	fb042503          	lw	a0,-80(s0)
    3fea:	00001097          	auipc	ra,0x1
    3fee:	4f4080e7          	jalr	1268(ra) # 54de <read>
    3ff2:	bfd9                	j	3fc8 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    3ff4:	6505                	lui	a0,0x1
    3ff6:	00001097          	auipc	ra,0x1
    3ffa:	558080e7          	jalr	1368(ra) # 554e <sbrk>
    3ffe:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    4000:	597d                	li	s2,-1
    4002:	a021                	j	400a <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4004:	0491                	addi	s1,s1,4
    4006:	01348f63          	beq	s1,s3,4024 <sbrkfail+0xe4>
    if(pids[i] == -1)
    400a:	4088                	lw	a0,0(s1)
    400c:	ff250ce3          	beq	a0,s2,4004 <sbrkfail+0xc4>
    kill(pids[i]);
    4010:	00001097          	auipc	ra,0x1
    4014:	4e6080e7          	jalr	1254(ra) # 54f6 <kill>
    wait(0);
    4018:	4501                	li	a0,0
    401a:	00001097          	auipc	ra,0x1
    401e:	4b4080e7          	jalr	1204(ra) # 54ce <wait>
    4022:	b7cd                	j	4004 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    4024:	57fd                	li	a5,-1
    4026:	04fa0163          	beq	s4,a5,4068 <sbrkfail+0x128>
  pid = fork();
    402a:	00001097          	auipc	ra,0x1
    402e:	494080e7          	jalr	1172(ra) # 54be <fork>
    4032:	84aa                	mv	s1,a0
  if(pid < 0){
    4034:	04054863          	bltz	a0,4084 <sbrkfail+0x144>
  if(pid == 0){
    4038:	c525                	beqz	a0,40a0 <sbrkfail+0x160>
  wait(&xstatus);
    403a:	fbc40513          	addi	a0,s0,-68
    403e:	00001097          	auipc	ra,0x1
    4042:	490080e7          	jalr	1168(ra) # 54ce <wait>
  if(xstatus != -1 && xstatus != 2)
    4046:	fbc42783          	lw	a5,-68(s0)
    404a:	577d                	li	a4,-1
    404c:	00e78563          	beq	a5,a4,4056 <sbrkfail+0x116>
    4050:	4709                	li	a4,2
    4052:	08e79d63          	bne	a5,a4,40ec <sbrkfail+0x1ac>
}
    4056:	70e6                	ld	ra,120(sp)
    4058:	7446                	ld	s0,112(sp)
    405a:	74a6                	ld	s1,104(sp)
    405c:	7906                	ld	s2,96(sp)
    405e:	69e6                	ld	s3,88(sp)
    4060:	6a46                	ld	s4,80(sp)
    4062:	6aa6                	ld	s5,72(sp)
    4064:	6109                	addi	sp,sp,128
    4066:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4068:	85d6                	mv	a1,s5
    406a:	00003517          	auipc	a0,0x3
    406e:	79650513          	addi	a0,a0,1942 # 7800 <malloc+0x1f04>
    4072:	00001097          	auipc	ra,0x1
    4076:	7cc080e7          	jalr	1996(ra) # 583e <printf>
    exit(1);
    407a:	4505                	li	a0,1
    407c:	00001097          	auipc	ra,0x1
    4080:	44a080e7          	jalr	1098(ra) # 54c6 <exit>
    printf("%s: fork failed\n", s);
    4084:	85d6                	mv	a1,s5
    4086:	00002517          	auipc	a0,0x2
    408a:	4da50513          	addi	a0,a0,1242 # 6560 <malloc+0xc64>
    408e:	00001097          	auipc	ra,0x1
    4092:	7b0080e7          	jalr	1968(ra) # 583e <printf>
    exit(1);
    4096:	4505                	li	a0,1
    4098:	00001097          	auipc	ra,0x1
    409c:	42e080e7          	jalr	1070(ra) # 54c6 <exit>
    a = sbrk(0);
    40a0:	4501                	li	a0,0
    40a2:	00001097          	auipc	ra,0x1
    40a6:	4ac080e7          	jalr	1196(ra) # 554e <sbrk>
    40aa:	892a                	mv	s2,a0
    sbrk(10*BIG);
    40ac:	3e800537          	lui	a0,0x3e800
    40b0:	00001097          	auipc	ra,0x1
    40b4:	49e080e7          	jalr	1182(ra) # 554e <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    40b8:	87ca                	mv	a5,s2
    40ba:	3e800737          	lui	a4,0x3e800
    40be:	993a                	add	s2,s2,a4
    40c0:	6705                	lui	a4,0x1
      n += *(a+i);
    40c2:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f16d0>
    40c6:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    40c8:	97ba                	add	a5,a5,a4
    40ca:	ff279ce3          	bne	a5,s2,40c2 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    40ce:	8626                	mv	a2,s1
    40d0:	85d6                	mv	a1,s5
    40d2:	00003517          	auipc	a0,0x3
    40d6:	74e50513          	addi	a0,a0,1870 # 7820 <malloc+0x1f24>
    40da:	00001097          	auipc	ra,0x1
    40de:	764080e7          	jalr	1892(ra) # 583e <printf>
    exit(1);
    40e2:	4505                	li	a0,1
    40e4:	00001097          	auipc	ra,0x1
    40e8:	3e2080e7          	jalr	994(ra) # 54c6 <exit>
    exit(1);
    40ec:	4505                	li	a0,1
    40ee:	00001097          	auipc	ra,0x1
    40f2:	3d8080e7          	jalr	984(ra) # 54c6 <exit>

00000000000040f6 <reparent>:
{
    40f6:	7179                	addi	sp,sp,-48
    40f8:	f406                	sd	ra,40(sp)
    40fa:	f022                	sd	s0,32(sp)
    40fc:	ec26                	sd	s1,24(sp)
    40fe:	e84a                	sd	s2,16(sp)
    4100:	e44e                	sd	s3,8(sp)
    4102:	e052                	sd	s4,0(sp)
    4104:	1800                	addi	s0,sp,48
    4106:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4108:	00001097          	auipc	ra,0x1
    410c:	43e080e7          	jalr	1086(ra) # 5546 <getpid>
    4110:	8a2a                	mv	s4,a0
    4112:	0c800913          	li	s2,200
    int pid = fork();
    4116:	00001097          	auipc	ra,0x1
    411a:	3a8080e7          	jalr	936(ra) # 54be <fork>
    411e:	84aa                	mv	s1,a0
    if(pid < 0){
    4120:	02054263          	bltz	a0,4144 <reparent+0x4e>
    if(pid){
    4124:	cd21                	beqz	a0,417c <reparent+0x86>
      if(wait(0) != pid){
    4126:	4501                	li	a0,0
    4128:	00001097          	auipc	ra,0x1
    412c:	3a6080e7          	jalr	934(ra) # 54ce <wait>
    4130:	02951863          	bne	a0,s1,4160 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    4134:	397d                	addiw	s2,s2,-1
    4136:	fe0910e3          	bnez	s2,4116 <reparent+0x20>
  exit(0);
    413a:	4501                	li	a0,0
    413c:	00001097          	auipc	ra,0x1
    4140:	38a080e7          	jalr	906(ra) # 54c6 <exit>
      printf("%s: fork failed\n", s);
    4144:	85ce                	mv	a1,s3
    4146:	00002517          	auipc	a0,0x2
    414a:	41a50513          	addi	a0,a0,1050 # 6560 <malloc+0xc64>
    414e:	00001097          	auipc	ra,0x1
    4152:	6f0080e7          	jalr	1776(ra) # 583e <printf>
      exit(1);
    4156:	4505                	li	a0,1
    4158:	00001097          	auipc	ra,0x1
    415c:	36e080e7          	jalr	878(ra) # 54c6 <exit>
        printf("%s: wait wrong pid\n", s);
    4160:	85ce                	mv	a1,s3
    4162:	00002517          	auipc	a0,0x2
    4166:	58650513          	addi	a0,a0,1414 # 66e8 <malloc+0xdec>
    416a:	00001097          	auipc	ra,0x1
    416e:	6d4080e7          	jalr	1748(ra) # 583e <printf>
        exit(1);
    4172:	4505                	li	a0,1
    4174:	00001097          	auipc	ra,0x1
    4178:	352080e7          	jalr	850(ra) # 54c6 <exit>
      int pid2 = fork();
    417c:	00001097          	auipc	ra,0x1
    4180:	342080e7          	jalr	834(ra) # 54be <fork>
      if(pid2 < 0){
    4184:	00054763          	bltz	a0,4192 <reparent+0x9c>
      exit(0);
    4188:	4501                	li	a0,0
    418a:	00001097          	auipc	ra,0x1
    418e:	33c080e7          	jalr	828(ra) # 54c6 <exit>
        kill(master_pid);
    4192:	8552                	mv	a0,s4
    4194:	00001097          	auipc	ra,0x1
    4198:	362080e7          	jalr	866(ra) # 54f6 <kill>
        exit(1);
    419c:	4505                	li	a0,1
    419e:	00001097          	auipc	ra,0x1
    41a2:	328080e7          	jalr	808(ra) # 54c6 <exit>

00000000000041a6 <mem>:
{
    41a6:	7139                	addi	sp,sp,-64
    41a8:	fc06                	sd	ra,56(sp)
    41aa:	f822                	sd	s0,48(sp)
    41ac:	f426                	sd	s1,40(sp)
    41ae:	f04a                	sd	s2,32(sp)
    41b0:	ec4e                	sd	s3,24(sp)
    41b2:	0080                	addi	s0,sp,64
    41b4:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    41b6:	00001097          	auipc	ra,0x1
    41ba:	308080e7          	jalr	776(ra) # 54be <fork>
    m1 = 0;
    41be:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    41c0:	6909                	lui	s2,0x2
    41c2:	71190913          	addi	s2,s2,1809 # 2711 <sbrkmuch+0x10b>
  if((pid = fork()) == 0){
    41c6:	c115                	beqz	a0,41ea <mem+0x44>
    wait(&xstatus);
    41c8:	fcc40513          	addi	a0,s0,-52
    41cc:	00001097          	auipc	ra,0x1
    41d0:	302080e7          	jalr	770(ra) # 54ce <wait>
    if(xstatus == -1){
    41d4:	fcc42503          	lw	a0,-52(s0)
    41d8:	57fd                	li	a5,-1
    41da:	06f50363          	beq	a0,a5,4240 <mem+0x9a>
    exit(xstatus);
    41de:	00001097          	auipc	ra,0x1
    41e2:	2e8080e7          	jalr	744(ra) # 54c6 <exit>
      *(char**)m2 = m1;
    41e6:	e104                	sd	s1,0(a0)
      m1 = m2;
    41e8:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    41ea:	854a                	mv	a0,s2
    41ec:	00001097          	auipc	ra,0x1
    41f0:	710080e7          	jalr	1808(ra) # 58fc <malloc>
    41f4:	f96d                	bnez	a0,41e6 <mem+0x40>
    while(m1){
    41f6:	c881                	beqz	s1,4206 <mem+0x60>
      m2 = *(char**)m1;
    41f8:	8526                	mv	a0,s1
    41fa:	6084                	ld	s1,0(s1)
      free(m1);
    41fc:	00001097          	auipc	ra,0x1
    4200:	678080e7          	jalr	1656(ra) # 5874 <free>
    while(m1){
    4204:	f8f5                	bnez	s1,41f8 <mem+0x52>
    m1 = malloc(1024*20);
    4206:	6515                	lui	a0,0x5
    4208:	00001097          	auipc	ra,0x1
    420c:	6f4080e7          	jalr	1780(ra) # 58fc <malloc>
    if(m1 == 0){
    4210:	c911                	beqz	a0,4224 <mem+0x7e>
    free(m1);
    4212:	00001097          	auipc	ra,0x1
    4216:	662080e7          	jalr	1634(ra) # 5874 <free>
    exit(0);
    421a:	4501                	li	a0,0
    421c:	00001097          	auipc	ra,0x1
    4220:	2aa080e7          	jalr	682(ra) # 54c6 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4224:	85ce                	mv	a1,s3
    4226:	00003517          	auipc	a0,0x3
    422a:	62a50513          	addi	a0,a0,1578 # 7850 <malloc+0x1f54>
    422e:	00001097          	auipc	ra,0x1
    4232:	610080e7          	jalr	1552(ra) # 583e <printf>
      exit(1);
    4236:	4505                	li	a0,1
    4238:	00001097          	auipc	ra,0x1
    423c:	28e080e7          	jalr	654(ra) # 54c6 <exit>
      exit(0);
    4240:	4501                	li	a0,0
    4242:	00001097          	auipc	ra,0x1
    4246:	284080e7          	jalr	644(ra) # 54c6 <exit>

000000000000424a <sharedfd>:
{
    424a:	7159                	addi	sp,sp,-112
    424c:	f486                	sd	ra,104(sp)
    424e:	f0a2                	sd	s0,96(sp)
    4250:	eca6                	sd	s1,88(sp)
    4252:	e8ca                	sd	s2,80(sp)
    4254:	e4ce                	sd	s3,72(sp)
    4256:	e0d2                	sd	s4,64(sp)
    4258:	fc56                	sd	s5,56(sp)
    425a:	f85a                	sd	s6,48(sp)
    425c:	f45e                	sd	s7,40(sp)
    425e:	1880                	addi	s0,sp,112
    4260:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4262:	00002517          	auipc	a0,0x2
    4266:	90650513          	addi	a0,a0,-1786 # 5b68 <malloc+0x26c>
    426a:	00001097          	auipc	ra,0x1
    426e:	2ac080e7          	jalr	684(ra) # 5516 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4272:	20200593          	li	a1,514
    4276:	00002517          	auipc	a0,0x2
    427a:	8f250513          	addi	a0,a0,-1806 # 5b68 <malloc+0x26c>
    427e:	00001097          	auipc	ra,0x1
    4282:	288080e7          	jalr	648(ra) # 5506 <open>
  if(fd < 0){
    4286:	04054a63          	bltz	a0,42da <sharedfd+0x90>
    428a:	892a                	mv	s2,a0
  pid = fork();
    428c:	00001097          	auipc	ra,0x1
    4290:	232080e7          	jalr	562(ra) # 54be <fork>
    4294:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4296:	06300593          	li	a1,99
    429a:	c119                	beqz	a0,42a0 <sharedfd+0x56>
    429c:	07000593          	li	a1,112
    42a0:	4629                	li	a2,10
    42a2:	fa040513          	addi	a0,s0,-96
    42a6:	00001097          	auipc	ra,0x1
    42aa:	024080e7          	jalr	36(ra) # 52ca <memset>
    42ae:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    42b2:	4629                	li	a2,10
    42b4:	fa040593          	addi	a1,s0,-96
    42b8:	854a                	mv	a0,s2
    42ba:	00001097          	auipc	ra,0x1
    42be:	22c080e7          	jalr	556(ra) # 54e6 <write>
    42c2:	47a9                	li	a5,10
    42c4:	02f51963          	bne	a0,a5,42f6 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    42c8:	34fd                	addiw	s1,s1,-1
    42ca:	f4e5                	bnez	s1,42b2 <sharedfd+0x68>
  if(pid == 0) {
    42cc:	04099363          	bnez	s3,4312 <sharedfd+0xc8>
    exit(0);
    42d0:	4501                	li	a0,0
    42d2:	00001097          	auipc	ra,0x1
    42d6:	1f4080e7          	jalr	500(ra) # 54c6 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    42da:	85d2                	mv	a1,s4
    42dc:	00003517          	auipc	a0,0x3
    42e0:	59450513          	addi	a0,a0,1428 # 7870 <malloc+0x1f74>
    42e4:	00001097          	auipc	ra,0x1
    42e8:	55a080e7          	jalr	1370(ra) # 583e <printf>
    exit(1);
    42ec:	4505                	li	a0,1
    42ee:	00001097          	auipc	ra,0x1
    42f2:	1d8080e7          	jalr	472(ra) # 54c6 <exit>
      printf("%s: write sharedfd failed\n", s);
    42f6:	85d2                	mv	a1,s4
    42f8:	00003517          	auipc	a0,0x3
    42fc:	5a050513          	addi	a0,a0,1440 # 7898 <malloc+0x1f9c>
    4300:	00001097          	auipc	ra,0x1
    4304:	53e080e7          	jalr	1342(ra) # 583e <printf>
      exit(1);
    4308:	4505                	li	a0,1
    430a:	00001097          	auipc	ra,0x1
    430e:	1bc080e7          	jalr	444(ra) # 54c6 <exit>
    wait(&xstatus);
    4312:	f9c40513          	addi	a0,s0,-100
    4316:	00001097          	auipc	ra,0x1
    431a:	1b8080e7          	jalr	440(ra) # 54ce <wait>
    if(xstatus != 0)
    431e:	f9c42983          	lw	s3,-100(s0)
    4322:	00098763          	beqz	s3,4330 <sharedfd+0xe6>
      exit(xstatus);
    4326:	854e                	mv	a0,s3
    4328:	00001097          	auipc	ra,0x1
    432c:	19e080e7          	jalr	414(ra) # 54c6 <exit>
  close(fd);
    4330:	854a                	mv	a0,s2
    4332:	00001097          	auipc	ra,0x1
    4336:	1bc080e7          	jalr	444(ra) # 54ee <close>
  fd = open("sharedfd", 0);
    433a:	4581                	li	a1,0
    433c:	00002517          	auipc	a0,0x2
    4340:	82c50513          	addi	a0,a0,-2004 # 5b68 <malloc+0x26c>
    4344:	00001097          	auipc	ra,0x1
    4348:	1c2080e7          	jalr	450(ra) # 5506 <open>
    434c:	8baa                	mv	s7,a0
  nc = np = 0;
    434e:	8ace                	mv	s5,s3
  if(fd < 0){
    4350:	02054563          	bltz	a0,437a <sharedfd+0x130>
    4354:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4358:	06300493          	li	s1,99
      if(buf[i] == 'p')
    435c:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4360:	4629                	li	a2,10
    4362:	fa040593          	addi	a1,s0,-96
    4366:	855e                	mv	a0,s7
    4368:	00001097          	auipc	ra,0x1
    436c:	176080e7          	jalr	374(ra) # 54de <read>
    4370:	02a05f63          	blez	a0,43ae <sharedfd+0x164>
    4374:	fa040793          	addi	a5,s0,-96
    4378:	a01d                	j	439e <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    437a:	85d2                	mv	a1,s4
    437c:	00003517          	auipc	a0,0x3
    4380:	53c50513          	addi	a0,a0,1340 # 78b8 <malloc+0x1fbc>
    4384:	00001097          	auipc	ra,0x1
    4388:	4ba080e7          	jalr	1210(ra) # 583e <printf>
    exit(1);
    438c:	4505                	li	a0,1
    438e:	00001097          	auipc	ra,0x1
    4392:	138080e7          	jalr	312(ra) # 54c6 <exit>
        nc++;
    4396:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    4398:	0785                	addi	a5,a5,1
    439a:	fd2783e3          	beq	a5,s2,4360 <sharedfd+0x116>
      if(buf[i] == 'c')
    439e:	0007c703          	lbu	a4,0(a5)
    43a2:	fe970ae3          	beq	a4,s1,4396 <sharedfd+0x14c>
      if(buf[i] == 'p')
    43a6:	ff6719e3          	bne	a4,s6,4398 <sharedfd+0x14e>
        np++;
    43aa:	2a85                	addiw	s5,s5,1
    43ac:	b7f5                	j	4398 <sharedfd+0x14e>
  close(fd);
    43ae:	855e                	mv	a0,s7
    43b0:	00001097          	auipc	ra,0x1
    43b4:	13e080e7          	jalr	318(ra) # 54ee <close>
  unlink("sharedfd");
    43b8:	00001517          	auipc	a0,0x1
    43bc:	7b050513          	addi	a0,a0,1968 # 5b68 <malloc+0x26c>
    43c0:	00001097          	auipc	ra,0x1
    43c4:	156080e7          	jalr	342(ra) # 5516 <unlink>
  if(nc == N*SZ && np == N*SZ){
    43c8:	6789                	lui	a5,0x2
    43ca:	71078793          	addi	a5,a5,1808 # 2710 <sbrkmuch+0x10a>
    43ce:	00f99763          	bne	s3,a5,43dc <sharedfd+0x192>
    43d2:	6789                	lui	a5,0x2
    43d4:	71078793          	addi	a5,a5,1808 # 2710 <sbrkmuch+0x10a>
    43d8:	02fa8063          	beq	s5,a5,43f8 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    43dc:	85d2                	mv	a1,s4
    43de:	00003517          	auipc	a0,0x3
    43e2:	50250513          	addi	a0,a0,1282 # 78e0 <malloc+0x1fe4>
    43e6:	00001097          	auipc	ra,0x1
    43ea:	458080e7          	jalr	1112(ra) # 583e <printf>
    exit(1);
    43ee:	4505                	li	a0,1
    43f0:	00001097          	auipc	ra,0x1
    43f4:	0d6080e7          	jalr	214(ra) # 54c6 <exit>
    exit(0);
    43f8:	4501                	li	a0,0
    43fa:	00001097          	auipc	ra,0x1
    43fe:	0cc080e7          	jalr	204(ra) # 54c6 <exit>

0000000000004402 <fourfiles>:
{
    4402:	7171                	addi	sp,sp,-176
    4404:	f506                	sd	ra,168(sp)
    4406:	f122                	sd	s0,160(sp)
    4408:	ed26                	sd	s1,152(sp)
    440a:	e94a                	sd	s2,144(sp)
    440c:	e54e                	sd	s3,136(sp)
    440e:	e152                	sd	s4,128(sp)
    4410:	fcd6                	sd	s5,120(sp)
    4412:	f8da                	sd	s6,112(sp)
    4414:	f4de                	sd	s7,104(sp)
    4416:	f0e2                	sd	s8,96(sp)
    4418:	ece6                	sd	s9,88(sp)
    441a:	e8ea                	sd	s10,80(sp)
    441c:	e4ee                	sd	s11,72(sp)
    441e:	1900                	addi	s0,sp,176
    4420:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    4424:	00001797          	auipc	a5,0x1
    4428:	5bc78793          	addi	a5,a5,1468 # 59e0 <malloc+0xe4>
    442c:	f6f43823          	sd	a5,-144(s0)
    4430:	00001797          	auipc	a5,0x1
    4434:	5b878793          	addi	a5,a5,1464 # 59e8 <malloc+0xec>
    4438:	f6f43c23          	sd	a5,-136(s0)
    443c:	00001797          	auipc	a5,0x1
    4440:	5b478793          	addi	a5,a5,1460 # 59f0 <malloc+0xf4>
    4444:	f8f43023          	sd	a5,-128(s0)
    4448:	00001797          	auipc	a5,0x1
    444c:	5b078793          	addi	a5,a5,1456 # 59f8 <malloc+0xfc>
    4450:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4454:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4458:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    445a:	4481                	li	s1,0
    445c:	4a11                	li	s4,4
    fname = names[pi];
    445e:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4462:	854e                	mv	a0,s3
    4464:	00001097          	auipc	ra,0x1
    4468:	0b2080e7          	jalr	178(ra) # 5516 <unlink>
    pid = fork();
    446c:	00001097          	auipc	ra,0x1
    4470:	052080e7          	jalr	82(ra) # 54be <fork>
    if(pid < 0){
    4474:	04054463          	bltz	a0,44bc <fourfiles+0xba>
    if(pid == 0){
    4478:	c12d                	beqz	a0,44da <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    447a:	2485                	addiw	s1,s1,1
    447c:	0921                	addi	s2,s2,8
    447e:	ff4490e3          	bne	s1,s4,445e <fourfiles+0x5c>
    4482:	4491                	li	s1,4
    wait(&xstatus);
    4484:	f6c40513          	addi	a0,s0,-148
    4488:	00001097          	auipc	ra,0x1
    448c:	046080e7          	jalr	70(ra) # 54ce <wait>
    if(xstatus != 0)
    4490:	f6c42b03          	lw	s6,-148(s0)
    4494:	0c0b1e63          	bnez	s6,4570 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    4498:	34fd                	addiw	s1,s1,-1
    449a:	f4ed                	bnez	s1,4484 <fourfiles+0x82>
    449c:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    44a0:	00007a17          	auipc	s4,0x7
    44a4:	480a0a13          	addi	s4,s4,1152 # b920 <buf>
    44a8:	00007a97          	auipc	s5,0x7
    44ac:	479a8a93          	addi	s5,s5,1145 # b921 <buf+0x1>
    if(total != N*SZ){
    44b0:	6d85                	lui	s11,0x1
    44b2:	770d8d93          	addi	s11,s11,1904 # 1770 <pipe1+0x1e>
  for(i = 0; i < NCHILD; i++){
    44b6:	03400d13          	li	s10,52
    44ba:	aa1d                	j	45f0 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    44bc:	f5843583          	ld	a1,-168(s0)
    44c0:	00002517          	auipc	a0,0x2
    44c4:	49050513          	addi	a0,a0,1168 # 6950 <malloc+0x1054>
    44c8:	00001097          	auipc	ra,0x1
    44cc:	376080e7          	jalr	886(ra) # 583e <printf>
      exit(1);
    44d0:	4505                	li	a0,1
    44d2:	00001097          	auipc	ra,0x1
    44d6:	ff4080e7          	jalr	-12(ra) # 54c6 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    44da:	20200593          	li	a1,514
    44de:	854e                	mv	a0,s3
    44e0:	00001097          	auipc	ra,0x1
    44e4:	026080e7          	jalr	38(ra) # 5506 <open>
    44e8:	892a                	mv	s2,a0
      if(fd < 0){
    44ea:	04054763          	bltz	a0,4538 <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    44ee:	1f400613          	li	a2,500
    44f2:	0304859b          	addiw	a1,s1,48
    44f6:	00007517          	auipc	a0,0x7
    44fa:	42a50513          	addi	a0,a0,1066 # b920 <buf>
    44fe:	00001097          	auipc	ra,0x1
    4502:	dcc080e7          	jalr	-564(ra) # 52ca <memset>
    4506:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4508:	00007997          	auipc	s3,0x7
    450c:	41898993          	addi	s3,s3,1048 # b920 <buf>
    4510:	1f400613          	li	a2,500
    4514:	85ce                	mv	a1,s3
    4516:	854a                	mv	a0,s2
    4518:	00001097          	auipc	ra,0x1
    451c:	fce080e7          	jalr	-50(ra) # 54e6 <write>
    4520:	85aa                	mv	a1,a0
    4522:	1f400793          	li	a5,500
    4526:	02f51863          	bne	a0,a5,4556 <fourfiles+0x154>
      for(i = 0; i < N; i++){
    452a:	34fd                	addiw	s1,s1,-1
    452c:	f0f5                	bnez	s1,4510 <fourfiles+0x10e>
      exit(0);
    452e:	4501                	li	a0,0
    4530:	00001097          	auipc	ra,0x1
    4534:	f96080e7          	jalr	-106(ra) # 54c6 <exit>
        printf("create failed\n", s);
    4538:	f5843583          	ld	a1,-168(s0)
    453c:	00003517          	auipc	a0,0x3
    4540:	3bc50513          	addi	a0,a0,956 # 78f8 <malloc+0x1ffc>
    4544:	00001097          	auipc	ra,0x1
    4548:	2fa080e7          	jalr	762(ra) # 583e <printf>
        exit(1);
    454c:	4505                	li	a0,1
    454e:	00001097          	auipc	ra,0x1
    4552:	f78080e7          	jalr	-136(ra) # 54c6 <exit>
          printf("write failed %d\n", n);
    4556:	00003517          	auipc	a0,0x3
    455a:	3b250513          	addi	a0,a0,946 # 7908 <malloc+0x200c>
    455e:	00001097          	auipc	ra,0x1
    4562:	2e0080e7          	jalr	736(ra) # 583e <printf>
          exit(1);
    4566:	4505                	li	a0,1
    4568:	00001097          	auipc	ra,0x1
    456c:	f5e080e7          	jalr	-162(ra) # 54c6 <exit>
      exit(xstatus);
    4570:	855a                	mv	a0,s6
    4572:	00001097          	auipc	ra,0x1
    4576:	f54080e7          	jalr	-172(ra) # 54c6 <exit>
          printf("wrong char\n", s);
    457a:	f5843583          	ld	a1,-168(s0)
    457e:	00003517          	auipc	a0,0x3
    4582:	3a250513          	addi	a0,a0,930 # 7920 <malloc+0x2024>
    4586:	00001097          	auipc	ra,0x1
    458a:	2b8080e7          	jalr	696(ra) # 583e <printf>
          exit(1);
    458e:	4505                	li	a0,1
    4590:	00001097          	auipc	ra,0x1
    4594:	f36080e7          	jalr	-202(ra) # 54c6 <exit>
      total += n;
    4598:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    459c:	660d                	lui	a2,0x3
    459e:	85d2                	mv	a1,s4
    45a0:	854e                	mv	a0,s3
    45a2:	00001097          	auipc	ra,0x1
    45a6:	f3c080e7          	jalr	-196(ra) # 54de <read>
    45aa:	02a05363          	blez	a0,45d0 <fourfiles+0x1ce>
    45ae:	00007797          	auipc	a5,0x7
    45b2:	37278793          	addi	a5,a5,882 # b920 <buf>
    45b6:	fff5069b          	addiw	a3,a0,-1
    45ba:	1682                	slli	a3,a3,0x20
    45bc:	9281                	srli	a3,a3,0x20
    45be:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    45c0:	0007c703          	lbu	a4,0(a5)
    45c4:	fa971be3          	bne	a4,s1,457a <fourfiles+0x178>
      for(j = 0; j < n; j++){
    45c8:	0785                	addi	a5,a5,1
    45ca:	fed79be3          	bne	a5,a3,45c0 <fourfiles+0x1be>
    45ce:	b7e9                	j	4598 <fourfiles+0x196>
    close(fd);
    45d0:	854e                	mv	a0,s3
    45d2:	00001097          	auipc	ra,0x1
    45d6:	f1c080e7          	jalr	-228(ra) # 54ee <close>
    if(total != N*SZ){
    45da:	03b91863          	bne	s2,s11,460a <fourfiles+0x208>
    unlink(fname);
    45de:	8566                	mv	a0,s9
    45e0:	00001097          	auipc	ra,0x1
    45e4:	f36080e7          	jalr	-202(ra) # 5516 <unlink>
  for(i = 0; i < NCHILD; i++){
    45e8:	0c21                	addi	s8,s8,8
    45ea:	2b85                	addiw	s7,s7,1
    45ec:	03ab8d63          	beq	s7,s10,4626 <fourfiles+0x224>
    fname = names[i];
    45f0:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    45f4:	4581                	li	a1,0
    45f6:	8566                	mv	a0,s9
    45f8:	00001097          	auipc	ra,0x1
    45fc:	f0e080e7          	jalr	-242(ra) # 5506 <open>
    4600:	89aa                	mv	s3,a0
    total = 0;
    4602:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    4604:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4608:	bf51                	j	459c <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    460a:	85ca                	mv	a1,s2
    460c:	00003517          	auipc	a0,0x3
    4610:	32450513          	addi	a0,a0,804 # 7930 <malloc+0x2034>
    4614:	00001097          	auipc	ra,0x1
    4618:	22a080e7          	jalr	554(ra) # 583e <printf>
      exit(1);
    461c:	4505                	li	a0,1
    461e:	00001097          	auipc	ra,0x1
    4622:	ea8080e7          	jalr	-344(ra) # 54c6 <exit>
}
    4626:	70aa                	ld	ra,168(sp)
    4628:	740a                	ld	s0,160(sp)
    462a:	64ea                	ld	s1,152(sp)
    462c:	694a                	ld	s2,144(sp)
    462e:	69aa                	ld	s3,136(sp)
    4630:	6a0a                	ld	s4,128(sp)
    4632:	7ae6                	ld	s5,120(sp)
    4634:	7b46                	ld	s6,112(sp)
    4636:	7ba6                	ld	s7,104(sp)
    4638:	7c06                	ld	s8,96(sp)
    463a:	6ce6                	ld	s9,88(sp)
    463c:	6d46                	ld	s10,80(sp)
    463e:	6da6                	ld	s11,72(sp)
    4640:	614d                	addi	sp,sp,176
    4642:	8082                	ret

0000000000004644 <concreate>:
{
    4644:	7135                	addi	sp,sp,-160
    4646:	ed06                	sd	ra,152(sp)
    4648:	e922                	sd	s0,144(sp)
    464a:	e526                	sd	s1,136(sp)
    464c:	e14a                	sd	s2,128(sp)
    464e:	fcce                	sd	s3,120(sp)
    4650:	f8d2                	sd	s4,112(sp)
    4652:	f4d6                	sd	s5,104(sp)
    4654:	f0da                	sd	s6,96(sp)
    4656:	ecde                	sd	s7,88(sp)
    4658:	1100                	addi	s0,sp,160
    465a:	89aa                	mv	s3,a0
  file[0] = 'C';
    465c:	04300793          	li	a5,67
    4660:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4664:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4668:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    466a:	4b0d                	li	s6,3
    466c:	4a85                	li	s5,1
      link("C0", file);
    466e:	00003b97          	auipc	s7,0x3
    4672:	2dab8b93          	addi	s7,s7,730 # 7948 <malloc+0x204c>
  for(i = 0; i < N; i++){
    4676:	02800a13          	li	s4,40
    467a:	acc1                	j	494a <concreate+0x306>
      link("C0", file);
    467c:	fa840593          	addi	a1,s0,-88
    4680:	855e                	mv	a0,s7
    4682:	00001097          	auipc	ra,0x1
    4686:	ea4080e7          	jalr	-348(ra) # 5526 <link>
    if(pid == 0) {
    468a:	a45d                	j	4930 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    468c:	4795                	li	a5,5
    468e:	02f9693b          	remw	s2,s2,a5
    4692:	4785                	li	a5,1
    4694:	02f90b63          	beq	s2,a5,46ca <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4698:	20200593          	li	a1,514
    469c:	fa840513          	addi	a0,s0,-88
    46a0:	00001097          	auipc	ra,0x1
    46a4:	e66080e7          	jalr	-410(ra) # 5506 <open>
      if(fd < 0){
    46a8:	26055b63          	bgez	a0,491e <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    46ac:	fa840593          	addi	a1,s0,-88
    46b0:	00003517          	auipc	a0,0x3
    46b4:	2a050513          	addi	a0,a0,672 # 7950 <malloc+0x2054>
    46b8:	00001097          	auipc	ra,0x1
    46bc:	186080e7          	jalr	390(ra) # 583e <printf>
        exit(1);
    46c0:	4505                	li	a0,1
    46c2:	00001097          	auipc	ra,0x1
    46c6:	e04080e7          	jalr	-508(ra) # 54c6 <exit>
      link("C0", file);
    46ca:	fa840593          	addi	a1,s0,-88
    46ce:	00003517          	auipc	a0,0x3
    46d2:	27a50513          	addi	a0,a0,634 # 7948 <malloc+0x204c>
    46d6:	00001097          	auipc	ra,0x1
    46da:	e50080e7          	jalr	-432(ra) # 5526 <link>
      exit(0);
    46de:	4501                	li	a0,0
    46e0:	00001097          	auipc	ra,0x1
    46e4:	de6080e7          	jalr	-538(ra) # 54c6 <exit>
        exit(1);
    46e8:	4505                	li	a0,1
    46ea:	00001097          	auipc	ra,0x1
    46ee:	ddc080e7          	jalr	-548(ra) # 54c6 <exit>
  memset(fa, 0, sizeof(fa));
    46f2:	02800613          	li	a2,40
    46f6:	4581                	li	a1,0
    46f8:	f8040513          	addi	a0,s0,-128
    46fc:	00001097          	auipc	ra,0x1
    4700:	bce080e7          	jalr	-1074(ra) # 52ca <memset>
  fd = open(".", 0);
    4704:	4581                	li	a1,0
    4706:	00002517          	auipc	a0,0x2
    470a:	cba50513          	addi	a0,a0,-838 # 63c0 <malloc+0xac4>
    470e:	00001097          	auipc	ra,0x1
    4712:	df8080e7          	jalr	-520(ra) # 5506 <open>
    4716:	892a                	mv	s2,a0
  n = 0;
    4718:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    471a:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    471e:	02700b13          	li	s6,39
      fa[i] = 1;
    4722:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4724:	4641                	li	a2,16
    4726:	f7040593          	addi	a1,s0,-144
    472a:	854a                	mv	a0,s2
    472c:	00001097          	auipc	ra,0x1
    4730:	db2080e7          	jalr	-590(ra) # 54de <read>
    4734:	08a05163          	blez	a0,47b6 <concreate+0x172>
    if(de.inum == 0)
    4738:	f7045783          	lhu	a5,-144(s0)
    473c:	d7e5                	beqz	a5,4724 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    473e:	f7244783          	lbu	a5,-142(s0)
    4742:	ff4791e3          	bne	a5,s4,4724 <concreate+0xe0>
    4746:	f7444783          	lbu	a5,-140(s0)
    474a:	ffe9                	bnez	a5,4724 <concreate+0xe0>
      i = de.name[1] - '0';
    474c:	f7344783          	lbu	a5,-141(s0)
    4750:	fd07879b          	addiw	a5,a5,-48
    4754:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4758:	00eb6f63          	bltu	s6,a4,4776 <concreate+0x132>
      if(fa[i]){
    475c:	fb040793          	addi	a5,s0,-80
    4760:	97ba                	add	a5,a5,a4
    4762:	fd07c783          	lbu	a5,-48(a5)
    4766:	eb85                	bnez	a5,4796 <concreate+0x152>
      fa[i] = 1;
    4768:	fb040793          	addi	a5,s0,-80
    476c:	973e                	add	a4,a4,a5
    476e:	fd770823          	sb	s7,-48(a4) # fd0 <bigdir+0x5a>
      n++;
    4772:	2a85                	addiw	s5,s5,1
    4774:	bf45                	j	4724 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4776:	f7240613          	addi	a2,s0,-142
    477a:	85ce                	mv	a1,s3
    477c:	00003517          	auipc	a0,0x3
    4780:	1f450513          	addi	a0,a0,500 # 7970 <malloc+0x2074>
    4784:	00001097          	auipc	ra,0x1
    4788:	0ba080e7          	jalr	186(ra) # 583e <printf>
        exit(1);
    478c:	4505                	li	a0,1
    478e:	00001097          	auipc	ra,0x1
    4792:	d38080e7          	jalr	-712(ra) # 54c6 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4796:	f7240613          	addi	a2,s0,-142
    479a:	85ce                	mv	a1,s3
    479c:	00003517          	auipc	a0,0x3
    47a0:	1f450513          	addi	a0,a0,500 # 7990 <malloc+0x2094>
    47a4:	00001097          	auipc	ra,0x1
    47a8:	09a080e7          	jalr	154(ra) # 583e <printf>
        exit(1);
    47ac:	4505                	li	a0,1
    47ae:	00001097          	auipc	ra,0x1
    47b2:	d18080e7          	jalr	-744(ra) # 54c6 <exit>
  close(fd);
    47b6:	854a                	mv	a0,s2
    47b8:	00001097          	auipc	ra,0x1
    47bc:	d36080e7          	jalr	-714(ra) # 54ee <close>
  if(n != N){
    47c0:	02800793          	li	a5,40
    47c4:	00fa9763          	bne	s5,a5,47d2 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    47c8:	4a8d                	li	s5,3
    47ca:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    47cc:	02800a13          	li	s4,40
    47d0:	a8c9                	j	48a2 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    47d2:	85ce                	mv	a1,s3
    47d4:	00003517          	auipc	a0,0x3
    47d8:	1e450513          	addi	a0,a0,484 # 79b8 <malloc+0x20bc>
    47dc:	00001097          	auipc	ra,0x1
    47e0:	062080e7          	jalr	98(ra) # 583e <printf>
    exit(1);
    47e4:	4505                	li	a0,1
    47e6:	00001097          	auipc	ra,0x1
    47ea:	ce0080e7          	jalr	-800(ra) # 54c6 <exit>
      printf("%s: fork failed\n", s);
    47ee:	85ce                	mv	a1,s3
    47f0:	00002517          	auipc	a0,0x2
    47f4:	d7050513          	addi	a0,a0,-656 # 6560 <malloc+0xc64>
    47f8:	00001097          	auipc	ra,0x1
    47fc:	046080e7          	jalr	70(ra) # 583e <printf>
      exit(1);
    4800:	4505                	li	a0,1
    4802:	00001097          	auipc	ra,0x1
    4806:	cc4080e7          	jalr	-828(ra) # 54c6 <exit>
      close(open(file, 0));
    480a:	4581                	li	a1,0
    480c:	fa840513          	addi	a0,s0,-88
    4810:	00001097          	auipc	ra,0x1
    4814:	cf6080e7          	jalr	-778(ra) # 5506 <open>
    4818:	00001097          	auipc	ra,0x1
    481c:	cd6080e7          	jalr	-810(ra) # 54ee <close>
      close(open(file, 0));
    4820:	4581                	li	a1,0
    4822:	fa840513          	addi	a0,s0,-88
    4826:	00001097          	auipc	ra,0x1
    482a:	ce0080e7          	jalr	-800(ra) # 5506 <open>
    482e:	00001097          	auipc	ra,0x1
    4832:	cc0080e7          	jalr	-832(ra) # 54ee <close>
      close(open(file, 0));
    4836:	4581                	li	a1,0
    4838:	fa840513          	addi	a0,s0,-88
    483c:	00001097          	auipc	ra,0x1
    4840:	cca080e7          	jalr	-822(ra) # 5506 <open>
    4844:	00001097          	auipc	ra,0x1
    4848:	caa080e7          	jalr	-854(ra) # 54ee <close>
      close(open(file, 0));
    484c:	4581                	li	a1,0
    484e:	fa840513          	addi	a0,s0,-88
    4852:	00001097          	auipc	ra,0x1
    4856:	cb4080e7          	jalr	-844(ra) # 5506 <open>
    485a:	00001097          	auipc	ra,0x1
    485e:	c94080e7          	jalr	-876(ra) # 54ee <close>
      close(open(file, 0));
    4862:	4581                	li	a1,0
    4864:	fa840513          	addi	a0,s0,-88
    4868:	00001097          	auipc	ra,0x1
    486c:	c9e080e7          	jalr	-866(ra) # 5506 <open>
    4870:	00001097          	auipc	ra,0x1
    4874:	c7e080e7          	jalr	-898(ra) # 54ee <close>
      close(open(file, 0));
    4878:	4581                	li	a1,0
    487a:	fa840513          	addi	a0,s0,-88
    487e:	00001097          	auipc	ra,0x1
    4882:	c88080e7          	jalr	-888(ra) # 5506 <open>
    4886:	00001097          	auipc	ra,0x1
    488a:	c68080e7          	jalr	-920(ra) # 54ee <close>
    if(pid == 0)
    488e:	08090363          	beqz	s2,4914 <concreate+0x2d0>
      wait(0);
    4892:	4501                	li	a0,0
    4894:	00001097          	auipc	ra,0x1
    4898:	c3a080e7          	jalr	-966(ra) # 54ce <wait>
  for(i = 0; i < N; i++){
    489c:	2485                	addiw	s1,s1,1
    489e:	0f448563          	beq	s1,s4,4988 <concreate+0x344>
    file[1] = '0' + i;
    48a2:	0304879b          	addiw	a5,s1,48
    48a6:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    48aa:	00001097          	auipc	ra,0x1
    48ae:	c14080e7          	jalr	-1004(ra) # 54be <fork>
    48b2:	892a                	mv	s2,a0
    if(pid < 0){
    48b4:	f2054de3          	bltz	a0,47ee <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    48b8:	0354e73b          	remw	a4,s1,s5
    48bc:	00a767b3          	or	a5,a4,a0
    48c0:	2781                	sext.w	a5,a5
    48c2:	d7a1                	beqz	a5,480a <concreate+0x1c6>
    48c4:	01671363          	bne	a4,s6,48ca <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    48c8:	f129                	bnez	a0,480a <concreate+0x1c6>
      unlink(file);
    48ca:	fa840513          	addi	a0,s0,-88
    48ce:	00001097          	auipc	ra,0x1
    48d2:	c48080e7          	jalr	-952(ra) # 5516 <unlink>
      unlink(file);
    48d6:	fa840513          	addi	a0,s0,-88
    48da:	00001097          	auipc	ra,0x1
    48de:	c3c080e7          	jalr	-964(ra) # 5516 <unlink>
      unlink(file);
    48e2:	fa840513          	addi	a0,s0,-88
    48e6:	00001097          	auipc	ra,0x1
    48ea:	c30080e7          	jalr	-976(ra) # 5516 <unlink>
      unlink(file);
    48ee:	fa840513          	addi	a0,s0,-88
    48f2:	00001097          	auipc	ra,0x1
    48f6:	c24080e7          	jalr	-988(ra) # 5516 <unlink>
      unlink(file);
    48fa:	fa840513          	addi	a0,s0,-88
    48fe:	00001097          	auipc	ra,0x1
    4902:	c18080e7          	jalr	-1000(ra) # 5516 <unlink>
      unlink(file);
    4906:	fa840513          	addi	a0,s0,-88
    490a:	00001097          	auipc	ra,0x1
    490e:	c0c080e7          	jalr	-1012(ra) # 5516 <unlink>
    4912:	bfb5                	j	488e <concreate+0x24a>
      exit(0);
    4914:	4501                	li	a0,0
    4916:	00001097          	auipc	ra,0x1
    491a:	bb0080e7          	jalr	-1104(ra) # 54c6 <exit>
      close(fd);
    491e:	00001097          	auipc	ra,0x1
    4922:	bd0080e7          	jalr	-1072(ra) # 54ee <close>
    if(pid == 0) {
    4926:	bb65                	j	46de <concreate+0x9a>
      close(fd);
    4928:	00001097          	auipc	ra,0x1
    492c:	bc6080e7          	jalr	-1082(ra) # 54ee <close>
      wait(&xstatus);
    4930:	f6c40513          	addi	a0,s0,-148
    4934:	00001097          	auipc	ra,0x1
    4938:	b9a080e7          	jalr	-1126(ra) # 54ce <wait>
      if(xstatus != 0)
    493c:	f6c42483          	lw	s1,-148(s0)
    4940:	da0494e3          	bnez	s1,46e8 <concreate+0xa4>
  for(i = 0; i < N; i++){
    4944:	2905                	addiw	s2,s2,1
    4946:	db4906e3          	beq	s2,s4,46f2 <concreate+0xae>
    file[1] = '0' + i;
    494a:	0309079b          	addiw	a5,s2,48
    494e:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4952:	fa840513          	addi	a0,s0,-88
    4956:	00001097          	auipc	ra,0x1
    495a:	bc0080e7          	jalr	-1088(ra) # 5516 <unlink>
    pid = fork();
    495e:	00001097          	auipc	ra,0x1
    4962:	b60080e7          	jalr	-1184(ra) # 54be <fork>
    if(pid && (i % 3) == 1){
    4966:	d20503e3          	beqz	a0,468c <concreate+0x48>
    496a:	036967bb          	remw	a5,s2,s6
    496e:	d15787e3          	beq	a5,s5,467c <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4972:	20200593          	li	a1,514
    4976:	fa840513          	addi	a0,s0,-88
    497a:	00001097          	auipc	ra,0x1
    497e:	b8c080e7          	jalr	-1140(ra) # 5506 <open>
      if(fd < 0){
    4982:	fa0553e3          	bgez	a0,4928 <concreate+0x2e4>
    4986:	b31d                	j	46ac <concreate+0x68>
}
    4988:	60ea                	ld	ra,152(sp)
    498a:	644a                	ld	s0,144(sp)
    498c:	64aa                	ld	s1,136(sp)
    498e:	690a                	ld	s2,128(sp)
    4990:	79e6                	ld	s3,120(sp)
    4992:	7a46                	ld	s4,112(sp)
    4994:	7aa6                	ld	s5,104(sp)
    4996:	7b06                	ld	s6,96(sp)
    4998:	6be6                	ld	s7,88(sp)
    499a:	610d                	addi	sp,sp,160
    499c:	8082                	ret

000000000000499e <bigfile>:
{
    499e:	7139                	addi	sp,sp,-64
    49a0:	fc06                	sd	ra,56(sp)
    49a2:	f822                	sd	s0,48(sp)
    49a4:	f426                	sd	s1,40(sp)
    49a6:	f04a                	sd	s2,32(sp)
    49a8:	ec4e                	sd	s3,24(sp)
    49aa:	e852                	sd	s4,16(sp)
    49ac:	e456                	sd	s5,8(sp)
    49ae:	0080                	addi	s0,sp,64
    49b0:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    49b2:	00003517          	auipc	a0,0x3
    49b6:	03e50513          	addi	a0,a0,62 # 79f0 <malloc+0x20f4>
    49ba:	00001097          	auipc	ra,0x1
    49be:	b5c080e7          	jalr	-1188(ra) # 5516 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    49c2:	20200593          	li	a1,514
    49c6:	00003517          	auipc	a0,0x3
    49ca:	02a50513          	addi	a0,a0,42 # 79f0 <malloc+0x20f4>
    49ce:	00001097          	auipc	ra,0x1
    49d2:	b38080e7          	jalr	-1224(ra) # 5506 <open>
    49d6:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    49d8:	4481                	li	s1,0
    memset(buf, i, SZ);
    49da:	00007917          	auipc	s2,0x7
    49de:	f4690913          	addi	s2,s2,-186 # b920 <buf>
  for(i = 0; i < N; i++){
    49e2:	4a51                	li	s4,20
  if(fd < 0){
    49e4:	0a054063          	bltz	a0,4a84 <bigfile+0xe6>
    memset(buf, i, SZ);
    49e8:	25800613          	li	a2,600
    49ec:	85a6                	mv	a1,s1
    49ee:	854a                	mv	a0,s2
    49f0:	00001097          	auipc	ra,0x1
    49f4:	8da080e7          	jalr	-1830(ra) # 52ca <memset>
    if(write(fd, buf, SZ) != SZ){
    49f8:	25800613          	li	a2,600
    49fc:	85ca                	mv	a1,s2
    49fe:	854e                	mv	a0,s3
    4a00:	00001097          	auipc	ra,0x1
    4a04:	ae6080e7          	jalr	-1306(ra) # 54e6 <write>
    4a08:	25800793          	li	a5,600
    4a0c:	08f51a63          	bne	a0,a5,4aa0 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4a10:	2485                	addiw	s1,s1,1
    4a12:	fd449be3          	bne	s1,s4,49e8 <bigfile+0x4a>
  close(fd);
    4a16:	854e                	mv	a0,s3
    4a18:	00001097          	auipc	ra,0x1
    4a1c:	ad6080e7          	jalr	-1322(ra) # 54ee <close>
  fd = open("bigfile.dat", 0);
    4a20:	4581                	li	a1,0
    4a22:	00003517          	auipc	a0,0x3
    4a26:	fce50513          	addi	a0,a0,-50 # 79f0 <malloc+0x20f4>
    4a2a:	00001097          	auipc	ra,0x1
    4a2e:	adc080e7          	jalr	-1316(ra) # 5506 <open>
    4a32:	8a2a                	mv	s4,a0
  total = 0;
    4a34:	4981                	li	s3,0
  for(i = 0; ; i++){
    4a36:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4a38:	00007917          	auipc	s2,0x7
    4a3c:	ee890913          	addi	s2,s2,-280 # b920 <buf>
  if(fd < 0){
    4a40:	06054e63          	bltz	a0,4abc <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4a44:	12c00613          	li	a2,300
    4a48:	85ca                	mv	a1,s2
    4a4a:	8552                	mv	a0,s4
    4a4c:	00001097          	auipc	ra,0x1
    4a50:	a92080e7          	jalr	-1390(ra) # 54de <read>
    if(cc < 0){
    4a54:	08054263          	bltz	a0,4ad8 <bigfile+0x13a>
    if(cc == 0)
    4a58:	c971                	beqz	a0,4b2c <bigfile+0x18e>
    if(cc != SZ/2){
    4a5a:	12c00793          	li	a5,300
    4a5e:	08f51b63          	bne	a0,a5,4af4 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4a62:	01f4d79b          	srliw	a5,s1,0x1f
    4a66:	9fa5                	addw	a5,a5,s1
    4a68:	4017d79b          	sraiw	a5,a5,0x1
    4a6c:	00094703          	lbu	a4,0(s2)
    4a70:	0af71063          	bne	a4,a5,4b10 <bigfile+0x172>
    4a74:	12b94703          	lbu	a4,299(s2)
    4a78:	08f71c63          	bne	a4,a5,4b10 <bigfile+0x172>
    total += cc;
    4a7c:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4a80:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4a82:	b7c9                	j	4a44 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4a84:	85d6                	mv	a1,s5
    4a86:	00003517          	auipc	a0,0x3
    4a8a:	f7a50513          	addi	a0,a0,-134 # 7a00 <malloc+0x2104>
    4a8e:	00001097          	auipc	ra,0x1
    4a92:	db0080e7          	jalr	-592(ra) # 583e <printf>
    exit(1);
    4a96:	4505                	li	a0,1
    4a98:	00001097          	auipc	ra,0x1
    4a9c:	a2e080e7          	jalr	-1490(ra) # 54c6 <exit>
      printf("%s: write bigfile failed\n", s);
    4aa0:	85d6                	mv	a1,s5
    4aa2:	00003517          	auipc	a0,0x3
    4aa6:	f7e50513          	addi	a0,a0,-130 # 7a20 <malloc+0x2124>
    4aaa:	00001097          	auipc	ra,0x1
    4aae:	d94080e7          	jalr	-620(ra) # 583e <printf>
      exit(1);
    4ab2:	4505                	li	a0,1
    4ab4:	00001097          	auipc	ra,0x1
    4ab8:	a12080e7          	jalr	-1518(ra) # 54c6 <exit>
    printf("%s: cannot open bigfile\n", s);
    4abc:	85d6                	mv	a1,s5
    4abe:	00003517          	auipc	a0,0x3
    4ac2:	f8250513          	addi	a0,a0,-126 # 7a40 <malloc+0x2144>
    4ac6:	00001097          	auipc	ra,0x1
    4aca:	d78080e7          	jalr	-648(ra) # 583e <printf>
    exit(1);
    4ace:	4505                	li	a0,1
    4ad0:	00001097          	auipc	ra,0x1
    4ad4:	9f6080e7          	jalr	-1546(ra) # 54c6 <exit>
      printf("%s: read bigfile failed\n", s);
    4ad8:	85d6                	mv	a1,s5
    4ada:	00003517          	auipc	a0,0x3
    4ade:	f8650513          	addi	a0,a0,-122 # 7a60 <malloc+0x2164>
    4ae2:	00001097          	auipc	ra,0x1
    4ae6:	d5c080e7          	jalr	-676(ra) # 583e <printf>
      exit(1);
    4aea:	4505                	li	a0,1
    4aec:	00001097          	auipc	ra,0x1
    4af0:	9da080e7          	jalr	-1574(ra) # 54c6 <exit>
      printf("%s: short read bigfile\n", s);
    4af4:	85d6                	mv	a1,s5
    4af6:	00003517          	auipc	a0,0x3
    4afa:	f8a50513          	addi	a0,a0,-118 # 7a80 <malloc+0x2184>
    4afe:	00001097          	auipc	ra,0x1
    4b02:	d40080e7          	jalr	-704(ra) # 583e <printf>
      exit(1);
    4b06:	4505                	li	a0,1
    4b08:	00001097          	auipc	ra,0x1
    4b0c:	9be080e7          	jalr	-1602(ra) # 54c6 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4b10:	85d6                	mv	a1,s5
    4b12:	00003517          	auipc	a0,0x3
    4b16:	f8650513          	addi	a0,a0,-122 # 7a98 <malloc+0x219c>
    4b1a:	00001097          	auipc	ra,0x1
    4b1e:	d24080e7          	jalr	-732(ra) # 583e <printf>
      exit(1);
    4b22:	4505                	li	a0,1
    4b24:	00001097          	auipc	ra,0x1
    4b28:	9a2080e7          	jalr	-1630(ra) # 54c6 <exit>
  close(fd);
    4b2c:	8552                	mv	a0,s4
    4b2e:	00001097          	auipc	ra,0x1
    4b32:	9c0080e7          	jalr	-1600(ra) # 54ee <close>
  if(total != N*SZ){
    4b36:	678d                	lui	a5,0x3
    4b38:	ee078793          	addi	a5,a5,-288 # 2ee0 <dirtest+0x96>
    4b3c:	02f99363          	bne	s3,a5,4b62 <bigfile+0x1c4>
  unlink("bigfile.dat");
    4b40:	00003517          	auipc	a0,0x3
    4b44:	eb050513          	addi	a0,a0,-336 # 79f0 <malloc+0x20f4>
    4b48:	00001097          	auipc	ra,0x1
    4b4c:	9ce080e7          	jalr	-1586(ra) # 5516 <unlink>
}
    4b50:	70e2                	ld	ra,56(sp)
    4b52:	7442                	ld	s0,48(sp)
    4b54:	74a2                	ld	s1,40(sp)
    4b56:	7902                	ld	s2,32(sp)
    4b58:	69e2                	ld	s3,24(sp)
    4b5a:	6a42                	ld	s4,16(sp)
    4b5c:	6aa2                	ld	s5,8(sp)
    4b5e:	6121                	addi	sp,sp,64
    4b60:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4b62:	85d6                	mv	a1,s5
    4b64:	00003517          	auipc	a0,0x3
    4b68:	f5450513          	addi	a0,a0,-172 # 7ab8 <malloc+0x21bc>
    4b6c:	00001097          	auipc	ra,0x1
    4b70:	cd2080e7          	jalr	-814(ra) # 583e <printf>
    exit(1);
    4b74:	4505                	li	a0,1
    4b76:	00001097          	auipc	ra,0x1
    4b7a:	950080e7          	jalr	-1712(ra) # 54c6 <exit>

0000000000004b7e <fsfull>:
{
    4b7e:	7171                	addi	sp,sp,-176
    4b80:	f506                	sd	ra,168(sp)
    4b82:	f122                	sd	s0,160(sp)
    4b84:	ed26                	sd	s1,152(sp)
    4b86:	e94a                	sd	s2,144(sp)
    4b88:	e54e                	sd	s3,136(sp)
    4b8a:	e152                	sd	s4,128(sp)
    4b8c:	fcd6                	sd	s5,120(sp)
    4b8e:	f8da                	sd	s6,112(sp)
    4b90:	f4de                	sd	s7,104(sp)
    4b92:	f0e2                	sd	s8,96(sp)
    4b94:	ece6                	sd	s9,88(sp)
    4b96:	e8ea                	sd	s10,80(sp)
    4b98:	e4ee                	sd	s11,72(sp)
    4b9a:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4b9c:	00003517          	auipc	a0,0x3
    4ba0:	f3c50513          	addi	a0,a0,-196 # 7ad8 <malloc+0x21dc>
    4ba4:	00001097          	auipc	ra,0x1
    4ba8:	c9a080e7          	jalr	-870(ra) # 583e <printf>
  for(nfiles = 0; ; nfiles++){
    4bac:	4481                	li	s1,0
    name[0] = 'f';
    4bae:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4bb2:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4bb6:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4bba:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4bbc:	00003c97          	auipc	s9,0x3
    4bc0:	f2cc8c93          	addi	s9,s9,-212 # 7ae8 <malloc+0x21ec>
    int total = 0;
    4bc4:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4bc6:	00007a17          	auipc	s4,0x7
    4bca:	d5aa0a13          	addi	s4,s4,-678 # b920 <buf>
    name[0] = 'f';
    4bce:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4bd2:	0384c7bb          	divw	a5,s1,s8
    4bd6:	0307879b          	addiw	a5,a5,48
    4bda:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4bde:	0384e7bb          	remw	a5,s1,s8
    4be2:	0377c7bb          	divw	a5,a5,s7
    4be6:	0307879b          	addiw	a5,a5,48
    4bea:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4bee:	0374e7bb          	remw	a5,s1,s7
    4bf2:	0367c7bb          	divw	a5,a5,s6
    4bf6:	0307879b          	addiw	a5,a5,48
    4bfa:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4bfe:	0364e7bb          	remw	a5,s1,s6
    4c02:	0307879b          	addiw	a5,a5,48
    4c06:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c0a:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4c0e:	f5040593          	addi	a1,s0,-176
    4c12:	8566                	mv	a0,s9
    4c14:	00001097          	auipc	ra,0x1
    4c18:	c2a080e7          	jalr	-982(ra) # 583e <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4c1c:	20200593          	li	a1,514
    4c20:	f5040513          	addi	a0,s0,-176
    4c24:	00001097          	auipc	ra,0x1
    4c28:	8e2080e7          	jalr	-1822(ra) # 5506 <open>
    4c2c:	892a                	mv	s2,a0
    if(fd < 0){
    4c2e:	0a055663          	bgez	a0,4cda <fsfull+0x15c>
      printf("open %s failed\n", name);
    4c32:	f5040593          	addi	a1,s0,-176
    4c36:	00003517          	auipc	a0,0x3
    4c3a:	ec250513          	addi	a0,a0,-318 # 7af8 <malloc+0x21fc>
    4c3e:	00001097          	auipc	ra,0x1
    4c42:	c00080e7          	jalr	-1024(ra) # 583e <printf>
  while(nfiles >= 0){
    4c46:	0604c363          	bltz	s1,4cac <fsfull+0x12e>
    name[0] = 'f';
    4c4a:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4c4e:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4c52:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4c56:	4929                	li	s2,10
  while(nfiles >= 0){
    4c58:	5afd                	li	s5,-1
    name[0] = 'f';
    4c5a:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4c5e:	0344c7bb          	divw	a5,s1,s4
    4c62:	0307879b          	addiw	a5,a5,48
    4c66:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4c6a:	0344e7bb          	remw	a5,s1,s4
    4c6e:	0337c7bb          	divw	a5,a5,s3
    4c72:	0307879b          	addiw	a5,a5,48
    4c76:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4c7a:	0334e7bb          	remw	a5,s1,s3
    4c7e:	0327c7bb          	divw	a5,a5,s2
    4c82:	0307879b          	addiw	a5,a5,48
    4c86:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c8a:	0324e7bb          	remw	a5,s1,s2
    4c8e:	0307879b          	addiw	a5,a5,48
    4c92:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c96:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4c9a:	f5040513          	addi	a0,s0,-176
    4c9e:	00001097          	auipc	ra,0x1
    4ca2:	878080e7          	jalr	-1928(ra) # 5516 <unlink>
    nfiles--;
    4ca6:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4ca8:	fb5499e3          	bne	s1,s5,4c5a <fsfull+0xdc>
  printf("fsfull test finished\n");
    4cac:	00003517          	auipc	a0,0x3
    4cb0:	e6c50513          	addi	a0,a0,-404 # 7b18 <malloc+0x221c>
    4cb4:	00001097          	auipc	ra,0x1
    4cb8:	b8a080e7          	jalr	-1142(ra) # 583e <printf>
}
    4cbc:	70aa                	ld	ra,168(sp)
    4cbe:	740a                	ld	s0,160(sp)
    4cc0:	64ea                	ld	s1,152(sp)
    4cc2:	694a                	ld	s2,144(sp)
    4cc4:	69aa                	ld	s3,136(sp)
    4cc6:	6a0a                	ld	s4,128(sp)
    4cc8:	7ae6                	ld	s5,120(sp)
    4cca:	7b46                	ld	s6,112(sp)
    4ccc:	7ba6                	ld	s7,104(sp)
    4cce:	7c06                	ld	s8,96(sp)
    4cd0:	6ce6                	ld	s9,88(sp)
    4cd2:	6d46                	ld	s10,80(sp)
    4cd4:	6da6                	ld	s11,72(sp)
    4cd6:	614d                	addi	sp,sp,176
    4cd8:	8082                	ret
    int total = 0;
    4cda:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4cdc:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4ce0:	40000613          	li	a2,1024
    4ce4:	85d2                	mv	a1,s4
    4ce6:	854a                	mv	a0,s2
    4ce8:	00000097          	auipc	ra,0x0
    4cec:	7fe080e7          	jalr	2046(ra) # 54e6 <write>
      if(cc < BSIZE)
    4cf0:	00aad563          	bge	s5,a0,4cfa <fsfull+0x17c>
      total += cc;
    4cf4:	00a989bb          	addw	s3,s3,a0
    while(1){
    4cf8:	b7e5                	j	4ce0 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4cfa:	85ce                	mv	a1,s3
    4cfc:	00003517          	auipc	a0,0x3
    4d00:	e0c50513          	addi	a0,a0,-500 # 7b08 <malloc+0x220c>
    4d04:	00001097          	auipc	ra,0x1
    4d08:	b3a080e7          	jalr	-1222(ra) # 583e <printf>
    close(fd);
    4d0c:	854a                	mv	a0,s2
    4d0e:	00000097          	auipc	ra,0x0
    4d12:	7e0080e7          	jalr	2016(ra) # 54ee <close>
    if(total == 0)
    4d16:	f20988e3          	beqz	s3,4c46 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4d1a:	2485                	addiw	s1,s1,1
    4d1c:	bd4d                	j	4bce <fsfull+0x50>

0000000000004d1e <rand>:
{
    4d1e:	1141                	addi	sp,sp,-16
    4d20:	e422                	sd	s0,8(sp)
    4d22:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4d24:	00003717          	auipc	a4,0x3
    4d28:	3cc70713          	addi	a4,a4,972 # 80f0 <randstate>
    4d2c:	6308                	ld	a0,0(a4)
    4d2e:	001967b7          	lui	a5,0x196
    4d32:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187cdd>
    4d36:	02f50533          	mul	a0,a0,a5
    4d3a:	3c6ef7b7          	lui	a5,0x3c6ef
    4d3e:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e0a2f>
    4d42:	953e                	add	a0,a0,a5
    4d44:	e308                	sd	a0,0(a4)
}
    4d46:	2501                	sext.w	a0,a0
    4d48:	6422                	ld	s0,8(sp)
    4d4a:	0141                	addi	sp,sp,16
    4d4c:	8082                	ret

0000000000004d4e <badwrite>:
{
    4d4e:	7179                	addi	sp,sp,-48
    4d50:	f406                	sd	ra,40(sp)
    4d52:	f022                	sd	s0,32(sp)
    4d54:	ec26                	sd	s1,24(sp)
    4d56:	e84a                	sd	s2,16(sp)
    4d58:	e44e                	sd	s3,8(sp)
    4d5a:	e052                	sd	s4,0(sp)
    4d5c:	1800                	addi	s0,sp,48
  unlink("junk");
    4d5e:	00003517          	auipc	a0,0x3
    4d62:	dd250513          	addi	a0,a0,-558 # 7b30 <malloc+0x2234>
    4d66:	00000097          	auipc	ra,0x0
    4d6a:	7b0080e7          	jalr	1968(ra) # 5516 <unlink>
    4d6e:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4d72:	00003997          	auipc	s3,0x3
    4d76:	dbe98993          	addi	s3,s3,-578 # 7b30 <malloc+0x2234>
    write(fd, (char*)0xffffffffffL, 1);
    4d7a:	5a7d                	li	s4,-1
    4d7c:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4d80:	20100593          	li	a1,513
    4d84:	854e                	mv	a0,s3
    4d86:	00000097          	auipc	ra,0x0
    4d8a:	780080e7          	jalr	1920(ra) # 5506 <open>
    4d8e:	84aa                	mv	s1,a0
    if(fd < 0){
    4d90:	06054b63          	bltz	a0,4e06 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4d94:	4605                	li	a2,1
    4d96:	85d2                	mv	a1,s4
    4d98:	00000097          	auipc	ra,0x0
    4d9c:	74e080e7          	jalr	1870(ra) # 54e6 <write>
    close(fd);
    4da0:	8526                	mv	a0,s1
    4da2:	00000097          	auipc	ra,0x0
    4da6:	74c080e7          	jalr	1868(ra) # 54ee <close>
    unlink("junk");
    4daa:	854e                	mv	a0,s3
    4dac:	00000097          	auipc	ra,0x0
    4db0:	76a080e7          	jalr	1898(ra) # 5516 <unlink>
  for(int i = 0; i < assumed_free; i++){
    4db4:	397d                	addiw	s2,s2,-1
    4db6:	fc0915e3          	bnez	s2,4d80 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4dba:	20100593          	li	a1,513
    4dbe:	00003517          	auipc	a0,0x3
    4dc2:	d7250513          	addi	a0,a0,-654 # 7b30 <malloc+0x2234>
    4dc6:	00000097          	auipc	ra,0x0
    4dca:	740080e7          	jalr	1856(ra) # 5506 <open>
    4dce:	84aa                	mv	s1,a0
  if(fd < 0){
    4dd0:	04054863          	bltz	a0,4e20 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4dd4:	4605                	li	a2,1
    4dd6:	00001597          	auipc	a1,0x1
    4dda:	fc258593          	addi	a1,a1,-62 # 5d98 <malloc+0x49c>
    4dde:	00000097          	auipc	ra,0x0
    4de2:	708080e7          	jalr	1800(ra) # 54e6 <write>
    4de6:	4785                	li	a5,1
    4de8:	04f50963          	beq	a0,a5,4e3a <badwrite+0xec>
    printf("write failed\n");
    4dec:	00003517          	auipc	a0,0x3
    4df0:	d6450513          	addi	a0,a0,-668 # 7b50 <malloc+0x2254>
    4df4:	00001097          	auipc	ra,0x1
    4df8:	a4a080e7          	jalr	-1462(ra) # 583e <printf>
    exit(1);
    4dfc:	4505                	li	a0,1
    4dfe:	00000097          	auipc	ra,0x0
    4e02:	6c8080e7          	jalr	1736(ra) # 54c6 <exit>
      printf("open junk failed\n");
    4e06:	00003517          	auipc	a0,0x3
    4e0a:	d3250513          	addi	a0,a0,-718 # 7b38 <malloc+0x223c>
    4e0e:	00001097          	auipc	ra,0x1
    4e12:	a30080e7          	jalr	-1488(ra) # 583e <printf>
      exit(1);
    4e16:	4505                	li	a0,1
    4e18:	00000097          	auipc	ra,0x0
    4e1c:	6ae080e7          	jalr	1710(ra) # 54c6 <exit>
    printf("open junk failed\n");
    4e20:	00003517          	auipc	a0,0x3
    4e24:	d1850513          	addi	a0,a0,-744 # 7b38 <malloc+0x223c>
    4e28:	00001097          	auipc	ra,0x1
    4e2c:	a16080e7          	jalr	-1514(ra) # 583e <printf>
    exit(1);
    4e30:	4505                	li	a0,1
    4e32:	00000097          	auipc	ra,0x0
    4e36:	694080e7          	jalr	1684(ra) # 54c6 <exit>
  close(fd);
    4e3a:	8526                	mv	a0,s1
    4e3c:	00000097          	auipc	ra,0x0
    4e40:	6b2080e7          	jalr	1714(ra) # 54ee <close>
  unlink("junk");
    4e44:	00003517          	auipc	a0,0x3
    4e48:	cec50513          	addi	a0,a0,-788 # 7b30 <malloc+0x2234>
    4e4c:	00000097          	auipc	ra,0x0
    4e50:	6ca080e7          	jalr	1738(ra) # 5516 <unlink>
  exit(0);
    4e54:	4501                	li	a0,0
    4e56:	00000097          	auipc	ra,0x0
    4e5a:	670080e7          	jalr	1648(ra) # 54c6 <exit>

0000000000004e5e <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4e5e:	7139                	addi	sp,sp,-64
    4e60:	fc06                	sd	ra,56(sp)
    4e62:	f822                	sd	s0,48(sp)
    4e64:	f426                	sd	s1,40(sp)
    4e66:	f04a                	sd	s2,32(sp)
    4e68:	ec4e                	sd	s3,24(sp)
    4e6a:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4e6c:	fc840513          	addi	a0,s0,-56
    4e70:	00000097          	auipc	ra,0x0
    4e74:	666080e7          	jalr	1638(ra) # 54d6 <pipe>
    4e78:	06054763          	bltz	a0,4ee6 <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4e7c:	00000097          	auipc	ra,0x0
    4e80:	642080e7          	jalr	1602(ra) # 54be <fork>

  if(pid < 0){
    4e84:	06054e63          	bltz	a0,4f00 <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4e88:	ed51                	bnez	a0,4f24 <countfree+0xc6>
    close(fds[0]);
    4e8a:	fc842503          	lw	a0,-56(s0)
    4e8e:	00000097          	auipc	ra,0x0
    4e92:	660080e7          	jalr	1632(ra) # 54ee <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4e96:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4e98:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4e9a:	00001997          	auipc	s3,0x1
    4e9e:	efe98993          	addi	s3,s3,-258 # 5d98 <malloc+0x49c>
      uint64 a = (uint64) sbrk(4096);
    4ea2:	6505                	lui	a0,0x1
    4ea4:	00000097          	auipc	ra,0x0
    4ea8:	6aa080e7          	jalr	1706(ra) # 554e <sbrk>
      if(a == 0xffffffffffffffff){
    4eac:	07250763          	beq	a0,s2,4f1a <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    4eb0:	6785                	lui	a5,0x1
    4eb2:	953e                	add	a0,a0,a5
    4eb4:	fe950fa3          	sb	s1,-1(a0) # fff <bigdir+0x89>
      if(write(fds[1], "x", 1) != 1){
    4eb8:	8626                	mv	a2,s1
    4eba:	85ce                	mv	a1,s3
    4ebc:	fcc42503          	lw	a0,-52(s0)
    4ec0:	00000097          	auipc	ra,0x0
    4ec4:	626080e7          	jalr	1574(ra) # 54e6 <write>
    4ec8:	fc950de3          	beq	a0,s1,4ea2 <countfree+0x44>
        printf("write() failed in countfree()\n");
    4ecc:	00003517          	auipc	a0,0x3
    4ed0:	cd450513          	addi	a0,a0,-812 # 7ba0 <malloc+0x22a4>
    4ed4:	00001097          	auipc	ra,0x1
    4ed8:	96a080e7          	jalr	-1686(ra) # 583e <printf>
        exit(1);
    4edc:	4505                	li	a0,1
    4ede:	00000097          	auipc	ra,0x0
    4ee2:	5e8080e7          	jalr	1512(ra) # 54c6 <exit>
    printf("pipe() failed in countfree()\n");
    4ee6:	00003517          	auipc	a0,0x3
    4eea:	c7a50513          	addi	a0,a0,-902 # 7b60 <malloc+0x2264>
    4eee:	00001097          	auipc	ra,0x1
    4ef2:	950080e7          	jalr	-1712(ra) # 583e <printf>
    exit(1);
    4ef6:	4505                	li	a0,1
    4ef8:	00000097          	auipc	ra,0x0
    4efc:	5ce080e7          	jalr	1486(ra) # 54c6 <exit>
    printf("fork failed in countfree()\n");
    4f00:	00003517          	auipc	a0,0x3
    4f04:	c8050513          	addi	a0,a0,-896 # 7b80 <malloc+0x2284>
    4f08:	00001097          	auipc	ra,0x1
    4f0c:	936080e7          	jalr	-1738(ra) # 583e <printf>
    exit(1);
    4f10:	4505                	li	a0,1
    4f12:	00000097          	auipc	ra,0x0
    4f16:	5b4080e7          	jalr	1460(ra) # 54c6 <exit>
      }
    }

    exit(0);
    4f1a:	4501                	li	a0,0
    4f1c:	00000097          	auipc	ra,0x0
    4f20:	5aa080e7          	jalr	1450(ra) # 54c6 <exit>
  }

  close(fds[1]);
    4f24:	fcc42503          	lw	a0,-52(s0)
    4f28:	00000097          	auipc	ra,0x0
    4f2c:	5c6080e7          	jalr	1478(ra) # 54ee <close>

  int n = 0;
    4f30:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    4f32:	4605                	li	a2,1
    4f34:	fc740593          	addi	a1,s0,-57
    4f38:	fc842503          	lw	a0,-56(s0)
    4f3c:	00000097          	auipc	ra,0x0
    4f40:	5a2080e7          	jalr	1442(ra) # 54de <read>
    if(cc < 0){
    4f44:	00054563          	bltz	a0,4f4e <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    4f48:	c105                	beqz	a0,4f68 <countfree+0x10a>
      break;
    n += 1;
    4f4a:	2485                	addiw	s1,s1,1
  while(1){
    4f4c:	b7dd                	j	4f32 <countfree+0xd4>
      printf("read() failed in countfree()\n");
    4f4e:	00003517          	auipc	a0,0x3
    4f52:	c7250513          	addi	a0,a0,-910 # 7bc0 <malloc+0x22c4>
    4f56:	00001097          	auipc	ra,0x1
    4f5a:	8e8080e7          	jalr	-1816(ra) # 583e <printf>
      exit(1);
    4f5e:	4505                	li	a0,1
    4f60:	00000097          	auipc	ra,0x0
    4f64:	566080e7          	jalr	1382(ra) # 54c6 <exit>
  }

  close(fds[0]);
    4f68:	fc842503          	lw	a0,-56(s0)
    4f6c:	00000097          	auipc	ra,0x0
    4f70:	582080e7          	jalr	1410(ra) # 54ee <close>
  wait((int*)0);
    4f74:	4501                	li	a0,0
    4f76:	00000097          	auipc	ra,0x0
    4f7a:	558080e7          	jalr	1368(ra) # 54ce <wait>
  
  return n;
}
    4f7e:	8526                	mv	a0,s1
    4f80:	70e2                	ld	ra,56(sp)
    4f82:	7442                	ld	s0,48(sp)
    4f84:	74a2                	ld	s1,40(sp)
    4f86:	7902                	ld	s2,32(sp)
    4f88:	69e2                	ld	s3,24(sp)
    4f8a:	6121                	addi	sp,sp,64
    4f8c:	8082                	ret

0000000000004f8e <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    4f8e:	7179                	addi	sp,sp,-48
    4f90:	f406                	sd	ra,40(sp)
    4f92:	f022                	sd	s0,32(sp)
    4f94:	ec26                	sd	s1,24(sp)
    4f96:	e84a                	sd	s2,16(sp)
    4f98:	1800                	addi	s0,sp,48
    4f9a:	84aa                	mv	s1,a0
    4f9c:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    4f9e:	00003517          	auipc	a0,0x3
    4fa2:	c4250513          	addi	a0,a0,-958 # 7be0 <malloc+0x22e4>
    4fa6:	00001097          	auipc	ra,0x1
    4faa:	898080e7          	jalr	-1896(ra) # 583e <printf>
  if((pid = fork()) < 0) {
    4fae:	00000097          	auipc	ra,0x0
    4fb2:	510080e7          	jalr	1296(ra) # 54be <fork>
    4fb6:	02054e63          	bltz	a0,4ff2 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    4fba:	c929                	beqz	a0,500c <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    4fbc:	fdc40513          	addi	a0,s0,-36
    4fc0:	00000097          	auipc	ra,0x0
    4fc4:	50e080e7          	jalr	1294(ra) # 54ce <wait>
    if(xstatus != 0) 
    4fc8:	fdc42783          	lw	a5,-36(s0)
    4fcc:	c7b9                	beqz	a5,501a <run+0x8c>
      printf("FAILED\n");
    4fce:	00003517          	auipc	a0,0x3
    4fd2:	c3a50513          	addi	a0,a0,-966 # 7c08 <malloc+0x230c>
    4fd6:	00001097          	auipc	ra,0x1
    4fda:	868080e7          	jalr	-1944(ra) # 583e <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    4fde:	fdc42503          	lw	a0,-36(s0)
  }
}
    4fe2:	00153513          	seqz	a0,a0
    4fe6:	70a2                	ld	ra,40(sp)
    4fe8:	7402                	ld	s0,32(sp)
    4fea:	64e2                	ld	s1,24(sp)
    4fec:	6942                	ld	s2,16(sp)
    4fee:	6145                	addi	sp,sp,48
    4ff0:	8082                	ret
    printf("runtest: fork error\n");
    4ff2:	00003517          	auipc	a0,0x3
    4ff6:	bfe50513          	addi	a0,a0,-1026 # 7bf0 <malloc+0x22f4>
    4ffa:	00001097          	auipc	ra,0x1
    4ffe:	844080e7          	jalr	-1980(ra) # 583e <printf>
    exit(1);
    5002:	4505                	li	a0,1
    5004:	00000097          	auipc	ra,0x0
    5008:	4c2080e7          	jalr	1218(ra) # 54c6 <exit>
    f(s);
    500c:	854a                	mv	a0,s2
    500e:	9482                	jalr	s1
    exit(0);
    5010:	4501                	li	a0,0
    5012:	00000097          	auipc	ra,0x0
    5016:	4b4080e7          	jalr	1204(ra) # 54c6 <exit>
      printf("OK\n");
    501a:	00003517          	auipc	a0,0x3
    501e:	bf650513          	addi	a0,a0,-1034 # 7c10 <malloc+0x2314>
    5022:	00001097          	auipc	ra,0x1
    5026:	81c080e7          	jalr	-2020(ra) # 583e <printf>
    502a:	bf55                	j	4fde <run+0x50>

000000000000502c <main>:

int
main(int argc, char *argv[])
{
    502c:	c2010113          	addi	sp,sp,-992
    5030:	3c113c23          	sd	ra,984(sp)
    5034:	3c813823          	sd	s0,976(sp)
    5038:	3c913423          	sd	s1,968(sp)
    503c:	3d213023          	sd	s2,960(sp)
    5040:	3b313c23          	sd	s3,952(sp)
    5044:	3b413823          	sd	s4,944(sp)
    5048:	3b513423          	sd	s5,936(sp)
    504c:	3b613023          	sd	s6,928(sp)
    5050:	1780                	addi	s0,sp,992
    5052:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5054:	4789                	li	a5,2
    5056:	08f50763          	beq	a0,a5,50e4 <main+0xb8>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    505a:	4785                	li	a5,1
  char *justone = 0;
    505c:	4901                	li	s2,0
  } else if(argc > 1){
    505e:	0ca7c163          	blt	a5,a0,5120 <main+0xf4>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    5062:	00003797          	auipc	a5,0x3
    5066:	cc678793          	addi	a5,a5,-826 # 7d28 <malloc+0x242c>
    506a:	c2040713          	addi	a4,s0,-992
    506e:	00003817          	auipc	a6,0x3
    5072:	05a80813          	addi	a6,a6,90 # 80c8 <malloc+0x27cc>
    5076:	6388                	ld	a0,0(a5)
    5078:	678c                	ld	a1,8(a5)
    507a:	6b90                	ld	a2,16(a5)
    507c:	6f94                	ld	a3,24(a5)
    507e:	e308                	sd	a0,0(a4)
    5080:	e70c                	sd	a1,8(a4)
    5082:	eb10                	sd	a2,16(a4)
    5084:	ef14                	sd	a3,24(a4)
    5086:	02078793          	addi	a5,a5,32
    508a:	02070713          	addi	a4,a4,32
    508e:	ff0794e3          	bne	a5,a6,5076 <main+0x4a>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    5092:	00003517          	auipc	a0,0x3
    5096:	c3650513          	addi	a0,a0,-970 # 7cc8 <malloc+0x23cc>
    509a:	00000097          	auipc	ra,0x0
    509e:	7a4080e7          	jalr	1956(ra) # 583e <printf>
  int free0 = countfree();
    50a2:	00000097          	auipc	ra,0x0
    50a6:	dbc080e7          	jalr	-580(ra) # 4e5e <countfree>
    50aa:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    50ac:	c2843503          	ld	a0,-984(s0)
    50b0:	c2040493          	addi	s1,s0,-992
  int fail = 0;
    50b4:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    50b6:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    50b8:	e55d                	bnez	a0,5166 <main+0x13a>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    50ba:	00000097          	auipc	ra,0x0
    50be:	da4080e7          	jalr	-604(ra) # 4e5e <countfree>
    50c2:	85aa                	mv	a1,a0
    50c4:	0f455163          	bge	a0,s4,51a6 <main+0x17a>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    50c8:	8652                	mv	a2,s4
    50ca:	00003517          	auipc	a0,0x3
    50ce:	bb650513          	addi	a0,a0,-1098 # 7c80 <malloc+0x2384>
    50d2:	00000097          	auipc	ra,0x0
    50d6:	76c080e7          	jalr	1900(ra) # 583e <printf>
    exit(1);
    50da:	4505                	li	a0,1
    50dc:	00000097          	auipc	ra,0x0
    50e0:	3ea080e7          	jalr	1002(ra) # 54c6 <exit>
    50e4:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    50e6:	00003597          	auipc	a1,0x3
    50ea:	b3258593          	addi	a1,a1,-1230 # 7c18 <malloc+0x231c>
    50ee:	6488                	ld	a0,8(s1)
    50f0:	00000097          	auipc	ra,0x0
    50f4:	184080e7          	jalr	388(ra) # 5274 <strcmp>
    50f8:	10050563          	beqz	a0,5202 <main+0x1d6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    50fc:	00003597          	auipc	a1,0x3
    5100:	c0458593          	addi	a1,a1,-1020 # 7d00 <malloc+0x2404>
    5104:	6488                	ld	a0,8(s1)
    5106:	00000097          	auipc	ra,0x0
    510a:	16e080e7          	jalr	366(ra) # 5274 <strcmp>
    510e:	c97d                	beqz	a0,5204 <main+0x1d8>
  } else if(argc == 2 && argv[1][0] != '-'){
    5110:	0084b903          	ld	s2,8(s1)
    5114:	00094703          	lbu	a4,0(s2)
    5118:	02d00793          	li	a5,45
    511c:	f4f713e3          	bne	a4,a5,5062 <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    5120:	00003517          	auipc	a0,0x3
    5124:	b0050513          	addi	a0,a0,-1280 # 7c20 <malloc+0x2324>
    5128:	00000097          	auipc	ra,0x0
    512c:	716080e7          	jalr	1814(ra) # 583e <printf>
    exit(1);
    5130:	4505                	li	a0,1
    5132:	00000097          	auipc	ra,0x0
    5136:	394080e7          	jalr	916(ra) # 54c6 <exit>
          exit(1);
    513a:	4505                	li	a0,1
    513c:	00000097          	auipc	ra,0x0
    5140:	38a080e7          	jalr	906(ra) # 54c6 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5144:	40a905bb          	subw	a1,s2,a0
    5148:	855a                	mv	a0,s6
    514a:	00000097          	auipc	ra,0x0
    514e:	6f4080e7          	jalr	1780(ra) # 583e <printf>
        if(continuous != 2)
    5152:	09498463          	beq	s3,s4,51da <main+0x1ae>
          exit(1);
    5156:	4505                	li	a0,1
    5158:	00000097          	auipc	ra,0x0
    515c:	36e080e7          	jalr	878(ra) # 54c6 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    5160:	04c1                	addi	s1,s1,16
    5162:	6488                	ld	a0,8(s1)
    5164:	c115                	beqz	a0,5188 <main+0x15c>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    5166:	00090863          	beqz	s2,5176 <main+0x14a>
    516a:	85ca                	mv	a1,s2
    516c:	00000097          	auipc	ra,0x0
    5170:	108080e7          	jalr	264(ra) # 5274 <strcmp>
    5174:	f575                	bnez	a0,5160 <main+0x134>
      if(!run(t->f, t->s))
    5176:	648c                	ld	a1,8(s1)
    5178:	6088                	ld	a0,0(s1)
    517a:	00000097          	auipc	ra,0x0
    517e:	e14080e7          	jalr	-492(ra) # 4f8e <run>
    5182:	fd79                	bnez	a0,5160 <main+0x134>
        fail = 1;
    5184:	89d6                	mv	s3,s5
    5186:	bfe9                	j	5160 <main+0x134>
  if(fail){
    5188:	f20989e3          	beqz	s3,50ba <main+0x8e>
    printf("SOME TESTS FAILED\n");
    518c:	00003517          	auipc	a0,0x3
    5190:	adc50513          	addi	a0,a0,-1316 # 7c68 <malloc+0x236c>
    5194:	00000097          	auipc	ra,0x0
    5198:	6aa080e7          	jalr	1706(ra) # 583e <printf>
    exit(1);
    519c:	4505                	li	a0,1
    519e:	00000097          	auipc	ra,0x0
    51a2:	328080e7          	jalr	808(ra) # 54c6 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    51a6:	00003517          	auipc	a0,0x3
    51aa:	b0a50513          	addi	a0,a0,-1270 # 7cb0 <malloc+0x23b4>
    51ae:	00000097          	auipc	ra,0x0
    51b2:	690080e7          	jalr	1680(ra) # 583e <printf>
    exit(0);
    51b6:	4501                	li	a0,0
    51b8:	00000097          	auipc	ra,0x0
    51bc:	30e080e7          	jalr	782(ra) # 54c6 <exit>
        printf("SOME TESTS FAILED\n");
    51c0:	8556                	mv	a0,s5
    51c2:	00000097          	auipc	ra,0x0
    51c6:	67c080e7          	jalr	1660(ra) # 583e <printf>
        if(continuous != 2)
    51ca:	f74998e3          	bne	s3,s4,513a <main+0x10e>
      int free1 = countfree();
    51ce:	00000097          	auipc	ra,0x0
    51d2:	c90080e7          	jalr	-880(ra) # 4e5e <countfree>
      if(free1 < free0){
    51d6:	f72547e3          	blt	a0,s2,5144 <main+0x118>
      int free0 = countfree();
    51da:	00000097          	auipc	ra,0x0
    51de:	c84080e7          	jalr	-892(ra) # 4e5e <countfree>
    51e2:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    51e4:	c2843583          	ld	a1,-984(s0)
    51e8:	d1fd                	beqz	a1,51ce <main+0x1a2>
    51ea:	c2040493          	addi	s1,s0,-992
        if(!run(t->f, t->s)){
    51ee:	6088                	ld	a0,0(s1)
    51f0:	00000097          	auipc	ra,0x0
    51f4:	d9e080e7          	jalr	-610(ra) # 4f8e <run>
    51f8:	d561                	beqz	a0,51c0 <main+0x194>
      for (struct test *t = tests; t->s != 0; t++) {
    51fa:	04c1                	addi	s1,s1,16
    51fc:	648c                	ld	a1,8(s1)
    51fe:	f9e5                	bnez	a1,51ee <main+0x1c2>
    5200:	b7f9                	j	51ce <main+0x1a2>
    continuous = 1;
    5202:	4985                	li	s3,1
  } tests[] = {
    5204:	00003797          	auipc	a5,0x3
    5208:	b2478793          	addi	a5,a5,-1244 # 7d28 <malloc+0x242c>
    520c:	c2040713          	addi	a4,s0,-992
    5210:	00003817          	auipc	a6,0x3
    5214:	eb880813          	addi	a6,a6,-328 # 80c8 <malloc+0x27cc>
    5218:	6388                	ld	a0,0(a5)
    521a:	678c                	ld	a1,8(a5)
    521c:	6b90                	ld	a2,16(a5)
    521e:	6f94                	ld	a3,24(a5)
    5220:	e308                	sd	a0,0(a4)
    5222:	e70c                	sd	a1,8(a4)
    5224:	eb10                	sd	a2,16(a4)
    5226:	ef14                	sd	a3,24(a4)
    5228:	02078793          	addi	a5,a5,32
    522c:	02070713          	addi	a4,a4,32
    5230:	ff0794e3          	bne	a5,a6,5218 <main+0x1ec>
    printf("continuous usertests starting\n");
    5234:	00003517          	auipc	a0,0x3
    5238:	aac50513          	addi	a0,a0,-1364 # 7ce0 <malloc+0x23e4>
    523c:	00000097          	auipc	ra,0x0
    5240:	602080e7          	jalr	1538(ra) # 583e <printf>
        printf("SOME TESTS FAILED\n");
    5244:	00003a97          	auipc	s5,0x3
    5248:	a24a8a93          	addi	s5,s5,-1500 # 7c68 <malloc+0x236c>
        if(continuous != 2)
    524c:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    524e:	00003b17          	auipc	s6,0x3
    5252:	9fab0b13          	addi	s6,s6,-1542 # 7c48 <malloc+0x234c>
    5256:	b751                	j	51da <main+0x1ae>

0000000000005258 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    5258:	1141                	addi	sp,sp,-16
    525a:	e422                	sd	s0,8(sp)
    525c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    525e:	87aa                	mv	a5,a0
    5260:	0585                	addi	a1,a1,1
    5262:	0785                	addi	a5,a5,1
    5264:	fff5c703          	lbu	a4,-1(a1)
    5268:	fee78fa3          	sb	a4,-1(a5)
    526c:	fb75                	bnez	a4,5260 <strcpy+0x8>
    ;
  return os;
}
    526e:	6422                	ld	s0,8(sp)
    5270:	0141                	addi	sp,sp,16
    5272:	8082                	ret

0000000000005274 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5274:	1141                	addi	sp,sp,-16
    5276:	e422                	sd	s0,8(sp)
    5278:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    527a:	00054783          	lbu	a5,0(a0)
    527e:	cb91                	beqz	a5,5292 <strcmp+0x1e>
    5280:	0005c703          	lbu	a4,0(a1)
    5284:	00f71763          	bne	a4,a5,5292 <strcmp+0x1e>
    p++, q++;
    5288:	0505                	addi	a0,a0,1
    528a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    528c:	00054783          	lbu	a5,0(a0)
    5290:	fbe5                	bnez	a5,5280 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5292:	0005c503          	lbu	a0,0(a1)
}
    5296:	40a7853b          	subw	a0,a5,a0
    529a:	6422                	ld	s0,8(sp)
    529c:	0141                	addi	sp,sp,16
    529e:	8082                	ret

00000000000052a0 <strlen>:

uint
strlen(const char *s)
{
    52a0:	1141                	addi	sp,sp,-16
    52a2:	e422                	sd	s0,8(sp)
    52a4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    52a6:	00054783          	lbu	a5,0(a0)
    52aa:	cf91                	beqz	a5,52c6 <strlen+0x26>
    52ac:	0505                	addi	a0,a0,1
    52ae:	87aa                	mv	a5,a0
    52b0:	4685                	li	a3,1
    52b2:	9e89                	subw	a3,a3,a0
    52b4:	00f6853b          	addw	a0,a3,a5
    52b8:	0785                	addi	a5,a5,1
    52ba:	fff7c703          	lbu	a4,-1(a5)
    52be:	fb7d                	bnez	a4,52b4 <strlen+0x14>
    ;
  return n;
}
    52c0:	6422                	ld	s0,8(sp)
    52c2:	0141                	addi	sp,sp,16
    52c4:	8082                	ret
  for(n = 0; s[n]; n++)
    52c6:	4501                	li	a0,0
    52c8:	bfe5                	j	52c0 <strlen+0x20>

00000000000052ca <memset>:

void*
memset(void *dst, int c, uint n)
{
    52ca:	1141                	addi	sp,sp,-16
    52cc:	e422                	sd	s0,8(sp)
    52ce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    52d0:	ca19                	beqz	a2,52e6 <memset+0x1c>
    52d2:	87aa                	mv	a5,a0
    52d4:	1602                	slli	a2,a2,0x20
    52d6:	9201                	srli	a2,a2,0x20
    52d8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    52dc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    52e0:	0785                	addi	a5,a5,1
    52e2:	fee79de3          	bne	a5,a4,52dc <memset+0x12>
  }
  return dst;
}
    52e6:	6422                	ld	s0,8(sp)
    52e8:	0141                	addi	sp,sp,16
    52ea:	8082                	ret

00000000000052ec <strchr>:

char*
strchr(const char *s, char c)
{
    52ec:	1141                	addi	sp,sp,-16
    52ee:	e422                	sd	s0,8(sp)
    52f0:	0800                	addi	s0,sp,16
  for(; *s; s++)
    52f2:	00054783          	lbu	a5,0(a0)
    52f6:	cb99                	beqz	a5,530c <strchr+0x20>
    if(*s == c)
    52f8:	00f58763          	beq	a1,a5,5306 <strchr+0x1a>
  for(; *s; s++)
    52fc:	0505                	addi	a0,a0,1
    52fe:	00054783          	lbu	a5,0(a0)
    5302:	fbfd                	bnez	a5,52f8 <strchr+0xc>
      return (char*)s;
  return 0;
    5304:	4501                	li	a0,0
}
    5306:	6422                	ld	s0,8(sp)
    5308:	0141                	addi	sp,sp,16
    530a:	8082                	ret
  return 0;
    530c:	4501                	li	a0,0
    530e:	bfe5                	j	5306 <strchr+0x1a>

0000000000005310 <gets>:

char*
gets(char *buf, int max)
{
    5310:	711d                	addi	sp,sp,-96
    5312:	ec86                	sd	ra,88(sp)
    5314:	e8a2                	sd	s0,80(sp)
    5316:	e4a6                	sd	s1,72(sp)
    5318:	e0ca                	sd	s2,64(sp)
    531a:	fc4e                	sd	s3,56(sp)
    531c:	f852                	sd	s4,48(sp)
    531e:	f456                	sd	s5,40(sp)
    5320:	f05a                	sd	s6,32(sp)
    5322:	ec5e                	sd	s7,24(sp)
    5324:	1080                	addi	s0,sp,96
    5326:	8baa                	mv	s7,a0
    5328:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    532a:	892a                	mv	s2,a0
    532c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    532e:	4aa9                	li	s5,10
    5330:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5332:	89a6                	mv	s3,s1
    5334:	2485                	addiw	s1,s1,1
    5336:	0344d863          	bge	s1,s4,5366 <gets+0x56>
    cc = read(0, &c, 1);
    533a:	4605                	li	a2,1
    533c:	faf40593          	addi	a1,s0,-81
    5340:	4501                	li	a0,0
    5342:	00000097          	auipc	ra,0x0
    5346:	19c080e7          	jalr	412(ra) # 54de <read>
    if(cc < 1)
    534a:	00a05e63          	blez	a0,5366 <gets+0x56>
    buf[i++] = c;
    534e:	faf44783          	lbu	a5,-81(s0)
    5352:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5356:	01578763          	beq	a5,s5,5364 <gets+0x54>
    535a:	0905                	addi	s2,s2,1
    535c:	fd679be3          	bne	a5,s6,5332 <gets+0x22>
  for(i=0; i+1 < max; ){
    5360:	89a6                	mv	s3,s1
    5362:	a011                	j	5366 <gets+0x56>
    5364:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5366:	99de                	add	s3,s3,s7
    5368:	00098023          	sb	zero,0(s3)
  return buf;
}
    536c:	855e                	mv	a0,s7
    536e:	60e6                	ld	ra,88(sp)
    5370:	6446                	ld	s0,80(sp)
    5372:	64a6                	ld	s1,72(sp)
    5374:	6906                	ld	s2,64(sp)
    5376:	79e2                	ld	s3,56(sp)
    5378:	7a42                	ld	s4,48(sp)
    537a:	7aa2                	ld	s5,40(sp)
    537c:	7b02                	ld	s6,32(sp)
    537e:	6be2                	ld	s7,24(sp)
    5380:	6125                	addi	sp,sp,96
    5382:	8082                	ret

0000000000005384 <stat>:

int
stat(const char *n, struct stat *st)
{
    5384:	1101                	addi	sp,sp,-32
    5386:	ec06                	sd	ra,24(sp)
    5388:	e822                	sd	s0,16(sp)
    538a:	e426                	sd	s1,8(sp)
    538c:	e04a                	sd	s2,0(sp)
    538e:	1000                	addi	s0,sp,32
    5390:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5392:	4581                	li	a1,0
    5394:	00000097          	auipc	ra,0x0
    5398:	172080e7          	jalr	370(ra) # 5506 <open>
  if(fd < 0)
    539c:	02054563          	bltz	a0,53c6 <stat+0x42>
    53a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    53a2:	85ca                	mv	a1,s2
    53a4:	00000097          	auipc	ra,0x0
    53a8:	17a080e7          	jalr	378(ra) # 551e <fstat>
    53ac:	892a                	mv	s2,a0
  close(fd);
    53ae:	8526                	mv	a0,s1
    53b0:	00000097          	auipc	ra,0x0
    53b4:	13e080e7          	jalr	318(ra) # 54ee <close>
  return r;
}
    53b8:	854a                	mv	a0,s2
    53ba:	60e2                	ld	ra,24(sp)
    53bc:	6442                	ld	s0,16(sp)
    53be:	64a2                	ld	s1,8(sp)
    53c0:	6902                	ld	s2,0(sp)
    53c2:	6105                	addi	sp,sp,32
    53c4:	8082                	ret
    return -1;
    53c6:	597d                	li	s2,-1
    53c8:	bfc5                	j	53b8 <stat+0x34>

00000000000053ca <atoi>:

int
atoi(const char *s)
{
    53ca:	1141                	addi	sp,sp,-16
    53cc:	e422                	sd	s0,8(sp)
    53ce:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    53d0:	00054603          	lbu	a2,0(a0)
    53d4:	fd06079b          	addiw	a5,a2,-48
    53d8:	0ff7f793          	andi	a5,a5,255
    53dc:	4725                	li	a4,9
    53de:	02f76963          	bltu	a4,a5,5410 <atoi+0x46>
    53e2:	86aa                	mv	a3,a0
  n = 0;
    53e4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    53e6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    53e8:	0685                	addi	a3,a3,1
    53ea:	0025179b          	slliw	a5,a0,0x2
    53ee:	9fa9                	addw	a5,a5,a0
    53f0:	0017979b          	slliw	a5,a5,0x1
    53f4:	9fb1                	addw	a5,a5,a2
    53f6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    53fa:	0006c603          	lbu	a2,0(a3)
    53fe:	fd06071b          	addiw	a4,a2,-48
    5402:	0ff77713          	andi	a4,a4,255
    5406:	fee5f1e3          	bgeu	a1,a4,53e8 <atoi+0x1e>
  return n;
}
    540a:	6422                	ld	s0,8(sp)
    540c:	0141                	addi	sp,sp,16
    540e:	8082                	ret
  n = 0;
    5410:	4501                	li	a0,0
    5412:	bfe5                	j	540a <atoi+0x40>

0000000000005414 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5414:	1141                	addi	sp,sp,-16
    5416:	e422                	sd	s0,8(sp)
    5418:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    541a:	02b57463          	bgeu	a0,a1,5442 <memmove+0x2e>
    while(n-- > 0)
    541e:	00c05f63          	blez	a2,543c <memmove+0x28>
    5422:	1602                	slli	a2,a2,0x20
    5424:	9201                	srli	a2,a2,0x20
    5426:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    542a:	872a                	mv	a4,a0
      *dst++ = *src++;
    542c:	0585                	addi	a1,a1,1
    542e:	0705                	addi	a4,a4,1
    5430:	fff5c683          	lbu	a3,-1(a1)
    5434:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5438:	fee79ae3          	bne	a5,a4,542c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    543c:	6422                	ld	s0,8(sp)
    543e:	0141                	addi	sp,sp,16
    5440:	8082                	ret
    dst += n;
    5442:	00c50733          	add	a4,a0,a2
    src += n;
    5446:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5448:	fec05ae3          	blez	a2,543c <memmove+0x28>
    544c:	fff6079b          	addiw	a5,a2,-1
    5450:	1782                	slli	a5,a5,0x20
    5452:	9381                	srli	a5,a5,0x20
    5454:	fff7c793          	not	a5,a5
    5458:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    545a:	15fd                	addi	a1,a1,-1
    545c:	177d                	addi	a4,a4,-1
    545e:	0005c683          	lbu	a3,0(a1)
    5462:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5466:	fee79ae3          	bne	a5,a4,545a <memmove+0x46>
    546a:	bfc9                	j	543c <memmove+0x28>

000000000000546c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    546c:	1141                	addi	sp,sp,-16
    546e:	e422                	sd	s0,8(sp)
    5470:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5472:	ca05                	beqz	a2,54a2 <memcmp+0x36>
    5474:	fff6069b          	addiw	a3,a2,-1
    5478:	1682                	slli	a3,a3,0x20
    547a:	9281                	srli	a3,a3,0x20
    547c:	0685                	addi	a3,a3,1
    547e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5480:	00054783          	lbu	a5,0(a0)
    5484:	0005c703          	lbu	a4,0(a1)
    5488:	00e79863          	bne	a5,a4,5498 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    548c:	0505                	addi	a0,a0,1
    p2++;
    548e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5490:	fed518e3          	bne	a0,a3,5480 <memcmp+0x14>
  }
  return 0;
    5494:	4501                	li	a0,0
    5496:	a019                	j	549c <memcmp+0x30>
      return *p1 - *p2;
    5498:	40e7853b          	subw	a0,a5,a4
}
    549c:	6422                	ld	s0,8(sp)
    549e:	0141                	addi	sp,sp,16
    54a0:	8082                	ret
  return 0;
    54a2:	4501                	li	a0,0
    54a4:	bfe5                	j	549c <memcmp+0x30>

00000000000054a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    54a6:	1141                	addi	sp,sp,-16
    54a8:	e406                	sd	ra,8(sp)
    54aa:	e022                	sd	s0,0(sp)
    54ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    54ae:	00000097          	auipc	ra,0x0
    54b2:	f66080e7          	jalr	-154(ra) # 5414 <memmove>
}
    54b6:	60a2                	ld	ra,8(sp)
    54b8:	6402                	ld	s0,0(sp)
    54ba:	0141                	addi	sp,sp,16
    54bc:	8082                	ret

00000000000054be <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    54be:	4885                	li	a7,1
 ecall
    54c0:	00000073          	ecall
 ret
    54c4:	8082                	ret

00000000000054c6 <exit>:
.global exit
exit:
 li a7, SYS_exit
    54c6:	4889                	li	a7,2
 ecall
    54c8:	00000073          	ecall
 ret
    54cc:	8082                	ret

00000000000054ce <wait>:
.global wait
wait:
 li a7, SYS_wait
    54ce:	488d                	li	a7,3
 ecall
    54d0:	00000073          	ecall
 ret
    54d4:	8082                	ret

00000000000054d6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    54d6:	4891                	li	a7,4
 ecall
    54d8:	00000073          	ecall
 ret
    54dc:	8082                	ret

00000000000054de <read>:
.global read
read:
 li a7, SYS_read
    54de:	4895                	li	a7,5
 ecall
    54e0:	00000073          	ecall
 ret
    54e4:	8082                	ret

00000000000054e6 <write>:
.global write
write:
 li a7, SYS_write
    54e6:	48c1                	li	a7,16
 ecall
    54e8:	00000073          	ecall
 ret
    54ec:	8082                	ret

00000000000054ee <close>:
.global close
close:
 li a7, SYS_close
    54ee:	48d5                	li	a7,21
 ecall
    54f0:	00000073          	ecall
 ret
    54f4:	8082                	ret

00000000000054f6 <kill>:
.global kill
kill:
 li a7, SYS_kill
    54f6:	4899                	li	a7,6
 ecall
    54f8:	00000073          	ecall
 ret
    54fc:	8082                	ret

00000000000054fe <exec>:
.global exec
exec:
 li a7, SYS_exec
    54fe:	489d                	li	a7,7
 ecall
    5500:	00000073          	ecall
 ret
    5504:	8082                	ret

0000000000005506 <open>:
.global open
open:
 li a7, SYS_open
    5506:	48bd                	li	a7,15
 ecall
    5508:	00000073          	ecall
 ret
    550c:	8082                	ret

000000000000550e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    550e:	48c5                	li	a7,17
 ecall
    5510:	00000073          	ecall
 ret
    5514:	8082                	ret

0000000000005516 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5516:	48c9                	li	a7,18
 ecall
    5518:	00000073          	ecall
 ret
    551c:	8082                	ret

000000000000551e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    551e:	48a1                	li	a7,8
 ecall
    5520:	00000073          	ecall
 ret
    5524:	8082                	ret

0000000000005526 <link>:
.global link
link:
 li a7, SYS_link
    5526:	48cd                	li	a7,19
 ecall
    5528:	00000073          	ecall
 ret
    552c:	8082                	ret

000000000000552e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    552e:	48d1                	li	a7,20
 ecall
    5530:	00000073          	ecall
 ret
    5534:	8082                	ret

0000000000005536 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5536:	48a5                	li	a7,9
 ecall
    5538:	00000073          	ecall
 ret
    553c:	8082                	ret

000000000000553e <dup>:
.global dup
dup:
 li a7, SYS_dup
    553e:	48a9                	li	a7,10
 ecall
    5540:	00000073          	ecall
 ret
    5544:	8082                	ret

0000000000005546 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5546:	48ad                	li	a7,11
 ecall
    5548:	00000073          	ecall
 ret
    554c:	8082                	ret

000000000000554e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    554e:	48b1                	li	a7,12
 ecall
    5550:	00000073          	ecall
 ret
    5554:	8082                	ret

0000000000005556 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5556:	48b5                	li	a7,13
 ecall
    5558:	00000073          	ecall
 ret
    555c:	8082                	ret

000000000000555e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    555e:	48b9                	li	a7,14
 ecall
    5560:	00000073          	ecall
 ret
    5564:	8082                	ret

0000000000005566 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5566:	1101                	addi	sp,sp,-32
    5568:	ec06                	sd	ra,24(sp)
    556a:	e822                	sd	s0,16(sp)
    556c:	1000                	addi	s0,sp,32
    556e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5572:	4605                	li	a2,1
    5574:	fef40593          	addi	a1,s0,-17
    5578:	00000097          	auipc	ra,0x0
    557c:	f6e080e7          	jalr	-146(ra) # 54e6 <write>
}
    5580:	60e2                	ld	ra,24(sp)
    5582:	6442                	ld	s0,16(sp)
    5584:	6105                	addi	sp,sp,32
    5586:	8082                	ret

0000000000005588 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5588:	7139                	addi	sp,sp,-64
    558a:	fc06                	sd	ra,56(sp)
    558c:	f822                	sd	s0,48(sp)
    558e:	f426                	sd	s1,40(sp)
    5590:	f04a                	sd	s2,32(sp)
    5592:	ec4e                	sd	s3,24(sp)
    5594:	0080                	addi	s0,sp,64
    5596:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5598:	c299                	beqz	a3,559e <printint+0x16>
    559a:	0805c863          	bltz	a1,562a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    559e:	2581                	sext.w	a1,a1
  neg = 0;
    55a0:	4881                	li	a7,0
    55a2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    55a6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    55a8:	2601                	sext.w	a2,a2
    55aa:	00003517          	auipc	a0,0x3
    55ae:	b2650513          	addi	a0,a0,-1242 # 80d0 <digits>
    55b2:	883a                	mv	a6,a4
    55b4:	2705                	addiw	a4,a4,1
    55b6:	02c5f7bb          	remuw	a5,a1,a2
    55ba:	1782                	slli	a5,a5,0x20
    55bc:	9381                	srli	a5,a5,0x20
    55be:	97aa                	add	a5,a5,a0
    55c0:	0007c783          	lbu	a5,0(a5)
    55c4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    55c8:	0005879b          	sext.w	a5,a1
    55cc:	02c5d5bb          	divuw	a1,a1,a2
    55d0:	0685                	addi	a3,a3,1
    55d2:	fec7f0e3          	bgeu	a5,a2,55b2 <printint+0x2a>
  if(neg)
    55d6:	00088b63          	beqz	a7,55ec <printint+0x64>
    buf[i++] = '-';
    55da:	fd040793          	addi	a5,s0,-48
    55de:	973e                	add	a4,a4,a5
    55e0:	02d00793          	li	a5,45
    55e4:	fef70823          	sb	a5,-16(a4)
    55e8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    55ec:	02e05863          	blez	a4,561c <printint+0x94>
    55f0:	fc040793          	addi	a5,s0,-64
    55f4:	00e78933          	add	s2,a5,a4
    55f8:	fff78993          	addi	s3,a5,-1
    55fc:	99ba                	add	s3,s3,a4
    55fe:	377d                	addiw	a4,a4,-1
    5600:	1702                	slli	a4,a4,0x20
    5602:	9301                	srli	a4,a4,0x20
    5604:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5608:	fff94583          	lbu	a1,-1(s2)
    560c:	8526                	mv	a0,s1
    560e:	00000097          	auipc	ra,0x0
    5612:	f58080e7          	jalr	-168(ra) # 5566 <putc>
  while(--i >= 0)
    5616:	197d                	addi	s2,s2,-1
    5618:	ff3918e3          	bne	s2,s3,5608 <printint+0x80>
}
    561c:	70e2                	ld	ra,56(sp)
    561e:	7442                	ld	s0,48(sp)
    5620:	74a2                	ld	s1,40(sp)
    5622:	7902                	ld	s2,32(sp)
    5624:	69e2                	ld	s3,24(sp)
    5626:	6121                	addi	sp,sp,64
    5628:	8082                	ret
    x = -xx;
    562a:	40b005bb          	negw	a1,a1
    neg = 1;
    562e:	4885                	li	a7,1
    x = -xx;
    5630:	bf8d                	j	55a2 <printint+0x1a>

0000000000005632 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5632:	7119                	addi	sp,sp,-128
    5634:	fc86                	sd	ra,120(sp)
    5636:	f8a2                	sd	s0,112(sp)
    5638:	f4a6                	sd	s1,104(sp)
    563a:	f0ca                	sd	s2,96(sp)
    563c:	ecce                	sd	s3,88(sp)
    563e:	e8d2                	sd	s4,80(sp)
    5640:	e4d6                	sd	s5,72(sp)
    5642:	e0da                	sd	s6,64(sp)
    5644:	fc5e                	sd	s7,56(sp)
    5646:	f862                	sd	s8,48(sp)
    5648:	f466                	sd	s9,40(sp)
    564a:	f06a                	sd	s10,32(sp)
    564c:	ec6e                	sd	s11,24(sp)
    564e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5650:	0005c903          	lbu	s2,0(a1)
    5654:	18090f63          	beqz	s2,57f2 <vprintf+0x1c0>
    5658:	8aaa                	mv	s5,a0
    565a:	8b32                	mv	s6,a2
    565c:	00158493          	addi	s1,a1,1
  state = 0;
    5660:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5662:	02500a13          	li	s4,37
      if(c == 'd'){
    5666:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    566a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    566e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5672:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5676:	00003b97          	auipc	s7,0x3
    567a:	a5ab8b93          	addi	s7,s7,-1446 # 80d0 <digits>
    567e:	a839                	j	569c <vprintf+0x6a>
        putc(fd, c);
    5680:	85ca                	mv	a1,s2
    5682:	8556                	mv	a0,s5
    5684:	00000097          	auipc	ra,0x0
    5688:	ee2080e7          	jalr	-286(ra) # 5566 <putc>
    568c:	a019                	j	5692 <vprintf+0x60>
    } else if(state == '%'){
    568e:	01498f63          	beq	s3,s4,56ac <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5692:	0485                	addi	s1,s1,1
    5694:	fff4c903          	lbu	s2,-1(s1)
    5698:	14090d63          	beqz	s2,57f2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    569c:	0009079b          	sext.w	a5,s2
    if(state == 0){
    56a0:	fe0997e3          	bnez	s3,568e <vprintf+0x5c>
      if(c == '%'){
    56a4:	fd479ee3          	bne	a5,s4,5680 <vprintf+0x4e>
        state = '%';
    56a8:	89be                	mv	s3,a5
    56aa:	b7e5                	j	5692 <vprintf+0x60>
      if(c == 'd'){
    56ac:	05878063          	beq	a5,s8,56ec <vprintf+0xba>
      } else if(c == 'l') {
    56b0:	05978c63          	beq	a5,s9,5708 <vprintf+0xd6>
      } else if(c == 'x') {
    56b4:	07a78863          	beq	a5,s10,5724 <vprintf+0xf2>
      } else if(c == 'p') {
    56b8:	09b78463          	beq	a5,s11,5740 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    56bc:	07300713          	li	a4,115
    56c0:	0ce78663          	beq	a5,a4,578c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    56c4:	06300713          	li	a4,99
    56c8:	0ee78e63          	beq	a5,a4,57c4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    56cc:	11478863          	beq	a5,s4,57dc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    56d0:	85d2                	mv	a1,s4
    56d2:	8556                	mv	a0,s5
    56d4:	00000097          	auipc	ra,0x0
    56d8:	e92080e7          	jalr	-366(ra) # 5566 <putc>
        putc(fd, c);
    56dc:	85ca                	mv	a1,s2
    56de:	8556                	mv	a0,s5
    56e0:	00000097          	auipc	ra,0x0
    56e4:	e86080e7          	jalr	-378(ra) # 5566 <putc>
      }
      state = 0;
    56e8:	4981                	li	s3,0
    56ea:	b765                	j	5692 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    56ec:	008b0913          	addi	s2,s6,8
    56f0:	4685                	li	a3,1
    56f2:	4629                	li	a2,10
    56f4:	000b2583          	lw	a1,0(s6)
    56f8:	8556                	mv	a0,s5
    56fa:	00000097          	auipc	ra,0x0
    56fe:	e8e080e7          	jalr	-370(ra) # 5588 <printint>
    5702:	8b4a                	mv	s6,s2
      state = 0;
    5704:	4981                	li	s3,0
    5706:	b771                	j	5692 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5708:	008b0913          	addi	s2,s6,8
    570c:	4681                	li	a3,0
    570e:	4629                	li	a2,10
    5710:	000b2583          	lw	a1,0(s6)
    5714:	8556                	mv	a0,s5
    5716:	00000097          	auipc	ra,0x0
    571a:	e72080e7          	jalr	-398(ra) # 5588 <printint>
    571e:	8b4a                	mv	s6,s2
      state = 0;
    5720:	4981                	li	s3,0
    5722:	bf85                	j	5692 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5724:	008b0913          	addi	s2,s6,8
    5728:	4681                	li	a3,0
    572a:	4641                	li	a2,16
    572c:	000b2583          	lw	a1,0(s6)
    5730:	8556                	mv	a0,s5
    5732:	00000097          	auipc	ra,0x0
    5736:	e56080e7          	jalr	-426(ra) # 5588 <printint>
    573a:	8b4a                	mv	s6,s2
      state = 0;
    573c:	4981                	li	s3,0
    573e:	bf91                	j	5692 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5740:	008b0793          	addi	a5,s6,8
    5744:	f8f43423          	sd	a5,-120(s0)
    5748:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    574c:	03000593          	li	a1,48
    5750:	8556                	mv	a0,s5
    5752:	00000097          	auipc	ra,0x0
    5756:	e14080e7          	jalr	-492(ra) # 5566 <putc>
  putc(fd, 'x');
    575a:	85ea                	mv	a1,s10
    575c:	8556                	mv	a0,s5
    575e:	00000097          	auipc	ra,0x0
    5762:	e08080e7          	jalr	-504(ra) # 5566 <putc>
    5766:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5768:	03c9d793          	srli	a5,s3,0x3c
    576c:	97de                	add	a5,a5,s7
    576e:	0007c583          	lbu	a1,0(a5)
    5772:	8556                	mv	a0,s5
    5774:	00000097          	auipc	ra,0x0
    5778:	df2080e7          	jalr	-526(ra) # 5566 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    577c:	0992                	slli	s3,s3,0x4
    577e:	397d                	addiw	s2,s2,-1
    5780:	fe0914e3          	bnez	s2,5768 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5784:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5788:	4981                	li	s3,0
    578a:	b721                	j	5692 <vprintf+0x60>
        s = va_arg(ap, char*);
    578c:	008b0993          	addi	s3,s6,8
    5790:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5794:	02090163          	beqz	s2,57b6 <vprintf+0x184>
        while(*s != 0){
    5798:	00094583          	lbu	a1,0(s2)
    579c:	c9a1                	beqz	a1,57ec <vprintf+0x1ba>
          putc(fd, *s);
    579e:	8556                	mv	a0,s5
    57a0:	00000097          	auipc	ra,0x0
    57a4:	dc6080e7          	jalr	-570(ra) # 5566 <putc>
          s++;
    57a8:	0905                	addi	s2,s2,1
        while(*s != 0){
    57aa:	00094583          	lbu	a1,0(s2)
    57ae:	f9e5                	bnez	a1,579e <vprintf+0x16c>
        s = va_arg(ap, char*);
    57b0:	8b4e                	mv	s6,s3
      state = 0;
    57b2:	4981                	li	s3,0
    57b4:	bdf9                	j	5692 <vprintf+0x60>
          s = "(null)";
    57b6:	00003917          	auipc	s2,0x3
    57ba:	91290913          	addi	s2,s2,-1774 # 80c8 <malloc+0x27cc>
        while(*s != 0){
    57be:	02800593          	li	a1,40
    57c2:	bff1                	j	579e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    57c4:	008b0913          	addi	s2,s6,8
    57c8:	000b4583          	lbu	a1,0(s6)
    57cc:	8556                	mv	a0,s5
    57ce:	00000097          	auipc	ra,0x0
    57d2:	d98080e7          	jalr	-616(ra) # 5566 <putc>
    57d6:	8b4a                	mv	s6,s2
      state = 0;
    57d8:	4981                	li	s3,0
    57da:	bd65                	j	5692 <vprintf+0x60>
        putc(fd, c);
    57dc:	85d2                	mv	a1,s4
    57de:	8556                	mv	a0,s5
    57e0:	00000097          	auipc	ra,0x0
    57e4:	d86080e7          	jalr	-634(ra) # 5566 <putc>
      state = 0;
    57e8:	4981                	li	s3,0
    57ea:	b565                	j	5692 <vprintf+0x60>
        s = va_arg(ap, char*);
    57ec:	8b4e                	mv	s6,s3
      state = 0;
    57ee:	4981                	li	s3,0
    57f0:	b54d                	j	5692 <vprintf+0x60>
    }
  }
}
    57f2:	70e6                	ld	ra,120(sp)
    57f4:	7446                	ld	s0,112(sp)
    57f6:	74a6                	ld	s1,104(sp)
    57f8:	7906                	ld	s2,96(sp)
    57fa:	69e6                	ld	s3,88(sp)
    57fc:	6a46                	ld	s4,80(sp)
    57fe:	6aa6                	ld	s5,72(sp)
    5800:	6b06                	ld	s6,64(sp)
    5802:	7be2                	ld	s7,56(sp)
    5804:	7c42                	ld	s8,48(sp)
    5806:	7ca2                	ld	s9,40(sp)
    5808:	7d02                	ld	s10,32(sp)
    580a:	6de2                	ld	s11,24(sp)
    580c:	6109                	addi	sp,sp,128
    580e:	8082                	ret

0000000000005810 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5810:	715d                	addi	sp,sp,-80
    5812:	ec06                	sd	ra,24(sp)
    5814:	e822                	sd	s0,16(sp)
    5816:	1000                	addi	s0,sp,32
    5818:	e010                	sd	a2,0(s0)
    581a:	e414                	sd	a3,8(s0)
    581c:	e818                	sd	a4,16(s0)
    581e:	ec1c                	sd	a5,24(s0)
    5820:	03043023          	sd	a6,32(s0)
    5824:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5828:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    582c:	8622                	mv	a2,s0
    582e:	00000097          	auipc	ra,0x0
    5832:	e04080e7          	jalr	-508(ra) # 5632 <vprintf>
}
    5836:	60e2                	ld	ra,24(sp)
    5838:	6442                	ld	s0,16(sp)
    583a:	6161                	addi	sp,sp,80
    583c:	8082                	ret

000000000000583e <printf>:

void
printf(const char *fmt, ...)
{
    583e:	711d                	addi	sp,sp,-96
    5840:	ec06                	sd	ra,24(sp)
    5842:	e822                	sd	s0,16(sp)
    5844:	1000                	addi	s0,sp,32
    5846:	e40c                	sd	a1,8(s0)
    5848:	e810                	sd	a2,16(s0)
    584a:	ec14                	sd	a3,24(s0)
    584c:	f018                	sd	a4,32(s0)
    584e:	f41c                	sd	a5,40(s0)
    5850:	03043823          	sd	a6,48(s0)
    5854:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5858:	00840613          	addi	a2,s0,8
    585c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5860:	85aa                	mv	a1,a0
    5862:	4505                	li	a0,1
    5864:	00000097          	auipc	ra,0x0
    5868:	dce080e7          	jalr	-562(ra) # 5632 <vprintf>
}
    586c:	60e2                	ld	ra,24(sp)
    586e:	6442                	ld	s0,16(sp)
    5870:	6125                	addi	sp,sp,96
    5872:	8082                	ret

0000000000005874 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5874:	1141                	addi	sp,sp,-16
    5876:	e422                	sd	s0,8(sp)
    5878:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    587a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    587e:	00003797          	auipc	a5,0x3
    5882:	8827b783          	ld	a5,-1918(a5) # 8100 <freep>
    5886:	a805                	j	58b6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5888:	4618                	lw	a4,8(a2)
    588a:	9db9                	addw	a1,a1,a4
    588c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5890:	6398                	ld	a4,0(a5)
    5892:	6318                	ld	a4,0(a4)
    5894:	fee53823          	sd	a4,-16(a0)
    5898:	a091                	j	58dc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    589a:	ff852703          	lw	a4,-8(a0)
    589e:	9e39                	addw	a2,a2,a4
    58a0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    58a2:	ff053703          	ld	a4,-16(a0)
    58a6:	e398                	sd	a4,0(a5)
    58a8:	a099                	j	58ee <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    58aa:	6398                	ld	a4,0(a5)
    58ac:	00e7e463          	bltu	a5,a4,58b4 <free+0x40>
    58b0:	00e6ea63          	bltu	a3,a4,58c4 <free+0x50>
{
    58b4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    58b6:	fed7fae3          	bgeu	a5,a3,58aa <free+0x36>
    58ba:	6398                	ld	a4,0(a5)
    58bc:	00e6e463          	bltu	a3,a4,58c4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    58c0:	fee7eae3          	bltu	a5,a4,58b4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    58c4:	ff852583          	lw	a1,-8(a0)
    58c8:	6390                	ld	a2,0(a5)
    58ca:	02059713          	slli	a4,a1,0x20
    58ce:	9301                	srli	a4,a4,0x20
    58d0:	0712                	slli	a4,a4,0x4
    58d2:	9736                	add	a4,a4,a3
    58d4:	fae60ae3          	beq	a2,a4,5888 <free+0x14>
    bp->s.ptr = p->s.ptr;
    58d8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    58dc:	4790                	lw	a2,8(a5)
    58de:	02061713          	slli	a4,a2,0x20
    58e2:	9301                	srli	a4,a4,0x20
    58e4:	0712                	slli	a4,a4,0x4
    58e6:	973e                	add	a4,a4,a5
    58e8:	fae689e3          	beq	a3,a4,589a <free+0x26>
  } else
    p->s.ptr = bp;
    58ec:	e394                	sd	a3,0(a5)
  freep = p;
    58ee:	00003717          	auipc	a4,0x3
    58f2:	80f73923          	sd	a5,-2030(a4) # 8100 <freep>
}
    58f6:	6422                	ld	s0,8(sp)
    58f8:	0141                	addi	sp,sp,16
    58fa:	8082                	ret

00000000000058fc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    58fc:	7139                	addi	sp,sp,-64
    58fe:	fc06                	sd	ra,56(sp)
    5900:	f822                	sd	s0,48(sp)
    5902:	f426                	sd	s1,40(sp)
    5904:	f04a                	sd	s2,32(sp)
    5906:	ec4e                	sd	s3,24(sp)
    5908:	e852                	sd	s4,16(sp)
    590a:	e456                	sd	s5,8(sp)
    590c:	e05a                	sd	s6,0(sp)
    590e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5910:	02051493          	slli	s1,a0,0x20
    5914:	9081                	srli	s1,s1,0x20
    5916:	04bd                	addi	s1,s1,15
    5918:	8091                	srli	s1,s1,0x4
    591a:	0014899b          	addiw	s3,s1,1
    591e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5920:	00002517          	auipc	a0,0x2
    5924:	7e053503          	ld	a0,2016(a0) # 8100 <freep>
    5928:	c515                	beqz	a0,5954 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    592a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    592c:	4798                	lw	a4,8(a5)
    592e:	02977f63          	bgeu	a4,s1,596c <malloc+0x70>
    5932:	8a4e                	mv	s4,s3
    5934:	0009871b          	sext.w	a4,s3
    5938:	6685                	lui	a3,0x1
    593a:	00d77363          	bgeu	a4,a3,5940 <malloc+0x44>
    593e:	6a05                	lui	s4,0x1
    5940:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5944:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5948:	00002917          	auipc	s2,0x2
    594c:	7b890913          	addi	s2,s2,1976 # 8100 <freep>
  if(p == (char*)-1)
    5950:	5afd                	li	s5,-1
    5952:	a88d                	j	59c4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    5954:	00009797          	auipc	a5,0x9
    5958:	fcc78793          	addi	a5,a5,-52 # e920 <base>
    595c:	00002717          	auipc	a4,0x2
    5960:	7af73223          	sd	a5,1956(a4) # 8100 <freep>
    5964:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5966:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    596a:	b7e1                	j	5932 <malloc+0x36>
      if(p->s.size == nunits)
    596c:	02e48b63          	beq	s1,a4,59a2 <malloc+0xa6>
        p->s.size -= nunits;
    5970:	4137073b          	subw	a4,a4,s3
    5974:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5976:	1702                	slli	a4,a4,0x20
    5978:	9301                	srli	a4,a4,0x20
    597a:	0712                	slli	a4,a4,0x4
    597c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    597e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5982:	00002717          	auipc	a4,0x2
    5986:	76a73f23          	sd	a0,1918(a4) # 8100 <freep>
      return (void*)(p + 1);
    598a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    598e:	70e2                	ld	ra,56(sp)
    5990:	7442                	ld	s0,48(sp)
    5992:	74a2                	ld	s1,40(sp)
    5994:	7902                	ld	s2,32(sp)
    5996:	69e2                	ld	s3,24(sp)
    5998:	6a42                	ld	s4,16(sp)
    599a:	6aa2                	ld	s5,8(sp)
    599c:	6b02                	ld	s6,0(sp)
    599e:	6121                	addi	sp,sp,64
    59a0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    59a2:	6398                	ld	a4,0(a5)
    59a4:	e118                	sd	a4,0(a0)
    59a6:	bff1                	j	5982 <malloc+0x86>
  hp->s.size = nu;
    59a8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    59ac:	0541                	addi	a0,a0,16
    59ae:	00000097          	auipc	ra,0x0
    59b2:	ec6080e7          	jalr	-314(ra) # 5874 <free>
  return freep;
    59b6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    59ba:	d971                	beqz	a0,598e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    59bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    59be:	4798                	lw	a4,8(a5)
    59c0:	fa9776e3          	bgeu	a4,s1,596c <malloc+0x70>
    if(p == freep)
    59c4:	00093703          	ld	a4,0(s2)
    59c8:	853e                	mv	a0,a5
    59ca:	fef719e3          	bne	a4,a5,59bc <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    59ce:	8552                	mv	a0,s4
    59d0:	00000097          	auipc	ra,0x0
    59d4:	b7e080e7          	jalr	-1154(ra) # 554e <sbrk>
  if(p == (char*)-1)
    59d8:	fd5518e3          	bne	a0,s5,59a8 <malloc+0xac>
        return 0;
    59dc:	4501                	li	a0,0
    59de:	bf45                	j	598e <malloc+0x92>
