
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
      14:	518080e7          	jalr	1304(ra) # 5528 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	506080e7          	jalr	1286(ra) # 5528 <open>
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
      42:	cd250513          	addi	a0,a0,-814 # 5d10 <malloc+0x3f2>
      46:	00006097          	auipc	ra,0x6
      4a:	81a080e7          	jalr	-2022(ra) # 5860 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	498080e7          	jalr	1176(ra) # 54e8 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	20078793          	addi	a5,a5,512 # 9258 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	90868693          	addi	a3,a3,-1784 # b968 <buf>
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
      84:	cb050513          	addi	a0,a0,-848 # 5d30 <malloc+0x412>
      88:	00005097          	auipc	ra,0x5
      8c:	7d8080e7          	jalr	2008(ra) # 5860 <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	456080e7          	jalr	1110(ra) # 54e8 <exit>

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
      ac:	ca050513          	addi	a0,a0,-864 # 5d48 <malloc+0x42a>
      b0:	00005097          	auipc	ra,0x5
      b4:	478080e7          	jalr	1144(ra) # 5528 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	454080e7          	jalr	1108(ra) # 5510 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	ca250513          	addi	a0,a0,-862 # 5d68 <malloc+0x44a>
      ce:	00005097          	auipc	ra,0x5
      d2:	45a080e7          	jalr	1114(ra) # 5528 <open>
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
      ea:	c6a50513          	addi	a0,a0,-918 # 5d50 <malloc+0x432>
      ee:	00005097          	auipc	ra,0x5
      f2:	772080e7          	jalr	1906(ra) # 5860 <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	3f0080e7          	jalr	1008(ra) # 54e8 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	c7650513          	addi	a0,a0,-906 # 5d78 <malloc+0x45a>
     10a:	00005097          	auipc	ra,0x5
     10e:	756080e7          	jalr	1878(ra) # 5860 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	3d4080e7          	jalr	980(ra) # 54e8 <exit>

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
     130:	c7450513          	addi	a0,a0,-908 # 5da0 <malloc+0x482>
     134:	00005097          	auipc	ra,0x5
     138:	404080e7          	jalr	1028(ra) # 5538 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	c6050513          	addi	a0,a0,-928 # 5da0 <malloc+0x482>
     148:	00005097          	auipc	ra,0x5
     14c:	3e0080e7          	jalr	992(ra) # 5528 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	c5c58593          	addi	a1,a1,-932 # 5db0 <malloc+0x492>
     15c:	00005097          	auipc	ra,0x5
     160:	3ac080e7          	jalr	940(ra) # 5508 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	c3850513          	addi	a0,a0,-968 # 5da0 <malloc+0x482>
     170:	00005097          	auipc	ra,0x5
     174:	3b8080e7          	jalr	952(ra) # 5528 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	c3c58593          	addi	a1,a1,-964 # 5db8 <malloc+0x49a>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	382080e7          	jalr	898(ra) # 5508 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	c0c50513          	addi	a0,a0,-1012 # 5da0 <malloc+0x482>
     19c:	00005097          	auipc	ra,0x5
     1a0:	39c080e7          	jalr	924(ra) # 5538 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	36a080e7          	jalr	874(ra) # 5510 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	360080e7          	jalr	864(ra) # 5510 <close>
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
     1ce:	bf650513          	addi	a0,a0,-1034 # 5dc0 <malloc+0x4a2>
     1d2:	00005097          	auipc	ra,0x5
     1d6:	68e080e7          	jalr	1678(ra) # 5860 <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	30c080e7          	jalr	780(ra) # 54e8 <exit>

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
     1f6:	f4e78793          	addi	a5,a5,-178 # 8140 <name>
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
     21e:	30e080e7          	jalr	782(ra) # 5528 <open>
    close(fd);
     222:	00005097          	auipc	ra,0x5
     226:	2ee080e7          	jalr	750(ra) # 5510 <close>
  for(i = 0; i < N; i++){
     22a:	2485                	addiw	s1,s1,1
     22c:	0ff4f493          	andi	s1,s1,255
     230:	ff3490e3          	bne	s1,s3,210 <createtest+0x2c>
  name[0] = 'a';
     234:	00008797          	auipc	a5,0x8
     238:	f0c78793          	addi	a5,a5,-244 # 8140 <name>
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
     25c:	2e0080e7          	jalr	736(ra) # 5538 <unlink>
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
     294:	93050513          	addi	a0,a0,-1744 # 5bc0 <malloc+0x2a2>
     298:	00005097          	auipc	ra,0x5
     29c:	2a0080e7          	jalr	672(ra) # 5538 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a4:	00006a97          	auipc	s5,0x6
     2a8:	91ca8a93          	addi	s5,s5,-1764 # 5bc0 <malloc+0x2a2>
      int cc = write(fd, buf, sz);
     2ac:	0000ba17          	auipc	s4,0xb
     2b0:	6bca0a13          	addi	s4,s4,1724 # b968 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2b4:	6b0d                	lui	s6,0x3
     2b6:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x395>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2ba:	20200593          	li	a1,514
     2be:	8556                	mv	a0,s5
     2c0:	00005097          	auipc	ra,0x5
     2c4:	268080e7          	jalr	616(ra) # 5528 <open>
     2c8:	892a                	mv	s2,a0
    if(fd < 0){
     2ca:	04054d63          	bltz	a0,324 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ce:	8626                	mv	a2,s1
     2d0:	85d2                	mv	a1,s4
     2d2:	00005097          	auipc	ra,0x5
     2d6:	236080e7          	jalr	566(ra) # 5508 <write>
     2da:	89aa                	mv	s3,a0
      if(cc != sz){
     2dc:	06a49463          	bne	s1,a0,344 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2e0:	8626                	mv	a2,s1
     2e2:	85d2                	mv	a1,s4
     2e4:	854a                	mv	a0,s2
     2e6:	00005097          	auipc	ra,0x5
     2ea:	222080e7          	jalr	546(ra) # 5508 <write>
      if(cc != sz){
     2ee:	04951963          	bne	a0,s1,340 <bigwrite+0xc8>
    close(fd);
     2f2:	854a                	mv	a0,s2
     2f4:	00005097          	auipc	ra,0x5
     2f8:	21c080e7          	jalr	540(ra) # 5510 <close>
    unlink("bigwrite");
     2fc:	8556                	mv	a0,s5
     2fe:	00005097          	auipc	ra,0x5
     302:	23a080e7          	jalr	570(ra) # 5538 <unlink>
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
     32a:	ac250513          	addi	a0,a0,-1342 # 5de8 <malloc+0x4ca>
     32e:	00005097          	auipc	ra,0x5
     332:	532080e7          	jalr	1330(ra) # 5860 <printf>
      exit(1);
     336:	4505                	li	a0,1
     338:	00005097          	auipc	ra,0x5
     33c:	1b0080e7          	jalr	432(ra) # 54e8 <exit>
     340:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     342:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     344:	86ce                	mv	a3,s3
     346:	8626                	mv	a2,s1
     348:	85de                	mv	a1,s7
     34a:	00006517          	auipc	a0,0x6
     34e:	abe50513          	addi	a0,a0,-1346 # 5e08 <malloc+0x4ea>
     352:	00005097          	auipc	ra,0x5
     356:	50e080e7          	jalr	1294(ra) # 5860 <printf>
        exit(1);
     35a:	4505                	li	a0,1
     35c:	00005097          	auipc	ra,0x5
     360:	18c080e7          	jalr	396(ra) # 54e8 <exit>

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
     38a:	a9aa0a13          	addi	s4,s4,-1382 # 5e20 <malloc+0x502>
    uint64 addr = addrs[ai];
     38e:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     392:	20100593          	li	a1,513
     396:	8552                	mv	a0,s4
     398:	00005097          	auipc	ra,0x5
     39c:	190080e7          	jalr	400(ra) # 5528 <open>
     3a0:	84aa                	mv	s1,a0
    if(fd < 0){
     3a2:	08054863          	bltz	a0,432 <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     3a6:	6609                	lui	a2,0x2
     3a8:	85ce                	mv	a1,s3
     3aa:	00005097          	auipc	ra,0x5
     3ae:	15e080e7          	jalr	350(ra) # 5508 <write>
    if(n >= 0){
     3b2:	08055d63          	bgez	a0,44c <copyin+0xe8>
    close(fd);
     3b6:	8526                	mv	a0,s1
     3b8:	00005097          	auipc	ra,0x5
     3bc:	158080e7          	jalr	344(ra) # 5510 <close>
    unlink("copyin1");
     3c0:	8552                	mv	a0,s4
     3c2:	00005097          	auipc	ra,0x5
     3c6:	176080e7          	jalr	374(ra) # 5538 <unlink>
    n = write(1, (char*)addr, 8192);
     3ca:	6609                	lui	a2,0x2
     3cc:	85ce                	mv	a1,s3
     3ce:	4505                	li	a0,1
     3d0:	00005097          	auipc	ra,0x5
     3d4:	138080e7          	jalr	312(ra) # 5508 <write>
    if(n > 0){
     3d8:	08a04963          	bgtz	a0,46a <copyin+0x106>
    if(pipe(fds) < 0){
     3dc:	fb840513          	addi	a0,s0,-72
     3e0:	00005097          	auipc	ra,0x5
     3e4:	118080e7          	jalr	280(ra) # 54f8 <pipe>
     3e8:	0a054063          	bltz	a0,488 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3ec:	6609                	lui	a2,0x2
     3ee:	85ce                	mv	a1,s3
     3f0:	fbc42503          	lw	a0,-68(s0)
     3f4:	00005097          	auipc	ra,0x5
     3f8:	114080e7          	jalr	276(ra) # 5508 <write>
    if(n > 0){
     3fc:	0aa04363          	bgtz	a0,4a2 <copyin+0x13e>
    close(fds[0]);
     400:	fb842503          	lw	a0,-72(s0)
     404:	00005097          	auipc	ra,0x5
     408:	10c080e7          	jalr	268(ra) # 5510 <close>
    close(fds[1]);
     40c:	fbc42503          	lw	a0,-68(s0)
     410:	00005097          	auipc	ra,0x5
     414:	100080e7          	jalr	256(ra) # 5510 <close>
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
     436:	9f650513          	addi	a0,a0,-1546 # 5e28 <malloc+0x50a>
     43a:	00005097          	auipc	ra,0x5
     43e:	426080e7          	jalr	1062(ra) # 5860 <printf>
      exit(1);
     442:	4505                	li	a0,1
     444:	00005097          	auipc	ra,0x5
     448:	0a4080e7          	jalr	164(ra) # 54e8 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     44c:	862a                	mv	a2,a0
     44e:	85ce                	mv	a1,s3
     450:	00006517          	auipc	a0,0x6
     454:	9f050513          	addi	a0,a0,-1552 # 5e40 <malloc+0x522>
     458:	00005097          	auipc	ra,0x5
     45c:	408080e7          	jalr	1032(ra) # 5860 <printf>
      exit(1);
     460:	4505                	li	a0,1
     462:	00005097          	auipc	ra,0x5
     466:	086080e7          	jalr	134(ra) # 54e8 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     46a:	862a                	mv	a2,a0
     46c:	85ce                	mv	a1,s3
     46e:	00006517          	auipc	a0,0x6
     472:	a0250513          	addi	a0,a0,-1534 # 5e70 <malloc+0x552>
     476:	00005097          	auipc	ra,0x5
     47a:	3ea080e7          	jalr	1002(ra) # 5860 <printf>
      exit(1);
     47e:	4505                	li	a0,1
     480:	00005097          	auipc	ra,0x5
     484:	068080e7          	jalr	104(ra) # 54e8 <exit>
      printf("pipe() failed\n");
     488:	00006517          	auipc	a0,0x6
     48c:	a1850513          	addi	a0,a0,-1512 # 5ea0 <malloc+0x582>
     490:	00005097          	auipc	ra,0x5
     494:	3d0080e7          	jalr	976(ra) # 5860 <printf>
      exit(1);
     498:	4505                	li	a0,1
     49a:	00005097          	auipc	ra,0x5
     49e:	04e080e7          	jalr	78(ra) # 54e8 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     4a2:	862a                	mv	a2,a0
     4a4:	85ce                	mv	a1,s3
     4a6:	00006517          	auipc	a0,0x6
     4aa:	a0a50513          	addi	a0,a0,-1526 # 5eb0 <malloc+0x592>
     4ae:	00005097          	auipc	ra,0x5
     4b2:	3b2080e7          	jalr	946(ra) # 5860 <printf>
      exit(1);
     4b6:	4505                	li	a0,1
     4b8:	00005097          	auipc	ra,0x5
     4bc:	030080e7          	jalr	48(ra) # 54e8 <exit>

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
     4e8:	9fca0a13          	addi	s4,s4,-1540 # 5ee0 <malloc+0x5c2>
    n = write(fds[1], "x", 1);
     4ec:	00006a97          	auipc	s5,0x6
     4f0:	8cca8a93          	addi	s5,s5,-1844 # 5db8 <malloc+0x49a>
    uint64 addr = addrs[ai];
     4f4:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4f8:	4581                	li	a1,0
     4fa:	8552                	mv	a0,s4
     4fc:	00005097          	auipc	ra,0x5
     500:	02c080e7          	jalr	44(ra) # 5528 <open>
     504:	84aa                	mv	s1,a0
    if(fd < 0){
     506:	08054663          	bltz	a0,592 <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     50a:	6609                	lui	a2,0x2
     50c:	85ce                	mv	a1,s3
     50e:	00005097          	auipc	ra,0x5
     512:	ff2080e7          	jalr	-14(ra) # 5500 <read>
    if(n > 0){
     516:	08a04b63          	bgtz	a0,5ac <copyout+0xec>
    close(fd);
     51a:	8526                	mv	a0,s1
     51c:	00005097          	auipc	ra,0x5
     520:	ff4080e7          	jalr	-12(ra) # 5510 <close>
    if(pipe(fds) < 0){
     524:	fa840513          	addi	a0,s0,-88
     528:	00005097          	auipc	ra,0x5
     52c:	fd0080e7          	jalr	-48(ra) # 54f8 <pipe>
     530:	08054d63          	bltz	a0,5ca <copyout+0x10a>
    n = write(fds[1], "x", 1);
     534:	4605                	li	a2,1
     536:	85d6                	mv	a1,s5
     538:	fac42503          	lw	a0,-84(s0)
     53c:	00005097          	auipc	ra,0x5
     540:	fcc080e7          	jalr	-52(ra) # 5508 <write>
    if(n != 1){
     544:	4785                	li	a5,1
     546:	08f51f63          	bne	a0,a5,5e4 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     54a:	6609                	lui	a2,0x2
     54c:	85ce                	mv	a1,s3
     54e:	fa842503          	lw	a0,-88(s0)
     552:	00005097          	auipc	ra,0x5
     556:	fae080e7          	jalr	-82(ra) # 5500 <read>
    if(n > 0){
     55a:	0aa04263          	bgtz	a0,5fe <copyout+0x13e>
    close(fds[0]);
     55e:	fa842503          	lw	a0,-88(s0)
     562:	00005097          	auipc	ra,0x5
     566:	fae080e7          	jalr	-82(ra) # 5510 <close>
    close(fds[1]);
     56a:	fac42503          	lw	a0,-84(s0)
     56e:	00005097          	auipc	ra,0x5
     572:	fa2080e7          	jalr	-94(ra) # 5510 <close>
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
     596:	95650513          	addi	a0,a0,-1706 # 5ee8 <malloc+0x5ca>
     59a:	00005097          	auipc	ra,0x5
     59e:	2c6080e7          	jalr	710(ra) # 5860 <printf>
      exit(1);
     5a2:	4505                	li	a0,1
     5a4:	00005097          	auipc	ra,0x5
     5a8:	f44080e7          	jalr	-188(ra) # 54e8 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ac:	862a                	mv	a2,a0
     5ae:	85ce                	mv	a1,s3
     5b0:	00006517          	auipc	a0,0x6
     5b4:	95050513          	addi	a0,a0,-1712 # 5f00 <malloc+0x5e2>
     5b8:	00005097          	auipc	ra,0x5
     5bc:	2a8080e7          	jalr	680(ra) # 5860 <printf>
      exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00005097          	auipc	ra,0x5
     5c6:	f26080e7          	jalr	-218(ra) # 54e8 <exit>
      printf("pipe() failed\n");
     5ca:	00006517          	auipc	a0,0x6
     5ce:	8d650513          	addi	a0,a0,-1834 # 5ea0 <malloc+0x582>
     5d2:	00005097          	auipc	ra,0x5
     5d6:	28e080e7          	jalr	654(ra) # 5860 <printf>
      exit(1);
     5da:	4505                	li	a0,1
     5dc:	00005097          	auipc	ra,0x5
     5e0:	f0c080e7          	jalr	-244(ra) # 54e8 <exit>
      printf("pipe write failed\n");
     5e4:	00006517          	auipc	a0,0x6
     5e8:	94c50513          	addi	a0,a0,-1716 # 5f30 <malloc+0x612>
     5ec:	00005097          	auipc	ra,0x5
     5f0:	274080e7          	jalr	628(ra) # 5860 <printf>
      exit(1);
     5f4:	4505                	li	a0,1
     5f6:	00005097          	auipc	ra,0x5
     5fa:	ef2080e7          	jalr	-270(ra) # 54e8 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5fe:	862a                	mv	a2,a0
     600:	85ce                	mv	a1,s3
     602:	00006517          	auipc	a0,0x6
     606:	94650513          	addi	a0,a0,-1722 # 5f48 <malloc+0x62a>
     60a:	00005097          	auipc	ra,0x5
     60e:	256080e7          	jalr	598(ra) # 5860 <printf>
      exit(1);
     612:	4505                	li	a0,1
     614:	00005097          	auipc	ra,0x5
     618:	ed4080e7          	jalr	-300(ra) # 54e8 <exit>

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
     634:	77050513          	addi	a0,a0,1904 # 5da0 <malloc+0x482>
     638:	00005097          	auipc	ra,0x5
     63c:	f00080e7          	jalr	-256(ra) # 5538 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     640:	60100593          	li	a1,1537
     644:	00005517          	auipc	a0,0x5
     648:	75c50513          	addi	a0,a0,1884 # 5da0 <malloc+0x482>
     64c:	00005097          	auipc	ra,0x5
     650:	edc080e7          	jalr	-292(ra) # 5528 <open>
     654:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     656:	4611                	li	a2,4
     658:	00005597          	auipc	a1,0x5
     65c:	75858593          	addi	a1,a1,1880 # 5db0 <malloc+0x492>
     660:	00005097          	auipc	ra,0x5
     664:	ea8080e7          	jalr	-344(ra) # 5508 <write>
  close(fd1);
     668:	8526                	mv	a0,s1
     66a:	00005097          	auipc	ra,0x5
     66e:	ea6080e7          	jalr	-346(ra) # 5510 <close>
  int fd2 = open("truncfile", O_RDONLY);
     672:	4581                	li	a1,0
     674:	00005517          	auipc	a0,0x5
     678:	72c50513          	addi	a0,a0,1836 # 5da0 <malloc+0x482>
     67c:	00005097          	auipc	ra,0x5
     680:	eac080e7          	jalr	-340(ra) # 5528 <open>
     684:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     686:	02000613          	li	a2,32
     68a:	fa040593          	addi	a1,s0,-96
     68e:	00005097          	auipc	ra,0x5
     692:	e72080e7          	jalr	-398(ra) # 5500 <read>
  if(n != 4){
     696:	4791                	li	a5,4
     698:	0cf51e63          	bne	a0,a5,774 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     69c:	40100593          	li	a1,1025
     6a0:	00005517          	auipc	a0,0x5
     6a4:	70050513          	addi	a0,a0,1792 # 5da0 <malloc+0x482>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	e80080e7          	jalr	-384(ra) # 5528 <open>
     6b0:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     6b2:	4581                	li	a1,0
     6b4:	00005517          	auipc	a0,0x5
     6b8:	6ec50513          	addi	a0,a0,1772 # 5da0 <malloc+0x482>
     6bc:	00005097          	auipc	ra,0x5
     6c0:	e6c080e7          	jalr	-404(ra) # 5528 <open>
     6c4:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	00005097          	auipc	ra,0x5
     6d2:	e32080e7          	jalr	-462(ra) # 5500 <read>
     6d6:	8a2a                	mv	s4,a0
  if(n != 0){
     6d8:	ed4d                	bnez	a0,792 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6da:	02000613          	li	a2,32
     6de:	fa040593          	addi	a1,s0,-96
     6e2:	8526                	mv	a0,s1
     6e4:	00005097          	auipc	ra,0x5
     6e8:	e1c080e7          	jalr	-484(ra) # 5500 <read>
     6ec:	8a2a                	mv	s4,a0
  if(n != 0){
     6ee:	e971                	bnez	a0,7c2 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6f0:	4619                	li	a2,6
     6f2:	00006597          	auipc	a1,0x6
     6f6:	8e658593          	addi	a1,a1,-1818 # 5fd8 <malloc+0x6ba>
     6fa:	854e                	mv	a0,s3
     6fc:	00005097          	auipc	ra,0x5
     700:	e0c080e7          	jalr	-500(ra) # 5508 <write>
  n = read(fd3, buf, sizeof(buf));
     704:	02000613          	li	a2,32
     708:	fa040593          	addi	a1,s0,-96
     70c:	854a                	mv	a0,s2
     70e:	00005097          	auipc	ra,0x5
     712:	df2080e7          	jalr	-526(ra) # 5500 <read>
  if(n != 6){
     716:	4799                	li	a5,6
     718:	0cf51d63          	bne	a0,a5,7f2 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     71c:	02000613          	li	a2,32
     720:	fa040593          	addi	a1,s0,-96
     724:	8526                	mv	a0,s1
     726:	00005097          	auipc	ra,0x5
     72a:	dda080e7          	jalr	-550(ra) # 5500 <read>
  if(n != 2){
     72e:	4789                	li	a5,2
     730:	0ef51063          	bne	a0,a5,810 <truncate1+0x1f4>
  unlink("truncfile");
     734:	00005517          	auipc	a0,0x5
     738:	66c50513          	addi	a0,a0,1644 # 5da0 <malloc+0x482>
     73c:	00005097          	auipc	ra,0x5
     740:	dfc080e7          	jalr	-516(ra) # 5538 <unlink>
  close(fd1);
     744:	854e                	mv	a0,s3
     746:	00005097          	auipc	ra,0x5
     74a:	dca080e7          	jalr	-566(ra) # 5510 <close>
  close(fd2);
     74e:	8526                	mv	a0,s1
     750:	00005097          	auipc	ra,0x5
     754:	dc0080e7          	jalr	-576(ra) # 5510 <close>
  close(fd3);
     758:	854a                	mv	a0,s2
     75a:	00005097          	auipc	ra,0x5
     75e:	db6080e7          	jalr	-586(ra) # 5510 <close>
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
     778:	00006517          	auipc	a0,0x6
     77c:	80050513          	addi	a0,a0,-2048 # 5f78 <malloc+0x65a>
     780:	00005097          	auipc	ra,0x5
     784:	0e0080e7          	jalr	224(ra) # 5860 <printf>
    exit(1);
     788:	4505                	li	a0,1
     78a:	00005097          	auipc	ra,0x5
     78e:	d5e080e7          	jalr	-674(ra) # 54e8 <exit>
    printf("aaa fd3=%d\n", fd3);
     792:	85ca                	mv	a1,s2
     794:	00006517          	auipc	a0,0x6
     798:	80450513          	addi	a0,a0,-2044 # 5f98 <malloc+0x67a>
     79c:	00005097          	auipc	ra,0x5
     7a0:	0c4080e7          	jalr	196(ra) # 5860 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7a4:	8652                	mv	a2,s4
     7a6:	85d6                	mv	a1,s5
     7a8:	00006517          	auipc	a0,0x6
     7ac:	80050513          	addi	a0,a0,-2048 # 5fa8 <malloc+0x68a>
     7b0:	00005097          	auipc	ra,0x5
     7b4:	0b0080e7          	jalr	176(ra) # 5860 <printf>
    exit(1);
     7b8:	4505                	li	a0,1
     7ba:	00005097          	auipc	ra,0x5
     7be:	d2e080e7          	jalr	-722(ra) # 54e8 <exit>
    printf("bbb fd2=%d\n", fd2);
     7c2:	85a6                	mv	a1,s1
     7c4:	00006517          	auipc	a0,0x6
     7c8:	80450513          	addi	a0,a0,-2044 # 5fc8 <malloc+0x6aa>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	094080e7          	jalr	148(ra) # 5860 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7d4:	8652                	mv	a2,s4
     7d6:	85d6                	mv	a1,s5
     7d8:	00005517          	auipc	a0,0x5
     7dc:	7d050513          	addi	a0,a0,2000 # 5fa8 <malloc+0x68a>
     7e0:	00005097          	auipc	ra,0x5
     7e4:	080080e7          	jalr	128(ra) # 5860 <printf>
    exit(1);
     7e8:	4505                	li	a0,1
     7ea:	00005097          	auipc	ra,0x5
     7ee:	cfe080e7          	jalr	-770(ra) # 54e8 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7f2:	862a                	mv	a2,a0
     7f4:	85d6                	mv	a1,s5
     7f6:	00005517          	auipc	a0,0x5
     7fa:	7ea50513          	addi	a0,a0,2026 # 5fe0 <malloc+0x6c2>
     7fe:	00005097          	auipc	ra,0x5
     802:	062080e7          	jalr	98(ra) # 5860 <printf>
    exit(1);
     806:	4505                	li	a0,1
     808:	00005097          	auipc	ra,0x5
     80c:	ce0080e7          	jalr	-800(ra) # 54e8 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     810:	862a                	mv	a2,a0
     812:	85d6                	mv	a1,s5
     814:	00005517          	auipc	a0,0x5
     818:	7ec50513          	addi	a0,a0,2028 # 6000 <malloc+0x6e2>
     81c:	00005097          	auipc	ra,0x5
     820:	044080e7          	jalr	68(ra) # 5860 <printf>
    exit(1);
     824:	4505                	li	a0,1
     826:	00005097          	auipc	ra,0x5
     82a:	cc2080e7          	jalr	-830(ra) # 54e8 <exit>

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
     84c:	7d850513          	addi	a0,a0,2008 # 6020 <malloc+0x702>
     850:	00005097          	auipc	ra,0x5
     854:	cd8080e7          	jalr	-808(ra) # 5528 <open>
  if(fd < 0){
     858:	0a054d63          	bltz	a0,912 <writetest+0xe4>
     85c:	892a                	mv	s2,a0
     85e:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	00005997          	auipc	s3,0x5
     864:	7e898993          	addi	s3,s3,2024 # 6048 <malloc+0x72a>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     868:	00006a97          	auipc	s5,0x6
     86c:	818a8a93          	addi	s5,s5,-2024 # 6080 <malloc+0x762>
  for(i = 0; i < N; i++){
     870:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85ce                	mv	a1,s3
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	c8e080e7          	jalr	-882(ra) # 5508 <write>
     882:	47a9                	li	a5,10
     884:	0af51563          	bne	a0,a5,92e <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     888:	4629                	li	a2,10
     88a:	85d6                	mv	a1,s5
     88c:	854a                	mv	a0,s2
     88e:	00005097          	auipc	ra,0x5
     892:	c7a080e7          	jalr	-902(ra) # 5508 <write>
     896:	47a9                	li	a5,10
     898:	0af51963          	bne	a0,a5,94a <writetest+0x11c>
  for(i = 0; i < N; i++){
     89c:	2485                	addiw	s1,s1,1
     89e:	fd449be3          	bne	s1,s4,874 <writetest+0x46>
  close(fd);
     8a2:	854a                	mv	a0,s2
     8a4:	00005097          	auipc	ra,0x5
     8a8:	c6c080e7          	jalr	-916(ra) # 5510 <close>
  fd = open("small", O_RDONLY);
     8ac:	4581                	li	a1,0
     8ae:	00005517          	auipc	a0,0x5
     8b2:	77250513          	addi	a0,a0,1906 # 6020 <malloc+0x702>
     8b6:	00005097          	auipc	ra,0x5
     8ba:	c72080e7          	jalr	-910(ra) # 5528 <open>
     8be:	84aa                	mv	s1,a0
  if(fd < 0){
     8c0:	0a054363          	bltz	a0,966 <writetest+0x138>
  i = read(fd, buf, N*SZ*2);
     8c4:	7d000613          	li	a2,2000
     8c8:	0000b597          	auipc	a1,0xb
     8cc:	0a058593          	addi	a1,a1,160 # b968 <buf>
     8d0:	00005097          	auipc	ra,0x5
     8d4:	c30080e7          	jalr	-976(ra) # 5500 <read>
  if(i != N*SZ*2){
     8d8:	7d000793          	li	a5,2000
     8dc:	0af51363          	bne	a0,a5,982 <writetest+0x154>
  close(fd);
     8e0:	8526                	mv	a0,s1
     8e2:	00005097          	auipc	ra,0x5
     8e6:	c2e080e7          	jalr	-978(ra) # 5510 <close>
  if(unlink("small") < 0){
     8ea:	00005517          	auipc	a0,0x5
     8ee:	73650513          	addi	a0,a0,1846 # 6020 <malloc+0x702>
     8f2:	00005097          	auipc	ra,0x5
     8f6:	c46080e7          	jalr	-954(ra) # 5538 <unlink>
     8fa:	0a054263          	bltz	a0,99e <writetest+0x170>
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
     918:	71450513          	addi	a0,a0,1812 # 6028 <malloc+0x70a>
     91c:	00005097          	auipc	ra,0x5
     920:	f44080e7          	jalr	-188(ra) # 5860 <printf>
    exit(1);
     924:	4505                	li	a0,1
     926:	00005097          	auipc	ra,0x5
     92a:	bc2080e7          	jalr	-1086(ra) # 54e8 <exit>
      printf("%s: error: write aa %d new file failed\n", i);
     92e:	85a6                	mv	a1,s1
     930:	00005517          	auipc	a0,0x5
     934:	72850513          	addi	a0,a0,1832 # 6058 <malloc+0x73a>
     938:	00005097          	auipc	ra,0x5
     93c:	f28080e7          	jalr	-216(ra) # 5860 <printf>
      exit(1);
     940:	4505                	li	a0,1
     942:	00005097          	auipc	ra,0x5
     946:	ba6080e7          	jalr	-1114(ra) # 54e8 <exit>
      printf("%s: error: write bb %d new file failed\n", i);
     94a:	85a6                	mv	a1,s1
     94c:	00005517          	auipc	a0,0x5
     950:	74450513          	addi	a0,a0,1860 # 6090 <malloc+0x772>
     954:	00005097          	auipc	ra,0x5
     958:	f0c080e7          	jalr	-244(ra) # 5860 <printf>
      exit(1);
     95c:	4505                	li	a0,1
     95e:	00005097          	auipc	ra,0x5
     962:	b8a080e7          	jalr	-1142(ra) # 54e8 <exit>
    printf("%s: error: open small failed!\n", s);
     966:	85da                	mv	a1,s6
     968:	00005517          	auipc	a0,0x5
     96c:	75050513          	addi	a0,a0,1872 # 60b8 <malloc+0x79a>
     970:	00005097          	auipc	ra,0x5
     974:	ef0080e7          	jalr	-272(ra) # 5860 <printf>
    exit(1);
     978:	4505                	li	a0,1
     97a:	00005097          	auipc	ra,0x5
     97e:	b6e080e7          	jalr	-1170(ra) # 54e8 <exit>
    printf("%s: read failed\n", s);
     982:	85da                	mv	a1,s6
     984:	00005517          	auipc	a0,0x5
     988:	75450513          	addi	a0,a0,1876 # 60d8 <malloc+0x7ba>
     98c:	00005097          	auipc	ra,0x5
     990:	ed4080e7          	jalr	-300(ra) # 5860 <printf>
    exit(1);
     994:	4505                	li	a0,1
     996:	00005097          	auipc	ra,0x5
     99a:	b52080e7          	jalr	-1198(ra) # 54e8 <exit>
    printf("%s: unlink small failed\n", s);
     99e:	85da                	mv	a1,s6
     9a0:	00005517          	auipc	a0,0x5
     9a4:	75050513          	addi	a0,a0,1872 # 60f0 <malloc+0x7d2>
     9a8:	00005097          	auipc	ra,0x5
     9ac:	eb8080e7          	jalr	-328(ra) # 5860 <printf>
    exit(1);
     9b0:	4505                	li	a0,1
     9b2:	00005097          	auipc	ra,0x5
     9b6:	b36080e7          	jalr	-1226(ra) # 54e8 <exit>

00000000000009ba <writebig>:
{
     9ba:	7139                	addi	sp,sp,-64
     9bc:	fc06                	sd	ra,56(sp)
     9be:	f822                	sd	s0,48(sp)
     9c0:	f426                	sd	s1,40(sp)
     9c2:	f04a                	sd	s2,32(sp)
     9c4:	ec4e                	sd	s3,24(sp)
     9c6:	e852                	sd	s4,16(sp)
     9c8:	e456                	sd	s5,8(sp)
     9ca:	0080                	addi	s0,sp,64
     9cc:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9ce:	20200593          	li	a1,514
     9d2:	00005517          	auipc	a0,0x5
     9d6:	73e50513          	addi	a0,a0,1854 # 6110 <malloc+0x7f2>
     9da:	00005097          	auipc	ra,0x5
     9de:	b4e080e7          	jalr	-1202(ra) # 5528 <open>
     9e2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9e4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9e6:	0000b917          	auipc	s2,0xb
     9ea:	f8290913          	addi	s2,s2,-126 # b968 <buf>
  for(i = 0; i < MAXFILE; i++){
     9ee:	10c00a13          	li	s4,268
  if(fd < 0){
     9f2:	06054c63          	bltz	a0,a6a <writebig+0xb0>
    ((int*)buf)[0] = i;
     9f6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fa:	40000613          	li	a2,1024
     9fe:	85ca                	mv	a1,s2
     a00:	854e                	mv	a0,s3
     a02:	00005097          	auipc	ra,0x5
     a06:	b06080e7          	jalr	-1274(ra) # 5508 <write>
     a0a:	40000793          	li	a5,1024
     a0e:	06f51c63          	bne	a0,a5,a86 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a12:	2485                	addiw	s1,s1,1
     a14:	ff4491e3          	bne	s1,s4,9f6 <writebig+0x3c>
  close(fd);
     a18:	854e                	mv	a0,s3
     a1a:	00005097          	auipc	ra,0x5
     a1e:	af6080e7          	jalr	-1290(ra) # 5510 <close>
  fd = open("big", O_RDONLY);
     a22:	4581                	li	a1,0
     a24:	00005517          	auipc	a0,0x5
     a28:	6ec50513          	addi	a0,a0,1772 # 6110 <malloc+0x7f2>
     a2c:	00005097          	auipc	ra,0x5
     a30:	afc080e7          	jalr	-1284(ra) # 5528 <open>
     a34:	89aa                	mv	s3,a0
  n = 0;
     a36:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a38:	0000b917          	auipc	s2,0xb
     a3c:	f3090913          	addi	s2,s2,-208 # b968 <buf>
  if(fd < 0){
     a40:	06054163          	bltz	a0,aa2 <writebig+0xe8>
    i = read(fd, buf, BSIZE);
     a44:	40000613          	li	a2,1024
     a48:	85ca                	mv	a1,s2
     a4a:	854e                	mv	a0,s3
     a4c:	00005097          	auipc	ra,0x5
     a50:	ab4080e7          	jalr	-1356(ra) # 5500 <read>
    if(i == 0){
     a54:	c52d                	beqz	a0,abe <writebig+0x104>
    } else if(i != BSIZE){
     a56:	40000793          	li	a5,1024
     a5a:	0af51d63          	bne	a0,a5,b14 <writebig+0x15a>
    if(((int*)buf)[0] != n){
     a5e:	00092603          	lw	a2,0(s2)
     a62:	0c961763          	bne	a2,s1,b30 <writebig+0x176>
    n++;
     a66:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a68:	bff1                	j	a44 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a6a:	85d6                	mv	a1,s5
     a6c:	00005517          	auipc	a0,0x5
     a70:	6ac50513          	addi	a0,a0,1708 # 6118 <malloc+0x7fa>
     a74:	00005097          	auipc	ra,0x5
     a78:	dec080e7          	jalr	-532(ra) # 5860 <printf>
    exit(1);
     a7c:	4505                	li	a0,1
     a7e:	00005097          	auipc	ra,0x5
     a82:	a6a080e7          	jalr	-1430(ra) # 54e8 <exit>
      printf("%s: error: write big file failed\n", i);
     a86:	85a6                	mv	a1,s1
     a88:	00005517          	auipc	a0,0x5
     a8c:	6b050513          	addi	a0,a0,1712 # 6138 <malloc+0x81a>
     a90:	00005097          	auipc	ra,0x5
     a94:	dd0080e7          	jalr	-560(ra) # 5860 <printf>
      exit(1);
     a98:	4505                	li	a0,1
     a9a:	00005097          	auipc	ra,0x5
     a9e:	a4e080e7          	jalr	-1458(ra) # 54e8 <exit>
    printf("%s: error: open big failed!\n", s);
     aa2:	85d6                	mv	a1,s5
     aa4:	00005517          	auipc	a0,0x5
     aa8:	6bc50513          	addi	a0,a0,1724 # 6160 <malloc+0x842>
     aac:	00005097          	auipc	ra,0x5
     ab0:	db4080e7          	jalr	-588(ra) # 5860 <printf>
    exit(1);
     ab4:	4505                	li	a0,1
     ab6:	00005097          	auipc	ra,0x5
     aba:	a32080e7          	jalr	-1486(ra) # 54e8 <exit>
      if(n == MAXFILE - 1){
     abe:	10b00793          	li	a5,267
     ac2:	02f48a63          	beq	s1,a5,af6 <writebig+0x13c>
  close(fd);
     ac6:	854e                	mv	a0,s3
     ac8:	00005097          	auipc	ra,0x5
     acc:	a48080e7          	jalr	-1464(ra) # 5510 <close>
  if(unlink("big") < 0){
     ad0:	00005517          	auipc	a0,0x5
     ad4:	64050513          	addi	a0,a0,1600 # 6110 <malloc+0x7f2>
     ad8:	00005097          	auipc	ra,0x5
     adc:	a60080e7          	jalr	-1440(ra) # 5538 <unlink>
     ae0:	06054663          	bltz	a0,b4c <writebig+0x192>
}
     ae4:	70e2                	ld	ra,56(sp)
     ae6:	7442                	ld	s0,48(sp)
     ae8:	74a2                	ld	s1,40(sp)
     aea:	7902                	ld	s2,32(sp)
     aec:	69e2                	ld	s3,24(sp)
     aee:	6a42                	ld	s4,16(sp)
     af0:	6aa2                	ld	s5,8(sp)
     af2:	6121                	addi	sp,sp,64
     af4:	8082                	ret
        printf("%s: read only %d blocks from big", n);
     af6:	10b00593          	li	a1,267
     afa:	00005517          	auipc	a0,0x5
     afe:	68650513          	addi	a0,a0,1670 # 6180 <malloc+0x862>
     b02:	00005097          	auipc	ra,0x5
     b06:	d5e080e7          	jalr	-674(ra) # 5860 <printf>
        exit(1);
     b0a:	4505                	li	a0,1
     b0c:	00005097          	auipc	ra,0x5
     b10:	9dc080e7          	jalr	-1572(ra) # 54e8 <exit>
      printf("%s: read failed %d\n", i);
     b14:	85aa                	mv	a1,a0
     b16:	00005517          	auipc	a0,0x5
     b1a:	69250513          	addi	a0,a0,1682 # 61a8 <malloc+0x88a>
     b1e:	00005097          	auipc	ra,0x5
     b22:	d42080e7          	jalr	-702(ra) # 5860 <printf>
      exit(1);
     b26:	4505                	li	a0,1
     b28:	00005097          	auipc	ra,0x5
     b2c:	9c0080e7          	jalr	-1600(ra) # 54e8 <exit>
      printf("%s: read content of block %d is %d\n",
     b30:	85a6                	mv	a1,s1
     b32:	00005517          	auipc	a0,0x5
     b36:	68e50513          	addi	a0,a0,1678 # 61c0 <malloc+0x8a2>
     b3a:	00005097          	auipc	ra,0x5
     b3e:	d26080e7          	jalr	-730(ra) # 5860 <printf>
      exit(1);
     b42:	4505                	li	a0,1
     b44:	00005097          	auipc	ra,0x5
     b48:	9a4080e7          	jalr	-1628(ra) # 54e8 <exit>
    printf("%s: unlink big failed\n", s);
     b4c:	85d6                	mv	a1,s5
     b4e:	00005517          	auipc	a0,0x5
     b52:	69a50513          	addi	a0,a0,1690 # 61e8 <malloc+0x8ca>
     b56:	00005097          	auipc	ra,0x5
     b5a:	d0a080e7          	jalr	-758(ra) # 5860 <printf>
    exit(1);
     b5e:	4505                	li	a0,1
     b60:	00005097          	auipc	ra,0x5
     b64:	988080e7          	jalr	-1656(ra) # 54e8 <exit>

0000000000000b68 <unlinkread>:
{
     b68:	7179                	addi	sp,sp,-48
     b6a:	f406                	sd	ra,40(sp)
     b6c:	f022                	sd	s0,32(sp)
     b6e:	ec26                	sd	s1,24(sp)
     b70:	e84a                	sd	s2,16(sp)
     b72:	e44e                	sd	s3,8(sp)
     b74:	1800                	addi	s0,sp,48
     b76:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b78:	20200593          	li	a1,514
     b7c:	00005517          	auipc	a0,0x5
     b80:	fdc50513          	addi	a0,a0,-36 # 5b58 <malloc+0x23a>
     b84:	00005097          	auipc	ra,0x5
     b88:	9a4080e7          	jalr	-1628(ra) # 5528 <open>
  if(fd < 0){
     b8c:	0e054563          	bltz	a0,c76 <unlinkread+0x10e>
     b90:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b92:	4615                	li	a2,5
     b94:	00005597          	auipc	a1,0x5
     b98:	68c58593          	addi	a1,a1,1676 # 6220 <malloc+0x902>
     b9c:	00005097          	auipc	ra,0x5
     ba0:	96c080e7          	jalr	-1684(ra) # 5508 <write>
  close(fd);
     ba4:	8526                	mv	a0,s1
     ba6:	00005097          	auipc	ra,0x5
     baa:	96a080e7          	jalr	-1686(ra) # 5510 <close>
  fd = open("unlinkread", O_RDWR);
     bae:	4589                	li	a1,2
     bb0:	00005517          	auipc	a0,0x5
     bb4:	fa850513          	addi	a0,a0,-88 # 5b58 <malloc+0x23a>
     bb8:	00005097          	auipc	ra,0x5
     bbc:	970080e7          	jalr	-1680(ra) # 5528 <open>
     bc0:	84aa                	mv	s1,a0
  if(fd < 0){
     bc2:	0c054863          	bltz	a0,c92 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bc6:	00005517          	auipc	a0,0x5
     bca:	f9250513          	addi	a0,a0,-110 # 5b58 <malloc+0x23a>
     bce:	00005097          	auipc	ra,0x5
     bd2:	96a080e7          	jalr	-1686(ra) # 5538 <unlink>
     bd6:	ed61                	bnez	a0,cae <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bd8:	20200593          	li	a1,514
     bdc:	00005517          	auipc	a0,0x5
     be0:	f7c50513          	addi	a0,a0,-132 # 5b58 <malloc+0x23a>
     be4:	00005097          	auipc	ra,0x5
     be8:	944080e7          	jalr	-1724(ra) # 5528 <open>
     bec:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     bee:	460d                	li	a2,3
     bf0:	00005597          	auipc	a1,0x5
     bf4:	67858593          	addi	a1,a1,1656 # 6268 <malloc+0x94a>
     bf8:	00005097          	auipc	ra,0x5
     bfc:	910080e7          	jalr	-1776(ra) # 5508 <write>
  close(fd1);
     c00:	854a                	mv	a0,s2
     c02:	00005097          	auipc	ra,0x5
     c06:	90e080e7          	jalr	-1778(ra) # 5510 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c0a:	660d                	lui	a2,0x3
     c0c:	0000b597          	auipc	a1,0xb
     c10:	d5c58593          	addi	a1,a1,-676 # b968 <buf>
     c14:	8526                	mv	a0,s1
     c16:	00005097          	auipc	ra,0x5
     c1a:	8ea080e7          	jalr	-1814(ra) # 5500 <read>
     c1e:	4795                	li	a5,5
     c20:	0af51563          	bne	a0,a5,cca <unlinkread+0x162>
  if(buf[0] != 'h'){
     c24:	0000b717          	auipc	a4,0xb
     c28:	d4474703          	lbu	a4,-700(a4) # b968 <buf>
     c2c:	06800793          	li	a5,104
     c30:	0af71b63          	bne	a4,a5,ce6 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c34:	4629                	li	a2,10
     c36:	0000b597          	auipc	a1,0xb
     c3a:	d3258593          	addi	a1,a1,-718 # b968 <buf>
     c3e:	8526                	mv	a0,s1
     c40:	00005097          	auipc	ra,0x5
     c44:	8c8080e7          	jalr	-1848(ra) # 5508 <write>
     c48:	47a9                	li	a5,10
     c4a:	0af51c63          	bne	a0,a5,d02 <unlinkread+0x19a>
  close(fd);
     c4e:	8526                	mv	a0,s1
     c50:	00005097          	auipc	ra,0x5
     c54:	8c0080e7          	jalr	-1856(ra) # 5510 <close>
  unlink("unlinkread");
     c58:	00005517          	auipc	a0,0x5
     c5c:	f0050513          	addi	a0,a0,-256 # 5b58 <malloc+0x23a>
     c60:	00005097          	auipc	ra,0x5
     c64:	8d8080e7          	jalr	-1832(ra) # 5538 <unlink>
}
     c68:	70a2                	ld	ra,40(sp)
     c6a:	7402                	ld	s0,32(sp)
     c6c:	64e2                	ld	s1,24(sp)
     c6e:	6942                	ld	s2,16(sp)
     c70:	69a2                	ld	s3,8(sp)
     c72:	6145                	addi	sp,sp,48
     c74:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c76:	85ce                	mv	a1,s3
     c78:	00005517          	auipc	a0,0x5
     c7c:	58850513          	addi	a0,a0,1416 # 6200 <malloc+0x8e2>
     c80:	00005097          	auipc	ra,0x5
     c84:	be0080e7          	jalr	-1056(ra) # 5860 <printf>
    exit(1);
     c88:	4505                	li	a0,1
     c8a:	00005097          	auipc	ra,0x5
     c8e:	85e080e7          	jalr	-1954(ra) # 54e8 <exit>
    printf("%s: open unlinkread failed\n", s);
     c92:	85ce                	mv	a1,s3
     c94:	00005517          	auipc	a0,0x5
     c98:	59450513          	addi	a0,a0,1428 # 6228 <malloc+0x90a>
     c9c:	00005097          	auipc	ra,0x5
     ca0:	bc4080e7          	jalr	-1084(ra) # 5860 <printf>
    exit(1);
     ca4:	4505                	li	a0,1
     ca6:	00005097          	auipc	ra,0x5
     caa:	842080e7          	jalr	-1982(ra) # 54e8 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     cae:	85ce                	mv	a1,s3
     cb0:	00005517          	auipc	a0,0x5
     cb4:	59850513          	addi	a0,a0,1432 # 6248 <malloc+0x92a>
     cb8:	00005097          	auipc	ra,0x5
     cbc:	ba8080e7          	jalr	-1112(ra) # 5860 <printf>
    exit(1);
     cc0:	4505                	li	a0,1
     cc2:	00005097          	auipc	ra,0x5
     cc6:	826080e7          	jalr	-2010(ra) # 54e8 <exit>
    printf("%s: unlinkread read failed", s);
     cca:	85ce                	mv	a1,s3
     ccc:	00005517          	auipc	a0,0x5
     cd0:	5a450513          	addi	a0,a0,1444 # 6270 <malloc+0x952>
     cd4:	00005097          	auipc	ra,0x5
     cd8:	b8c080e7          	jalr	-1140(ra) # 5860 <printf>
    exit(1);
     cdc:	4505                	li	a0,1
     cde:	00005097          	auipc	ra,0x5
     ce2:	80a080e7          	jalr	-2038(ra) # 54e8 <exit>
    printf("%s: unlinkread wrong data\n", s);
     ce6:	85ce                	mv	a1,s3
     ce8:	00005517          	auipc	a0,0x5
     cec:	5a850513          	addi	a0,a0,1448 # 6290 <malloc+0x972>
     cf0:	00005097          	auipc	ra,0x5
     cf4:	b70080e7          	jalr	-1168(ra) # 5860 <printf>
    exit(1);
     cf8:	4505                	li	a0,1
     cfa:	00004097          	auipc	ra,0x4
     cfe:	7ee080e7          	jalr	2030(ra) # 54e8 <exit>
    printf("%s: unlinkread write failed\n", s);
     d02:	85ce                	mv	a1,s3
     d04:	00005517          	auipc	a0,0x5
     d08:	5ac50513          	addi	a0,a0,1452 # 62b0 <malloc+0x992>
     d0c:	00005097          	auipc	ra,0x5
     d10:	b54080e7          	jalr	-1196(ra) # 5860 <printf>
    exit(1);
     d14:	4505                	li	a0,1
     d16:	00004097          	auipc	ra,0x4
     d1a:	7d2080e7          	jalr	2002(ra) # 54e8 <exit>

0000000000000d1e <linktest>:
{
     d1e:	1101                	addi	sp,sp,-32
     d20:	ec06                	sd	ra,24(sp)
     d22:	e822                	sd	s0,16(sp)
     d24:	e426                	sd	s1,8(sp)
     d26:	e04a                	sd	s2,0(sp)
     d28:	1000                	addi	s0,sp,32
     d2a:	892a                	mv	s2,a0
  unlink("lf1");
     d2c:	00005517          	auipc	a0,0x5
     d30:	5a450513          	addi	a0,a0,1444 # 62d0 <malloc+0x9b2>
     d34:	00005097          	auipc	ra,0x5
     d38:	804080e7          	jalr	-2044(ra) # 5538 <unlink>
  unlink("lf2");
     d3c:	00005517          	auipc	a0,0x5
     d40:	59c50513          	addi	a0,a0,1436 # 62d8 <malloc+0x9ba>
     d44:	00004097          	auipc	ra,0x4
     d48:	7f4080e7          	jalr	2036(ra) # 5538 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d4c:	20200593          	li	a1,514
     d50:	00005517          	auipc	a0,0x5
     d54:	58050513          	addi	a0,a0,1408 # 62d0 <malloc+0x9b2>
     d58:	00004097          	auipc	ra,0x4
     d5c:	7d0080e7          	jalr	2000(ra) # 5528 <open>
  if(fd < 0){
     d60:	10054763          	bltz	a0,e6e <linktest+0x150>
     d64:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d66:	4615                	li	a2,5
     d68:	00005597          	auipc	a1,0x5
     d6c:	4b858593          	addi	a1,a1,1208 # 6220 <malloc+0x902>
     d70:	00004097          	auipc	ra,0x4
     d74:	798080e7          	jalr	1944(ra) # 5508 <write>
     d78:	4795                	li	a5,5
     d7a:	10f51863          	bne	a0,a5,e8a <linktest+0x16c>
  close(fd);
     d7e:	8526                	mv	a0,s1
     d80:	00004097          	auipc	ra,0x4
     d84:	790080e7          	jalr	1936(ra) # 5510 <close>
  if(link("lf1", "lf2") < 0){
     d88:	00005597          	auipc	a1,0x5
     d8c:	55058593          	addi	a1,a1,1360 # 62d8 <malloc+0x9ba>
     d90:	00005517          	auipc	a0,0x5
     d94:	54050513          	addi	a0,a0,1344 # 62d0 <malloc+0x9b2>
     d98:	00004097          	auipc	ra,0x4
     d9c:	7b0080e7          	jalr	1968(ra) # 5548 <link>
     da0:	10054363          	bltz	a0,ea6 <linktest+0x188>
  unlink("lf1");
     da4:	00005517          	auipc	a0,0x5
     da8:	52c50513          	addi	a0,a0,1324 # 62d0 <malloc+0x9b2>
     dac:	00004097          	auipc	ra,0x4
     db0:	78c080e7          	jalr	1932(ra) # 5538 <unlink>
  if(open("lf1", 0) >= 0){
     db4:	4581                	li	a1,0
     db6:	00005517          	auipc	a0,0x5
     dba:	51a50513          	addi	a0,a0,1306 # 62d0 <malloc+0x9b2>
     dbe:	00004097          	auipc	ra,0x4
     dc2:	76a080e7          	jalr	1898(ra) # 5528 <open>
     dc6:	0e055e63          	bgez	a0,ec2 <linktest+0x1a4>
  fd = open("lf2", 0);
     dca:	4581                	li	a1,0
     dcc:	00005517          	auipc	a0,0x5
     dd0:	50c50513          	addi	a0,a0,1292 # 62d8 <malloc+0x9ba>
     dd4:	00004097          	auipc	ra,0x4
     dd8:	754080e7          	jalr	1876(ra) # 5528 <open>
     ddc:	84aa                	mv	s1,a0
  if(fd < 0){
     dde:	10054063          	bltz	a0,ede <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     de2:	660d                	lui	a2,0x3
     de4:	0000b597          	auipc	a1,0xb
     de8:	b8458593          	addi	a1,a1,-1148 # b968 <buf>
     dec:	00004097          	auipc	ra,0x4
     df0:	714080e7          	jalr	1812(ra) # 5500 <read>
     df4:	4795                	li	a5,5
     df6:	10f51263          	bne	a0,a5,efa <linktest+0x1dc>
  close(fd);
     dfa:	8526                	mv	a0,s1
     dfc:	00004097          	auipc	ra,0x4
     e00:	714080e7          	jalr	1812(ra) # 5510 <close>
  if(link("lf2", "lf2") >= 0){
     e04:	00005597          	auipc	a1,0x5
     e08:	4d458593          	addi	a1,a1,1236 # 62d8 <malloc+0x9ba>
     e0c:	852e                	mv	a0,a1
     e0e:	00004097          	auipc	ra,0x4
     e12:	73a080e7          	jalr	1850(ra) # 5548 <link>
     e16:	10055063          	bgez	a0,f16 <linktest+0x1f8>
  unlink("lf2");
     e1a:	00005517          	auipc	a0,0x5
     e1e:	4be50513          	addi	a0,a0,1214 # 62d8 <malloc+0x9ba>
     e22:	00004097          	auipc	ra,0x4
     e26:	716080e7          	jalr	1814(ra) # 5538 <unlink>
  if(link("lf2", "lf1") >= 0){
     e2a:	00005597          	auipc	a1,0x5
     e2e:	4a658593          	addi	a1,a1,1190 # 62d0 <malloc+0x9b2>
     e32:	00005517          	auipc	a0,0x5
     e36:	4a650513          	addi	a0,a0,1190 # 62d8 <malloc+0x9ba>
     e3a:	00004097          	auipc	ra,0x4
     e3e:	70e080e7          	jalr	1806(ra) # 5548 <link>
     e42:	0e055863          	bgez	a0,f32 <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e46:	00005597          	auipc	a1,0x5
     e4a:	48a58593          	addi	a1,a1,1162 # 62d0 <malloc+0x9b2>
     e4e:	00005517          	auipc	a0,0x5
     e52:	59250513          	addi	a0,a0,1426 # 63e0 <malloc+0xac2>
     e56:	00004097          	auipc	ra,0x4
     e5a:	6f2080e7          	jalr	1778(ra) # 5548 <link>
     e5e:	0e055863          	bgez	a0,f4e <linktest+0x230>
}
     e62:	60e2                	ld	ra,24(sp)
     e64:	6442                	ld	s0,16(sp)
     e66:	64a2                	ld	s1,8(sp)
     e68:	6902                	ld	s2,0(sp)
     e6a:	6105                	addi	sp,sp,32
     e6c:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e6e:	85ca                	mv	a1,s2
     e70:	00005517          	auipc	a0,0x5
     e74:	47050513          	addi	a0,a0,1136 # 62e0 <malloc+0x9c2>
     e78:	00005097          	auipc	ra,0x5
     e7c:	9e8080e7          	jalr	-1560(ra) # 5860 <printf>
    exit(1);
     e80:	4505                	li	a0,1
     e82:	00004097          	auipc	ra,0x4
     e86:	666080e7          	jalr	1638(ra) # 54e8 <exit>
    printf("%s: write lf1 failed\n", s);
     e8a:	85ca                	mv	a1,s2
     e8c:	00005517          	auipc	a0,0x5
     e90:	46c50513          	addi	a0,a0,1132 # 62f8 <malloc+0x9da>
     e94:	00005097          	auipc	ra,0x5
     e98:	9cc080e7          	jalr	-1588(ra) # 5860 <printf>
    exit(1);
     e9c:	4505                	li	a0,1
     e9e:	00004097          	auipc	ra,0x4
     ea2:	64a080e7          	jalr	1610(ra) # 54e8 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     ea6:	85ca                	mv	a1,s2
     ea8:	00005517          	auipc	a0,0x5
     eac:	46850513          	addi	a0,a0,1128 # 6310 <malloc+0x9f2>
     eb0:	00005097          	auipc	ra,0x5
     eb4:	9b0080e7          	jalr	-1616(ra) # 5860 <printf>
    exit(1);
     eb8:	4505                	li	a0,1
     eba:	00004097          	auipc	ra,0x4
     ebe:	62e080e7          	jalr	1582(ra) # 54e8 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     ec2:	85ca                	mv	a1,s2
     ec4:	00005517          	auipc	a0,0x5
     ec8:	46c50513          	addi	a0,a0,1132 # 6330 <malloc+0xa12>
     ecc:	00005097          	auipc	ra,0x5
     ed0:	994080e7          	jalr	-1644(ra) # 5860 <printf>
    exit(1);
     ed4:	4505                	li	a0,1
     ed6:	00004097          	auipc	ra,0x4
     eda:	612080e7          	jalr	1554(ra) # 54e8 <exit>
    printf("%s: open lf2 failed\n", s);
     ede:	85ca                	mv	a1,s2
     ee0:	00005517          	auipc	a0,0x5
     ee4:	48050513          	addi	a0,a0,1152 # 6360 <malloc+0xa42>
     ee8:	00005097          	auipc	ra,0x5
     eec:	978080e7          	jalr	-1672(ra) # 5860 <printf>
    exit(1);
     ef0:	4505                	li	a0,1
     ef2:	00004097          	auipc	ra,0x4
     ef6:	5f6080e7          	jalr	1526(ra) # 54e8 <exit>
    printf("%s: read lf2 failed\n", s);
     efa:	85ca                	mv	a1,s2
     efc:	00005517          	auipc	a0,0x5
     f00:	47c50513          	addi	a0,a0,1148 # 6378 <malloc+0xa5a>
     f04:	00005097          	auipc	ra,0x5
     f08:	95c080e7          	jalr	-1700(ra) # 5860 <printf>
    exit(1);
     f0c:	4505                	li	a0,1
     f0e:	00004097          	auipc	ra,0x4
     f12:	5da080e7          	jalr	1498(ra) # 54e8 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f16:	85ca                	mv	a1,s2
     f18:	00005517          	auipc	a0,0x5
     f1c:	47850513          	addi	a0,a0,1144 # 6390 <malloc+0xa72>
     f20:	00005097          	auipc	ra,0x5
     f24:	940080e7          	jalr	-1728(ra) # 5860 <printf>
    exit(1);
     f28:	4505                	li	a0,1
     f2a:	00004097          	auipc	ra,0x4
     f2e:	5be080e7          	jalr	1470(ra) # 54e8 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f32:	85ca                	mv	a1,s2
     f34:	00005517          	auipc	a0,0x5
     f38:	48450513          	addi	a0,a0,1156 # 63b8 <malloc+0xa9a>
     f3c:	00005097          	auipc	ra,0x5
     f40:	924080e7          	jalr	-1756(ra) # 5860 <printf>
    exit(1);
     f44:	4505                	li	a0,1
     f46:	00004097          	auipc	ra,0x4
     f4a:	5a2080e7          	jalr	1442(ra) # 54e8 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f4e:	85ca                	mv	a1,s2
     f50:	00005517          	auipc	a0,0x5
     f54:	49850513          	addi	a0,a0,1176 # 63e8 <malloc+0xaca>
     f58:	00005097          	auipc	ra,0x5
     f5c:	908080e7          	jalr	-1784(ra) # 5860 <printf>
    exit(1);
     f60:	4505                	li	a0,1
     f62:	00004097          	auipc	ra,0x4
     f66:	586080e7          	jalr	1414(ra) # 54e8 <exit>

0000000000000f6a <bigdir>:
{
     f6a:	715d                	addi	sp,sp,-80
     f6c:	e486                	sd	ra,72(sp)
     f6e:	e0a2                	sd	s0,64(sp)
     f70:	fc26                	sd	s1,56(sp)
     f72:	f84a                	sd	s2,48(sp)
     f74:	f44e                	sd	s3,40(sp)
     f76:	f052                	sd	s4,32(sp)
     f78:	ec56                	sd	s5,24(sp)
     f7a:	e85a                	sd	s6,16(sp)
     f7c:	0880                	addi	s0,sp,80
     f7e:	89aa                	mv	s3,a0
  unlink("bd");
     f80:	00005517          	auipc	a0,0x5
     f84:	48850513          	addi	a0,a0,1160 # 6408 <malloc+0xaea>
     f88:	00004097          	auipc	ra,0x4
     f8c:	5b0080e7          	jalr	1456(ra) # 5538 <unlink>
  fd = open("bd", O_CREATE);
     f90:	20000593          	li	a1,512
     f94:	00005517          	auipc	a0,0x5
     f98:	47450513          	addi	a0,a0,1140 # 6408 <malloc+0xaea>
     f9c:	00004097          	auipc	ra,0x4
     fa0:	58c080e7          	jalr	1420(ra) # 5528 <open>
  if(fd < 0){
     fa4:	0c054963          	bltz	a0,1076 <bigdir+0x10c>
  close(fd);
     fa8:	00004097          	auipc	ra,0x4
     fac:	568080e7          	jalr	1384(ra) # 5510 <close>
  for(i = 0; i < N; i++){
     fb0:	4901                	li	s2,0
    name[0] = 'x';
     fb2:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fb6:	00005a17          	auipc	s4,0x5
     fba:	452a0a13          	addi	s4,s4,1106 # 6408 <malloc+0xaea>
  for(i = 0; i < N; i++){
     fbe:	1f400b13          	li	s6,500
    name[0] = 'x';
     fc2:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fc6:	41f9579b          	sraiw	a5,s2,0x1f
     fca:	01a7d71b          	srliw	a4,a5,0x1a
     fce:	012707bb          	addw	a5,a4,s2
     fd2:	4067d69b          	sraiw	a3,a5,0x6
     fd6:	0306869b          	addiw	a3,a3,48
     fda:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fde:	03f7f793          	andi	a5,a5,63
     fe2:	9f99                	subw	a5,a5,a4
     fe4:	0307879b          	addiw	a5,a5,48
     fe8:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     fec:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     ff0:	fb040593          	addi	a1,s0,-80
     ff4:	8552                	mv	a0,s4
     ff6:	00004097          	auipc	ra,0x4
     ffa:	552080e7          	jalr	1362(ra) # 5548 <link>
     ffe:	84aa                	mv	s1,a0
    1000:	e949                	bnez	a0,1092 <bigdir+0x128>
  for(i = 0; i < N; i++){
    1002:	2905                	addiw	s2,s2,1
    1004:	fb691fe3          	bne	s2,s6,fc2 <bigdir+0x58>
  unlink("bd");
    1008:	00005517          	auipc	a0,0x5
    100c:	40050513          	addi	a0,a0,1024 # 6408 <malloc+0xaea>
    1010:	00004097          	auipc	ra,0x4
    1014:	528080e7          	jalr	1320(ra) # 5538 <unlink>
    name[0] = 'x';
    1018:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    101c:	1f400a13          	li	s4,500
    name[0] = 'x';
    1020:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1024:	41f4d79b          	sraiw	a5,s1,0x1f
    1028:	01a7d71b          	srliw	a4,a5,0x1a
    102c:	009707bb          	addw	a5,a4,s1
    1030:	4067d69b          	sraiw	a3,a5,0x6
    1034:	0306869b          	addiw	a3,a3,48
    1038:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    103c:	03f7f793          	andi	a5,a5,63
    1040:	9f99                	subw	a5,a5,a4
    1042:	0307879b          	addiw	a5,a5,48
    1046:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    104a:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    104e:	fb040513          	addi	a0,s0,-80
    1052:	00004097          	auipc	ra,0x4
    1056:	4e6080e7          	jalr	1254(ra) # 5538 <unlink>
    105a:	ed21                	bnez	a0,10b2 <bigdir+0x148>
  for(i = 0; i < N; i++){
    105c:	2485                	addiw	s1,s1,1
    105e:	fd4491e3          	bne	s1,s4,1020 <bigdir+0xb6>
}
    1062:	60a6                	ld	ra,72(sp)
    1064:	6406                	ld	s0,64(sp)
    1066:	74e2                	ld	s1,56(sp)
    1068:	7942                	ld	s2,48(sp)
    106a:	79a2                	ld	s3,40(sp)
    106c:	7a02                	ld	s4,32(sp)
    106e:	6ae2                	ld	s5,24(sp)
    1070:	6b42                	ld	s6,16(sp)
    1072:	6161                	addi	sp,sp,80
    1074:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1076:	85ce                	mv	a1,s3
    1078:	00005517          	auipc	a0,0x5
    107c:	39850513          	addi	a0,a0,920 # 6410 <malloc+0xaf2>
    1080:	00004097          	auipc	ra,0x4
    1084:	7e0080e7          	jalr	2016(ra) # 5860 <printf>
    exit(1);
    1088:	4505                	li	a0,1
    108a:	00004097          	auipc	ra,0x4
    108e:	45e080e7          	jalr	1118(ra) # 54e8 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    1092:	fb040613          	addi	a2,s0,-80
    1096:	85ce                	mv	a1,s3
    1098:	00005517          	auipc	a0,0x5
    109c:	39850513          	addi	a0,a0,920 # 6430 <malloc+0xb12>
    10a0:	00004097          	auipc	ra,0x4
    10a4:	7c0080e7          	jalr	1984(ra) # 5860 <printf>
      exit(1);
    10a8:	4505                	li	a0,1
    10aa:	00004097          	auipc	ra,0x4
    10ae:	43e080e7          	jalr	1086(ra) # 54e8 <exit>
      printf("%s: bigdir unlink failed", s);
    10b2:	85ce                	mv	a1,s3
    10b4:	00005517          	auipc	a0,0x5
    10b8:	39c50513          	addi	a0,a0,924 # 6450 <malloc+0xb32>
    10bc:	00004097          	auipc	ra,0x4
    10c0:	7a4080e7          	jalr	1956(ra) # 5860 <printf>
      exit(1);
    10c4:	4505                	li	a0,1
    10c6:	00004097          	auipc	ra,0x4
    10ca:	422080e7          	jalr	1058(ra) # 54e8 <exit>

00000000000010ce <validatetest>:
{
    10ce:	7139                	addi	sp,sp,-64
    10d0:	fc06                	sd	ra,56(sp)
    10d2:	f822                	sd	s0,48(sp)
    10d4:	f426                	sd	s1,40(sp)
    10d6:	f04a                	sd	s2,32(sp)
    10d8:	ec4e                	sd	s3,24(sp)
    10da:	e852                	sd	s4,16(sp)
    10dc:	e456                	sd	s5,8(sp)
    10de:	e05a                	sd	s6,0(sp)
    10e0:	0080                	addi	s0,sp,64
    10e2:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10e4:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10e6:	00005997          	auipc	s3,0x5
    10ea:	38a98993          	addi	s3,s3,906 # 6470 <malloc+0xb52>
    10ee:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10f0:	6a85                	lui	s5,0x1
    10f2:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    10f6:	85a6                	mv	a1,s1
    10f8:	854e                	mv	a0,s3
    10fa:	00004097          	auipc	ra,0x4
    10fe:	44e080e7          	jalr	1102(ra) # 5548 <link>
    1102:	01251f63          	bne	a0,s2,1120 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1106:	94d6                	add	s1,s1,s5
    1108:	ff4497e3          	bne	s1,s4,10f6 <validatetest+0x28>
}
    110c:	70e2                	ld	ra,56(sp)
    110e:	7442                	ld	s0,48(sp)
    1110:	74a2                	ld	s1,40(sp)
    1112:	7902                	ld	s2,32(sp)
    1114:	69e2                	ld	s3,24(sp)
    1116:	6a42                	ld	s4,16(sp)
    1118:	6aa2                	ld	s5,8(sp)
    111a:	6b02                	ld	s6,0(sp)
    111c:	6121                	addi	sp,sp,64
    111e:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1120:	85da                	mv	a1,s6
    1122:	00005517          	auipc	a0,0x5
    1126:	35e50513          	addi	a0,a0,862 # 6480 <malloc+0xb62>
    112a:	00004097          	auipc	ra,0x4
    112e:	736080e7          	jalr	1846(ra) # 5860 <printf>
      exit(1);
    1132:	4505                	li	a0,1
    1134:	00004097          	auipc	ra,0x4
    1138:	3b4080e7          	jalr	948(ra) # 54e8 <exit>

000000000000113c <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    113c:	7179                	addi	sp,sp,-48
    113e:	f406                	sd	ra,40(sp)
    1140:	f022                	sd	s0,32(sp)
    1142:	ec26                	sd	s1,24(sp)
    1144:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1146:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    114a:	00007497          	auipc	s1,0x7
    114e:	fe64b483          	ld	s1,-26(s1) # 8130 <__SDATA_BEGIN__>
    1152:	fd840593          	addi	a1,s0,-40
    1156:	8526                	mv	a0,s1
    1158:	00004097          	auipc	ra,0x4
    115c:	3c8080e7          	jalr	968(ra) # 5520 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    1160:	8526                	mv	a0,s1
    1162:	00004097          	auipc	ra,0x4
    1166:	396080e7          	jalr	918(ra) # 54f8 <pipe>

  exit(0);
    116a:	4501                	li	a0,0
    116c:	00004097          	auipc	ra,0x4
    1170:	37c080e7          	jalr	892(ra) # 54e8 <exit>

0000000000001174 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1174:	7139                	addi	sp,sp,-64
    1176:	fc06                	sd	ra,56(sp)
    1178:	f822                	sd	s0,48(sp)
    117a:	f426                	sd	s1,40(sp)
    117c:	f04a                	sd	s2,32(sp)
    117e:	ec4e                	sd	s3,24(sp)
    1180:	0080                	addi	s0,sp,64
    1182:	64b1                	lui	s1,0xc
    1184:	35048493          	addi	s1,s1,848 # c350 <buf+0x9e8>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1188:	597d                	li	s2,-1
    118a:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    118e:	00005997          	auipc	s3,0x5
    1192:	bba98993          	addi	s3,s3,-1094 # 5d48 <malloc+0x42a>
    argv[0] = (char*)0xffffffff;
    1196:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    119a:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    119e:	fc040593          	addi	a1,s0,-64
    11a2:	854e                	mv	a0,s3
    11a4:	00004097          	auipc	ra,0x4
    11a8:	37c080e7          	jalr	892(ra) # 5520 <exec>
  for(int i = 0; i < 50000; i++){
    11ac:	34fd                	addiw	s1,s1,-1
    11ae:	f4e5                	bnez	s1,1196 <badarg+0x22>
  }
  
  exit(0);
    11b0:	4501                	li	a0,0
    11b2:	00004097          	auipc	ra,0x4
    11b6:	336080e7          	jalr	822(ra) # 54e8 <exit>

00000000000011ba <copyinstr2>:
{
    11ba:	7155                	addi	sp,sp,-208
    11bc:	e586                	sd	ra,200(sp)
    11be:	e1a2                	sd	s0,192(sp)
    11c0:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11c2:	f6840793          	addi	a5,s0,-152
    11c6:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11ca:	07800713          	li	a4,120
    11ce:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11d2:	0785                	addi	a5,a5,1
    11d4:	fed79de3          	bne	a5,a3,11ce <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11d8:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11dc:	f6840513          	addi	a0,s0,-152
    11e0:	00004097          	auipc	ra,0x4
    11e4:	358080e7          	jalr	856(ra) # 5538 <unlink>
  if(ret != -1){
    11e8:	57fd                	li	a5,-1
    11ea:	0ef51063          	bne	a0,a5,12ca <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11ee:	20100593          	li	a1,513
    11f2:	f6840513          	addi	a0,s0,-152
    11f6:	00004097          	auipc	ra,0x4
    11fa:	332080e7          	jalr	818(ra) # 5528 <open>
  if(fd != -1){
    11fe:	57fd                	li	a5,-1
    1200:	0ef51563          	bne	a0,a5,12ea <copyinstr2+0x130>
  ret = link(b, b);
    1204:	f6840593          	addi	a1,s0,-152
    1208:	852e                	mv	a0,a1
    120a:	00004097          	auipc	ra,0x4
    120e:	33e080e7          	jalr	830(ra) # 5548 <link>
  if(ret != -1){
    1212:	57fd                	li	a5,-1
    1214:	0ef51b63          	bne	a0,a5,130a <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1218:	00006797          	auipc	a5,0x6
    121c:	3d078793          	addi	a5,a5,976 # 75e8 <malloc+0x1cca>
    1220:	f4f43c23          	sd	a5,-168(s0)
    1224:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1228:	f5840593          	addi	a1,s0,-168
    122c:	f6840513          	addi	a0,s0,-152
    1230:	00004097          	auipc	ra,0x4
    1234:	2f0080e7          	jalr	752(ra) # 5520 <exec>
  if(ret != -1){
    1238:	57fd                	li	a5,-1
    123a:	0ef51963          	bne	a0,a5,132c <copyinstr2+0x172>
  int pid = fork();
    123e:	00004097          	auipc	ra,0x4
    1242:	2a2080e7          	jalr	674(ra) # 54e0 <fork>
  if(pid < 0){
    1246:	10054363          	bltz	a0,134c <copyinstr2+0x192>
  if(pid == 0){
    124a:	12051463          	bnez	a0,1372 <copyinstr2+0x1b8>
    124e:	00007797          	auipc	a5,0x7
    1252:	00278793          	addi	a5,a5,2 # 8250 <big.0>
    1256:	00008697          	auipc	a3,0x8
    125a:	ffa68693          	addi	a3,a3,-6 # 9250 <__global_pointer$+0x920>
      big[i] = 'x';
    125e:	07800713          	li	a4,120
    1262:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1266:	0785                	addi	a5,a5,1
    1268:	fed79de3          	bne	a5,a3,1262 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    126c:	00008797          	auipc	a5,0x8
    1270:	fe078223          	sb	zero,-28(a5) # 9250 <__global_pointer$+0x920>
    char *args2[] = { big, big, big, 0 };
    1274:	00007797          	auipc	a5,0x7
    1278:	aec78793          	addi	a5,a5,-1300 # 7d60 <malloc+0x2442>
    127c:	6390                	ld	a2,0(a5)
    127e:	6794                	ld	a3,8(a5)
    1280:	6b98                	ld	a4,16(a5)
    1282:	6f9c                	ld	a5,24(a5)
    1284:	f2c43823          	sd	a2,-208(s0)
    1288:	f2d43c23          	sd	a3,-200(s0)
    128c:	f4e43023          	sd	a4,-192(s0)
    1290:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1294:	f3040593          	addi	a1,s0,-208
    1298:	00005517          	auipc	a0,0x5
    129c:	ab050513          	addi	a0,a0,-1360 # 5d48 <malloc+0x42a>
    12a0:	00004097          	auipc	ra,0x4
    12a4:	280080e7          	jalr	640(ra) # 5520 <exec>
    if(ret != -1){
    12a8:	57fd                	li	a5,-1
    12aa:	0af50e63          	beq	a0,a5,1366 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12ae:	55fd                	li	a1,-1
    12b0:	00005517          	auipc	a0,0x5
    12b4:	27850513          	addi	a0,a0,632 # 6528 <malloc+0xc0a>
    12b8:	00004097          	auipc	ra,0x4
    12bc:	5a8080e7          	jalr	1448(ra) # 5860 <printf>
      exit(1);
    12c0:	4505                	li	a0,1
    12c2:	00004097          	auipc	ra,0x4
    12c6:	226080e7          	jalr	550(ra) # 54e8 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12ca:	862a                	mv	a2,a0
    12cc:	f6840593          	addi	a1,s0,-152
    12d0:	00005517          	auipc	a0,0x5
    12d4:	1d050513          	addi	a0,a0,464 # 64a0 <malloc+0xb82>
    12d8:	00004097          	auipc	ra,0x4
    12dc:	588080e7          	jalr	1416(ra) # 5860 <printf>
    exit(1);
    12e0:	4505                	li	a0,1
    12e2:	00004097          	auipc	ra,0x4
    12e6:	206080e7          	jalr	518(ra) # 54e8 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12ea:	862a                	mv	a2,a0
    12ec:	f6840593          	addi	a1,s0,-152
    12f0:	00005517          	auipc	a0,0x5
    12f4:	1d050513          	addi	a0,a0,464 # 64c0 <malloc+0xba2>
    12f8:	00004097          	auipc	ra,0x4
    12fc:	568080e7          	jalr	1384(ra) # 5860 <printf>
    exit(1);
    1300:	4505                	li	a0,1
    1302:	00004097          	auipc	ra,0x4
    1306:	1e6080e7          	jalr	486(ra) # 54e8 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    130a:	86aa                	mv	a3,a0
    130c:	f6840613          	addi	a2,s0,-152
    1310:	85b2                	mv	a1,a2
    1312:	00005517          	auipc	a0,0x5
    1316:	1ce50513          	addi	a0,a0,462 # 64e0 <malloc+0xbc2>
    131a:	00004097          	auipc	ra,0x4
    131e:	546080e7          	jalr	1350(ra) # 5860 <printf>
    exit(1);
    1322:	4505                	li	a0,1
    1324:	00004097          	auipc	ra,0x4
    1328:	1c4080e7          	jalr	452(ra) # 54e8 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    132c:	567d                	li	a2,-1
    132e:	f6840593          	addi	a1,s0,-152
    1332:	00005517          	auipc	a0,0x5
    1336:	1d650513          	addi	a0,a0,470 # 6508 <malloc+0xbea>
    133a:	00004097          	auipc	ra,0x4
    133e:	526080e7          	jalr	1318(ra) # 5860 <printf>
    exit(1);
    1342:	4505                	li	a0,1
    1344:	00004097          	auipc	ra,0x4
    1348:	1a4080e7          	jalr	420(ra) # 54e8 <exit>
    printf("fork failed\n");
    134c:	00005517          	auipc	a0,0x5
    1350:	62450513          	addi	a0,a0,1572 # 6970 <malloc+0x1052>
    1354:	00004097          	auipc	ra,0x4
    1358:	50c080e7          	jalr	1292(ra) # 5860 <printf>
    exit(1);
    135c:	4505                	li	a0,1
    135e:	00004097          	auipc	ra,0x4
    1362:	18a080e7          	jalr	394(ra) # 54e8 <exit>
    exit(747); // OK
    1366:	2eb00513          	li	a0,747
    136a:	00004097          	auipc	ra,0x4
    136e:	17e080e7          	jalr	382(ra) # 54e8 <exit>
  int st = 0;
    1372:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1376:	f5440513          	addi	a0,s0,-172
    137a:	00004097          	auipc	ra,0x4
    137e:	176080e7          	jalr	374(ra) # 54f0 <wait>
  if(st != 747){
    1382:	f5442703          	lw	a4,-172(s0)
    1386:	2eb00793          	li	a5,747
    138a:	00f71663          	bne	a4,a5,1396 <copyinstr2+0x1dc>
}
    138e:	60ae                	ld	ra,200(sp)
    1390:	640e                	ld	s0,192(sp)
    1392:	6169                	addi	sp,sp,208
    1394:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    1396:	00005517          	auipc	a0,0x5
    139a:	1ba50513          	addi	a0,a0,442 # 6550 <malloc+0xc32>
    139e:	00004097          	auipc	ra,0x4
    13a2:	4c2080e7          	jalr	1218(ra) # 5860 <printf>
    exit(1);
    13a6:	4505                	li	a0,1
    13a8:	00004097          	auipc	ra,0x4
    13ac:	140080e7          	jalr	320(ra) # 54e8 <exit>

00000000000013b0 <truncate3>:
{
    13b0:	7159                	addi	sp,sp,-112
    13b2:	f486                	sd	ra,104(sp)
    13b4:	f0a2                	sd	s0,96(sp)
    13b6:	eca6                	sd	s1,88(sp)
    13b8:	e8ca                	sd	s2,80(sp)
    13ba:	e4ce                	sd	s3,72(sp)
    13bc:	e0d2                	sd	s4,64(sp)
    13be:	fc56                	sd	s5,56(sp)
    13c0:	1880                	addi	s0,sp,112
    13c2:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13c4:	60100593          	li	a1,1537
    13c8:	00005517          	auipc	a0,0x5
    13cc:	9d850513          	addi	a0,a0,-1576 # 5da0 <malloc+0x482>
    13d0:	00004097          	auipc	ra,0x4
    13d4:	158080e7          	jalr	344(ra) # 5528 <open>
    13d8:	00004097          	auipc	ra,0x4
    13dc:	138080e7          	jalr	312(ra) # 5510 <close>
  pid = fork();
    13e0:	00004097          	auipc	ra,0x4
    13e4:	100080e7          	jalr	256(ra) # 54e0 <fork>
  if(pid < 0){
    13e8:	08054063          	bltz	a0,1468 <truncate3+0xb8>
  if(pid == 0){
    13ec:	e969                	bnez	a0,14be <truncate3+0x10e>
    13ee:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    13f2:	00005a17          	auipc	s4,0x5
    13f6:	9aea0a13          	addi	s4,s4,-1618 # 5da0 <malloc+0x482>
      int n = write(fd, "1234567890", 10);
    13fa:	00005a97          	auipc	s5,0x5
    13fe:	1b6a8a93          	addi	s5,s5,438 # 65b0 <malloc+0xc92>
      int fd = open("truncfile", O_WRONLY);
    1402:	4585                	li	a1,1
    1404:	8552                	mv	a0,s4
    1406:	00004097          	auipc	ra,0x4
    140a:	122080e7          	jalr	290(ra) # 5528 <open>
    140e:	84aa                	mv	s1,a0
      if(fd < 0){
    1410:	06054a63          	bltz	a0,1484 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1414:	4629                	li	a2,10
    1416:	85d6                	mv	a1,s5
    1418:	00004097          	auipc	ra,0x4
    141c:	0f0080e7          	jalr	240(ra) # 5508 <write>
      if(n != 10){
    1420:	47a9                	li	a5,10
    1422:	06f51f63          	bne	a0,a5,14a0 <truncate3+0xf0>
      close(fd);
    1426:	8526                	mv	a0,s1
    1428:	00004097          	auipc	ra,0x4
    142c:	0e8080e7          	jalr	232(ra) # 5510 <close>
      fd = open("truncfile", O_RDONLY);
    1430:	4581                	li	a1,0
    1432:	8552                	mv	a0,s4
    1434:	00004097          	auipc	ra,0x4
    1438:	0f4080e7          	jalr	244(ra) # 5528 <open>
    143c:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    143e:	02000613          	li	a2,32
    1442:	f9840593          	addi	a1,s0,-104
    1446:	00004097          	auipc	ra,0x4
    144a:	0ba080e7          	jalr	186(ra) # 5500 <read>
      close(fd);
    144e:	8526                	mv	a0,s1
    1450:	00004097          	auipc	ra,0x4
    1454:	0c0080e7          	jalr	192(ra) # 5510 <close>
    for(int i = 0; i < 100; i++){
    1458:	39fd                	addiw	s3,s3,-1
    145a:	fa0994e3          	bnez	s3,1402 <truncate3+0x52>
    exit(0);
    145e:	4501                	li	a0,0
    1460:	00004097          	auipc	ra,0x4
    1464:	088080e7          	jalr	136(ra) # 54e8 <exit>
    printf("%s: fork failed\n", s);
    1468:	85ca                	mv	a1,s2
    146a:	00005517          	auipc	a0,0x5
    146e:	11650513          	addi	a0,a0,278 # 6580 <malloc+0xc62>
    1472:	00004097          	auipc	ra,0x4
    1476:	3ee080e7          	jalr	1006(ra) # 5860 <printf>
    exit(1);
    147a:	4505                	li	a0,1
    147c:	00004097          	auipc	ra,0x4
    1480:	06c080e7          	jalr	108(ra) # 54e8 <exit>
        printf("%s: open failed\n", s);
    1484:	85ca                	mv	a1,s2
    1486:	00005517          	auipc	a0,0x5
    148a:	11250513          	addi	a0,a0,274 # 6598 <malloc+0xc7a>
    148e:	00004097          	auipc	ra,0x4
    1492:	3d2080e7          	jalr	978(ra) # 5860 <printf>
        exit(1);
    1496:	4505                	li	a0,1
    1498:	00004097          	auipc	ra,0x4
    149c:	050080e7          	jalr	80(ra) # 54e8 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    14a0:	862a                	mv	a2,a0
    14a2:	85ca                	mv	a1,s2
    14a4:	00005517          	auipc	a0,0x5
    14a8:	11c50513          	addi	a0,a0,284 # 65c0 <malloc+0xca2>
    14ac:	00004097          	auipc	ra,0x4
    14b0:	3b4080e7          	jalr	948(ra) # 5860 <printf>
        exit(1);
    14b4:	4505                	li	a0,1
    14b6:	00004097          	auipc	ra,0x4
    14ba:	032080e7          	jalr	50(ra) # 54e8 <exit>
    14be:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14c2:	00005a17          	auipc	s4,0x5
    14c6:	8dea0a13          	addi	s4,s4,-1826 # 5da0 <malloc+0x482>
    int n = write(fd, "xxx", 3);
    14ca:	00005a97          	auipc	s5,0x5
    14ce:	116a8a93          	addi	s5,s5,278 # 65e0 <malloc+0xcc2>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14d2:	60100593          	li	a1,1537
    14d6:	8552                	mv	a0,s4
    14d8:	00004097          	auipc	ra,0x4
    14dc:	050080e7          	jalr	80(ra) # 5528 <open>
    14e0:	84aa                	mv	s1,a0
    if(fd < 0){
    14e2:	04054763          	bltz	a0,1530 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14e6:	460d                	li	a2,3
    14e8:	85d6                	mv	a1,s5
    14ea:	00004097          	auipc	ra,0x4
    14ee:	01e080e7          	jalr	30(ra) # 5508 <write>
    if(n != 3){
    14f2:	478d                	li	a5,3
    14f4:	04f51c63          	bne	a0,a5,154c <truncate3+0x19c>
    close(fd);
    14f8:	8526                	mv	a0,s1
    14fa:	00004097          	auipc	ra,0x4
    14fe:	016080e7          	jalr	22(ra) # 5510 <close>
  for(int i = 0; i < 150; i++){
    1502:	39fd                	addiw	s3,s3,-1
    1504:	fc0997e3          	bnez	s3,14d2 <truncate3+0x122>
  wait(&xstatus);
    1508:	fbc40513          	addi	a0,s0,-68
    150c:	00004097          	auipc	ra,0x4
    1510:	fe4080e7          	jalr	-28(ra) # 54f0 <wait>
  unlink("truncfile");
    1514:	00005517          	auipc	a0,0x5
    1518:	88c50513          	addi	a0,a0,-1908 # 5da0 <malloc+0x482>
    151c:	00004097          	auipc	ra,0x4
    1520:	01c080e7          	jalr	28(ra) # 5538 <unlink>
  exit(xstatus);
    1524:	fbc42503          	lw	a0,-68(s0)
    1528:	00004097          	auipc	ra,0x4
    152c:	fc0080e7          	jalr	-64(ra) # 54e8 <exit>
      printf("%s: open failed\n", s);
    1530:	85ca                	mv	a1,s2
    1532:	00005517          	auipc	a0,0x5
    1536:	06650513          	addi	a0,a0,102 # 6598 <malloc+0xc7a>
    153a:	00004097          	auipc	ra,0x4
    153e:	326080e7          	jalr	806(ra) # 5860 <printf>
      exit(1);
    1542:	4505                	li	a0,1
    1544:	00004097          	auipc	ra,0x4
    1548:	fa4080e7          	jalr	-92(ra) # 54e8 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    154c:	862a                	mv	a2,a0
    154e:	85ca                	mv	a1,s2
    1550:	00005517          	auipc	a0,0x5
    1554:	09850513          	addi	a0,a0,152 # 65e8 <malloc+0xcca>
    1558:	00004097          	auipc	ra,0x4
    155c:	308080e7          	jalr	776(ra) # 5860 <printf>
      exit(1);
    1560:	4505                	li	a0,1
    1562:	00004097          	auipc	ra,0x4
    1566:	f86080e7          	jalr	-122(ra) # 54e8 <exit>

000000000000156a <exectest>:
{
    156a:	715d                	addi	sp,sp,-80
    156c:	e486                	sd	ra,72(sp)
    156e:	e0a2                	sd	s0,64(sp)
    1570:	fc26                	sd	s1,56(sp)
    1572:	f84a                	sd	s2,48(sp)
    1574:	0880                	addi	s0,sp,80
    1576:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1578:	00004797          	auipc	a5,0x4
    157c:	7d078793          	addi	a5,a5,2000 # 5d48 <malloc+0x42a>
    1580:	fcf43023          	sd	a5,-64(s0)
    1584:	00005797          	auipc	a5,0x5
    1588:	08478793          	addi	a5,a5,132 # 6608 <malloc+0xcea>
    158c:	fcf43423          	sd	a5,-56(s0)
    1590:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    1594:	00005517          	auipc	a0,0x5
    1598:	07c50513          	addi	a0,a0,124 # 6610 <malloc+0xcf2>
    159c:	00004097          	auipc	ra,0x4
    15a0:	f9c080e7          	jalr	-100(ra) # 5538 <unlink>
  pid = fork();
    15a4:	00004097          	auipc	ra,0x4
    15a8:	f3c080e7          	jalr	-196(ra) # 54e0 <fork>
  if(pid < 0) {
    15ac:	04054663          	bltz	a0,15f8 <exectest+0x8e>
    15b0:	84aa                	mv	s1,a0
  if(pid == 0) {
    15b2:	e959                	bnez	a0,1648 <exectest+0xde>
    close(1);
    15b4:	4505                	li	a0,1
    15b6:	00004097          	auipc	ra,0x4
    15ba:	f5a080e7          	jalr	-166(ra) # 5510 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15be:	20100593          	li	a1,513
    15c2:	00005517          	auipc	a0,0x5
    15c6:	04e50513          	addi	a0,a0,78 # 6610 <malloc+0xcf2>
    15ca:	00004097          	auipc	ra,0x4
    15ce:	f5e080e7          	jalr	-162(ra) # 5528 <open>
    if(fd < 0) {
    15d2:	04054163          	bltz	a0,1614 <exectest+0xaa>
    if(fd != 1) {
    15d6:	4785                	li	a5,1
    15d8:	04f50c63          	beq	a0,a5,1630 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15dc:	85ca                	mv	a1,s2
    15de:	00005517          	auipc	a0,0x5
    15e2:	05250513          	addi	a0,a0,82 # 6630 <malloc+0xd12>
    15e6:	00004097          	auipc	ra,0x4
    15ea:	27a080e7          	jalr	634(ra) # 5860 <printf>
      exit(1);
    15ee:	4505                	li	a0,1
    15f0:	00004097          	auipc	ra,0x4
    15f4:	ef8080e7          	jalr	-264(ra) # 54e8 <exit>
     printf("%s: fork failed\n", s);
    15f8:	85ca                	mv	a1,s2
    15fa:	00005517          	auipc	a0,0x5
    15fe:	f8650513          	addi	a0,a0,-122 # 6580 <malloc+0xc62>
    1602:	00004097          	auipc	ra,0x4
    1606:	25e080e7          	jalr	606(ra) # 5860 <printf>
     exit(1);
    160a:	4505                	li	a0,1
    160c:	00004097          	auipc	ra,0x4
    1610:	edc080e7          	jalr	-292(ra) # 54e8 <exit>
      printf("%s: create failed\n", s);
    1614:	85ca                	mv	a1,s2
    1616:	00005517          	auipc	a0,0x5
    161a:	00250513          	addi	a0,a0,2 # 6618 <malloc+0xcfa>
    161e:	00004097          	auipc	ra,0x4
    1622:	242080e7          	jalr	578(ra) # 5860 <printf>
      exit(1);
    1626:	4505                	li	a0,1
    1628:	00004097          	auipc	ra,0x4
    162c:	ec0080e7          	jalr	-320(ra) # 54e8 <exit>
    if(exec("echo", echoargv) < 0){
    1630:	fc040593          	addi	a1,s0,-64
    1634:	00004517          	auipc	a0,0x4
    1638:	71450513          	addi	a0,a0,1812 # 5d48 <malloc+0x42a>
    163c:	00004097          	auipc	ra,0x4
    1640:	ee4080e7          	jalr	-284(ra) # 5520 <exec>
    1644:	02054163          	bltz	a0,1666 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1648:	fdc40513          	addi	a0,s0,-36
    164c:	00004097          	auipc	ra,0x4
    1650:	ea4080e7          	jalr	-348(ra) # 54f0 <wait>
    1654:	02951763          	bne	a0,s1,1682 <exectest+0x118>
  if(xstatus != 0)
    1658:	fdc42503          	lw	a0,-36(s0)
    165c:	cd0d                	beqz	a0,1696 <exectest+0x12c>
    exit(xstatus);
    165e:	00004097          	auipc	ra,0x4
    1662:	e8a080e7          	jalr	-374(ra) # 54e8 <exit>
      printf("%s: exec echo failed\n", s);
    1666:	85ca                	mv	a1,s2
    1668:	00005517          	auipc	a0,0x5
    166c:	fd850513          	addi	a0,a0,-40 # 6640 <malloc+0xd22>
    1670:	00004097          	auipc	ra,0x4
    1674:	1f0080e7          	jalr	496(ra) # 5860 <printf>
      exit(1);
    1678:	4505                	li	a0,1
    167a:	00004097          	auipc	ra,0x4
    167e:	e6e080e7          	jalr	-402(ra) # 54e8 <exit>
    printf("%s: wait failed!\n", s);
    1682:	85ca                	mv	a1,s2
    1684:	00005517          	auipc	a0,0x5
    1688:	fd450513          	addi	a0,a0,-44 # 6658 <malloc+0xd3a>
    168c:	00004097          	auipc	ra,0x4
    1690:	1d4080e7          	jalr	468(ra) # 5860 <printf>
    1694:	b7d1                	j	1658 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    1696:	4581                	li	a1,0
    1698:	00005517          	auipc	a0,0x5
    169c:	f7850513          	addi	a0,a0,-136 # 6610 <malloc+0xcf2>
    16a0:	00004097          	auipc	ra,0x4
    16a4:	e88080e7          	jalr	-376(ra) # 5528 <open>
  if(fd < 0) {
    16a8:	02054a63          	bltz	a0,16dc <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16ac:	4609                	li	a2,2
    16ae:	fb840593          	addi	a1,s0,-72
    16b2:	00004097          	auipc	ra,0x4
    16b6:	e4e080e7          	jalr	-434(ra) # 5500 <read>
    16ba:	4789                	li	a5,2
    16bc:	02f50e63          	beq	a0,a5,16f8 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16c0:	85ca                	mv	a1,s2
    16c2:	00005517          	auipc	a0,0x5
    16c6:	a1650513          	addi	a0,a0,-1514 # 60d8 <malloc+0x7ba>
    16ca:	00004097          	auipc	ra,0x4
    16ce:	196080e7          	jalr	406(ra) # 5860 <printf>
    exit(1);
    16d2:	4505                	li	a0,1
    16d4:	00004097          	auipc	ra,0x4
    16d8:	e14080e7          	jalr	-492(ra) # 54e8 <exit>
    printf("%s: open failed\n", s);
    16dc:	85ca                	mv	a1,s2
    16de:	00005517          	auipc	a0,0x5
    16e2:	eba50513          	addi	a0,a0,-326 # 6598 <malloc+0xc7a>
    16e6:	00004097          	auipc	ra,0x4
    16ea:	17a080e7          	jalr	378(ra) # 5860 <printf>
    exit(1);
    16ee:	4505                	li	a0,1
    16f0:	00004097          	auipc	ra,0x4
    16f4:	df8080e7          	jalr	-520(ra) # 54e8 <exit>
  unlink("echo-ok");
    16f8:	00005517          	auipc	a0,0x5
    16fc:	f1850513          	addi	a0,a0,-232 # 6610 <malloc+0xcf2>
    1700:	00004097          	auipc	ra,0x4
    1704:	e38080e7          	jalr	-456(ra) # 5538 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1708:	fb844703          	lbu	a4,-72(s0)
    170c:	04f00793          	li	a5,79
    1710:	00f71863          	bne	a4,a5,1720 <exectest+0x1b6>
    1714:	fb944703          	lbu	a4,-71(s0)
    1718:	04b00793          	li	a5,75
    171c:	02f70063          	beq	a4,a5,173c <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1720:	85ca                	mv	a1,s2
    1722:	00005517          	auipc	a0,0x5
    1726:	f4e50513          	addi	a0,a0,-178 # 6670 <malloc+0xd52>
    172a:	00004097          	auipc	ra,0x4
    172e:	136080e7          	jalr	310(ra) # 5860 <printf>
    exit(1);
    1732:	4505                	li	a0,1
    1734:	00004097          	auipc	ra,0x4
    1738:	db4080e7          	jalr	-588(ra) # 54e8 <exit>
    exit(0);
    173c:	4501                	li	a0,0
    173e:	00004097          	auipc	ra,0x4
    1742:	daa080e7          	jalr	-598(ra) # 54e8 <exit>

0000000000001746 <pipe1>:
{
    1746:	711d                	addi	sp,sp,-96
    1748:	ec86                	sd	ra,88(sp)
    174a:	e8a2                	sd	s0,80(sp)
    174c:	e4a6                	sd	s1,72(sp)
    174e:	e0ca                	sd	s2,64(sp)
    1750:	fc4e                	sd	s3,56(sp)
    1752:	f852                	sd	s4,48(sp)
    1754:	f456                	sd	s5,40(sp)
    1756:	f05a                	sd	s6,32(sp)
    1758:	ec5e                	sd	s7,24(sp)
    175a:	1080                	addi	s0,sp,96
    175c:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    175e:	fa840513          	addi	a0,s0,-88
    1762:	00004097          	auipc	ra,0x4
    1766:	d96080e7          	jalr	-618(ra) # 54f8 <pipe>
    176a:	ed25                	bnez	a0,17e2 <pipe1+0x9c>
    176c:	84aa                	mv	s1,a0
  pid = fork();
    176e:	00004097          	auipc	ra,0x4
    1772:	d72080e7          	jalr	-654(ra) # 54e0 <fork>
    1776:	8a2a                	mv	s4,a0
  if(pid == 0){
    1778:	c159                	beqz	a0,17fe <pipe1+0xb8>
  } else if(pid > 0){
    177a:	16a05e63          	blez	a0,18f6 <pipe1+0x1b0>
    close(fds[1]);
    177e:	fac42503          	lw	a0,-84(s0)
    1782:	00004097          	auipc	ra,0x4
    1786:	d8e080e7          	jalr	-626(ra) # 5510 <close>
    total = 0;
    178a:	8a26                	mv	s4,s1
    cc = 1;
    178c:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    178e:	0000aa97          	auipc	s5,0xa
    1792:	1daa8a93          	addi	s5,s5,474 # b968 <buf>
      if(cc > sizeof(buf))
    1796:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1798:	864e                	mv	a2,s3
    179a:	85d6                	mv	a1,s5
    179c:	fa842503          	lw	a0,-88(s0)
    17a0:	00004097          	auipc	ra,0x4
    17a4:	d60080e7          	jalr	-672(ra) # 5500 <read>
    17a8:	10a05263          	blez	a0,18ac <pipe1+0x166>
      for(i = 0; i < n; i++){
    17ac:	0000a717          	auipc	a4,0xa
    17b0:	1bc70713          	addi	a4,a4,444 # b968 <buf>
    17b4:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17b8:	00074683          	lbu	a3,0(a4)
    17bc:	0ff4f793          	andi	a5,s1,255
    17c0:	2485                	addiw	s1,s1,1
    17c2:	0cf69163          	bne	a3,a5,1884 <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17c6:	0705                	addi	a4,a4,1
    17c8:	fec498e3          	bne	s1,a2,17b8 <pipe1+0x72>
      total += n;
    17cc:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17d0:	0019979b          	slliw	a5,s3,0x1
    17d4:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17d8:	013b7363          	bgeu	s6,s3,17de <pipe1+0x98>
        cc = sizeof(buf);
    17dc:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17de:	84b2                	mv	s1,a2
    17e0:	bf65                	j	1798 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17e2:	85ca                	mv	a1,s2
    17e4:	00005517          	auipc	a0,0x5
    17e8:	ea450513          	addi	a0,a0,-348 # 6688 <malloc+0xd6a>
    17ec:	00004097          	auipc	ra,0x4
    17f0:	074080e7          	jalr	116(ra) # 5860 <printf>
    exit(1);
    17f4:	4505                	li	a0,1
    17f6:	00004097          	auipc	ra,0x4
    17fa:	cf2080e7          	jalr	-782(ra) # 54e8 <exit>
    close(fds[0]);
    17fe:	fa842503          	lw	a0,-88(s0)
    1802:	00004097          	auipc	ra,0x4
    1806:	d0e080e7          	jalr	-754(ra) # 5510 <close>
    for(n = 0; n < N; n++){
    180a:	0000ab17          	auipc	s6,0xa
    180e:	15eb0b13          	addi	s6,s6,350 # b968 <buf>
    1812:	416004bb          	negw	s1,s6
    1816:	0ff4f493          	andi	s1,s1,255
    181a:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    181e:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1820:	6a85                	lui	s5,0x1
    1822:	42da8a93          	addi	s5,s5,1069 # 142d <truncate3+0x7d>
{
    1826:	87da                	mv	a5,s6
        buf[i] = seq++;
    1828:	0097873b          	addw	a4,a5,s1
    182c:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1830:	0785                	addi	a5,a5,1
    1832:	fef99be3          	bne	s3,a5,1828 <pipe1+0xe2>
        buf[i] = seq++;
    1836:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    183a:	40900613          	li	a2,1033
    183e:	85de                	mv	a1,s7
    1840:	fac42503          	lw	a0,-84(s0)
    1844:	00004097          	auipc	ra,0x4
    1848:	cc4080e7          	jalr	-828(ra) # 5508 <write>
    184c:	40900793          	li	a5,1033
    1850:	00f51c63          	bne	a0,a5,1868 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1854:	24a5                	addiw	s1,s1,9
    1856:	0ff4f493          	andi	s1,s1,255
    185a:	fd5a16e3          	bne	s4,s5,1826 <pipe1+0xe0>
    exit(0);
    185e:	4501                	li	a0,0
    1860:	00004097          	auipc	ra,0x4
    1864:	c88080e7          	jalr	-888(ra) # 54e8 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1868:	85ca                	mv	a1,s2
    186a:	00005517          	auipc	a0,0x5
    186e:	e3650513          	addi	a0,a0,-458 # 66a0 <malloc+0xd82>
    1872:	00004097          	auipc	ra,0x4
    1876:	fee080e7          	jalr	-18(ra) # 5860 <printf>
        exit(1);
    187a:	4505                	li	a0,1
    187c:	00004097          	auipc	ra,0x4
    1880:	c6c080e7          	jalr	-916(ra) # 54e8 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1884:	85ca                	mv	a1,s2
    1886:	00005517          	auipc	a0,0x5
    188a:	e3250513          	addi	a0,a0,-462 # 66b8 <malloc+0xd9a>
    188e:	00004097          	auipc	ra,0x4
    1892:	fd2080e7          	jalr	-46(ra) # 5860 <printf>
}
    1896:	60e6                	ld	ra,88(sp)
    1898:	6446                	ld	s0,80(sp)
    189a:	64a6                	ld	s1,72(sp)
    189c:	6906                	ld	s2,64(sp)
    189e:	79e2                	ld	s3,56(sp)
    18a0:	7a42                	ld	s4,48(sp)
    18a2:	7aa2                	ld	s5,40(sp)
    18a4:	7b02                	ld	s6,32(sp)
    18a6:	6be2                	ld	s7,24(sp)
    18a8:	6125                	addi	sp,sp,96
    18aa:	8082                	ret
    if(total != N * SZ){
    18ac:	6785                	lui	a5,0x1
    18ae:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x7d>
    18b2:	02fa0063          	beq	s4,a5,18d2 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18b6:	85d2                	mv	a1,s4
    18b8:	00005517          	auipc	a0,0x5
    18bc:	e1850513          	addi	a0,a0,-488 # 66d0 <malloc+0xdb2>
    18c0:	00004097          	auipc	ra,0x4
    18c4:	fa0080e7          	jalr	-96(ra) # 5860 <printf>
      exit(1);
    18c8:	4505                	li	a0,1
    18ca:	00004097          	auipc	ra,0x4
    18ce:	c1e080e7          	jalr	-994(ra) # 54e8 <exit>
    close(fds[0]);
    18d2:	fa842503          	lw	a0,-88(s0)
    18d6:	00004097          	auipc	ra,0x4
    18da:	c3a080e7          	jalr	-966(ra) # 5510 <close>
    wait(&xstatus);
    18de:	fa440513          	addi	a0,s0,-92
    18e2:	00004097          	auipc	ra,0x4
    18e6:	c0e080e7          	jalr	-1010(ra) # 54f0 <wait>
    exit(xstatus);
    18ea:	fa442503          	lw	a0,-92(s0)
    18ee:	00004097          	auipc	ra,0x4
    18f2:	bfa080e7          	jalr	-1030(ra) # 54e8 <exit>
    printf("%s: fork() failed\n", s);
    18f6:	85ca                	mv	a1,s2
    18f8:	00005517          	auipc	a0,0x5
    18fc:	df850513          	addi	a0,a0,-520 # 66f0 <malloc+0xdd2>
    1900:	00004097          	auipc	ra,0x4
    1904:	f60080e7          	jalr	-160(ra) # 5860 <printf>
    exit(1);
    1908:	4505                	li	a0,1
    190a:	00004097          	auipc	ra,0x4
    190e:	bde080e7          	jalr	-1058(ra) # 54e8 <exit>

0000000000001912 <exitwait>:
{
    1912:	7139                	addi	sp,sp,-64
    1914:	fc06                	sd	ra,56(sp)
    1916:	f822                	sd	s0,48(sp)
    1918:	f426                	sd	s1,40(sp)
    191a:	f04a                	sd	s2,32(sp)
    191c:	ec4e                	sd	s3,24(sp)
    191e:	e852                	sd	s4,16(sp)
    1920:	0080                	addi	s0,sp,64
    1922:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1924:	4901                	li	s2,0
    1926:	06400993          	li	s3,100
    pid = fork();
    192a:	00004097          	auipc	ra,0x4
    192e:	bb6080e7          	jalr	-1098(ra) # 54e0 <fork>
    1932:	84aa                	mv	s1,a0
    if(pid < 0){
    1934:	02054a63          	bltz	a0,1968 <exitwait+0x56>
    if(pid){
    1938:	c151                	beqz	a0,19bc <exitwait+0xaa>
      if(wait(&xstate) != pid){
    193a:	fcc40513          	addi	a0,s0,-52
    193e:	00004097          	auipc	ra,0x4
    1942:	bb2080e7          	jalr	-1102(ra) # 54f0 <wait>
    1946:	02951f63          	bne	a0,s1,1984 <exitwait+0x72>
      if(i != xstate) {
    194a:	fcc42783          	lw	a5,-52(s0)
    194e:	05279963          	bne	a5,s2,19a0 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1952:	2905                	addiw	s2,s2,1
    1954:	fd391be3          	bne	s2,s3,192a <exitwait+0x18>
}
    1958:	70e2                	ld	ra,56(sp)
    195a:	7442                	ld	s0,48(sp)
    195c:	74a2                	ld	s1,40(sp)
    195e:	7902                	ld	s2,32(sp)
    1960:	69e2                	ld	s3,24(sp)
    1962:	6a42                	ld	s4,16(sp)
    1964:	6121                	addi	sp,sp,64
    1966:	8082                	ret
      printf("%s: fork failed\n", s);
    1968:	85d2                	mv	a1,s4
    196a:	00005517          	auipc	a0,0x5
    196e:	c1650513          	addi	a0,a0,-1002 # 6580 <malloc+0xc62>
    1972:	00004097          	auipc	ra,0x4
    1976:	eee080e7          	jalr	-274(ra) # 5860 <printf>
      exit(1);
    197a:	4505                	li	a0,1
    197c:	00004097          	auipc	ra,0x4
    1980:	b6c080e7          	jalr	-1172(ra) # 54e8 <exit>
        printf("%s: wait wrong pid\n", s);
    1984:	85d2                	mv	a1,s4
    1986:	00005517          	auipc	a0,0x5
    198a:	d8250513          	addi	a0,a0,-638 # 6708 <malloc+0xdea>
    198e:	00004097          	auipc	ra,0x4
    1992:	ed2080e7          	jalr	-302(ra) # 5860 <printf>
        exit(1);
    1996:	4505                	li	a0,1
    1998:	00004097          	auipc	ra,0x4
    199c:	b50080e7          	jalr	-1200(ra) # 54e8 <exit>
        printf("%s: wait wrong exit status\n", s);
    19a0:	85d2                	mv	a1,s4
    19a2:	00005517          	auipc	a0,0x5
    19a6:	d7e50513          	addi	a0,a0,-642 # 6720 <malloc+0xe02>
    19aa:	00004097          	auipc	ra,0x4
    19ae:	eb6080e7          	jalr	-330(ra) # 5860 <printf>
        exit(1);
    19b2:	4505                	li	a0,1
    19b4:	00004097          	auipc	ra,0x4
    19b8:	b34080e7          	jalr	-1228(ra) # 54e8 <exit>
      exit(i);
    19bc:	854a                	mv	a0,s2
    19be:	00004097          	auipc	ra,0x4
    19c2:	b2a080e7          	jalr	-1238(ra) # 54e8 <exit>

00000000000019c6 <twochildren>:
{
    19c6:	1101                	addi	sp,sp,-32
    19c8:	ec06                	sd	ra,24(sp)
    19ca:	e822                	sd	s0,16(sp)
    19cc:	e426                	sd	s1,8(sp)
    19ce:	e04a                	sd	s2,0(sp)
    19d0:	1000                	addi	s0,sp,32
    19d2:	892a                	mv	s2,a0
    19d4:	3e800493          	li	s1,1000
    int pid1 = fork();
    19d8:	00004097          	auipc	ra,0x4
    19dc:	b08080e7          	jalr	-1272(ra) # 54e0 <fork>
    if(pid1 < 0){
    19e0:	02054c63          	bltz	a0,1a18 <twochildren+0x52>
    if(pid1 == 0){
    19e4:	c921                	beqz	a0,1a34 <twochildren+0x6e>
      int pid2 = fork();
    19e6:	00004097          	auipc	ra,0x4
    19ea:	afa080e7          	jalr	-1286(ra) # 54e0 <fork>
      if(pid2 < 0){
    19ee:	04054763          	bltz	a0,1a3c <twochildren+0x76>
      if(pid2 == 0){
    19f2:	c13d                	beqz	a0,1a58 <twochildren+0x92>
        wait(0);
    19f4:	4501                	li	a0,0
    19f6:	00004097          	auipc	ra,0x4
    19fa:	afa080e7          	jalr	-1286(ra) # 54f0 <wait>
        wait(0);
    19fe:	4501                	li	a0,0
    1a00:	00004097          	auipc	ra,0x4
    1a04:	af0080e7          	jalr	-1296(ra) # 54f0 <wait>
  for(int i = 0; i < 1000; i++){
    1a08:	34fd                	addiw	s1,s1,-1
    1a0a:	f4f9                	bnez	s1,19d8 <twochildren+0x12>
}
    1a0c:	60e2                	ld	ra,24(sp)
    1a0e:	6442                	ld	s0,16(sp)
    1a10:	64a2                	ld	s1,8(sp)
    1a12:	6902                	ld	s2,0(sp)
    1a14:	6105                	addi	sp,sp,32
    1a16:	8082                	ret
      printf("%s: fork failed\n", s);
    1a18:	85ca                	mv	a1,s2
    1a1a:	00005517          	auipc	a0,0x5
    1a1e:	b6650513          	addi	a0,a0,-1178 # 6580 <malloc+0xc62>
    1a22:	00004097          	auipc	ra,0x4
    1a26:	e3e080e7          	jalr	-450(ra) # 5860 <printf>
      exit(1);
    1a2a:	4505                	li	a0,1
    1a2c:	00004097          	auipc	ra,0x4
    1a30:	abc080e7          	jalr	-1348(ra) # 54e8 <exit>
      exit(0);
    1a34:	00004097          	auipc	ra,0x4
    1a38:	ab4080e7          	jalr	-1356(ra) # 54e8 <exit>
        printf("%s: fork failed\n", s);
    1a3c:	85ca                	mv	a1,s2
    1a3e:	00005517          	auipc	a0,0x5
    1a42:	b4250513          	addi	a0,a0,-1214 # 6580 <malloc+0xc62>
    1a46:	00004097          	auipc	ra,0x4
    1a4a:	e1a080e7          	jalr	-486(ra) # 5860 <printf>
        exit(1);
    1a4e:	4505                	li	a0,1
    1a50:	00004097          	auipc	ra,0x4
    1a54:	a98080e7          	jalr	-1384(ra) # 54e8 <exit>
        exit(0);
    1a58:	00004097          	auipc	ra,0x4
    1a5c:	a90080e7          	jalr	-1392(ra) # 54e8 <exit>

0000000000001a60 <forkfork>:
{
    1a60:	7179                	addi	sp,sp,-48
    1a62:	f406                	sd	ra,40(sp)
    1a64:	f022                	sd	s0,32(sp)
    1a66:	ec26                	sd	s1,24(sp)
    1a68:	1800                	addi	s0,sp,48
    1a6a:	84aa                	mv	s1,a0
    int pid = fork();
    1a6c:	00004097          	auipc	ra,0x4
    1a70:	a74080e7          	jalr	-1420(ra) # 54e0 <fork>
    if(pid < 0){
    1a74:	04054163          	bltz	a0,1ab6 <forkfork+0x56>
    if(pid == 0){
    1a78:	cd29                	beqz	a0,1ad2 <forkfork+0x72>
    int pid = fork();
    1a7a:	00004097          	auipc	ra,0x4
    1a7e:	a66080e7          	jalr	-1434(ra) # 54e0 <fork>
    if(pid < 0){
    1a82:	02054a63          	bltz	a0,1ab6 <forkfork+0x56>
    if(pid == 0){
    1a86:	c531                	beqz	a0,1ad2 <forkfork+0x72>
    wait(&xstatus);
    1a88:	fdc40513          	addi	a0,s0,-36
    1a8c:	00004097          	auipc	ra,0x4
    1a90:	a64080e7          	jalr	-1436(ra) # 54f0 <wait>
    if(xstatus != 0) {
    1a94:	fdc42783          	lw	a5,-36(s0)
    1a98:	ebbd                	bnez	a5,1b0e <forkfork+0xae>
    wait(&xstatus);
    1a9a:	fdc40513          	addi	a0,s0,-36
    1a9e:	00004097          	auipc	ra,0x4
    1aa2:	a52080e7          	jalr	-1454(ra) # 54f0 <wait>
    if(xstatus != 0) {
    1aa6:	fdc42783          	lw	a5,-36(s0)
    1aaa:	e3b5                	bnez	a5,1b0e <forkfork+0xae>
}
    1aac:	70a2                	ld	ra,40(sp)
    1aae:	7402                	ld	s0,32(sp)
    1ab0:	64e2                	ld	s1,24(sp)
    1ab2:	6145                	addi	sp,sp,48
    1ab4:	8082                	ret
      printf("%s: fork failed", s);
    1ab6:	85a6                	mv	a1,s1
    1ab8:	00005517          	auipc	a0,0x5
    1abc:	c8850513          	addi	a0,a0,-888 # 6740 <malloc+0xe22>
    1ac0:	00004097          	auipc	ra,0x4
    1ac4:	da0080e7          	jalr	-608(ra) # 5860 <printf>
      exit(1);
    1ac8:	4505                	li	a0,1
    1aca:	00004097          	auipc	ra,0x4
    1ace:	a1e080e7          	jalr	-1506(ra) # 54e8 <exit>
{
    1ad2:	0c800493          	li	s1,200
        int pid1 = fork();
    1ad6:	00004097          	auipc	ra,0x4
    1ada:	a0a080e7          	jalr	-1526(ra) # 54e0 <fork>
        if(pid1 < 0){
    1ade:	00054f63          	bltz	a0,1afc <forkfork+0x9c>
        if(pid1 == 0){
    1ae2:	c115                	beqz	a0,1b06 <forkfork+0xa6>
        wait(0);
    1ae4:	4501                	li	a0,0
    1ae6:	00004097          	auipc	ra,0x4
    1aea:	a0a080e7          	jalr	-1526(ra) # 54f0 <wait>
      for(int j = 0; j < 200; j++){
    1aee:	34fd                	addiw	s1,s1,-1
    1af0:	f0fd                	bnez	s1,1ad6 <forkfork+0x76>
      exit(0);
    1af2:	4501                	li	a0,0
    1af4:	00004097          	auipc	ra,0x4
    1af8:	9f4080e7          	jalr	-1548(ra) # 54e8 <exit>
          exit(1);
    1afc:	4505                	li	a0,1
    1afe:	00004097          	auipc	ra,0x4
    1b02:	9ea080e7          	jalr	-1558(ra) # 54e8 <exit>
          exit(0);
    1b06:	00004097          	auipc	ra,0x4
    1b0a:	9e2080e7          	jalr	-1566(ra) # 54e8 <exit>
      printf("%s: fork in child failed", s);
    1b0e:	85a6                	mv	a1,s1
    1b10:	00005517          	auipc	a0,0x5
    1b14:	c4050513          	addi	a0,a0,-960 # 6750 <malloc+0xe32>
    1b18:	00004097          	auipc	ra,0x4
    1b1c:	d48080e7          	jalr	-696(ra) # 5860 <printf>
      exit(1);
    1b20:	4505                	li	a0,1
    1b22:	00004097          	auipc	ra,0x4
    1b26:	9c6080e7          	jalr	-1594(ra) # 54e8 <exit>

0000000000001b2a <reparent2>:
{
    1b2a:	1101                	addi	sp,sp,-32
    1b2c:	ec06                	sd	ra,24(sp)
    1b2e:	e822                	sd	s0,16(sp)
    1b30:	e426                	sd	s1,8(sp)
    1b32:	1000                	addi	s0,sp,32
    1b34:	32000493          	li	s1,800
    int pid1 = fork();
    1b38:	00004097          	auipc	ra,0x4
    1b3c:	9a8080e7          	jalr	-1624(ra) # 54e0 <fork>
    if(pid1 < 0){
    1b40:	00054f63          	bltz	a0,1b5e <reparent2+0x34>
    if(pid1 == 0){
    1b44:	c915                	beqz	a0,1b78 <reparent2+0x4e>
    wait(0);
    1b46:	4501                	li	a0,0
    1b48:	00004097          	auipc	ra,0x4
    1b4c:	9a8080e7          	jalr	-1624(ra) # 54f0 <wait>
  for(int i = 0; i < 800; i++){
    1b50:	34fd                	addiw	s1,s1,-1
    1b52:	f0fd                	bnez	s1,1b38 <reparent2+0xe>
  exit(0);
    1b54:	4501                	li	a0,0
    1b56:	00004097          	auipc	ra,0x4
    1b5a:	992080e7          	jalr	-1646(ra) # 54e8 <exit>
      printf("fork failed\n");
    1b5e:	00005517          	auipc	a0,0x5
    1b62:	e1250513          	addi	a0,a0,-494 # 6970 <malloc+0x1052>
    1b66:	00004097          	auipc	ra,0x4
    1b6a:	cfa080e7          	jalr	-774(ra) # 5860 <printf>
      exit(1);
    1b6e:	4505                	li	a0,1
    1b70:	00004097          	auipc	ra,0x4
    1b74:	978080e7          	jalr	-1672(ra) # 54e8 <exit>
      fork();
    1b78:	00004097          	auipc	ra,0x4
    1b7c:	968080e7          	jalr	-1688(ra) # 54e0 <fork>
      fork();
    1b80:	00004097          	auipc	ra,0x4
    1b84:	960080e7          	jalr	-1696(ra) # 54e0 <fork>
      exit(0);
    1b88:	4501                	li	a0,0
    1b8a:	00004097          	auipc	ra,0x4
    1b8e:	95e080e7          	jalr	-1698(ra) # 54e8 <exit>

0000000000001b92 <createdelete>:
{
    1b92:	7175                	addi	sp,sp,-144
    1b94:	e506                	sd	ra,136(sp)
    1b96:	e122                	sd	s0,128(sp)
    1b98:	fca6                	sd	s1,120(sp)
    1b9a:	f8ca                	sd	s2,112(sp)
    1b9c:	f4ce                	sd	s3,104(sp)
    1b9e:	f0d2                	sd	s4,96(sp)
    1ba0:	ecd6                	sd	s5,88(sp)
    1ba2:	e8da                	sd	s6,80(sp)
    1ba4:	e4de                	sd	s7,72(sp)
    1ba6:	e0e2                	sd	s8,64(sp)
    1ba8:	fc66                	sd	s9,56(sp)
    1baa:	0900                	addi	s0,sp,144
    1bac:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1bae:	4901                	li	s2,0
    1bb0:	4991                	li	s3,4
    pid = fork();
    1bb2:	00004097          	auipc	ra,0x4
    1bb6:	92e080e7          	jalr	-1746(ra) # 54e0 <fork>
    1bba:	84aa                	mv	s1,a0
    if(pid < 0){
    1bbc:	02054f63          	bltz	a0,1bfa <createdelete+0x68>
    if(pid == 0){
    1bc0:	c939                	beqz	a0,1c16 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bc2:	2905                	addiw	s2,s2,1
    1bc4:	ff3917e3          	bne	s2,s3,1bb2 <createdelete+0x20>
    1bc8:	4491                	li	s1,4
    wait(&xstatus);
    1bca:	f7c40513          	addi	a0,s0,-132
    1bce:	00004097          	auipc	ra,0x4
    1bd2:	922080e7          	jalr	-1758(ra) # 54f0 <wait>
    if(xstatus != 0)
    1bd6:	f7c42903          	lw	s2,-132(s0)
    1bda:	0e091263          	bnez	s2,1cbe <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bde:	34fd                	addiw	s1,s1,-1
    1be0:	f4ed                	bnez	s1,1bca <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1be2:	f8040123          	sb	zero,-126(s0)
    1be6:	03000993          	li	s3,48
    1bea:	5a7d                	li	s4,-1
    1bec:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1bf0:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1bf2:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1bf4:	07400a93          	li	s5,116
    1bf8:	a29d                	j	1d5e <createdelete+0x1cc>
      printf("fork failed\n", s);
    1bfa:	85e6                	mv	a1,s9
    1bfc:	00005517          	auipc	a0,0x5
    1c00:	d7450513          	addi	a0,a0,-652 # 6970 <malloc+0x1052>
    1c04:	00004097          	auipc	ra,0x4
    1c08:	c5c080e7          	jalr	-932(ra) # 5860 <printf>
      exit(1);
    1c0c:	4505                	li	a0,1
    1c0e:	00004097          	auipc	ra,0x4
    1c12:	8da080e7          	jalr	-1830(ra) # 54e8 <exit>
      name[0] = 'p' + pi;
    1c16:	0709091b          	addiw	s2,s2,112
    1c1a:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c1e:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c22:	4951                	li	s2,20
    1c24:	a015                	j	1c48 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c26:	85e6                	mv	a1,s9
    1c28:	00005517          	auipc	a0,0x5
    1c2c:	9f050513          	addi	a0,a0,-1552 # 6618 <malloc+0xcfa>
    1c30:	00004097          	auipc	ra,0x4
    1c34:	c30080e7          	jalr	-976(ra) # 5860 <printf>
          exit(1);
    1c38:	4505                	li	a0,1
    1c3a:	00004097          	auipc	ra,0x4
    1c3e:	8ae080e7          	jalr	-1874(ra) # 54e8 <exit>
      for(i = 0; i < N; i++){
    1c42:	2485                	addiw	s1,s1,1
    1c44:	07248863          	beq	s1,s2,1cb4 <createdelete+0x122>
        name[1] = '0' + i;
    1c48:	0304879b          	addiw	a5,s1,48
    1c4c:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c50:	20200593          	li	a1,514
    1c54:	f8040513          	addi	a0,s0,-128
    1c58:	00004097          	auipc	ra,0x4
    1c5c:	8d0080e7          	jalr	-1840(ra) # 5528 <open>
        if(fd < 0){
    1c60:	fc0543e3          	bltz	a0,1c26 <createdelete+0x94>
        close(fd);
    1c64:	00004097          	auipc	ra,0x4
    1c68:	8ac080e7          	jalr	-1876(ra) # 5510 <close>
        if(i > 0 && (i % 2 ) == 0){
    1c6c:	fc905be3          	blez	s1,1c42 <createdelete+0xb0>
    1c70:	0014f793          	andi	a5,s1,1
    1c74:	f7f9                	bnez	a5,1c42 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c76:	01f4d79b          	srliw	a5,s1,0x1f
    1c7a:	9fa5                	addw	a5,a5,s1
    1c7c:	4017d79b          	sraiw	a5,a5,0x1
    1c80:	0307879b          	addiw	a5,a5,48
    1c84:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1c88:	f8040513          	addi	a0,s0,-128
    1c8c:	00004097          	auipc	ra,0x4
    1c90:	8ac080e7          	jalr	-1876(ra) # 5538 <unlink>
    1c94:	fa0557e3          	bgez	a0,1c42 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1c98:	85e6                	mv	a1,s9
    1c9a:	00005517          	auipc	a0,0x5
    1c9e:	ad650513          	addi	a0,a0,-1322 # 6770 <malloc+0xe52>
    1ca2:	00004097          	auipc	ra,0x4
    1ca6:	bbe080e7          	jalr	-1090(ra) # 5860 <printf>
            exit(1);
    1caa:	4505                	li	a0,1
    1cac:	00004097          	auipc	ra,0x4
    1cb0:	83c080e7          	jalr	-1988(ra) # 54e8 <exit>
      exit(0);
    1cb4:	4501                	li	a0,0
    1cb6:	00004097          	auipc	ra,0x4
    1cba:	832080e7          	jalr	-1998(ra) # 54e8 <exit>
      exit(1);
    1cbe:	4505                	li	a0,1
    1cc0:	00004097          	auipc	ra,0x4
    1cc4:	828080e7          	jalr	-2008(ra) # 54e8 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cc8:	f8040613          	addi	a2,s0,-128
    1ccc:	85e6                	mv	a1,s9
    1cce:	00005517          	auipc	a0,0x5
    1cd2:	aba50513          	addi	a0,a0,-1350 # 6788 <malloc+0xe6a>
    1cd6:	00004097          	auipc	ra,0x4
    1cda:	b8a080e7          	jalr	-1142(ra) # 5860 <printf>
        exit(1);
    1cde:	4505                	li	a0,1
    1ce0:	00004097          	auipc	ra,0x4
    1ce4:	808080e7          	jalr	-2040(ra) # 54e8 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ce8:	054b7163          	bgeu	s6,s4,1d2a <createdelete+0x198>
      if(fd >= 0)
    1cec:	02055a63          	bgez	a0,1d20 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1cf0:	2485                	addiw	s1,s1,1
    1cf2:	0ff4f493          	andi	s1,s1,255
    1cf6:	05548c63          	beq	s1,s5,1d4e <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1cfa:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1cfe:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1d02:	4581                	li	a1,0
    1d04:	f8040513          	addi	a0,s0,-128
    1d08:	00004097          	auipc	ra,0x4
    1d0c:	820080e7          	jalr	-2016(ra) # 5528 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d10:	00090463          	beqz	s2,1d18 <createdelete+0x186>
    1d14:	fd2bdae3          	bge	s7,s2,1ce8 <createdelete+0x156>
    1d18:	fa0548e3          	bltz	a0,1cc8 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d1c:	014b7963          	bgeu	s6,s4,1d2e <createdelete+0x19c>
        close(fd);
    1d20:	00003097          	auipc	ra,0x3
    1d24:	7f0080e7          	jalr	2032(ra) # 5510 <close>
    1d28:	b7e1                	j	1cf0 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d2a:	fc0543e3          	bltz	a0,1cf0 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d2e:	f8040613          	addi	a2,s0,-128
    1d32:	85e6                	mv	a1,s9
    1d34:	00005517          	auipc	a0,0x5
    1d38:	a7c50513          	addi	a0,a0,-1412 # 67b0 <malloc+0xe92>
    1d3c:	00004097          	auipc	ra,0x4
    1d40:	b24080e7          	jalr	-1244(ra) # 5860 <printf>
        exit(1);
    1d44:	4505                	li	a0,1
    1d46:	00003097          	auipc	ra,0x3
    1d4a:	7a2080e7          	jalr	1954(ra) # 54e8 <exit>
  for(i = 0; i < N; i++){
    1d4e:	2905                	addiw	s2,s2,1
    1d50:	2a05                	addiw	s4,s4,1
    1d52:	2985                	addiw	s3,s3,1
    1d54:	0ff9f993          	andi	s3,s3,255
    1d58:	47d1                	li	a5,20
    1d5a:	02f90a63          	beq	s2,a5,1d8e <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d5e:	84e2                	mv	s1,s8
    1d60:	bf69                	j	1cfa <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d62:	2905                	addiw	s2,s2,1
    1d64:	0ff97913          	andi	s2,s2,255
    1d68:	2985                	addiw	s3,s3,1
    1d6a:	0ff9f993          	andi	s3,s3,255
    1d6e:	03490863          	beq	s2,s4,1d9e <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d72:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d74:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d78:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d7c:	f8040513          	addi	a0,s0,-128
    1d80:	00003097          	auipc	ra,0x3
    1d84:	7b8080e7          	jalr	1976(ra) # 5538 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1d88:	34fd                	addiw	s1,s1,-1
    1d8a:	f4ed                	bnez	s1,1d74 <createdelete+0x1e2>
    1d8c:	bfd9                	j	1d62 <createdelete+0x1d0>
    1d8e:	03000993          	li	s3,48
    1d92:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1d96:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1d98:	08400a13          	li	s4,132
    1d9c:	bfd9                	j	1d72 <createdelete+0x1e0>
}
    1d9e:	60aa                	ld	ra,136(sp)
    1da0:	640a                	ld	s0,128(sp)
    1da2:	74e6                	ld	s1,120(sp)
    1da4:	7946                	ld	s2,112(sp)
    1da6:	79a6                	ld	s3,104(sp)
    1da8:	7a06                	ld	s4,96(sp)
    1daa:	6ae6                	ld	s5,88(sp)
    1dac:	6b46                	ld	s6,80(sp)
    1dae:	6ba6                	ld	s7,72(sp)
    1db0:	6c06                	ld	s8,64(sp)
    1db2:	7ce2                	ld	s9,56(sp)
    1db4:	6149                	addi	sp,sp,144
    1db6:	8082                	ret

0000000000001db8 <linkunlink>:
{
    1db8:	711d                	addi	sp,sp,-96
    1dba:	ec86                	sd	ra,88(sp)
    1dbc:	e8a2                	sd	s0,80(sp)
    1dbe:	e4a6                	sd	s1,72(sp)
    1dc0:	e0ca                	sd	s2,64(sp)
    1dc2:	fc4e                	sd	s3,56(sp)
    1dc4:	f852                	sd	s4,48(sp)
    1dc6:	f456                	sd	s5,40(sp)
    1dc8:	f05a                	sd	s6,32(sp)
    1dca:	ec5e                	sd	s7,24(sp)
    1dcc:	e862                	sd	s8,16(sp)
    1dce:	e466                	sd	s9,8(sp)
    1dd0:	1080                	addi	s0,sp,96
    1dd2:	84aa                	mv	s1,a0
  unlink("x");
    1dd4:	00004517          	auipc	a0,0x4
    1dd8:	fe450513          	addi	a0,a0,-28 # 5db8 <malloc+0x49a>
    1ddc:	00003097          	auipc	ra,0x3
    1de0:	75c080e7          	jalr	1884(ra) # 5538 <unlink>
  pid = fork();
    1de4:	00003097          	auipc	ra,0x3
    1de8:	6fc080e7          	jalr	1788(ra) # 54e0 <fork>
  if(pid < 0){
    1dec:	02054b63          	bltz	a0,1e22 <linkunlink+0x6a>
    1df0:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1df2:	4c85                	li	s9,1
    1df4:	e119                	bnez	a0,1dfa <linkunlink+0x42>
    1df6:	06100c93          	li	s9,97
    1dfa:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1dfe:	41c659b7          	lui	s3,0x41c65
    1e02:	e6d9899b          	addiw	s3,s3,-403
    1e06:	690d                	lui	s2,0x3
    1e08:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e0c:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e0e:	4b05                	li	s6,1
      unlink("x");
    1e10:	00004a97          	auipc	s5,0x4
    1e14:	fa8a8a93          	addi	s5,s5,-88 # 5db8 <malloc+0x49a>
      link("cat", "x");
    1e18:	00005b97          	auipc	s7,0x5
    1e1c:	9c0b8b93          	addi	s7,s7,-1600 # 67d8 <malloc+0xeba>
    1e20:	a825                	j	1e58 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    1e22:	85a6                	mv	a1,s1
    1e24:	00004517          	auipc	a0,0x4
    1e28:	75c50513          	addi	a0,a0,1884 # 6580 <malloc+0xc62>
    1e2c:	00004097          	auipc	ra,0x4
    1e30:	a34080e7          	jalr	-1484(ra) # 5860 <printf>
    exit(1);
    1e34:	4505                	li	a0,1
    1e36:	00003097          	auipc	ra,0x3
    1e3a:	6b2080e7          	jalr	1714(ra) # 54e8 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e3e:	20200593          	li	a1,514
    1e42:	8556                	mv	a0,s5
    1e44:	00003097          	auipc	ra,0x3
    1e48:	6e4080e7          	jalr	1764(ra) # 5528 <open>
    1e4c:	00003097          	auipc	ra,0x3
    1e50:	6c4080e7          	jalr	1732(ra) # 5510 <close>
  for(i = 0; i < 100; i++){
    1e54:	34fd                	addiw	s1,s1,-1
    1e56:	c88d                	beqz	s1,1e88 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e58:	033c87bb          	mulw	a5,s9,s3
    1e5c:	012787bb          	addw	a5,a5,s2
    1e60:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e64:	0347f7bb          	remuw	a5,a5,s4
    1e68:	dbf9                	beqz	a5,1e3e <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e6a:	01678863          	beq	a5,s6,1e7a <linkunlink+0xc2>
      unlink("x");
    1e6e:	8556                	mv	a0,s5
    1e70:	00003097          	auipc	ra,0x3
    1e74:	6c8080e7          	jalr	1736(ra) # 5538 <unlink>
    1e78:	bff1                	j	1e54 <linkunlink+0x9c>
      link("cat", "x");
    1e7a:	85d6                	mv	a1,s5
    1e7c:	855e                	mv	a0,s7
    1e7e:	00003097          	auipc	ra,0x3
    1e82:	6ca080e7          	jalr	1738(ra) # 5548 <link>
    1e86:	b7f9                	j	1e54 <linkunlink+0x9c>
  if(pid)
    1e88:	020c0463          	beqz	s8,1eb0 <linkunlink+0xf8>
    wait(0);
    1e8c:	4501                	li	a0,0
    1e8e:	00003097          	auipc	ra,0x3
    1e92:	662080e7          	jalr	1634(ra) # 54f0 <wait>
}
    1e96:	60e6                	ld	ra,88(sp)
    1e98:	6446                	ld	s0,80(sp)
    1e9a:	64a6                	ld	s1,72(sp)
    1e9c:	6906                	ld	s2,64(sp)
    1e9e:	79e2                	ld	s3,56(sp)
    1ea0:	7a42                	ld	s4,48(sp)
    1ea2:	7aa2                	ld	s5,40(sp)
    1ea4:	7b02                	ld	s6,32(sp)
    1ea6:	6be2                	ld	s7,24(sp)
    1ea8:	6c42                	ld	s8,16(sp)
    1eaa:	6ca2                	ld	s9,8(sp)
    1eac:	6125                	addi	sp,sp,96
    1eae:	8082                	ret
    exit(0);
    1eb0:	4501                	li	a0,0
    1eb2:	00003097          	auipc	ra,0x3
    1eb6:	636080e7          	jalr	1590(ra) # 54e8 <exit>

0000000000001eba <forktest>:
{
    1eba:	7179                	addi	sp,sp,-48
    1ebc:	f406                	sd	ra,40(sp)
    1ebe:	f022                	sd	s0,32(sp)
    1ec0:	ec26                	sd	s1,24(sp)
    1ec2:	e84a                	sd	s2,16(sp)
    1ec4:	e44e                	sd	s3,8(sp)
    1ec6:	1800                	addi	s0,sp,48
    1ec8:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1eca:	4481                	li	s1,0
    1ecc:	3e800913          	li	s2,1000
    pid = fork();
    1ed0:	00003097          	auipc	ra,0x3
    1ed4:	610080e7          	jalr	1552(ra) # 54e0 <fork>
    if(pid < 0)
    1ed8:	02054863          	bltz	a0,1f08 <forktest+0x4e>
    if(pid == 0)
    1edc:	c115                	beqz	a0,1f00 <forktest+0x46>
  for(n=0; n<N; n++){
    1ede:	2485                	addiw	s1,s1,1
    1ee0:	ff2498e3          	bne	s1,s2,1ed0 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1ee4:	85ce                	mv	a1,s3
    1ee6:	00005517          	auipc	a0,0x5
    1eea:	91250513          	addi	a0,a0,-1774 # 67f8 <malloc+0xeda>
    1eee:	00004097          	auipc	ra,0x4
    1ef2:	972080e7          	jalr	-1678(ra) # 5860 <printf>
    exit(1);
    1ef6:	4505                	li	a0,1
    1ef8:	00003097          	auipc	ra,0x3
    1efc:	5f0080e7          	jalr	1520(ra) # 54e8 <exit>
      exit(0);
    1f00:	00003097          	auipc	ra,0x3
    1f04:	5e8080e7          	jalr	1512(ra) # 54e8 <exit>
  if (n == 0) {
    1f08:	cc9d                	beqz	s1,1f46 <forktest+0x8c>
  if(n == N){
    1f0a:	3e800793          	li	a5,1000
    1f0e:	fcf48be3          	beq	s1,a5,1ee4 <forktest+0x2a>
  for(; n > 0; n--){
    1f12:	00905b63          	blez	s1,1f28 <forktest+0x6e>
    if(wait(0) < 0){
    1f16:	4501                	li	a0,0
    1f18:	00003097          	auipc	ra,0x3
    1f1c:	5d8080e7          	jalr	1496(ra) # 54f0 <wait>
    1f20:	04054163          	bltz	a0,1f62 <forktest+0xa8>
  for(; n > 0; n--){
    1f24:	34fd                	addiw	s1,s1,-1
    1f26:	f8e5                	bnez	s1,1f16 <forktest+0x5c>
  if(wait(0) != -1){
    1f28:	4501                	li	a0,0
    1f2a:	00003097          	auipc	ra,0x3
    1f2e:	5c6080e7          	jalr	1478(ra) # 54f0 <wait>
    1f32:	57fd                	li	a5,-1
    1f34:	04f51563          	bne	a0,a5,1f7e <forktest+0xc4>
}
    1f38:	70a2                	ld	ra,40(sp)
    1f3a:	7402                	ld	s0,32(sp)
    1f3c:	64e2                	ld	s1,24(sp)
    1f3e:	6942                	ld	s2,16(sp)
    1f40:	69a2                	ld	s3,8(sp)
    1f42:	6145                	addi	sp,sp,48
    1f44:	8082                	ret
    printf("%s: no fork at all!\n", s);
    1f46:	85ce                	mv	a1,s3
    1f48:	00005517          	auipc	a0,0x5
    1f4c:	89850513          	addi	a0,a0,-1896 # 67e0 <malloc+0xec2>
    1f50:	00004097          	auipc	ra,0x4
    1f54:	910080e7          	jalr	-1776(ra) # 5860 <printf>
    exit(1);
    1f58:	4505                	li	a0,1
    1f5a:	00003097          	auipc	ra,0x3
    1f5e:	58e080e7          	jalr	1422(ra) # 54e8 <exit>
      printf("%s: wait stopped early\n", s);
    1f62:	85ce                	mv	a1,s3
    1f64:	00005517          	auipc	a0,0x5
    1f68:	8bc50513          	addi	a0,a0,-1860 # 6820 <malloc+0xf02>
    1f6c:	00004097          	auipc	ra,0x4
    1f70:	8f4080e7          	jalr	-1804(ra) # 5860 <printf>
      exit(1);
    1f74:	4505                	li	a0,1
    1f76:	00003097          	auipc	ra,0x3
    1f7a:	572080e7          	jalr	1394(ra) # 54e8 <exit>
    printf("%s: wait got too many\n", s);
    1f7e:	85ce                	mv	a1,s3
    1f80:	00005517          	auipc	a0,0x5
    1f84:	8b850513          	addi	a0,a0,-1864 # 6838 <malloc+0xf1a>
    1f88:	00004097          	auipc	ra,0x4
    1f8c:	8d8080e7          	jalr	-1832(ra) # 5860 <printf>
    exit(1);
    1f90:	4505                	li	a0,1
    1f92:	00003097          	auipc	ra,0x3
    1f96:	556080e7          	jalr	1366(ra) # 54e8 <exit>

0000000000001f9a <kernmem>:
{
    1f9a:	715d                	addi	sp,sp,-80
    1f9c:	e486                	sd	ra,72(sp)
    1f9e:	e0a2                	sd	s0,64(sp)
    1fa0:	fc26                	sd	s1,56(sp)
    1fa2:	f84a                	sd	s2,48(sp)
    1fa4:	f44e                	sd	s3,40(sp)
    1fa6:	f052                	sd	s4,32(sp)
    1fa8:	ec56                	sd	s5,24(sp)
    1faa:	0880                	addi	s0,sp,80
    1fac:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fae:	4485                	li	s1,1
    1fb0:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1fb2:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fb4:	69b1                	lui	s3,0xc
    1fb6:	35098993          	addi	s3,s3,848 # c350 <buf+0x9e8>
    1fba:	1003d937          	lui	s2,0x1003d
    1fbe:	090e                	slli	s2,s2,0x3
    1fc0:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002eb08>
    pid = fork();
    1fc4:	00003097          	auipc	ra,0x3
    1fc8:	51c080e7          	jalr	1308(ra) # 54e0 <fork>
    if(pid < 0){
    1fcc:	02054963          	bltz	a0,1ffe <kernmem+0x64>
    if(pid == 0){
    1fd0:	c529                	beqz	a0,201a <kernmem+0x80>
    wait(&xstatus);
    1fd2:	fbc40513          	addi	a0,s0,-68
    1fd6:	00003097          	auipc	ra,0x3
    1fda:	51a080e7          	jalr	1306(ra) # 54f0 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1fde:	fbc42783          	lw	a5,-68(s0)
    1fe2:	05579c63          	bne	a5,s5,203a <kernmem+0xa0>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fe6:	94ce                	add	s1,s1,s3
    1fe8:	fd249ee3          	bne	s1,s2,1fc4 <kernmem+0x2a>
}
    1fec:	60a6                	ld	ra,72(sp)
    1fee:	6406                	ld	s0,64(sp)
    1ff0:	74e2                	ld	s1,56(sp)
    1ff2:	7942                	ld	s2,48(sp)
    1ff4:	79a2                	ld	s3,40(sp)
    1ff6:	7a02                	ld	s4,32(sp)
    1ff8:	6ae2                	ld	s5,24(sp)
    1ffa:	6161                	addi	sp,sp,80
    1ffc:	8082                	ret
      printf("%s: fork failed\n", s);
    1ffe:	85d2                	mv	a1,s4
    2000:	00004517          	auipc	a0,0x4
    2004:	58050513          	addi	a0,a0,1408 # 6580 <malloc+0xc62>
    2008:	00004097          	auipc	ra,0x4
    200c:	858080e7          	jalr	-1960(ra) # 5860 <printf>
      exit(1);
    2010:	4505                	li	a0,1
    2012:	00003097          	auipc	ra,0x3
    2016:	4d6080e7          	jalr	1238(ra) # 54e8 <exit>
      printf("%s: oops could read %x = %x\n", a, *a);
    201a:	0004c603          	lbu	a2,0(s1)
    201e:	85a6                	mv	a1,s1
    2020:	00005517          	auipc	a0,0x5
    2024:	83050513          	addi	a0,a0,-2000 # 6850 <malloc+0xf32>
    2028:	00004097          	auipc	ra,0x4
    202c:	838080e7          	jalr	-1992(ra) # 5860 <printf>
      exit(1);
    2030:	4505                	li	a0,1
    2032:	00003097          	auipc	ra,0x3
    2036:	4b6080e7          	jalr	1206(ra) # 54e8 <exit>
      exit(1);
    203a:	4505                	li	a0,1
    203c:	00003097          	auipc	ra,0x3
    2040:	4ac080e7          	jalr	1196(ra) # 54e8 <exit>

0000000000002044 <bigargtest>:
{
    2044:	7179                	addi	sp,sp,-48
    2046:	f406                	sd	ra,40(sp)
    2048:	f022                	sd	s0,32(sp)
    204a:	ec26                	sd	s1,24(sp)
    204c:	1800                	addi	s0,sp,48
    204e:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2050:	00005517          	auipc	a0,0x5
    2054:	82050513          	addi	a0,a0,-2016 # 6870 <malloc+0xf52>
    2058:	00003097          	auipc	ra,0x3
    205c:	4e0080e7          	jalr	1248(ra) # 5538 <unlink>
  pid = fork();
    2060:	00003097          	auipc	ra,0x3
    2064:	480080e7          	jalr	1152(ra) # 54e0 <fork>
  if(pid == 0){
    2068:	c121                	beqz	a0,20a8 <bigargtest+0x64>
  } else if(pid < 0){
    206a:	0a054063          	bltz	a0,210a <bigargtest+0xc6>
  wait(&xstatus);
    206e:	fdc40513          	addi	a0,s0,-36
    2072:	00003097          	auipc	ra,0x3
    2076:	47e080e7          	jalr	1150(ra) # 54f0 <wait>
  if(xstatus != 0)
    207a:	fdc42503          	lw	a0,-36(s0)
    207e:	e545                	bnez	a0,2126 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    2080:	4581                	li	a1,0
    2082:	00004517          	auipc	a0,0x4
    2086:	7ee50513          	addi	a0,a0,2030 # 6870 <malloc+0xf52>
    208a:	00003097          	auipc	ra,0x3
    208e:	49e080e7          	jalr	1182(ra) # 5528 <open>
  if(fd < 0){
    2092:	08054e63          	bltz	a0,212e <bigargtest+0xea>
  close(fd);
    2096:	00003097          	auipc	ra,0x3
    209a:	47a080e7          	jalr	1146(ra) # 5510 <close>
}
    209e:	70a2                	ld	ra,40(sp)
    20a0:	7402                	ld	s0,32(sp)
    20a2:	64e2                	ld	s1,24(sp)
    20a4:	6145                	addi	sp,sp,48
    20a6:	8082                	ret
    20a8:	00006797          	auipc	a5,0x6
    20ac:	0a878793          	addi	a5,a5,168 # 8150 <args.1>
    20b0:	00006697          	auipc	a3,0x6
    20b4:	19868693          	addi	a3,a3,408 # 8248 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    20b8:	00004717          	auipc	a4,0x4
    20bc:	7c870713          	addi	a4,a4,1992 # 6880 <malloc+0xf62>
    20c0:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    20c2:	07a1                	addi	a5,a5,8
    20c4:	fed79ee3          	bne	a5,a3,20c0 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    20c8:	00006597          	auipc	a1,0x6
    20cc:	08858593          	addi	a1,a1,136 # 8150 <args.1>
    20d0:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    20d4:	00004517          	auipc	a0,0x4
    20d8:	c7450513          	addi	a0,a0,-908 # 5d48 <malloc+0x42a>
    20dc:	00003097          	auipc	ra,0x3
    20e0:	444080e7          	jalr	1092(ra) # 5520 <exec>
    fd = open("bigarg-ok", O_CREATE);
    20e4:	20000593          	li	a1,512
    20e8:	00004517          	auipc	a0,0x4
    20ec:	78850513          	addi	a0,a0,1928 # 6870 <malloc+0xf52>
    20f0:	00003097          	auipc	ra,0x3
    20f4:	438080e7          	jalr	1080(ra) # 5528 <open>
    close(fd);
    20f8:	00003097          	auipc	ra,0x3
    20fc:	418080e7          	jalr	1048(ra) # 5510 <close>
    exit(0);
    2100:	4501                	li	a0,0
    2102:	00003097          	auipc	ra,0x3
    2106:	3e6080e7          	jalr	998(ra) # 54e8 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    210a:	85a6                	mv	a1,s1
    210c:	00005517          	auipc	a0,0x5
    2110:	85450513          	addi	a0,a0,-1964 # 6960 <malloc+0x1042>
    2114:	00003097          	auipc	ra,0x3
    2118:	74c080e7          	jalr	1868(ra) # 5860 <printf>
    exit(1);
    211c:	4505                	li	a0,1
    211e:	00003097          	auipc	ra,0x3
    2122:	3ca080e7          	jalr	970(ra) # 54e8 <exit>
    exit(xstatus);
    2126:	00003097          	auipc	ra,0x3
    212a:	3c2080e7          	jalr	962(ra) # 54e8 <exit>
    printf("%s: bigarg test failed!\n", s);
    212e:	85a6                	mv	a1,s1
    2130:	00005517          	auipc	a0,0x5
    2134:	85050513          	addi	a0,a0,-1968 # 6980 <malloc+0x1062>
    2138:	00003097          	auipc	ra,0x3
    213c:	728080e7          	jalr	1832(ra) # 5860 <printf>
    exit(1);
    2140:	4505                	li	a0,1
    2142:	00003097          	auipc	ra,0x3
    2146:	3a6080e7          	jalr	934(ra) # 54e8 <exit>

000000000000214a <stacktest>:
{
    214a:	7179                	addi	sp,sp,-48
    214c:	f406                	sd	ra,40(sp)
    214e:	f022                	sd	s0,32(sp)
    2150:	ec26                	sd	s1,24(sp)
    2152:	1800                	addi	s0,sp,48
    2154:	84aa                	mv	s1,a0
  pid = fork();
    2156:	00003097          	auipc	ra,0x3
    215a:	38a080e7          	jalr	906(ra) # 54e0 <fork>
  if(pid == 0) {
    215e:	c115                	beqz	a0,2182 <stacktest+0x38>
  } else if(pid < 0){
    2160:	04054363          	bltz	a0,21a6 <stacktest+0x5c>
  wait(&xstatus);
    2164:	fdc40513          	addi	a0,s0,-36
    2168:	00003097          	auipc	ra,0x3
    216c:	388080e7          	jalr	904(ra) # 54f0 <wait>
  if(xstatus == -1)  // kernel killed child?
    2170:	fdc42503          	lw	a0,-36(s0)
    2174:	57fd                	li	a5,-1
    2176:	04f50663          	beq	a0,a5,21c2 <stacktest+0x78>
    exit(xstatus);
    217a:	00003097          	auipc	ra,0x3
    217e:	36e080e7          	jalr	878(ra) # 54e8 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    2182:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", *sp);
    2184:	77fd                	lui	a5,0xfffff
    2186:	97ba                	add	a5,a5,a4
    2188:	0007c583          	lbu	a1,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff0688>
    218c:	00005517          	auipc	a0,0x5
    2190:	81450513          	addi	a0,a0,-2028 # 69a0 <malloc+0x1082>
    2194:	00003097          	auipc	ra,0x3
    2198:	6cc080e7          	jalr	1740(ra) # 5860 <printf>
    exit(1);
    219c:	4505                	li	a0,1
    219e:	00003097          	auipc	ra,0x3
    21a2:	34a080e7          	jalr	842(ra) # 54e8 <exit>
    printf("%s: fork failed\n", s);
    21a6:	85a6                	mv	a1,s1
    21a8:	00004517          	auipc	a0,0x4
    21ac:	3d850513          	addi	a0,a0,984 # 6580 <malloc+0xc62>
    21b0:	00003097          	auipc	ra,0x3
    21b4:	6b0080e7          	jalr	1712(ra) # 5860 <printf>
    exit(1);
    21b8:	4505                	li	a0,1
    21ba:	00003097          	auipc	ra,0x3
    21be:	32e080e7          	jalr	814(ra) # 54e8 <exit>
    exit(0);
    21c2:	4501                	li	a0,0
    21c4:	00003097          	auipc	ra,0x3
    21c8:	324080e7          	jalr	804(ra) # 54e8 <exit>

00000000000021cc <copyinstr3>:
{
    21cc:	7179                	addi	sp,sp,-48
    21ce:	f406                	sd	ra,40(sp)
    21d0:	f022                	sd	s0,32(sp)
    21d2:	ec26                	sd	s1,24(sp)
    21d4:	1800                	addi	s0,sp,48
  sbrk(8192);
    21d6:	6509                	lui	a0,0x2
    21d8:	00003097          	auipc	ra,0x3
    21dc:	398080e7          	jalr	920(ra) # 5570 <sbrk>
  uint64 top = (uint64) sbrk(0);
    21e0:	4501                	li	a0,0
    21e2:	00003097          	auipc	ra,0x3
    21e6:	38e080e7          	jalr	910(ra) # 5570 <sbrk>
  if((top % PGSIZE) != 0){
    21ea:	03451793          	slli	a5,a0,0x34
    21ee:	e3c9                	bnez	a5,2270 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    21f0:	4501                	li	a0,0
    21f2:	00003097          	auipc	ra,0x3
    21f6:	37e080e7          	jalr	894(ra) # 5570 <sbrk>
  if(top % PGSIZE){
    21fa:	03451793          	slli	a5,a0,0x34
    21fe:	e3d9                	bnez	a5,2284 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2200:	fff50493          	addi	s1,a0,-1 # 1fff <kernmem+0x65>
  *b = 'x';
    2204:	07800793          	li	a5,120
    2208:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    220c:	8526                	mv	a0,s1
    220e:	00003097          	auipc	ra,0x3
    2212:	32a080e7          	jalr	810(ra) # 5538 <unlink>
  if(ret != -1){
    2216:	57fd                	li	a5,-1
    2218:	08f51363          	bne	a0,a5,229e <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    221c:	20100593          	li	a1,513
    2220:	8526                	mv	a0,s1
    2222:	00003097          	auipc	ra,0x3
    2226:	306080e7          	jalr	774(ra) # 5528 <open>
  if(fd != -1){
    222a:	57fd                	li	a5,-1
    222c:	08f51863          	bne	a0,a5,22bc <copyinstr3+0xf0>
  ret = link(b, b);
    2230:	85a6                	mv	a1,s1
    2232:	8526                	mv	a0,s1
    2234:	00003097          	auipc	ra,0x3
    2238:	314080e7          	jalr	788(ra) # 5548 <link>
  if(ret != -1){
    223c:	57fd                	li	a5,-1
    223e:	08f51e63          	bne	a0,a5,22da <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2242:	00005797          	auipc	a5,0x5
    2246:	3a678793          	addi	a5,a5,934 # 75e8 <malloc+0x1cca>
    224a:	fcf43823          	sd	a5,-48(s0)
    224e:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2252:	fd040593          	addi	a1,s0,-48
    2256:	8526                	mv	a0,s1
    2258:	00003097          	auipc	ra,0x3
    225c:	2c8080e7          	jalr	712(ra) # 5520 <exec>
  if(ret != -1){
    2260:	57fd                	li	a5,-1
    2262:	08f51c63          	bne	a0,a5,22fa <copyinstr3+0x12e>
}
    2266:	70a2                	ld	ra,40(sp)
    2268:	7402                	ld	s0,32(sp)
    226a:	64e2                	ld	s1,24(sp)
    226c:	6145                	addi	sp,sp,48
    226e:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2270:	0347d513          	srli	a0,a5,0x34
    2274:	6785                	lui	a5,0x1
    2276:	40a7853b          	subw	a0,a5,a0
    227a:	00003097          	auipc	ra,0x3
    227e:	2f6080e7          	jalr	758(ra) # 5570 <sbrk>
    2282:	b7bd                	j	21f0 <copyinstr3+0x24>
    printf("oops\n");
    2284:	00004517          	auipc	a0,0x4
    2288:	74450513          	addi	a0,a0,1860 # 69c8 <malloc+0x10aa>
    228c:	00003097          	auipc	ra,0x3
    2290:	5d4080e7          	jalr	1492(ra) # 5860 <printf>
    exit(1);
    2294:	4505                	li	a0,1
    2296:	00003097          	auipc	ra,0x3
    229a:	252080e7          	jalr	594(ra) # 54e8 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    229e:	862a                	mv	a2,a0
    22a0:	85a6                	mv	a1,s1
    22a2:	00004517          	auipc	a0,0x4
    22a6:	1fe50513          	addi	a0,a0,510 # 64a0 <malloc+0xb82>
    22aa:	00003097          	auipc	ra,0x3
    22ae:	5b6080e7          	jalr	1462(ra) # 5860 <printf>
    exit(1);
    22b2:	4505                	li	a0,1
    22b4:	00003097          	auipc	ra,0x3
    22b8:	234080e7          	jalr	564(ra) # 54e8 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    22bc:	862a                	mv	a2,a0
    22be:	85a6                	mv	a1,s1
    22c0:	00004517          	auipc	a0,0x4
    22c4:	20050513          	addi	a0,a0,512 # 64c0 <malloc+0xba2>
    22c8:	00003097          	auipc	ra,0x3
    22cc:	598080e7          	jalr	1432(ra) # 5860 <printf>
    exit(1);
    22d0:	4505                	li	a0,1
    22d2:	00003097          	auipc	ra,0x3
    22d6:	216080e7          	jalr	534(ra) # 54e8 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    22da:	86aa                	mv	a3,a0
    22dc:	8626                	mv	a2,s1
    22de:	85a6                	mv	a1,s1
    22e0:	00004517          	auipc	a0,0x4
    22e4:	20050513          	addi	a0,a0,512 # 64e0 <malloc+0xbc2>
    22e8:	00003097          	auipc	ra,0x3
    22ec:	578080e7          	jalr	1400(ra) # 5860 <printf>
    exit(1);
    22f0:	4505                	li	a0,1
    22f2:	00003097          	auipc	ra,0x3
    22f6:	1f6080e7          	jalr	502(ra) # 54e8 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    22fa:	567d                	li	a2,-1
    22fc:	85a6                	mv	a1,s1
    22fe:	00004517          	auipc	a0,0x4
    2302:	20a50513          	addi	a0,a0,522 # 6508 <malloc+0xbea>
    2306:	00003097          	auipc	ra,0x3
    230a:	55a080e7          	jalr	1370(ra) # 5860 <printf>
    exit(1);
    230e:	4505                	li	a0,1
    2310:	00003097          	auipc	ra,0x3
    2314:	1d8080e7          	jalr	472(ra) # 54e8 <exit>

0000000000002318 <rwsbrk>:
{
    2318:	1101                	addi	sp,sp,-32
    231a:	ec06                	sd	ra,24(sp)
    231c:	e822                	sd	s0,16(sp)
    231e:	e426                	sd	s1,8(sp)
    2320:	e04a                	sd	s2,0(sp)
    2322:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2324:	6509                	lui	a0,0x2
    2326:	00003097          	auipc	ra,0x3
    232a:	24a080e7          	jalr	586(ra) # 5570 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    232e:	57fd                	li	a5,-1
    2330:	06f50363          	beq	a0,a5,2396 <rwsbrk+0x7e>
    2334:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2336:	7579                	lui	a0,0xffffe
    2338:	00003097          	auipc	ra,0x3
    233c:	238080e7          	jalr	568(ra) # 5570 <sbrk>
    2340:	57fd                	li	a5,-1
    2342:	06f50763          	beq	a0,a5,23b0 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    2346:	20100593          	li	a1,513
    234a:	00003517          	auipc	a0,0x3
    234e:	72650513          	addi	a0,a0,1830 # 5a70 <malloc+0x152>
    2352:	00003097          	auipc	ra,0x3
    2356:	1d6080e7          	jalr	470(ra) # 5528 <open>
    235a:	892a                	mv	s2,a0
  if(fd < 0){
    235c:	06054763          	bltz	a0,23ca <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    2360:	6505                	lui	a0,0x1
    2362:	94aa                	add	s1,s1,a0
    2364:	40000613          	li	a2,1024
    2368:	85a6                	mv	a1,s1
    236a:	854a                	mv	a0,s2
    236c:	00003097          	auipc	ra,0x3
    2370:	19c080e7          	jalr	412(ra) # 5508 <write>
    2374:	862a                	mv	a2,a0
  if(n >= 0){
    2376:	06054763          	bltz	a0,23e4 <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    237a:	85a6                	mv	a1,s1
    237c:	00004517          	auipc	a0,0x4
    2380:	6a450513          	addi	a0,a0,1700 # 6a20 <malloc+0x1102>
    2384:	00003097          	auipc	ra,0x3
    2388:	4dc080e7          	jalr	1244(ra) # 5860 <printf>
    exit(1);
    238c:	4505                	li	a0,1
    238e:	00003097          	auipc	ra,0x3
    2392:	15a080e7          	jalr	346(ra) # 54e8 <exit>
    printf("sbrk(rwsbrk) failed\n");
    2396:	00004517          	auipc	a0,0x4
    239a:	63a50513          	addi	a0,a0,1594 # 69d0 <malloc+0x10b2>
    239e:	00003097          	auipc	ra,0x3
    23a2:	4c2080e7          	jalr	1218(ra) # 5860 <printf>
    exit(1);
    23a6:	4505                	li	a0,1
    23a8:	00003097          	auipc	ra,0x3
    23ac:	140080e7          	jalr	320(ra) # 54e8 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    23b0:	00004517          	auipc	a0,0x4
    23b4:	63850513          	addi	a0,a0,1592 # 69e8 <malloc+0x10ca>
    23b8:	00003097          	auipc	ra,0x3
    23bc:	4a8080e7          	jalr	1192(ra) # 5860 <printf>
    exit(1);
    23c0:	4505                	li	a0,1
    23c2:	00003097          	auipc	ra,0x3
    23c6:	126080e7          	jalr	294(ra) # 54e8 <exit>
    printf("open(rwsbrk) failed\n");
    23ca:	00004517          	auipc	a0,0x4
    23ce:	63e50513          	addi	a0,a0,1598 # 6a08 <malloc+0x10ea>
    23d2:	00003097          	auipc	ra,0x3
    23d6:	48e080e7          	jalr	1166(ra) # 5860 <printf>
    exit(1);
    23da:	4505                	li	a0,1
    23dc:	00003097          	auipc	ra,0x3
    23e0:	10c080e7          	jalr	268(ra) # 54e8 <exit>
  close(fd);
    23e4:	854a                	mv	a0,s2
    23e6:	00003097          	auipc	ra,0x3
    23ea:	12a080e7          	jalr	298(ra) # 5510 <close>
  unlink("rwsbrk");
    23ee:	00003517          	auipc	a0,0x3
    23f2:	68250513          	addi	a0,a0,1666 # 5a70 <malloc+0x152>
    23f6:	00003097          	auipc	ra,0x3
    23fa:	142080e7          	jalr	322(ra) # 5538 <unlink>
  fd = open("README", O_RDONLY);
    23fe:	4581                	li	a1,0
    2400:	00004517          	auipc	a0,0x4
    2404:	ae050513          	addi	a0,a0,-1312 # 5ee0 <malloc+0x5c2>
    2408:	00003097          	auipc	ra,0x3
    240c:	120080e7          	jalr	288(ra) # 5528 <open>
    2410:	892a                	mv	s2,a0
  if(fd < 0){
    2412:	02054963          	bltz	a0,2444 <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    2416:	4629                	li	a2,10
    2418:	85a6                	mv	a1,s1
    241a:	00003097          	auipc	ra,0x3
    241e:	0e6080e7          	jalr	230(ra) # 5500 <read>
    2422:	862a                	mv	a2,a0
  if(n >= 0){
    2424:	02054d63          	bltz	a0,245e <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2428:	85a6                	mv	a1,s1
    242a:	00004517          	auipc	a0,0x4
    242e:	62650513          	addi	a0,a0,1574 # 6a50 <malloc+0x1132>
    2432:	00003097          	auipc	ra,0x3
    2436:	42e080e7          	jalr	1070(ra) # 5860 <printf>
    exit(1);
    243a:	4505                	li	a0,1
    243c:	00003097          	auipc	ra,0x3
    2440:	0ac080e7          	jalr	172(ra) # 54e8 <exit>
    printf("open(rwsbrk) failed\n");
    2444:	00004517          	auipc	a0,0x4
    2448:	5c450513          	addi	a0,a0,1476 # 6a08 <malloc+0x10ea>
    244c:	00003097          	auipc	ra,0x3
    2450:	414080e7          	jalr	1044(ra) # 5860 <printf>
    exit(1);
    2454:	4505                	li	a0,1
    2456:	00003097          	auipc	ra,0x3
    245a:	092080e7          	jalr	146(ra) # 54e8 <exit>
  close(fd);
    245e:	854a                	mv	a0,s2
    2460:	00003097          	auipc	ra,0x3
    2464:	0b0080e7          	jalr	176(ra) # 5510 <close>
  exit(0);
    2468:	4501                	li	a0,0
    246a:	00003097          	auipc	ra,0x3
    246e:	07e080e7          	jalr	126(ra) # 54e8 <exit>

0000000000002472 <sbrkbasic>:
{
    2472:	7139                	addi	sp,sp,-64
    2474:	fc06                	sd	ra,56(sp)
    2476:	f822                	sd	s0,48(sp)
    2478:	f426                	sd	s1,40(sp)
    247a:	f04a                	sd	s2,32(sp)
    247c:	ec4e                	sd	s3,24(sp)
    247e:	e852                	sd	s4,16(sp)
    2480:	0080                	addi	s0,sp,64
    2482:	8a2a                	mv	s4,a0
  pid = fork();
    2484:	00003097          	auipc	ra,0x3
    2488:	05c080e7          	jalr	92(ra) # 54e0 <fork>
  if(pid < 0){
    248c:	02054c63          	bltz	a0,24c4 <sbrkbasic+0x52>
  if(pid == 0){
    2490:	ed21                	bnez	a0,24e8 <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    2492:	40000537          	lui	a0,0x40000
    2496:	00003097          	auipc	ra,0x3
    249a:	0da080e7          	jalr	218(ra) # 5570 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    249e:	57fd                	li	a5,-1
    24a0:	02f50f63          	beq	a0,a5,24de <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    24a4:	400007b7          	lui	a5,0x40000
    24a8:	97aa                	add	a5,a5,a0
      *b = 99;
    24aa:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    24ae:	6705                	lui	a4,0x1
      *b = 99;
    24b0:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff1688>
    for(b = a; b < a+TOOMUCH; b += 4096){
    24b4:	953a                	add	a0,a0,a4
    24b6:	fef51de3          	bne	a0,a5,24b0 <sbrkbasic+0x3e>
    exit(1);
    24ba:	4505                	li	a0,1
    24bc:	00003097          	auipc	ra,0x3
    24c0:	02c080e7          	jalr	44(ra) # 54e8 <exit>
    printf("fork failed in sbrkbasic\n");
    24c4:	00004517          	auipc	a0,0x4
    24c8:	5b450513          	addi	a0,a0,1460 # 6a78 <malloc+0x115a>
    24cc:	00003097          	auipc	ra,0x3
    24d0:	394080e7          	jalr	916(ra) # 5860 <printf>
    exit(1);
    24d4:	4505                	li	a0,1
    24d6:	00003097          	auipc	ra,0x3
    24da:	012080e7          	jalr	18(ra) # 54e8 <exit>
      exit(0);
    24de:	4501                	li	a0,0
    24e0:	00003097          	auipc	ra,0x3
    24e4:	008080e7          	jalr	8(ra) # 54e8 <exit>
  wait(&xstatus);
    24e8:	fcc40513          	addi	a0,s0,-52
    24ec:	00003097          	auipc	ra,0x3
    24f0:	004080e7          	jalr	4(ra) # 54f0 <wait>
  if(xstatus == 1){
    24f4:	fcc42703          	lw	a4,-52(s0)
    24f8:	4785                	li	a5,1
    24fa:	00f70d63          	beq	a4,a5,2514 <sbrkbasic+0xa2>
  a = sbrk(0);
    24fe:	4501                	li	a0,0
    2500:	00003097          	auipc	ra,0x3
    2504:	070080e7          	jalr	112(ra) # 5570 <sbrk>
    2508:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    250a:	4901                	li	s2,0
    250c:	6985                	lui	s3,0x1
    250e:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1ce>
    2512:	a005                	j	2532 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    2514:	85d2                	mv	a1,s4
    2516:	00004517          	auipc	a0,0x4
    251a:	58250513          	addi	a0,a0,1410 # 6a98 <malloc+0x117a>
    251e:	00003097          	auipc	ra,0x3
    2522:	342080e7          	jalr	834(ra) # 5860 <printf>
    exit(1);
    2526:	4505                	li	a0,1
    2528:	00003097          	auipc	ra,0x3
    252c:	fc0080e7          	jalr	-64(ra) # 54e8 <exit>
    a = b + 1;
    2530:	84be                	mv	s1,a5
    b = sbrk(1);
    2532:	4505                	li	a0,1
    2534:	00003097          	auipc	ra,0x3
    2538:	03c080e7          	jalr	60(ra) # 5570 <sbrk>
    if(b != a){
    253c:	04951c63          	bne	a0,s1,2594 <sbrkbasic+0x122>
    *b = 1;
    2540:	4785                	li	a5,1
    2542:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2546:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    254a:	2905                	addiw	s2,s2,1
    254c:	ff3912e3          	bne	s2,s3,2530 <sbrkbasic+0xbe>
  pid = fork();
    2550:	00003097          	auipc	ra,0x3
    2554:	f90080e7          	jalr	-112(ra) # 54e0 <fork>
    2558:	892a                	mv	s2,a0
  if(pid < 0){
    255a:	04054d63          	bltz	a0,25b4 <sbrkbasic+0x142>
  c = sbrk(1);
    255e:	4505                	li	a0,1
    2560:	00003097          	auipc	ra,0x3
    2564:	010080e7          	jalr	16(ra) # 5570 <sbrk>
  c = sbrk(1);
    2568:	4505                	li	a0,1
    256a:	00003097          	auipc	ra,0x3
    256e:	006080e7          	jalr	6(ra) # 5570 <sbrk>
  if(c != a + 1){
    2572:	0489                	addi	s1,s1,2
    2574:	04a48e63          	beq	s1,a0,25d0 <sbrkbasic+0x15e>
    printf("%s: sbrk test failed post-fork\n", s);
    2578:	85d2                	mv	a1,s4
    257a:	00004517          	auipc	a0,0x4
    257e:	57e50513          	addi	a0,a0,1406 # 6af8 <malloc+0x11da>
    2582:	00003097          	auipc	ra,0x3
    2586:	2de080e7          	jalr	734(ra) # 5860 <printf>
    exit(1);
    258a:	4505                	li	a0,1
    258c:	00003097          	auipc	ra,0x3
    2590:	f5c080e7          	jalr	-164(ra) # 54e8 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    2594:	86aa                	mv	a3,a0
    2596:	8626                	mv	a2,s1
    2598:	85ca                	mv	a1,s2
    259a:	00004517          	auipc	a0,0x4
    259e:	51e50513          	addi	a0,a0,1310 # 6ab8 <malloc+0x119a>
    25a2:	00003097          	auipc	ra,0x3
    25a6:	2be080e7          	jalr	702(ra) # 5860 <printf>
      exit(1);
    25aa:	4505                	li	a0,1
    25ac:	00003097          	auipc	ra,0x3
    25b0:	f3c080e7          	jalr	-196(ra) # 54e8 <exit>
    printf("%s: sbrk test fork failed\n", s);
    25b4:	85d2                	mv	a1,s4
    25b6:	00004517          	auipc	a0,0x4
    25ba:	52250513          	addi	a0,a0,1314 # 6ad8 <malloc+0x11ba>
    25be:	00003097          	auipc	ra,0x3
    25c2:	2a2080e7          	jalr	674(ra) # 5860 <printf>
    exit(1);
    25c6:	4505                	li	a0,1
    25c8:	00003097          	auipc	ra,0x3
    25cc:	f20080e7          	jalr	-224(ra) # 54e8 <exit>
  if(pid == 0)
    25d0:	00091763          	bnez	s2,25de <sbrkbasic+0x16c>
    exit(0);
    25d4:	4501                	li	a0,0
    25d6:	00003097          	auipc	ra,0x3
    25da:	f12080e7          	jalr	-238(ra) # 54e8 <exit>
  wait(&xstatus);
    25de:	fcc40513          	addi	a0,s0,-52
    25e2:	00003097          	auipc	ra,0x3
    25e6:	f0e080e7          	jalr	-242(ra) # 54f0 <wait>
  exit(xstatus);
    25ea:	fcc42503          	lw	a0,-52(s0)
    25ee:	00003097          	auipc	ra,0x3
    25f2:	efa080e7          	jalr	-262(ra) # 54e8 <exit>

00000000000025f6 <sbrkmuch>:
{
    25f6:	7179                	addi	sp,sp,-48
    25f8:	f406                	sd	ra,40(sp)
    25fa:	f022                	sd	s0,32(sp)
    25fc:	ec26                	sd	s1,24(sp)
    25fe:	e84a                	sd	s2,16(sp)
    2600:	e44e                	sd	s3,8(sp)
    2602:	e052                	sd	s4,0(sp)
    2604:	1800                	addi	s0,sp,48
    2606:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2608:	4501                	li	a0,0
    260a:	00003097          	auipc	ra,0x3
    260e:	f66080e7          	jalr	-154(ra) # 5570 <sbrk>
    2612:	892a                	mv	s2,a0
  a = sbrk(0);
    2614:	4501                	li	a0,0
    2616:	00003097          	auipc	ra,0x3
    261a:	f5a080e7          	jalr	-166(ra) # 5570 <sbrk>
    261e:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2620:	06400537          	lui	a0,0x6400
    2624:	9d05                	subw	a0,a0,s1
    2626:	00003097          	auipc	ra,0x3
    262a:	f4a080e7          	jalr	-182(ra) # 5570 <sbrk>
  if (p != a) {
    262e:	0ca49863          	bne	s1,a0,26fe <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2632:	4501                	li	a0,0
    2634:	00003097          	auipc	ra,0x3
    2638:	f3c080e7          	jalr	-196(ra) # 5570 <sbrk>
    263c:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    263e:	00a4f963          	bgeu	s1,a0,2650 <sbrkmuch+0x5a>
    *pp = 1;
    2642:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2644:	6705                	lui	a4,0x1
    *pp = 1;
    2646:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    264a:	94ba                	add	s1,s1,a4
    264c:	fef4ede3          	bltu	s1,a5,2646 <sbrkmuch+0x50>
  *lastaddr = 99;
    2650:	064007b7          	lui	a5,0x6400
    2654:	06300713          	li	a4,99
    2658:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f1687>
  a = sbrk(0);
    265c:	4501                	li	a0,0
    265e:	00003097          	auipc	ra,0x3
    2662:	f12080e7          	jalr	-238(ra) # 5570 <sbrk>
    2666:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2668:	757d                	lui	a0,0xfffff
    266a:	00003097          	auipc	ra,0x3
    266e:	f06080e7          	jalr	-250(ra) # 5570 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2672:	57fd                	li	a5,-1
    2674:	0af50363          	beq	a0,a5,271a <sbrkmuch+0x124>
  c = sbrk(0);
    2678:	4501                	li	a0,0
    267a:	00003097          	auipc	ra,0x3
    267e:	ef6080e7          	jalr	-266(ra) # 5570 <sbrk>
  if(c != a - PGSIZE){
    2682:	77fd                	lui	a5,0xfffff
    2684:	97a6                	add	a5,a5,s1
    2686:	0af51863          	bne	a0,a5,2736 <sbrkmuch+0x140>
  a = sbrk(0);
    268a:	4501                	li	a0,0
    268c:	00003097          	auipc	ra,0x3
    2690:	ee4080e7          	jalr	-284(ra) # 5570 <sbrk>
    2694:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2696:	6505                	lui	a0,0x1
    2698:	00003097          	auipc	ra,0x3
    269c:	ed8080e7          	jalr	-296(ra) # 5570 <sbrk>
    26a0:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    26a2:	0aa49963          	bne	s1,a0,2754 <sbrkmuch+0x15e>
    26a6:	4501                	li	a0,0
    26a8:	00003097          	auipc	ra,0x3
    26ac:	ec8080e7          	jalr	-312(ra) # 5570 <sbrk>
    26b0:	6785                	lui	a5,0x1
    26b2:	97a6                	add	a5,a5,s1
    26b4:	0af51063          	bne	a0,a5,2754 <sbrkmuch+0x15e>
  if(*lastaddr == 99){
    26b8:	064007b7          	lui	a5,0x6400
    26bc:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f1687>
    26c0:	06300793          	li	a5,99
    26c4:	0af70763          	beq	a4,a5,2772 <sbrkmuch+0x17c>
  a = sbrk(0);
    26c8:	4501                	li	a0,0
    26ca:	00003097          	auipc	ra,0x3
    26ce:	ea6080e7          	jalr	-346(ra) # 5570 <sbrk>
    26d2:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    26d4:	4501                	li	a0,0
    26d6:	00003097          	auipc	ra,0x3
    26da:	e9a080e7          	jalr	-358(ra) # 5570 <sbrk>
    26de:	40a9053b          	subw	a0,s2,a0
    26e2:	00003097          	auipc	ra,0x3
    26e6:	e8e080e7          	jalr	-370(ra) # 5570 <sbrk>
  if(c != a){
    26ea:	0aa49263          	bne	s1,a0,278e <sbrkmuch+0x198>
}
    26ee:	70a2                	ld	ra,40(sp)
    26f0:	7402                	ld	s0,32(sp)
    26f2:	64e2                	ld	s1,24(sp)
    26f4:	6942                	ld	s2,16(sp)
    26f6:	69a2                	ld	s3,8(sp)
    26f8:	6a02                	ld	s4,0(sp)
    26fa:	6145                	addi	sp,sp,48
    26fc:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    26fe:	85ce                	mv	a1,s3
    2700:	00004517          	auipc	a0,0x4
    2704:	41850513          	addi	a0,a0,1048 # 6b18 <malloc+0x11fa>
    2708:	00003097          	auipc	ra,0x3
    270c:	158080e7          	jalr	344(ra) # 5860 <printf>
    exit(1);
    2710:	4505                	li	a0,1
    2712:	00003097          	auipc	ra,0x3
    2716:	dd6080e7          	jalr	-554(ra) # 54e8 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    271a:	85ce                	mv	a1,s3
    271c:	00004517          	auipc	a0,0x4
    2720:	44450513          	addi	a0,a0,1092 # 6b60 <malloc+0x1242>
    2724:	00003097          	auipc	ra,0x3
    2728:	13c080e7          	jalr	316(ra) # 5860 <printf>
    exit(1);
    272c:	4505                	li	a0,1
    272e:	00003097          	auipc	ra,0x3
    2732:	dba080e7          	jalr	-582(ra) # 54e8 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    2736:	862a                	mv	a2,a0
    2738:	85a6                	mv	a1,s1
    273a:	00004517          	auipc	a0,0x4
    273e:	44650513          	addi	a0,a0,1094 # 6b80 <malloc+0x1262>
    2742:	00003097          	auipc	ra,0x3
    2746:	11e080e7          	jalr	286(ra) # 5860 <printf>
    exit(1);
    274a:	4505                	li	a0,1
    274c:	00003097          	auipc	ra,0x3
    2750:	d9c080e7          	jalr	-612(ra) # 54e8 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", a, c);
    2754:	8652                	mv	a2,s4
    2756:	85a6                	mv	a1,s1
    2758:	00004517          	auipc	a0,0x4
    275c:	46850513          	addi	a0,a0,1128 # 6bc0 <malloc+0x12a2>
    2760:	00003097          	auipc	ra,0x3
    2764:	100080e7          	jalr	256(ra) # 5860 <printf>
    exit(1);
    2768:	4505                	li	a0,1
    276a:	00003097          	auipc	ra,0x3
    276e:	d7e080e7          	jalr	-642(ra) # 54e8 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2772:	85ce                	mv	a1,s3
    2774:	00004517          	auipc	a0,0x4
    2778:	47c50513          	addi	a0,a0,1148 # 6bf0 <malloc+0x12d2>
    277c:	00003097          	auipc	ra,0x3
    2780:	0e4080e7          	jalr	228(ra) # 5860 <printf>
    exit(1);
    2784:	4505                	li	a0,1
    2786:	00003097          	auipc	ra,0x3
    278a:	d62080e7          	jalr	-670(ra) # 54e8 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", a, c);
    278e:	862a                	mv	a2,a0
    2790:	85a6                	mv	a1,s1
    2792:	00004517          	auipc	a0,0x4
    2796:	49650513          	addi	a0,a0,1174 # 6c28 <malloc+0x130a>
    279a:	00003097          	auipc	ra,0x3
    279e:	0c6080e7          	jalr	198(ra) # 5860 <printf>
    exit(1);
    27a2:	4505                	li	a0,1
    27a4:	00003097          	auipc	ra,0x3
    27a8:	d44080e7          	jalr	-700(ra) # 54e8 <exit>

00000000000027ac <sbrkarg>:
{
    27ac:	7179                	addi	sp,sp,-48
    27ae:	f406                	sd	ra,40(sp)
    27b0:	f022                	sd	s0,32(sp)
    27b2:	ec26                	sd	s1,24(sp)
    27b4:	e84a                	sd	s2,16(sp)
    27b6:	e44e                	sd	s3,8(sp)
    27b8:	1800                	addi	s0,sp,48
    27ba:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    27bc:	6505                	lui	a0,0x1
    27be:	00003097          	auipc	ra,0x3
    27c2:	db2080e7          	jalr	-590(ra) # 5570 <sbrk>
    27c6:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    27c8:	20100593          	li	a1,513
    27cc:	00004517          	auipc	a0,0x4
    27d0:	48450513          	addi	a0,a0,1156 # 6c50 <malloc+0x1332>
    27d4:	00003097          	auipc	ra,0x3
    27d8:	d54080e7          	jalr	-684(ra) # 5528 <open>
    27dc:	84aa                	mv	s1,a0
  unlink("sbrk");
    27de:	00004517          	auipc	a0,0x4
    27e2:	47250513          	addi	a0,a0,1138 # 6c50 <malloc+0x1332>
    27e6:	00003097          	auipc	ra,0x3
    27ea:	d52080e7          	jalr	-686(ra) # 5538 <unlink>
  if(fd < 0)  {
    27ee:	0404c163          	bltz	s1,2830 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    27f2:	6605                	lui	a2,0x1
    27f4:	85ca                	mv	a1,s2
    27f6:	8526                	mv	a0,s1
    27f8:	00003097          	auipc	ra,0x3
    27fc:	d10080e7          	jalr	-752(ra) # 5508 <write>
    2800:	04054663          	bltz	a0,284c <sbrkarg+0xa0>
  close(fd);
    2804:	8526                	mv	a0,s1
    2806:	00003097          	auipc	ra,0x3
    280a:	d0a080e7          	jalr	-758(ra) # 5510 <close>
  a = sbrk(PGSIZE);
    280e:	6505                	lui	a0,0x1
    2810:	00003097          	auipc	ra,0x3
    2814:	d60080e7          	jalr	-672(ra) # 5570 <sbrk>
  if(pipe((int *) a) != 0){
    2818:	00003097          	auipc	ra,0x3
    281c:	ce0080e7          	jalr	-800(ra) # 54f8 <pipe>
    2820:	e521                	bnez	a0,2868 <sbrkarg+0xbc>
}
    2822:	70a2                	ld	ra,40(sp)
    2824:	7402                	ld	s0,32(sp)
    2826:	64e2                	ld	s1,24(sp)
    2828:	6942                	ld	s2,16(sp)
    282a:	69a2                	ld	s3,8(sp)
    282c:	6145                	addi	sp,sp,48
    282e:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2830:	85ce                	mv	a1,s3
    2832:	00004517          	auipc	a0,0x4
    2836:	42650513          	addi	a0,a0,1062 # 6c58 <malloc+0x133a>
    283a:	00003097          	auipc	ra,0x3
    283e:	026080e7          	jalr	38(ra) # 5860 <printf>
    exit(1);
    2842:	4505                	li	a0,1
    2844:	00003097          	auipc	ra,0x3
    2848:	ca4080e7          	jalr	-860(ra) # 54e8 <exit>
    printf("%s: write sbrk failed\n", s);
    284c:	85ce                	mv	a1,s3
    284e:	00004517          	auipc	a0,0x4
    2852:	42250513          	addi	a0,a0,1058 # 6c70 <malloc+0x1352>
    2856:	00003097          	auipc	ra,0x3
    285a:	00a080e7          	jalr	10(ra) # 5860 <printf>
    exit(1);
    285e:	4505                	li	a0,1
    2860:	00003097          	auipc	ra,0x3
    2864:	c88080e7          	jalr	-888(ra) # 54e8 <exit>
    printf("%s: pipe() failed\n", s);
    2868:	85ce                	mv	a1,s3
    286a:	00004517          	auipc	a0,0x4
    286e:	e1e50513          	addi	a0,a0,-482 # 6688 <malloc+0xd6a>
    2872:	00003097          	auipc	ra,0x3
    2876:	fee080e7          	jalr	-18(ra) # 5860 <printf>
    exit(1);
    287a:	4505                	li	a0,1
    287c:	00003097          	auipc	ra,0x3
    2880:	c6c080e7          	jalr	-916(ra) # 54e8 <exit>

0000000000002884 <argptest>:
{
    2884:	1101                	addi	sp,sp,-32
    2886:	ec06                	sd	ra,24(sp)
    2888:	e822                	sd	s0,16(sp)
    288a:	e426                	sd	s1,8(sp)
    288c:	e04a                	sd	s2,0(sp)
    288e:	1000                	addi	s0,sp,32
    2890:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2892:	4581                	li	a1,0
    2894:	00004517          	auipc	a0,0x4
    2898:	3f450513          	addi	a0,a0,1012 # 6c88 <malloc+0x136a>
    289c:	00003097          	auipc	ra,0x3
    28a0:	c8c080e7          	jalr	-884(ra) # 5528 <open>
  if (fd < 0) {
    28a4:	02054b63          	bltz	a0,28da <argptest+0x56>
    28a8:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    28aa:	4501                	li	a0,0
    28ac:	00003097          	auipc	ra,0x3
    28b0:	cc4080e7          	jalr	-828(ra) # 5570 <sbrk>
    28b4:	567d                	li	a2,-1
    28b6:	fff50593          	addi	a1,a0,-1
    28ba:	8526                	mv	a0,s1
    28bc:	00003097          	auipc	ra,0x3
    28c0:	c44080e7          	jalr	-956(ra) # 5500 <read>
  close(fd);
    28c4:	8526                	mv	a0,s1
    28c6:	00003097          	auipc	ra,0x3
    28ca:	c4a080e7          	jalr	-950(ra) # 5510 <close>
}
    28ce:	60e2                	ld	ra,24(sp)
    28d0:	6442                	ld	s0,16(sp)
    28d2:	64a2                	ld	s1,8(sp)
    28d4:	6902                	ld	s2,0(sp)
    28d6:	6105                	addi	sp,sp,32
    28d8:	8082                	ret
    printf("%s: open failed\n", s);
    28da:	85ca                	mv	a1,s2
    28dc:	00004517          	auipc	a0,0x4
    28e0:	cbc50513          	addi	a0,a0,-836 # 6598 <malloc+0xc7a>
    28e4:	00003097          	auipc	ra,0x3
    28e8:	f7c080e7          	jalr	-132(ra) # 5860 <printf>
    exit(1);
    28ec:	4505                	li	a0,1
    28ee:	00003097          	auipc	ra,0x3
    28f2:	bfa080e7          	jalr	-1030(ra) # 54e8 <exit>

00000000000028f6 <sbrkbugs>:
{
    28f6:	1141                	addi	sp,sp,-16
    28f8:	e406                	sd	ra,8(sp)
    28fa:	e022                	sd	s0,0(sp)
    28fc:	0800                	addi	s0,sp,16
  int pid = fork();
    28fe:	00003097          	auipc	ra,0x3
    2902:	be2080e7          	jalr	-1054(ra) # 54e0 <fork>
  if(pid < 0){
    2906:	02054263          	bltz	a0,292a <sbrkbugs+0x34>
  if(pid == 0){
    290a:	ed0d                	bnez	a0,2944 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    290c:	00003097          	auipc	ra,0x3
    2910:	c64080e7          	jalr	-924(ra) # 5570 <sbrk>
    sbrk(-sz);
    2914:	40a0053b          	negw	a0,a0
    2918:	00003097          	auipc	ra,0x3
    291c:	c58080e7          	jalr	-936(ra) # 5570 <sbrk>
    exit(0);
    2920:	4501                	li	a0,0
    2922:	00003097          	auipc	ra,0x3
    2926:	bc6080e7          	jalr	-1082(ra) # 54e8 <exit>
    printf("fork failed\n");
    292a:	00004517          	auipc	a0,0x4
    292e:	04650513          	addi	a0,a0,70 # 6970 <malloc+0x1052>
    2932:	00003097          	auipc	ra,0x3
    2936:	f2e080e7          	jalr	-210(ra) # 5860 <printf>
    exit(1);
    293a:	4505                	li	a0,1
    293c:	00003097          	auipc	ra,0x3
    2940:	bac080e7          	jalr	-1108(ra) # 54e8 <exit>
  wait(0);
    2944:	4501                	li	a0,0
    2946:	00003097          	auipc	ra,0x3
    294a:	baa080e7          	jalr	-1110(ra) # 54f0 <wait>
  pid = fork();
    294e:	00003097          	auipc	ra,0x3
    2952:	b92080e7          	jalr	-1134(ra) # 54e0 <fork>
  if(pid < 0){
    2956:	02054563          	bltz	a0,2980 <sbrkbugs+0x8a>
  if(pid == 0){
    295a:	e121                	bnez	a0,299a <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    295c:	00003097          	auipc	ra,0x3
    2960:	c14080e7          	jalr	-1004(ra) # 5570 <sbrk>
    sbrk(-(sz - 3500));
    2964:	6785                	lui	a5,0x1
    2966:	dac7879b          	addiw	a5,a5,-596
    296a:	40a7853b          	subw	a0,a5,a0
    296e:	00003097          	auipc	ra,0x3
    2972:	c02080e7          	jalr	-1022(ra) # 5570 <sbrk>
    exit(0);
    2976:	4501                	li	a0,0
    2978:	00003097          	auipc	ra,0x3
    297c:	b70080e7          	jalr	-1168(ra) # 54e8 <exit>
    printf("fork failed\n");
    2980:	00004517          	auipc	a0,0x4
    2984:	ff050513          	addi	a0,a0,-16 # 6970 <malloc+0x1052>
    2988:	00003097          	auipc	ra,0x3
    298c:	ed8080e7          	jalr	-296(ra) # 5860 <printf>
    exit(1);
    2990:	4505                	li	a0,1
    2992:	00003097          	auipc	ra,0x3
    2996:	b56080e7          	jalr	-1194(ra) # 54e8 <exit>
  wait(0);
    299a:	4501                	li	a0,0
    299c:	00003097          	auipc	ra,0x3
    29a0:	b54080e7          	jalr	-1196(ra) # 54f0 <wait>
  pid = fork();
    29a4:	00003097          	auipc	ra,0x3
    29a8:	b3c080e7          	jalr	-1220(ra) # 54e0 <fork>
  if(pid < 0){
    29ac:	02054a63          	bltz	a0,29e0 <sbrkbugs+0xea>
  if(pid == 0){
    29b0:	e529                	bnez	a0,29fa <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    29b2:	00003097          	auipc	ra,0x3
    29b6:	bbe080e7          	jalr	-1090(ra) # 5570 <sbrk>
    29ba:	67ad                	lui	a5,0xb
    29bc:	8007879b          	addiw	a5,a5,-2048
    29c0:	40a7853b          	subw	a0,a5,a0
    29c4:	00003097          	auipc	ra,0x3
    29c8:	bac080e7          	jalr	-1108(ra) # 5570 <sbrk>
    sbrk(-10);
    29cc:	5559                	li	a0,-10
    29ce:	00003097          	auipc	ra,0x3
    29d2:	ba2080e7          	jalr	-1118(ra) # 5570 <sbrk>
    exit(0);
    29d6:	4501                	li	a0,0
    29d8:	00003097          	auipc	ra,0x3
    29dc:	b10080e7          	jalr	-1264(ra) # 54e8 <exit>
    printf("fork failed\n");
    29e0:	00004517          	auipc	a0,0x4
    29e4:	f9050513          	addi	a0,a0,-112 # 6970 <malloc+0x1052>
    29e8:	00003097          	auipc	ra,0x3
    29ec:	e78080e7          	jalr	-392(ra) # 5860 <printf>
    exit(1);
    29f0:	4505                	li	a0,1
    29f2:	00003097          	auipc	ra,0x3
    29f6:	af6080e7          	jalr	-1290(ra) # 54e8 <exit>
  wait(0);
    29fa:	4501                	li	a0,0
    29fc:	00003097          	auipc	ra,0x3
    2a00:	af4080e7          	jalr	-1292(ra) # 54f0 <wait>
  exit(0);
    2a04:	4501                	li	a0,0
    2a06:	00003097          	auipc	ra,0x3
    2a0a:	ae2080e7          	jalr	-1310(ra) # 54e8 <exit>

0000000000002a0e <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2a0e:	715d                	addi	sp,sp,-80
    2a10:	e486                	sd	ra,72(sp)
    2a12:	e0a2                	sd	s0,64(sp)
    2a14:	fc26                	sd	s1,56(sp)
    2a16:	f84a                	sd	s2,48(sp)
    2a18:	f44e                	sd	s3,40(sp)
    2a1a:	f052                	sd	s4,32(sp)
    2a1c:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2a1e:	4901                	li	s2,0
    2a20:	49bd                	li	s3,15
    int pid = fork();
    2a22:	00003097          	auipc	ra,0x3
    2a26:	abe080e7          	jalr	-1346(ra) # 54e0 <fork>
    2a2a:	84aa                	mv	s1,a0
    if(pid < 0){
    2a2c:	02054063          	bltz	a0,2a4c <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2a30:	c91d                	beqz	a0,2a66 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2a32:	4501                	li	a0,0
    2a34:	00003097          	auipc	ra,0x3
    2a38:	abc080e7          	jalr	-1348(ra) # 54f0 <wait>
  for(int avail = 0; avail < 15; avail++){
    2a3c:	2905                	addiw	s2,s2,1
    2a3e:	ff3912e3          	bne	s2,s3,2a22 <execout+0x14>
    }
  }

  exit(0);
    2a42:	4501                	li	a0,0
    2a44:	00003097          	auipc	ra,0x3
    2a48:	aa4080e7          	jalr	-1372(ra) # 54e8 <exit>
      printf("fork failed\n");
    2a4c:	00004517          	auipc	a0,0x4
    2a50:	f2450513          	addi	a0,a0,-220 # 6970 <malloc+0x1052>
    2a54:	00003097          	auipc	ra,0x3
    2a58:	e0c080e7          	jalr	-500(ra) # 5860 <printf>
      exit(1);
    2a5c:	4505                	li	a0,1
    2a5e:	00003097          	auipc	ra,0x3
    2a62:	a8a080e7          	jalr	-1398(ra) # 54e8 <exit>
        if(a == 0xffffffffffffffffLL)
    2a66:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2a68:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2a6a:	6505                	lui	a0,0x1
    2a6c:	00003097          	auipc	ra,0x3
    2a70:	b04080e7          	jalr	-1276(ra) # 5570 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2a74:	01350763          	beq	a0,s3,2a82 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2a78:	6785                	lui	a5,0x1
    2a7a:	953e                	add	a0,a0,a5
    2a7c:	ff450fa3          	sb	s4,-1(a0) # fff <bigdir+0x95>
      while(1){
    2a80:	b7ed                	j	2a6a <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2a82:	01205a63          	blez	s2,2a96 <execout+0x88>
        sbrk(-4096);
    2a86:	757d                	lui	a0,0xfffff
    2a88:	00003097          	auipc	ra,0x3
    2a8c:	ae8080e7          	jalr	-1304(ra) # 5570 <sbrk>
      for(int i = 0; i < avail; i++)
    2a90:	2485                	addiw	s1,s1,1
    2a92:	ff249ae3          	bne	s1,s2,2a86 <execout+0x78>
      close(1);
    2a96:	4505                	li	a0,1
    2a98:	00003097          	auipc	ra,0x3
    2a9c:	a78080e7          	jalr	-1416(ra) # 5510 <close>
      char *args[] = { "echo", "x", 0 };
    2aa0:	00003517          	auipc	a0,0x3
    2aa4:	2a850513          	addi	a0,a0,680 # 5d48 <malloc+0x42a>
    2aa8:	faa43c23          	sd	a0,-72(s0)
    2aac:	00003797          	auipc	a5,0x3
    2ab0:	30c78793          	addi	a5,a5,780 # 5db8 <malloc+0x49a>
    2ab4:	fcf43023          	sd	a5,-64(s0)
    2ab8:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2abc:	fb840593          	addi	a1,s0,-72
    2ac0:	00003097          	auipc	ra,0x3
    2ac4:	a60080e7          	jalr	-1440(ra) # 5520 <exec>
      exit(0);
    2ac8:	4501                	li	a0,0
    2aca:	00003097          	auipc	ra,0x3
    2ace:	a1e080e7          	jalr	-1506(ra) # 54e8 <exit>

0000000000002ad2 <fourteen>:
{
    2ad2:	1101                	addi	sp,sp,-32
    2ad4:	ec06                	sd	ra,24(sp)
    2ad6:	e822                	sd	s0,16(sp)
    2ad8:	e426                	sd	s1,8(sp)
    2ada:	1000                	addi	s0,sp,32
    2adc:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2ade:	00004517          	auipc	a0,0x4
    2ae2:	38250513          	addi	a0,a0,898 # 6e60 <malloc+0x1542>
    2ae6:	00003097          	auipc	ra,0x3
    2aea:	a6a080e7          	jalr	-1430(ra) # 5550 <mkdir>
    2aee:	e165                	bnez	a0,2bce <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2af0:	00004517          	auipc	a0,0x4
    2af4:	1c850513          	addi	a0,a0,456 # 6cb8 <malloc+0x139a>
    2af8:	00003097          	auipc	ra,0x3
    2afc:	a58080e7          	jalr	-1448(ra) # 5550 <mkdir>
    2b00:	e56d                	bnez	a0,2bea <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2b02:	20000593          	li	a1,512
    2b06:	00004517          	auipc	a0,0x4
    2b0a:	20a50513          	addi	a0,a0,522 # 6d10 <malloc+0x13f2>
    2b0e:	00003097          	auipc	ra,0x3
    2b12:	a1a080e7          	jalr	-1510(ra) # 5528 <open>
  if(fd < 0){
    2b16:	0e054863          	bltz	a0,2c06 <fourteen+0x134>
  close(fd);
    2b1a:	00003097          	auipc	ra,0x3
    2b1e:	9f6080e7          	jalr	-1546(ra) # 5510 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2b22:	4581                	li	a1,0
    2b24:	00004517          	auipc	a0,0x4
    2b28:	26450513          	addi	a0,a0,612 # 6d88 <malloc+0x146a>
    2b2c:	00003097          	auipc	ra,0x3
    2b30:	9fc080e7          	jalr	-1540(ra) # 5528 <open>
  if(fd < 0){
    2b34:	0e054763          	bltz	a0,2c22 <fourteen+0x150>
  close(fd);
    2b38:	00003097          	auipc	ra,0x3
    2b3c:	9d8080e7          	jalr	-1576(ra) # 5510 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2b40:	00004517          	auipc	a0,0x4
    2b44:	2b850513          	addi	a0,a0,696 # 6df8 <malloc+0x14da>
    2b48:	00003097          	auipc	ra,0x3
    2b4c:	a08080e7          	jalr	-1528(ra) # 5550 <mkdir>
    2b50:	c57d                	beqz	a0,2c3e <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2b52:	00004517          	auipc	a0,0x4
    2b56:	2fe50513          	addi	a0,a0,766 # 6e50 <malloc+0x1532>
    2b5a:	00003097          	auipc	ra,0x3
    2b5e:	9f6080e7          	jalr	-1546(ra) # 5550 <mkdir>
    2b62:	cd65                	beqz	a0,2c5a <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2b64:	00004517          	auipc	a0,0x4
    2b68:	2ec50513          	addi	a0,a0,748 # 6e50 <malloc+0x1532>
    2b6c:	00003097          	auipc	ra,0x3
    2b70:	9cc080e7          	jalr	-1588(ra) # 5538 <unlink>
  unlink("12345678901234/12345678901234");
    2b74:	00004517          	auipc	a0,0x4
    2b78:	28450513          	addi	a0,a0,644 # 6df8 <malloc+0x14da>
    2b7c:	00003097          	auipc	ra,0x3
    2b80:	9bc080e7          	jalr	-1604(ra) # 5538 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2b84:	00004517          	auipc	a0,0x4
    2b88:	20450513          	addi	a0,a0,516 # 6d88 <malloc+0x146a>
    2b8c:	00003097          	auipc	ra,0x3
    2b90:	9ac080e7          	jalr	-1620(ra) # 5538 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2b94:	00004517          	auipc	a0,0x4
    2b98:	17c50513          	addi	a0,a0,380 # 6d10 <malloc+0x13f2>
    2b9c:	00003097          	auipc	ra,0x3
    2ba0:	99c080e7          	jalr	-1636(ra) # 5538 <unlink>
  unlink("12345678901234/123456789012345");
    2ba4:	00004517          	auipc	a0,0x4
    2ba8:	11450513          	addi	a0,a0,276 # 6cb8 <malloc+0x139a>
    2bac:	00003097          	auipc	ra,0x3
    2bb0:	98c080e7          	jalr	-1652(ra) # 5538 <unlink>
  unlink("12345678901234");
    2bb4:	00004517          	auipc	a0,0x4
    2bb8:	2ac50513          	addi	a0,a0,684 # 6e60 <malloc+0x1542>
    2bbc:	00003097          	auipc	ra,0x3
    2bc0:	97c080e7          	jalr	-1668(ra) # 5538 <unlink>
}
    2bc4:	60e2                	ld	ra,24(sp)
    2bc6:	6442                	ld	s0,16(sp)
    2bc8:	64a2                	ld	s1,8(sp)
    2bca:	6105                	addi	sp,sp,32
    2bcc:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2bce:	85a6                	mv	a1,s1
    2bd0:	00004517          	auipc	a0,0x4
    2bd4:	0c050513          	addi	a0,a0,192 # 6c90 <malloc+0x1372>
    2bd8:	00003097          	auipc	ra,0x3
    2bdc:	c88080e7          	jalr	-888(ra) # 5860 <printf>
    exit(1);
    2be0:	4505                	li	a0,1
    2be2:	00003097          	auipc	ra,0x3
    2be6:	906080e7          	jalr	-1786(ra) # 54e8 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2bea:	85a6                	mv	a1,s1
    2bec:	00004517          	auipc	a0,0x4
    2bf0:	0ec50513          	addi	a0,a0,236 # 6cd8 <malloc+0x13ba>
    2bf4:	00003097          	auipc	ra,0x3
    2bf8:	c6c080e7          	jalr	-916(ra) # 5860 <printf>
    exit(1);
    2bfc:	4505                	li	a0,1
    2bfe:	00003097          	auipc	ra,0x3
    2c02:	8ea080e7          	jalr	-1814(ra) # 54e8 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2c06:	85a6                	mv	a1,s1
    2c08:	00004517          	auipc	a0,0x4
    2c0c:	13850513          	addi	a0,a0,312 # 6d40 <malloc+0x1422>
    2c10:	00003097          	auipc	ra,0x3
    2c14:	c50080e7          	jalr	-944(ra) # 5860 <printf>
    exit(1);
    2c18:	4505                	li	a0,1
    2c1a:	00003097          	auipc	ra,0x3
    2c1e:	8ce080e7          	jalr	-1842(ra) # 54e8 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2c22:	85a6                	mv	a1,s1
    2c24:	00004517          	auipc	a0,0x4
    2c28:	19450513          	addi	a0,a0,404 # 6db8 <malloc+0x149a>
    2c2c:	00003097          	auipc	ra,0x3
    2c30:	c34080e7          	jalr	-972(ra) # 5860 <printf>
    exit(1);
    2c34:	4505                	li	a0,1
    2c36:	00003097          	auipc	ra,0x3
    2c3a:	8b2080e7          	jalr	-1870(ra) # 54e8 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2c3e:	85a6                	mv	a1,s1
    2c40:	00004517          	auipc	a0,0x4
    2c44:	1d850513          	addi	a0,a0,472 # 6e18 <malloc+0x14fa>
    2c48:	00003097          	auipc	ra,0x3
    2c4c:	c18080e7          	jalr	-1000(ra) # 5860 <printf>
    exit(1);
    2c50:	4505                	li	a0,1
    2c52:	00003097          	auipc	ra,0x3
    2c56:	896080e7          	jalr	-1898(ra) # 54e8 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2c5a:	85a6                	mv	a1,s1
    2c5c:	00004517          	auipc	a0,0x4
    2c60:	21450513          	addi	a0,a0,532 # 6e70 <malloc+0x1552>
    2c64:	00003097          	auipc	ra,0x3
    2c68:	bfc080e7          	jalr	-1028(ra) # 5860 <printf>
    exit(1);
    2c6c:	4505                	li	a0,1
    2c6e:	00003097          	auipc	ra,0x3
    2c72:	87a080e7          	jalr	-1926(ra) # 54e8 <exit>

0000000000002c76 <iputtest>:
{
    2c76:	1101                	addi	sp,sp,-32
    2c78:	ec06                	sd	ra,24(sp)
    2c7a:	e822                	sd	s0,16(sp)
    2c7c:	e426                	sd	s1,8(sp)
    2c7e:	1000                	addi	s0,sp,32
    2c80:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2c82:	00004517          	auipc	a0,0x4
    2c86:	22650513          	addi	a0,a0,550 # 6ea8 <malloc+0x158a>
    2c8a:	00003097          	auipc	ra,0x3
    2c8e:	8c6080e7          	jalr	-1850(ra) # 5550 <mkdir>
    2c92:	04054563          	bltz	a0,2cdc <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2c96:	00004517          	auipc	a0,0x4
    2c9a:	21250513          	addi	a0,a0,530 # 6ea8 <malloc+0x158a>
    2c9e:	00003097          	auipc	ra,0x3
    2ca2:	8ba080e7          	jalr	-1862(ra) # 5558 <chdir>
    2ca6:	04054963          	bltz	a0,2cf8 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2caa:	00004517          	auipc	a0,0x4
    2cae:	23e50513          	addi	a0,a0,574 # 6ee8 <malloc+0x15ca>
    2cb2:	00003097          	auipc	ra,0x3
    2cb6:	886080e7          	jalr	-1914(ra) # 5538 <unlink>
    2cba:	04054d63          	bltz	a0,2d14 <iputtest+0x9e>
  if(chdir("/") < 0){
    2cbe:	00004517          	auipc	a0,0x4
    2cc2:	25a50513          	addi	a0,a0,602 # 6f18 <malloc+0x15fa>
    2cc6:	00003097          	auipc	ra,0x3
    2cca:	892080e7          	jalr	-1902(ra) # 5558 <chdir>
    2cce:	06054163          	bltz	a0,2d30 <iputtest+0xba>
}
    2cd2:	60e2                	ld	ra,24(sp)
    2cd4:	6442                	ld	s0,16(sp)
    2cd6:	64a2                	ld	s1,8(sp)
    2cd8:	6105                	addi	sp,sp,32
    2cda:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2cdc:	85a6                	mv	a1,s1
    2cde:	00004517          	auipc	a0,0x4
    2ce2:	1d250513          	addi	a0,a0,466 # 6eb0 <malloc+0x1592>
    2ce6:	00003097          	auipc	ra,0x3
    2cea:	b7a080e7          	jalr	-1158(ra) # 5860 <printf>
    exit(1);
    2cee:	4505                	li	a0,1
    2cf0:	00002097          	auipc	ra,0x2
    2cf4:	7f8080e7          	jalr	2040(ra) # 54e8 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2cf8:	85a6                	mv	a1,s1
    2cfa:	00004517          	auipc	a0,0x4
    2cfe:	1ce50513          	addi	a0,a0,462 # 6ec8 <malloc+0x15aa>
    2d02:	00003097          	auipc	ra,0x3
    2d06:	b5e080e7          	jalr	-1186(ra) # 5860 <printf>
    exit(1);
    2d0a:	4505                	li	a0,1
    2d0c:	00002097          	auipc	ra,0x2
    2d10:	7dc080e7          	jalr	2012(ra) # 54e8 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2d14:	85a6                	mv	a1,s1
    2d16:	00004517          	auipc	a0,0x4
    2d1a:	1e250513          	addi	a0,a0,482 # 6ef8 <malloc+0x15da>
    2d1e:	00003097          	auipc	ra,0x3
    2d22:	b42080e7          	jalr	-1214(ra) # 5860 <printf>
    exit(1);
    2d26:	4505                	li	a0,1
    2d28:	00002097          	auipc	ra,0x2
    2d2c:	7c0080e7          	jalr	1984(ra) # 54e8 <exit>
    printf("%s: chdir / failed\n", s);
    2d30:	85a6                	mv	a1,s1
    2d32:	00004517          	auipc	a0,0x4
    2d36:	1ee50513          	addi	a0,a0,494 # 6f20 <malloc+0x1602>
    2d3a:	00003097          	auipc	ra,0x3
    2d3e:	b26080e7          	jalr	-1242(ra) # 5860 <printf>
    exit(1);
    2d42:	4505                	li	a0,1
    2d44:	00002097          	auipc	ra,0x2
    2d48:	7a4080e7          	jalr	1956(ra) # 54e8 <exit>

0000000000002d4c <exitiputtest>:
{
    2d4c:	7179                	addi	sp,sp,-48
    2d4e:	f406                	sd	ra,40(sp)
    2d50:	f022                	sd	s0,32(sp)
    2d52:	ec26                	sd	s1,24(sp)
    2d54:	1800                	addi	s0,sp,48
    2d56:	84aa                	mv	s1,a0
  pid = fork();
    2d58:	00002097          	auipc	ra,0x2
    2d5c:	788080e7          	jalr	1928(ra) # 54e0 <fork>
  if(pid < 0){
    2d60:	04054663          	bltz	a0,2dac <exitiputtest+0x60>
  if(pid == 0){
    2d64:	ed45                	bnez	a0,2e1c <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2d66:	00004517          	auipc	a0,0x4
    2d6a:	14250513          	addi	a0,a0,322 # 6ea8 <malloc+0x158a>
    2d6e:	00002097          	auipc	ra,0x2
    2d72:	7e2080e7          	jalr	2018(ra) # 5550 <mkdir>
    2d76:	04054963          	bltz	a0,2dc8 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2d7a:	00004517          	auipc	a0,0x4
    2d7e:	12e50513          	addi	a0,a0,302 # 6ea8 <malloc+0x158a>
    2d82:	00002097          	auipc	ra,0x2
    2d86:	7d6080e7          	jalr	2006(ra) # 5558 <chdir>
    2d8a:	04054d63          	bltz	a0,2de4 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2d8e:	00004517          	auipc	a0,0x4
    2d92:	15a50513          	addi	a0,a0,346 # 6ee8 <malloc+0x15ca>
    2d96:	00002097          	auipc	ra,0x2
    2d9a:	7a2080e7          	jalr	1954(ra) # 5538 <unlink>
    2d9e:	06054163          	bltz	a0,2e00 <exitiputtest+0xb4>
    exit(0);
    2da2:	4501                	li	a0,0
    2da4:	00002097          	auipc	ra,0x2
    2da8:	744080e7          	jalr	1860(ra) # 54e8 <exit>
    printf("%s: fork failed\n", s);
    2dac:	85a6                	mv	a1,s1
    2dae:	00003517          	auipc	a0,0x3
    2db2:	7d250513          	addi	a0,a0,2002 # 6580 <malloc+0xc62>
    2db6:	00003097          	auipc	ra,0x3
    2dba:	aaa080e7          	jalr	-1366(ra) # 5860 <printf>
    exit(1);
    2dbe:	4505                	li	a0,1
    2dc0:	00002097          	auipc	ra,0x2
    2dc4:	728080e7          	jalr	1832(ra) # 54e8 <exit>
      printf("%s: mkdir failed\n", s);
    2dc8:	85a6                	mv	a1,s1
    2dca:	00004517          	auipc	a0,0x4
    2dce:	0e650513          	addi	a0,a0,230 # 6eb0 <malloc+0x1592>
    2dd2:	00003097          	auipc	ra,0x3
    2dd6:	a8e080e7          	jalr	-1394(ra) # 5860 <printf>
      exit(1);
    2dda:	4505                	li	a0,1
    2ddc:	00002097          	auipc	ra,0x2
    2de0:	70c080e7          	jalr	1804(ra) # 54e8 <exit>
      printf("%s: child chdir failed\n", s);
    2de4:	85a6                	mv	a1,s1
    2de6:	00004517          	auipc	a0,0x4
    2dea:	15250513          	addi	a0,a0,338 # 6f38 <malloc+0x161a>
    2dee:	00003097          	auipc	ra,0x3
    2df2:	a72080e7          	jalr	-1422(ra) # 5860 <printf>
      exit(1);
    2df6:	4505                	li	a0,1
    2df8:	00002097          	auipc	ra,0x2
    2dfc:	6f0080e7          	jalr	1776(ra) # 54e8 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2e00:	85a6                	mv	a1,s1
    2e02:	00004517          	auipc	a0,0x4
    2e06:	0f650513          	addi	a0,a0,246 # 6ef8 <malloc+0x15da>
    2e0a:	00003097          	auipc	ra,0x3
    2e0e:	a56080e7          	jalr	-1450(ra) # 5860 <printf>
      exit(1);
    2e12:	4505                	li	a0,1
    2e14:	00002097          	auipc	ra,0x2
    2e18:	6d4080e7          	jalr	1748(ra) # 54e8 <exit>
  wait(&xstatus);
    2e1c:	fdc40513          	addi	a0,s0,-36
    2e20:	00002097          	auipc	ra,0x2
    2e24:	6d0080e7          	jalr	1744(ra) # 54f0 <wait>
  exit(xstatus);
    2e28:	fdc42503          	lw	a0,-36(s0)
    2e2c:	00002097          	auipc	ra,0x2
    2e30:	6bc080e7          	jalr	1724(ra) # 54e8 <exit>

0000000000002e34 <subdir>:
{
    2e34:	1101                	addi	sp,sp,-32
    2e36:	ec06                	sd	ra,24(sp)
    2e38:	e822                	sd	s0,16(sp)
    2e3a:	e426                	sd	s1,8(sp)
    2e3c:	e04a                	sd	s2,0(sp)
    2e3e:	1000                	addi	s0,sp,32
    2e40:	892a                	mv	s2,a0
  unlink("ff");
    2e42:	00004517          	auipc	a0,0x4
    2e46:	23e50513          	addi	a0,a0,574 # 7080 <malloc+0x1762>
    2e4a:	00002097          	auipc	ra,0x2
    2e4e:	6ee080e7          	jalr	1774(ra) # 5538 <unlink>
  if(mkdir("dd") != 0){
    2e52:	00004517          	auipc	a0,0x4
    2e56:	0fe50513          	addi	a0,a0,254 # 6f50 <malloc+0x1632>
    2e5a:	00002097          	auipc	ra,0x2
    2e5e:	6f6080e7          	jalr	1782(ra) # 5550 <mkdir>
    2e62:	38051663          	bnez	a0,31ee <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2e66:	20200593          	li	a1,514
    2e6a:	00004517          	auipc	a0,0x4
    2e6e:	10650513          	addi	a0,a0,262 # 6f70 <malloc+0x1652>
    2e72:	00002097          	auipc	ra,0x2
    2e76:	6b6080e7          	jalr	1718(ra) # 5528 <open>
    2e7a:	84aa                	mv	s1,a0
  if(fd < 0){
    2e7c:	38054763          	bltz	a0,320a <subdir+0x3d6>
  write(fd, "ff", 2);
    2e80:	4609                	li	a2,2
    2e82:	00004597          	auipc	a1,0x4
    2e86:	1fe58593          	addi	a1,a1,510 # 7080 <malloc+0x1762>
    2e8a:	00002097          	auipc	ra,0x2
    2e8e:	67e080e7          	jalr	1662(ra) # 5508 <write>
  close(fd);
    2e92:	8526                	mv	a0,s1
    2e94:	00002097          	auipc	ra,0x2
    2e98:	67c080e7          	jalr	1660(ra) # 5510 <close>
  if(unlink("dd") >= 0){
    2e9c:	00004517          	auipc	a0,0x4
    2ea0:	0b450513          	addi	a0,a0,180 # 6f50 <malloc+0x1632>
    2ea4:	00002097          	auipc	ra,0x2
    2ea8:	694080e7          	jalr	1684(ra) # 5538 <unlink>
    2eac:	36055d63          	bgez	a0,3226 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2eb0:	00004517          	auipc	a0,0x4
    2eb4:	11850513          	addi	a0,a0,280 # 6fc8 <malloc+0x16aa>
    2eb8:	00002097          	auipc	ra,0x2
    2ebc:	698080e7          	jalr	1688(ra) # 5550 <mkdir>
    2ec0:	38051163          	bnez	a0,3242 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2ec4:	20200593          	li	a1,514
    2ec8:	00004517          	auipc	a0,0x4
    2ecc:	12850513          	addi	a0,a0,296 # 6ff0 <malloc+0x16d2>
    2ed0:	00002097          	auipc	ra,0x2
    2ed4:	658080e7          	jalr	1624(ra) # 5528 <open>
    2ed8:	84aa                	mv	s1,a0
  if(fd < 0){
    2eda:	38054263          	bltz	a0,325e <subdir+0x42a>
  write(fd, "FF", 2);
    2ede:	4609                	li	a2,2
    2ee0:	00004597          	auipc	a1,0x4
    2ee4:	14058593          	addi	a1,a1,320 # 7020 <malloc+0x1702>
    2ee8:	00002097          	auipc	ra,0x2
    2eec:	620080e7          	jalr	1568(ra) # 5508 <write>
  close(fd);
    2ef0:	8526                	mv	a0,s1
    2ef2:	00002097          	auipc	ra,0x2
    2ef6:	61e080e7          	jalr	1566(ra) # 5510 <close>
  fd = open("dd/dd/../ff", 0);
    2efa:	4581                	li	a1,0
    2efc:	00004517          	auipc	a0,0x4
    2f00:	12c50513          	addi	a0,a0,300 # 7028 <malloc+0x170a>
    2f04:	00002097          	auipc	ra,0x2
    2f08:	624080e7          	jalr	1572(ra) # 5528 <open>
    2f0c:	84aa                	mv	s1,a0
  if(fd < 0){
    2f0e:	36054663          	bltz	a0,327a <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    2f12:	660d                	lui	a2,0x3
    2f14:	00009597          	auipc	a1,0x9
    2f18:	a5458593          	addi	a1,a1,-1452 # b968 <buf>
    2f1c:	00002097          	auipc	ra,0x2
    2f20:	5e4080e7          	jalr	1508(ra) # 5500 <read>
  if(cc != 2 || buf[0] != 'f'){
    2f24:	4789                	li	a5,2
    2f26:	36f51863          	bne	a0,a5,3296 <subdir+0x462>
    2f2a:	00009717          	auipc	a4,0x9
    2f2e:	a3e74703          	lbu	a4,-1474(a4) # b968 <buf>
    2f32:	06600793          	li	a5,102
    2f36:	36f71063          	bne	a4,a5,3296 <subdir+0x462>
  close(fd);
    2f3a:	8526                	mv	a0,s1
    2f3c:	00002097          	auipc	ra,0x2
    2f40:	5d4080e7          	jalr	1492(ra) # 5510 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2f44:	00004597          	auipc	a1,0x4
    2f48:	13458593          	addi	a1,a1,308 # 7078 <malloc+0x175a>
    2f4c:	00004517          	auipc	a0,0x4
    2f50:	0a450513          	addi	a0,a0,164 # 6ff0 <malloc+0x16d2>
    2f54:	00002097          	auipc	ra,0x2
    2f58:	5f4080e7          	jalr	1524(ra) # 5548 <link>
    2f5c:	34051b63          	bnez	a0,32b2 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    2f60:	00004517          	auipc	a0,0x4
    2f64:	09050513          	addi	a0,a0,144 # 6ff0 <malloc+0x16d2>
    2f68:	00002097          	auipc	ra,0x2
    2f6c:	5d0080e7          	jalr	1488(ra) # 5538 <unlink>
    2f70:	34051f63          	bnez	a0,32ce <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2f74:	4581                	li	a1,0
    2f76:	00004517          	auipc	a0,0x4
    2f7a:	07a50513          	addi	a0,a0,122 # 6ff0 <malloc+0x16d2>
    2f7e:	00002097          	auipc	ra,0x2
    2f82:	5aa080e7          	jalr	1450(ra) # 5528 <open>
    2f86:	36055263          	bgez	a0,32ea <subdir+0x4b6>
  if(chdir("dd") != 0){
    2f8a:	00004517          	auipc	a0,0x4
    2f8e:	fc650513          	addi	a0,a0,-58 # 6f50 <malloc+0x1632>
    2f92:	00002097          	auipc	ra,0x2
    2f96:	5c6080e7          	jalr	1478(ra) # 5558 <chdir>
    2f9a:	36051663          	bnez	a0,3306 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    2f9e:	00004517          	auipc	a0,0x4
    2fa2:	17250513          	addi	a0,a0,370 # 7110 <malloc+0x17f2>
    2fa6:	00002097          	auipc	ra,0x2
    2faa:	5b2080e7          	jalr	1458(ra) # 5558 <chdir>
    2fae:	36051a63          	bnez	a0,3322 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    2fb2:	00004517          	auipc	a0,0x4
    2fb6:	18e50513          	addi	a0,a0,398 # 7140 <malloc+0x1822>
    2fba:	00002097          	auipc	ra,0x2
    2fbe:	59e080e7          	jalr	1438(ra) # 5558 <chdir>
    2fc2:	36051e63          	bnez	a0,333e <subdir+0x50a>
  if(chdir("./..") != 0){
    2fc6:	00004517          	auipc	a0,0x4
    2fca:	1aa50513          	addi	a0,a0,426 # 7170 <malloc+0x1852>
    2fce:	00002097          	auipc	ra,0x2
    2fd2:	58a080e7          	jalr	1418(ra) # 5558 <chdir>
    2fd6:	38051263          	bnez	a0,335a <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    2fda:	4581                	li	a1,0
    2fdc:	00004517          	auipc	a0,0x4
    2fe0:	09c50513          	addi	a0,a0,156 # 7078 <malloc+0x175a>
    2fe4:	00002097          	auipc	ra,0x2
    2fe8:	544080e7          	jalr	1348(ra) # 5528 <open>
    2fec:	84aa                	mv	s1,a0
  if(fd < 0){
    2fee:	38054463          	bltz	a0,3376 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    2ff2:	660d                	lui	a2,0x3
    2ff4:	00009597          	auipc	a1,0x9
    2ff8:	97458593          	addi	a1,a1,-1676 # b968 <buf>
    2ffc:	00002097          	auipc	ra,0x2
    3000:	504080e7          	jalr	1284(ra) # 5500 <read>
    3004:	4789                	li	a5,2
    3006:	38f51663          	bne	a0,a5,3392 <subdir+0x55e>
  close(fd);
    300a:	8526                	mv	a0,s1
    300c:	00002097          	auipc	ra,0x2
    3010:	504080e7          	jalr	1284(ra) # 5510 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3014:	4581                	li	a1,0
    3016:	00004517          	auipc	a0,0x4
    301a:	fda50513          	addi	a0,a0,-38 # 6ff0 <malloc+0x16d2>
    301e:	00002097          	auipc	ra,0x2
    3022:	50a080e7          	jalr	1290(ra) # 5528 <open>
    3026:	38055463          	bgez	a0,33ae <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    302a:	20200593          	li	a1,514
    302e:	00004517          	auipc	a0,0x4
    3032:	1d250513          	addi	a0,a0,466 # 7200 <malloc+0x18e2>
    3036:	00002097          	auipc	ra,0x2
    303a:	4f2080e7          	jalr	1266(ra) # 5528 <open>
    303e:	38055663          	bgez	a0,33ca <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3042:	20200593          	li	a1,514
    3046:	00004517          	auipc	a0,0x4
    304a:	1ea50513          	addi	a0,a0,490 # 7230 <malloc+0x1912>
    304e:	00002097          	auipc	ra,0x2
    3052:	4da080e7          	jalr	1242(ra) # 5528 <open>
    3056:	38055863          	bgez	a0,33e6 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    305a:	20000593          	li	a1,512
    305e:	00004517          	auipc	a0,0x4
    3062:	ef250513          	addi	a0,a0,-270 # 6f50 <malloc+0x1632>
    3066:	00002097          	auipc	ra,0x2
    306a:	4c2080e7          	jalr	1218(ra) # 5528 <open>
    306e:	38055a63          	bgez	a0,3402 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3072:	4589                	li	a1,2
    3074:	00004517          	auipc	a0,0x4
    3078:	edc50513          	addi	a0,a0,-292 # 6f50 <malloc+0x1632>
    307c:	00002097          	auipc	ra,0x2
    3080:	4ac080e7          	jalr	1196(ra) # 5528 <open>
    3084:	38055d63          	bgez	a0,341e <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    3088:	4585                	li	a1,1
    308a:	00004517          	auipc	a0,0x4
    308e:	ec650513          	addi	a0,a0,-314 # 6f50 <malloc+0x1632>
    3092:	00002097          	auipc	ra,0x2
    3096:	496080e7          	jalr	1174(ra) # 5528 <open>
    309a:	3a055063          	bgez	a0,343a <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    309e:	00004597          	auipc	a1,0x4
    30a2:	22258593          	addi	a1,a1,546 # 72c0 <malloc+0x19a2>
    30a6:	00004517          	auipc	a0,0x4
    30aa:	15a50513          	addi	a0,a0,346 # 7200 <malloc+0x18e2>
    30ae:	00002097          	auipc	ra,0x2
    30b2:	49a080e7          	jalr	1178(ra) # 5548 <link>
    30b6:	3a050063          	beqz	a0,3456 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    30ba:	00004597          	auipc	a1,0x4
    30be:	20658593          	addi	a1,a1,518 # 72c0 <malloc+0x19a2>
    30c2:	00004517          	auipc	a0,0x4
    30c6:	16e50513          	addi	a0,a0,366 # 7230 <malloc+0x1912>
    30ca:	00002097          	auipc	ra,0x2
    30ce:	47e080e7          	jalr	1150(ra) # 5548 <link>
    30d2:	3a050063          	beqz	a0,3472 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    30d6:	00004597          	auipc	a1,0x4
    30da:	fa258593          	addi	a1,a1,-94 # 7078 <malloc+0x175a>
    30de:	00004517          	auipc	a0,0x4
    30e2:	e9250513          	addi	a0,a0,-366 # 6f70 <malloc+0x1652>
    30e6:	00002097          	auipc	ra,0x2
    30ea:	462080e7          	jalr	1122(ra) # 5548 <link>
    30ee:	3a050063          	beqz	a0,348e <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    30f2:	00004517          	auipc	a0,0x4
    30f6:	10e50513          	addi	a0,a0,270 # 7200 <malloc+0x18e2>
    30fa:	00002097          	auipc	ra,0x2
    30fe:	456080e7          	jalr	1110(ra) # 5550 <mkdir>
    3102:	3a050463          	beqz	a0,34aa <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3106:	00004517          	auipc	a0,0x4
    310a:	12a50513          	addi	a0,a0,298 # 7230 <malloc+0x1912>
    310e:	00002097          	auipc	ra,0x2
    3112:	442080e7          	jalr	1090(ra) # 5550 <mkdir>
    3116:	3a050863          	beqz	a0,34c6 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    311a:	00004517          	auipc	a0,0x4
    311e:	f5e50513          	addi	a0,a0,-162 # 7078 <malloc+0x175a>
    3122:	00002097          	auipc	ra,0x2
    3126:	42e080e7          	jalr	1070(ra) # 5550 <mkdir>
    312a:	3a050c63          	beqz	a0,34e2 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    312e:	00004517          	auipc	a0,0x4
    3132:	10250513          	addi	a0,a0,258 # 7230 <malloc+0x1912>
    3136:	00002097          	auipc	ra,0x2
    313a:	402080e7          	jalr	1026(ra) # 5538 <unlink>
    313e:	3c050063          	beqz	a0,34fe <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3142:	00004517          	auipc	a0,0x4
    3146:	0be50513          	addi	a0,a0,190 # 7200 <malloc+0x18e2>
    314a:	00002097          	auipc	ra,0x2
    314e:	3ee080e7          	jalr	1006(ra) # 5538 <unlink>
    3152:	3c050463          	beqz	a0,351a <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3156:	00004517          	auipc	a0,0x4
    315a:	e1a50513          	addi	a0,a0,-486 # 6f70 <malloc+0x1652>
    315e:	00002097          	auipc	ra,0x2
    3162:	3fa080e7          	jalr	1018(ra) # 5558 <chdir>
    3166:	3c050863          	beqz	a0,3536 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    316a:	00004517          	auipc	a0,0x4
    316e:	2a650513          	addi	a0,a0,678 # 7410 <malloc+0x1af2>
    3172:	00002097          	auipc	ra,0x2
    3176:	3e6080e7          	jalr	998(ra) # 5558 <chdir>
    317a:	3c050c63          	beqz	a0,3552 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    317e:	00004517          	auipc	a0,0x4
    3182:	efa50513          	addi	a0,a0,-262 # 7078 <malloc+0x175a>
    3186:	00002097          	auipc	ra,0x2
    318a:	3b2080e7          	jalr	946(ra) # 5538 <unlink>
    318e:	3e051063          	bnez	a0,356e <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    3192:	00004517          	auipc	a0,0x4
    3196:	dde50513          	addi	a0,a0,-546 # 6f70 <malloc+0x1652>
    319a:	00002097          	auipc	ra,0x2
    319e:	39e080e7          	jalr	926(ra) # 5538 <unlink>
    31a2:	3e051463          	bnez	a0,358a <subdir+0x756>
  if(unlink("dd") == 0){
    31a6:	00004517          	auipc	a0,0x4
    31aa:	daa50513          	addi	a0,a0,-598 # 6f50 <malloc+0x1632>
    31ae:	00002097          	auipc	ra,0x2
    31b2:	38a080e7          	jalr	906(ra) # 5538 <unlink>
    31b6:	3e050863          	beqz	a0,35a6 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    31ba:	00004517          	auipc	a0,0x4
    31be:	2c650513          	addi	a0,a0,710 # 7480 <malloc+0x1b62>
    31c2:	00002097          	auipc	ra,0x2
    31c6:	376080e7          	jalr	886(ra) # 5538 <unlink>
    31ca:	3e054c63          	bltz	a0,35c2 <subdir+0x78e>
  if(unlink("dd") < 0){
    31ce:	00004517          	auipc	a0,0x4
    31d2:	d8250513          	addi	a0,a0,-638 # 6f50 <malloc+0x1632>
    31d6:	00002097          	auipc	ra,0x2
    31da:	362080e7          	jalr	866(ra) # 5538 <unlink>
    31de:	40054063          	bltz	a0,35de <subdir+0x7aa>
}
    31e2:	60e2                	ld	ra,24(sp)
    31e4:	6442                	ld	s0,16(sp)
    31e6:	64a2                	ld	s1,8(sp)
    31e8:	6902                	ld	s2,0(sp)
    31ea:	6105                	addi	sp,sp,32
    31ec:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    31ee:	85ca                	mv	a1,s2
    31f0:	00004517          	auipc	a0,0x4
    31f4:	d6850513          	addi	a0,a0,-664 # 6f58 <malloc+0x163a>
    31f8:	00002097          	auipc	ra,0x2
    31fc:	668080e7          	jalr	1640(ra) # 5860 <printf>
    exit(1);
    3200:	4505                	li	a0,1
    3202:	00002097          	auipc	ra,0x2
    3206:	2e6080e7          	jalr	742(ra) # 54e8 <exit>
    printf("%s: create dd/ff failed\n", s);
    320a:	85ca                	mv	a1,s2
    320c:	00004517          	auipc	a0,0x4
    3210:	d6c50513          	addi	a0,a0,-660 # 6f78 <malloc+0x165a>
    3214:	00002097          	auipc	ra,0x2
    3218:	64c080e7          	jalr	1612(ra) # 5860 <printf>
    exit(1);
    321c:	4505                	li	a0,1
    321e:	00002097          	auipc	ra,0x2
    3222:	2ca080e7          	jalr	714(ra) # 54e8 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3226:	85ca                	mv	a1,s2
    3228:	00004517          	auipc	a0,0x4
    322c:	d7050513          	addi	a0,a0,-656 # 6f98 <malloc+0x167a>
    3230:	00002097          	auipc	ra,0x2
    3234:	630080e7          	jalr	1584(ra) # 5860 <printf>
    exit(1);
    3238:	4505                	li	a0,1
    323a:	00002097          	auipc	ra,0x2
    323e:	2ae080e7          	jalr	686(ra) # 54e8 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3242:	85ca                	mv	a1,s2
    3244:	00004517          	auipc	a0,0x4
    3248:	d8c50513          	addi	a0,a0,-628 # 6fd0 <malloc+0x16b2>
    324c:	00002097          	auipc	ra,0x2
    3250:	614080e7          	jalr	1556(ra) # 5860 <printf>
    exit(1);
    3254:	4505                	li	a0,1
    3256:	00002097          	auipc	ra,0x2
    325a:	292080e7          	jalr	658(ra) # 54e8 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    325e:	85ca                	mv	a1,s2
    3260:	00004517          	auipc	a0,0x4
    3264:	da050513          	addi	a0,a0,-608 # 7000 <malloc+0x16e2>
    3268:	00002097          	auipc	ra,0x2
    326c:	5f8080e7          	jalr	1528(ra) # 5860 <printf>
    exit(1);
    3270:	4505                	li	a0,1
    3272:	00002097          	auipc	ra,0x2
    3276:	276080e7          	jalr	630(ra) # 54e8 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    327a:	85ca                	mv	a1,s2
    327c:	00004517          	auipc	a0,0x4
    3280:	dbc50513          	addi	a0,a0,-580 # 7038 <malloc+0x171a>
    3284:	00002097          	auipc	ra,0x2
    3288:	5dc080e7          	jalr	1500(ra) # 5860 <printf>
    exit(1);
    328c:	4505                	li	a0,1
    328e:	00002097          	auipc	ra,0x2
    3292:	25a080e7          	jalr	602(ra) # 54e8 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3296:	85ca                	mv	a1,s2
    3298:	00004517          	auipc	a0,0x4
    329c:	dc050513          	addi	a0,a0,-576 # 7058 <malloc+0x173a>
    32a0:	00002097          	auipc	ra,0x2
    32a4:	5c0080e7          	jalr	1472(ra) # 5860 <printf>
    exit(1);
    32a8:	4505                	li	a0,1
    32aa:	00002097          	auipc	ra,0x2
    32ae:	23e080e7          	jalr	574(ra) # 54e8 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    32b2:	85ca                	mv	a1,s2
    32b4:	00004517          	auipc	a0,0x4
    32b8:	dd450513          	addi	a0,a0,-556 # 7088 <malloc+0x176a>
    32bc:	00002097          	auipc	ra,0x2
    32c0:	5a4080e7          	jalr	1444(ra) # 5860 <printf>
    exit(1);
    32c4:	4505                	li	a0,1
    32c6:	00002097          	auipc	ra,0x2
    32ca:	222080e7          	jalr	546(ra) # 54e8 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    32ce:	85ca                	mv	a1,s2
    32d0:	00004517          	auipc	a0,0x4
    32d4:	de050513          	addi	a0,a0,-544 # 70b0 <malloc+0x1792>
    32d8:	00002097          	auipc	ra,0x2
    32dc:	588080e7          	jalr	1416(ra) # 5860 <printf>
    exit(1);
    32e0:	4505                	li	a0,1
    32e2:	00002097          	auipc	ra,0x2
    32e6:	206080e7          	jalr	518(ra) # 54e8 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    32ea:	85ca                	mv	a1,s2
    32ec:	00004517          	auipc	a0,0x4
    32f0:	de450513          	addi	a0,a0,-540 # 70d0 <malloc+0x17b2>
    32f4:	00002097          	auipc	ra,0x2
    32f8:	56c080e7          	jalr	1388(ra) # 5860 <printf>
    exit(1);
    32fc:	4505                	li	a0,1
    32fe:	00002097          	auipc	ra,0x2
    3302:	1ea080e7          	jalr	490(ra) # 54e8 <exit>
    printf("%s: chdir dd failed\n", s);
    3306:	85ca                	mv	a1,s2
    3308:	00004517          	auipc	a0,0x4
    330c:	df050513          	addi	a0,a0,-528 # 70f8 <malloc+0x17da>
    3310:	00002097          	auipc	ra,0x2
    3314:	550080e7          	jalr	1360(ra) # 5860 <printf>
    exit(1);
    3318:	4505                	li	a0,1
    331a:	00002097          	auipc	ra,0x2
    331e:	1ce080e7          	jalr	462(ra) # 54e8 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3322:	85ca                	mv	a1,s2
    3324:	00004517          	auipc	a0,0x4
    3328:	dfc50513          	addi	a0,a0,-516 # 7120 <malloc+0x1802>
    332c:	00002097          	auipc	ra,0x2
    3330:	534080e7          	jalr	1332(ra) # 5860 <printf>
    exit(1);
    3334:	4505                	li	a0,1
    3336:	00002097          	auipc	ra,0x2
    333a:	1b2080e7          	jalr	434(ra) # 54e8 <exit>
    printf("chdir dd/../../dd failed\n", s);
    333e:	85ca                	mv	a1,s2
    3340:	00004517          	auipc	a0,0x4
    3344:	e1050513          	addi	a0,a0,-496 # 7150 <malloc+0x1832>
    3348:	00002097          	auipc	ra,0x2
    334c:	518080e7          	jalr	1304(ra) # 5860 <printf>
    exit(1);
    3350:	4505                	li	a0,1
    3352:	00002097          	auipc	ra,0x2
    3356:	196080e7          	jalr	406(ra) # 54e8 <exit>
    printf("%s: chdir ./.. failed\n", s);
    335a:	85ca                	mv	a1,s2
    335c:	00004517          	auipc	a0,0x4
    3360:	e1c50513          	addi	a0,a0,-484 # 7178 <malloc+0x185a>
    3364:	00002097          	auipc	ra,0x2
    3368:	4fc080e7          	jalr	1276(ra) # 5860 <printf>
    exit(1);
    336c:	4505                	li	a0,1
    336e:	00002097          	auipc	ra,0x2
    3372:	17a080e7          	jalr	378(ra) # 54e8 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3376:	85ca                	mv	a1,s2
    3378:	00004517          	auipc	a0,0x4
    337c:	e1850513          	addi	a0,a0,-488 # 7190 <malloc+0x1872>
    3380:	00002097          	auipc	ra,0x2
    3384:	4e0080e7          	jalr	1248(ra) # 5860 <printf>
    exit(1);
    3388:	4505                	li	a0,1
    338a:	00002097          	auipc	ra,0x2
    338e:	15e080e7          	jalr	350(ra) # 54e8 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3392:	85ca                	mv	a1,s2
    3394:	00004517          	auipc	a0,0x4
    3398:	e1c50513          	addi	a0,a0,-484 # 71b0 <malloc+0x1892>
    339c:	00002097          	auipc	ra,0x2
    33a0:	4c4080e7          	jalr	1220(ra) # 5860 <printf>
    exit(1);
    33a4:	4505                	li	a0,1
    33a6:	00002097          	auipc	ra,0x2
    33aa:	142080e7          	jalr	322(ra) # 54e8 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    33ae:	85ca                	mv	a1,s2
    33b0:	00004517          	auipc	a0,0x4
    33b4:	e2050513          	addi	a0,a0,-480 # 71d0 <malloc+0x18b2>
    33b8:	00002097          	auipc	ra,0x2
    33bc:	4a8080e7          	jalr	1192(ra) # 5860 <printf>
    exit(1);
    33c0:	4505                	li	a0,1
    33c2:	00002097          	auipc	ra,0x2
    33c6:	126080e7          	jalr	294(ra) # 54e8 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    33ca:	85ca                	mv	a1,s2
    33cc:	00004517          	auipc	a0,0x4
    33d0:	e4450513          	addi	a0,a0,-444 # 7210 <malloc+0x18f2>
    33d4:	00002097          	auipc	ra,0x2
    33d8:	48c080e7          	jalr	1164(ra) # 5860 <printf>
    exit(1);
    33dc:	4505                	li	a0,1
    33de:	00002097          	auipc	ra,0x2
    33e2:	10a080e7          	jalr	266(ra) # 54e8 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    33e6:	85ca                	mv	a1,s2
    33e8:	00004517          	auipc	a0,0x4
    33ec:	e5850513          	addi	a0,a0,-424 # 7240 <malloc+0x1922>
    33f0:	00002097          	auipc	ra,0x2
    33f4:	470080e7          	jalr	1136(ra) # 5860 <printf>
    exit(1);
    33f8:	4505                	li	a0,1
    33fa:	00002097          	auipc	ra,0x2
    33fe:	0ee080e7          	jalr	238(ra) # 54e8 <exit>
    printf("%s: create dd succeeded!\n", s);
    3402:	85ca                	mv	a1,s2
    3404:	00004517          	auipc	a0,0x4
    3408:	e5c50513          	addi	a0,a0,-420 # 7260 <malloc+0x1942>
    340c:	00002097          	auipc	ra,0x2
    3410:	454080e7          	jalr	1108(ra) # 5860 <printf>
    exit(1);
    3414:	4505                	li	a0,1
    3416:	00002097          	auipc	ra,0x2
    341a:	0d2080e7          	jalr	210(ra) # 54e8 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    341e:	85ca                	mv	a1,s2
    3420:	00004517          	auipc	a0,0x4
    3424:	e6050513          	addi	a0,a0,-416 # 7280 <malloc+0x1962>
    3428:	00002097          	auipc	ra,0x2
    342c:	438080e7          	jalr	1080(ra) # 5860 <printf>
    exit(1);
    3430:	4505                	li	a0,1
    3432:	00002097          	auipc	ra,0x2
    3436:	0b6080e7          	jalr	182(ra) # 54e8 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    343a:	85ca                	mv	a1,s2
    343c:	00004517          	auipc	a0,0x4
    3440:	e6450513          	addi	a0,a0,-412 # 72a0 <malloc+0x1982>
    3444:	00002097          	auipc	ra,0x2
    3448:	41c080e7          	jalr	1052(ra) # 5860 <printf>
    exit(1);
    344c:	4505                	li	a0,1
    344e:	00002097          	auipc	ra,0x2
    3452:	09a080e7          	jalr	154(ra) # 54e8 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3456:	85ca                	mv	a1,s2
    3458:	00004517          	auipc	a0,0x4
    345c:	e7850513          	addi	a0,a0,-392 # 72d0 <malloc+0x19b2>
    3460:	00002097          	auipc	ra,0x2
    3464:	400080e7          	jalr	1024(ra) # 5860 <printf>
    exit(1);
    3468:	4505                	li	a0,1
    346a:	00002097          	auipc	ra,0x2
    346e:	07e080e7          	jalr	126(ra) # 54e8 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3472:	85ca                	mv	a1,s2
    3474:	00004517          	auipc	a0,0x4
    3478:	e8450513          	addi	a0,a0,-380 # 72f8 <malloc+0x19da>
    347c:	00002097          	auipc	ra,0x2
    3480:	3e4080e7          	jalr	996(ra) # 5860 <printf>
    exit(1);
    3484:	4505                	li	a0,1
    3486:	00002097          	auipc	ra,0x2
    348a:	062080e7          	jalr	98(ra) # 54e8 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    348e:	85ca                	mv	a1,s2
    3490:	00004517          	auipc	a0,0x4
    3494:	e9050513          	addi	a0,a0,-368 # 7320 <malloc+0x1a02>
    3498:	00002097          	auipc	ra,0x2
    349c:	3c8080e7          	jalr	968(ra) # 5860 <printf>
    exit(1);
    34a0:	4505                	li	a0,1
    34a2:	00002097          	auipc	ra,0x2
    34a6:	046080e7          	jalr	70(ra) # 54e8 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    34aa:	85ca                	mv	a1,s2
    34ac:	00004517          	auipc	a0,0x4
    34b0:	e9c50513          	addi	a0,a0,-356 # 7348 <malloc+0x1a2a>
    34b4:	00002097          	auipc	ra,0x2
    34b8:	3ac080e7          	jalr	940(ra) # 5860 <printf>
    exit(1);
    34bc:	4505                	li	a0,1
    34be:	00002097          	auipc	ra,0x2
    34c2:	02a080e7          	jalr	42(ra) # 54e8 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    34c6:	85ca                	mv	a1,s2
    34c8:	00004517          	auipc	a0,0x4
    34cc:	ea050513          	addi	a0,a0,-352 # 7368 <malloc+0x1a4a>
    34d0:	00002097          	auipc	ra,0x2
    34d4:	390080e7          	jalr	912(ra) # 5860 <printf>
    exit(1);
    34d8:	4505                	li	a0,1
    34da:	00002097          	auipc	ra,0x2
    34de:	00e080e7          	jalr	14(ra) # 54e8 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    34e2:	85ca                	mv	a1,s2
    34e4:	00004517          	auipc	a0,0x4
    34e8:	ea450513          	addi	a0,a0,-348 # 7388 <malloc+0x1a6a>
    34ec:	00002097          	auipc	ra,0x2
    34f0:	374080e7          	jalr	884(ra) # 5860 <printf>
    exit(1);
    34f4:	4505                	li	a0,1
    34f6:	00002097          	auipc	ra,0x2
    34fa:	ff2080e7          	jalr	-14(ra) # 54e8 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    34fe:	85ca                	mv	a1,s2
    3500:	00004517          	auipc	a0,0x4
    3504:	eb050513          	addi	a0,a0,-336 # 73b0 <malloc+0x1a92>
    3508:	00002097          	auipc	ra,0x2
    350c:	358080e7          	jalr	856(ra) # 5860 <printf>
    exit(1);
    3510:	4505                	li	a0,1
    3512:	00002097          	auipc	ra,0x2
    3516:	fd6080e7          	jalr	-42(ra) # 54e8 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    351a:	85ca                	mv	a1,s2
    351c:	00004517          	auipc	a0,0x4
    3520:	eb450513          	addi	a0,a0,-332 # 73d0 <malloc+0x1ab2>
    3524:	00002097          	auipc	ra,0x2
    3528:	33c080e7          	jalr	828(ra) # 5860 <printf>
    exit(1);
    352c:	4505                	li	a0,1
    352e:	00002097          	auipc	ra,0x2
    3532:	fba080e7          	jalr	-70(ra) # 54e8 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3536:	85ca                	mv	a1,s2
    3538:	00004517          	auipc	a0,0x4
    353c:	eb850513          	addi	a0,a0,-328 # 73f0 <malloc+0x1ad2>
    3540:	00002097          	auipc	ra,0x2
    3544:	320080e7          	jalr	800(ra) # 5860 <printf>
    exit(1);
    3548:	4505                	li	a0,1
    354a:	00002097          	auipc	ra,0x2
    354e:	f9e080e7          	jalr	-98(ra) # 54e8 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3552:	85ca                	mv	a1,s2
    3554:	00004517          	auipc	a0,0x4
    3558:	ec450513          	addi	a0,a0,-316 # 7418 <malloc+0x1afa>
    355c:	00002097          	auipc	ra,0x2
    3560:	304080e7          	jalr	772(ra) # 5860 <printf>
    exit(1);
    3564:	4505                	li	a0,1
    3566:	00002097          	auipc	ra,0x2
    356a:	f82080e7          	jalr	-126(ra) # 54e8 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    356e:	85ca                	mv	a1,s2
    3570:	00004517          	auipc	a0,0x4
    3574:	b4050513          	addi	a0,a0,-1216 # 70b0 <malloc+0x1792>
    3578:	00002097          	auipc	ra,0x2
    357c:	2e8080e7          	jalr	744(ra) # 5860 <printf>
    exit(1);
    3580:	4505                	li	a0,1
    3582:	00002097          	auipc	ra,0x2
    3586:	f66080e7          	jalr	-154(ra) # 54e8 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    358a:	85ca                	mv	a1,s2
    358c:	00004517          	auipc	a0,0x4
    3590:	eac50513          	addi	a0,a0,-340 # 7438 <malloc+0x1b1a>
    3594:	00002097          	auipc	ra,0x2
    3598:	2cc080e7          	jalr	716(ra) # 5860 <printf>
    exit(1);
    359c:	4505                	li	a0,1
    359e:	00002097          	auipc	ra,0x2
    35a2:	f4a080e7          	jalr	-182(ra) # 54e8 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    35a6:	85ca                	mv	a1,s2
    35a8:	00004517          	auipc	a0,0x4
    35ac:	eb050513          	addi	a0,a0,-336 # 7458 <malloc+0x1b3a>
    35b0:	00002097          	auipc	ra,0x2
    35b4:	2b0080e7          	jalr	688(ra) # 5860 <printf>
    exit(1);
    35b8:	4505                	li	a0,1
    35ba:	00002097          	auipc	ra,0x2
    35be:	f2e080e7          	jalr	-210(ra) # 54e8 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    35c2:	85ca                	mv	a1,s2
    35c4:	00004517          	auipc	a0,0x4
    35c8:	ec450513          	addi	a0,a0,-316 # 7488 <malloc+0x1b6a>
    35cc:	00002097          	auipc	ra,0x2
    35d0:	294080e7          	jalr	660(ra) # 5860 <printf>
    exit(1);
    35d4:	4505                	li	a0,1
    35d6:	00002097          	auipc	ra,0x2
    35da:	f12080e7          	jalr	-238(ra) # 54e8 <exit>
    printf("%s: unlink dd failed\n", s);
    35de:	85ca                	mv	a1,s2
    35e0:	00004517          	auipc	a0,0x4
    35e4:	ec850513          	addi	a0,a0,-312 # 74a8 <malloc+0x1b8a>
    35e8:	00002097          	auipc	ra,0x2
    35ec:	278080e7          	jalr	632(ra) # 5860 <printf>
    exit(1);
    35f0:	4505                	li	a0,1
    35f2:	00002097          	auipc	ra,0x2
    35f6:	ef6080e7          	jalr	-266(ra) # 54e8 <exit>

00000000000035fa <rmdot>:
{
    35fa:	1101                	addi	sp,sp,-32
    35fc:	ec06                	sd	ra,24(sp)
    35fe:	e822                	sd	s0,16(sp)
    3600:	e426                	sd	s1,8(sp)
    3602:	1000                	addi	s0,sp,32
    3604:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3606:	00004517          	auipc	a0,0x4
    360a:	eba50513          	addi	a0,a0,-326 # 74c0 <malloc+0x1ba2>
    360e:	00002097          	auipc	ra,0x2
    3612:	f42080e7          	jalr	-190(ra) # 5550 <mkdir>
    3616:	e549                	bnez	a0,36a0 <rmdot+0xa6>
  if(chdir("dots") != 0){
    3618:	00004517          	auipc	a0,0x4
    361c:	ea850513          	addi	a0,a0,-344 # 74c0 <malloc+0x1ba2>
    3620:	00002097          	auipc	ra,0x2
    3624:	f38080e7          	jalr	-200(ra) # 5558 <chdir>
    3628:	e951                	bnez	a0,36bc <rmdot+0xc2>
  if(unlink(".") == 0){
    362a:	00003517          	auipc	a0,0x3
    362e:	db650513          	addi	a0,a0,-586 # 63e0 <malloc+0xac2>
    3632:	00002097          	auipc	ra,0x2
    3636:	f06080e7          	jalr	-250(ra) # 5538 <unlink>
    363a:	cd59                	beqz	a0,36d8 <rmdot+0xde>
  if(unlink("..") == 0){
    363c:	00004517          	auipc	a0,0x4
    3640:	ed450513          	addi	a0,a0,-300 # 7510 <malloc+0x1bf2>
    3644:	00002097          	auipc	ra,0x2
    3648:	ef4080e7          	jalr	-268(ra) # 5538 <unlink>
    364c:	c545                	beqz	a0,36f4 <rmdot+0xfa>
  if(chdir("/") != 0){
    364e:	00004517          	auipc	a0,0x4
    3652:	8ca50513          	addi	a0,a0,-1846 # 6f18 <malloc+0x15fa>
    3656:	00002097          	auipc	ra,0x2
    365a:	f02080e7          	jalr	-254(ra) # 5558 <chdir>
    365e:	e94d                	bnez	a0,3710 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3660:	00004517          	auipc	a0,0x4
    3664:	ed050513          	addi	a0,a0,-304 # 7530 <malloc+0x1c12>
    3668:	00002097          	auipc	ra,0x2
    366c:	ed0080e7          	jalr	-304(ra) # 5538 <unlink>
    3670:	cd55                	beqz	a0,372c <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3672:	00004517          	auipc	a0,0x4
    3676:	ee650513          	addi	a0,a0,-282 # 7558 <malloc+0x1c3a>
    367a:	00002097          	auipc	ra,0x2
    367e:	ebe080e7          	jalr	-322(ra) # 5538 <unlink>
    3682:	c179                	beqz	a0,3748 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3684:	00004517          	auipc	a0,0x4
    3688:	e3c50513          	addi	a0,a0,-452 # 74c0 <malloc+0x1ba2>
    368c:	00002097          	auipc	ra,0x2
    3690:	eac080e7          	jalr	-340(ra) # 5538 <unlink>
    3694:	e961                	bnez	a0,3764 <rmdot+0x16a>
}
    3696:	60e2                	ld	ra,24(sp)
    3698:	6442                	ld	s0,16(sp)
    369a:	64a2                	ld	s1,8(sp)
    369c:	6105                	addi	sp,sp,32
    369e:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    36a0:	85a6                	mv	a1,s1
    36a2:	00004517          	auipc	a0,0x4
    36a6:	e2650513          	addi	a0,a0,-474 # 74c8 <malloc+0x1baa>
    36aa:	00002097          	auipc	ra,0x2
    36ae:	1b6080e7          	jalr	438(ra) # 5860 <printf>
    exit(1);
    36b2:	4505                	li	a0,1
    36b4:	00002097          	auipc	ra,0x2
    36b8:	e34080e7          	jalr	-460(ra) # 54e8 <exit>
    printf("%s: chdir dots failed\n", s);
    36bc:	85a6                	mv	a1,s1
    36be:	00004517          	auipc	a0,0x4
    36c2:	e2250513          	addi	a0,a0,-478 # 74e0 <malloc+0x1bc2>
    36c6:	00002097          	auipc	ra,0x2
    36ca:	19a080e7          	jalr	410(ra) # 5860 <printf>
    exit(1);
    36ce:	4505                	li	a0,1
    36d0:	00002097          	auipc	ra,0x2
    36d4:	e18080e7          	jalr	-488(ra) # 54e8 <exit>
    printf("%s: rm . worked!\n", s);
    36d8:	85a6                	mv	a1,s1
    36da:	00004517          	auipc	a0,0x4
    36de:	e1e50513          	addi	a0,a0,-482 # 74f8 <malloc+0x1bda>
    36e2:	00002097          	auipc	ra,0x2
    36e6:	17e080e7          	jalr	382(ra) # 5860 <printf>
    exit(1);
    36ea:	4505                	li	a0,1
    36ec:	00002097          	auipc	ra,0x2
    36f0:	dfc080e7          	jalr	-516(ra) # 54e8 <exit>
    printf("%s: rm .. worked!\n", s);
    36f4:	85a6                	mv	a1,s1
    36f6:	00004517          	auipc	a0,0x4
    36fa:	e2250513          	addi	a0,a0,-478 # 7518 <malloc+0x1bfa>
    36fe:	00002097          	auipc	ra,0x2
    3702:	162080e7          	jalr	354(ra) # 5860 <printf>
    exit(1);
    3706:	4505                	li	a0,1
    3708:	00002097          	auipc	ra,0x2
    370c:	de0080e7          	jalr	-544(ra) # 54e8 <exit>
    printf("%s: chdir / failed\n", s);
    3710:	85a6                	mv	a1,s1
    3712:	00004517          	auipc	a0,0x4
    3716:	80e50513          	addi	a0,a0,-2034 # 6f20 <malloc+0x1602>
    371a:	00002097          	auipc	ra,0x2
    371e:	146080e7          	jalr	326(ra) # 5860 <printf>
    exit(1);
    3722:	4505                	li	a0,1
    3724:	00002097          	auipc	ra,0x2
    3728:	dc4080e7          	jalr	-572(ra) # 54e8 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    372c:	85a6                	mv	a1,s1
    372e:	00004517          	auipc	a0,0x4
    3732:	e0a50513          	addi	a0,a0,-502 # 7538 <malloc+0x1c1a>
    3736:	00002097          	auipc	ra,0x2
    373a:	12a080e7          	jalr	298(ra) # 5860 <printf>
    exit(1);
    373e:	4505                	li	a0,1
    3740:	00002097          	auipc	ra,0x2
    3744:	da8080e7          	jalr	-600(ra) # 54e8 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3748:	85a6                	mv	a1,s1
    374a:	00004517          	auipc	a0,0x4
    374e:	e1650513          	addi	a0,a0,-490 # 7560 <malloc+0x1c42>
    3752:	00002097          	auipc	ra,0x2
    3756:	10e080e7          	jalr	270(ra) # 5860 <printf>
    exit(1);
    375a:	4505                	li	a0,1
    375c:	00002097          	auipc	ra,0x2
    3760:	d8c080e7          	jalr	-628(ra) # 54e8 <exit>
    printf("%s: unlink dots failed!\n", s);
    3764:	85a6                	mv	a1,s1
    3766:	00004517          	auipc	a0,0x4
    376a:	e1a50513          	addi	a0,a0,-486 # 7580 <malloc+0x1c62>
    376e:	00002097          	auipc	ra,0x2
    3772:	0f2080e7          	jalr	242(ra) # 5860 <printf>
    exit(1);
    3776:	4505                	li	a0,1
    3778:	00002097          	auipc	ra,0x2
    377c:	d70080e7          	jalr	-656(ra) # 54e8 <exit>

0000000000003780 <dirfile>:
{
    3780:	1101                	addi	sp,sp,-32
    3782:	ec06                	sd	ra,24(sp)
    3784:	e822                	sd	s0,16(sp)
    3786:	e426                	sd	s1,8(sp)
    3788:	e04a                	sd	s2,0(sp)
    378a:	1000                	addi	s0,sp,32
    378c:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    378e:	20000593          	li	a1,512
    3792:	00002517          	auipc	a0,0x2
    3796:	55650513          	addi	a0,a0,1366 # 5ce8 <malloc+0x3ca>
    379a:	00002097          	auipc	ra,0x2
    379e:	d8e080e7          	jalr	-626(ra) # 5528 <open>
  if(fd < 0){
    37a2:	0e054d63          	bltz	a0,389c <dirfile+0x11c>
  close(fd);
    37a6:	00002097          	auipc	ra,0x2
    37aa:	d6a080e7          	jalr	-662(ra) # 5510 <close>
  if(chdir("dirfile") == 0){
    37ae:	00002517          	auipc	a0,0x2
    37b2:	53a50513          	addi	a0,a0,1338 # 5ce8 <malloc+0x3ca>
    37b6:	00002097          	auipc	ra,0x2
    37ba:	da2080e7          	jalr	-606(ra) # 5558 <chdir>
    37be:	cd6d                	beqz	a0,38b8 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    37c0:	4581                	li	a1,0
    37c2:	00004517          	auipc	a0,0x4
    37c6:	e1e50513          	addi	a0,a0,-482 # 75e0 <malloc+0x1cc2>
    37ca:	00002097          	auipc	ra,0x2
    37ce:	d5e080e7          	jalr	-674(ra) # 5528 <open>
  if(fd >= 0){
    37d2:	10055163          	bgez	a0,38d4 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    37d6:	20000593          	li	a1,512
    37da:	00004517          	auipc	a0,0x4
    37de:	e0650513          	addi	a0,a0,-506 # 75e0 <malloc+0x1cc2>
    37e2:	00002097          	auipc	ra,0x2
    37e6:	d46080e7          	jalr	-698(ra) # 5528 <open>
  if(fd >= 0){
    37ea:	10055363          	bgez	a0,38f0 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    37ee:	00004517          	auipc	a0,0x4
    37f2:	df250513          	addi	a0,a0,-526 # 75e0 <malloc+0x1cc2>
    37f6:	00002097          	auipc	ra,0x2
    37fa:	d5a080e7          	jalr	-678(ra) # 5550 <mkdir>
    37fe:	10050763          	beqz	a0,390c <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3802:	00004517          	auipc	a0,0x4
    3806:	dde50513          	addi	a0,a0,-546 # 75e0 <malloc+0x1cc2>
    380a:	00002097          	auipc	ra,0x2
    380e:	d2e080e7          	jalr	-722(ra) # 5538 <unlink>
    3812:	10050b63          	beqz	a0,3928 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3816:	00004597          	auipc	a1,0x4
    381a:	dca58593          	addi	a1,a1,-566 # 75e0 <malloc+0x1cc2>
    381e:	00002517          	auipc	a0,0x2
    3822:	6c250513          	addi	a0,a0,1730 # 5ee0 <malloc+0x5c2>
    3826:	00002097          	auipc	ra,0x2
    382a:	d22080e7          	jalr	-734(ra) # 5548 <link>
    382e:	10050b63          	beqz	a0,3944 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3832:	00002517          	auipc	a0,0x2
    3836:	4b650513          	addi	a0,a0,1206 # 5ce8 <malloc+0x3ca>
    383a:	00002097          	auipc	ra,0x2
    383e:	cfe080e7          	jalr	-770(ra) # 5538 <unlink>
    3842:	10051f63          	bnez	a0,3960 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3846:	4589                	li	a1,2
    3848:	00003517          	auipc	a0,0x3
    384c:	b9850513          	addi	a0,a0,-1128 # 63e0 <malloc+0xac2>
    3850:	00002097          	auipc	ra,0x2
    3854:	cd8080e7          	jalr	-808(ra) # 5528 <open>
  if(fd >= 0){
    3858:	12055263          	bgez	a0,397c <dirfile+0x1fc>
  fd = open(".", 0);
    385c:	4581                	li	a1,0
    385e:	00003517          	auipc	a0,0x3
    3862:	b8250513          	addi	a0,a0,-1150 # 63e0 <malloc+0xac2>
    3866:	00002097          	auipc	ra,0x2
    386a:	cc2080e7          	jalr	-830(ra) # 5528 <open>
    386e:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3870:	4605                	li	a2,1
    3872:	00002597          	auipc	a1,0x2
    3876:	54658593          	addi	a1,a1,1350 # 5db8 <malloc+0x49a>
    387a:	00002097          	auipc	ra,0x2
    387e:	c8e080e7          	jalr	-882(ra) # 5508 <write>
    3882:	10a04b63          	bgtz	a0,3998 <dirfile+0x218>
  close(fd);
    3886:	8526                	mv	a0,s1
    3888:	00002097          	auipc	ra,0x2
    388c:	c88080e7          	jalr	-888(ra) # 5510 <close>
}
    3890:	60e2                	ld	ra,24(sp)
    3892:	6442                	ld	s0,16(sp)
    3894:	64a2                	ld	s1,8(sp)
    3896:	6902                	ld	s2,0(sp)
    3898:	6105                	addi	sp,sp,32
    389a:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    389c:	85ca                	mv	a1,s2
    389e:	00004517          	auipc	a0,0x4
    38a2:	d0250513          	addi	a0,a0,-766 # 75a0 <malloc+0x1c82>
    38a6:	00002097          	auipc	ra,0x2
    38aa:	fba080e7          	jalr	-70(ra) # 5860 <printf>
    exit(1);
    38ae:	4505                	li	a0,1
    38b0:	00002097          	auipc	ra,0x2
    38b4:	c38080e7          	jalr	-968(ra) # 54e8 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    38b8:	85ca                	mv	a1,s2
    38ba:	00004517          	auipc	a0,0x4
    38be:	d0650513          	addi	a0,a0,-762 # 75c0 <malloc+0x1ca2>
    38c2:	00002097          	auipc	ra,0x2
    38c6:	f9e080e7          	jalr	-98(ra) # 5860 <printf>
    exit(1);
    38ca:	4505                	li	a0,1
    38cc:	00002097          	auipc	ra,0x2
    38d0:	c1c080e7          	jalr	-996(ra) # 54e8 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    38d4:	85ca                	mv	a1,s2
    38d6:	00004517          	auipc	a0,0x4
    38da:	d1a50513          	addi	a0,a0,-742 # 75f0 <malloc+0x1cd2>
    38de:	00002097          	auipc	ra,0x2
    38e2:	f82080e7          	jalr	-126(ra) # 5860 <printf>
    exit(1);
    38e6:	4505                	li	a0,1
    38e8:	00002097          	auipc	ra,0x2
    38ec:	c00080e7          	jalr	-1024(ra) # 54e8 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    38f0:	85ca                	mv	a1,s2
    38f2:	00004517          	auipc	a0,0x4
    38f6:	cfe50513          	addi	a0,a0,-770 # 75f0 <malloc+0x1cd2>
    38fa:	00002097          	auipc	ra,0x2
    38fe:	f66080e7          	jalr	-154(ra) # 5860 <printf>
    exit(1);
    3902:	4505                	li	a0,1
    3904:	00002097          	auipc	ra,0x2
    3908:	be4080e7          	jalr	-1052(ra) # 54e8 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    390c:	85ca                	mv	a1,s2
    390e:	00004517          	auipc	a0,0x4
    3912:	d0a50513          	addi	a0,a0,-758 # 7618 <malloc+0x1cfa>
    3916:	00002097          	auipc	ra,0x2
    391a:	f4a080e7          	jalr	-182(ra) # 5860 <printf>
    exit(1);
    391e:	4505                	li	a0,1
    3920:	00002097          	auipc	ra,0x2
    3924:	bc8080e7          	jalr	-1080(ra) # 54e8 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3928:	85ca                	mv	a1,s2
    392a:	00004517          	auipc	a0,0x4
    392e:	d1650513          	addi	a0,a0,-746 # 7640 <malloc+0x1d22>
    3932:	00002097          	auipc	ra,0x2
    3936:	f2e080e7          	jalr	-210(ra) # 5860 <printf>
    exit(1);
    393a:	4505                	li	a0,1
    393c:	00002097          	auipc	ra,0x2
    3940:	bac080e7          	jalr	-1108(ra) # 54e8 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3944:	85ca                	mv	a1,s2
    3946:	00004517          	auipc	a0,0x4
    394a:	d2250513          	addi	a0,a0,-734 # 7668 <malloc+0x1d4a>
    394e:	00002097          	auipc	ra,0x2
    3952:	f12080e7          	jalr	-238(ra) # 5860 <printf>
    exit(1);
    3956:	4505                	li	a0,1
    3958:	00002097          	auipc	ra,0x2
    395c:	b90080e7          	jalr	-1136(ra) # 54e8 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3960:	85ca                	mv	a1,s2
    3962:	00004517          	auipc	a0,0x4
    3966:	d2e50513          	addi	a0,a0,-722 # 7690 <malloc+0x1d72>
    396a:	00002097          	auipc	ra,0x2
    396e:	ef6080e7          	jalr	-266(ra) # 5860 <printf>
    exit(1);
    3972:	4505                	li	a0,1
    3974:	00002097          	auipc	ra,0x2
    3978:	b74080e7          	jalr	-1164(ra) # 54e8 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    397c:	85ca                	mv	a1,s2
    397e:	00004517          	auipc	a0,0x4
    3982:	d3250513          	addi	a0,a0,-718 # 76b0 <malloc+0x1d92>
    3986:	00002097          	auipc	ra,0x2
    398a:	eda080e7          	jalr	-294(ra) # 5860 <printf>
    exit(1);
    398e:	4505                	li	a0,1
    3990:	00002097          	auipc	ra,0x2
    3994:	b58080e7          	jalr	-1192(ra) # 54e8 <exit>
    printf("%s: write . succeeded!\n", s);
    3998:	85ca                	mv	a1,s2
    399a:	00004517          	auipc	a0,0x4
    399e:	d3e50513          	addi	a0,a0,-706 # 76d8 <malloc+0x1dba>
    39a2:	00002097          	auipc	ra,0x2
    39a6:	ebe080e7          	jalr	-322(ra) # 5860 <printf>
    exit(1);
    39aa:	4505                	li	a0,1
    39ac:	00002097          	auipc	ra,0x2
    39b0:	b3c080e7          	jalr	-1220(ra) # 54e8 <exit>

00000000000039b4 <iref>:
{
    39b4:	7139                	addi	sp,sp,-64
    39b6:	fc06                	sd	ra,56(sp)
    39b8:	f822                	sd	s0,48(sp)
    39ba:	f426                	sd	s1,40(sp)
    39bc:	f04a                	sd	s2,32(sp)
    39be:	ec4e                	sd	s3,24(sp)
    39c0:	e852                	sd	s4,16(sp)
    39c2:	e456                	sd	s5,8(sp)
    39c4:	e05a                	sd	s6,0(sp)
    39c6:	0080                	addi	s0,sp,64
    39c8:	8b2a                	mv	s6,a0
    39ca:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    39ce:	00004a17          	auipc	s4,0x4
    39d2:	d22a0a13          	addi	s4,s4,-734 # 76f0 <malloc+0x1dd2>
    mkdir("");
    39d6:	00004497          	auipc	s1,0x4
    39da:	82248493          	addi	s1,s1,-2014 # 71f8 <malloc+0x18da>
    link("README", "");
    39de:	00002a97          	auipc	s5,0x2
    39e2:	502a8a93          	addi	s5,s5,1282 # 5ee0 <malloc+0x5c2>
    fd = open("xx", O_CREATE);
    39e6:	00004997          	auipc	s3,0x4
    39ea:	c0298993          	addi	s3,s3,-1022 # 75e8 <malloc+0x1cca>
    39ee:	a891                	j	3a42 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    39f0:	85da                	mv	a1,s6
    39f2:	00004517          	auipc	a0,0x4
    39f6:	d0650513          	addi	a0,a0,-762 # 76f8 <malloc+0x1dda>
    39fa:	00002097          	auipc	ra,0x2
    39fe:	e66080e7          	jalr	-410(ra) # 5860 <printf>
      exit(1);
    3a02:	4505                	li	a0,1
    3a04:	00002097          	auipc	ra,0x2
    3a08:	ae4080e7          	jalr	-1308(ra) # 54e8 <exit>
      printf("%s: chdir irefd failed\n", s);
    3a0c:	85da                	mv	a1,s6
    3a0e:	00004517          	auipc	a0,0x4
    3a12:	d0250513          	addi	a0,a0,-766 # 7710 <malloc+0x1df2>
    3a16:	00002097          	auipc	ra,0x2
    3a1a:	e4a080e7          	jalr	-438(ra) # 5860 <printf>
      exit(1);
    3a1e:	4505                	li	a0,1
    3a20:	00002097          	auipc	ra,0x2
    3a24:	ac8080e7          	jalr	-1336(ra) # 54e8 <exit>
      close(fd);
    3a28:	00002097          	auipc	ra,0x2
    3a2c:	ae8080e7          	jalr	-1304(ra) # 5510 <close>
    3a30:	a889                	j	3a82 <iref+0xce>
    unlink("xx");
    3a32:	854e                	mv	a0,s3
    3a34:	00002097          	auipc	ra,0x2
    3a38:	b04080e7          	jalr	-1276(ra) # 5538 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3a3c:	397d                	addiw	s2,s2,-1
    3a3e:	06090063          	beqz	s2,3a9e <iref+0xea>
    if(mkdir("irefd") != 0){
    3a42:	8552                	mv	a0,s4
    3a44:	00002097          	auipc	ra,0x2
    3a48:	b0c080e7          	jalr	-1268(ra) # 5550 <mkdir>
    3a4c:	f155                	bnez	a0,39f0 <iref+0x3c>
    if(chdir("irefd") != 0){
    3a4e:	8552                	mv	a0,s4
    3a50:	00002097          	auipc	ra,0x2
    3a54:	b08080e7          	jalr	-1272(ra) # 5558 <chdir>
    3a58:	f955                	bnez	a0,3a0c <iref+0x58>
    mkdir("");
    3a5a:	8526                	mv	a0,s1
    3a5c:	00002097          	auipc	ra,0x2
    3a60:	af4080e7          	jalr	-1292(ra) # 5550 <mkdir>
    link("README", "");
    3a64:	85a6                	mv	a1,s1
    3a66:	8556                	mv	a0,s5
    3a68:	00002097          	auipc	ra,0x2
    3a6c:	ae0080e7          	jalr	-1312(ra) # 5548 <link>
    fd = open("", O_CREATE);
    3a70:	20000593          	li	a1,512
    3a74:	8526                	mv	a0,s1
    3a76:	00002097          	auipc	ra,0x2
    3a7a:	ab2080e7          	jalr	-1358(ra) # 5528 <open>
    if(fd >= 0)
    3a7e:	fa0555e3          	bgez	a0,3a28 <iref+0x74>
    fd = open("xx", O_CREATE);
    3a82:	20000593          	li	a1,512
    3a86:	854e                	mv	a0,s3
    3a88:	00002097          	auipc	ra,0x2
    3a8c:	aa0080e7          	jalr	-1376(ra) # 5528 <open>
    if(fd >= 0)
    3a90:	fa0541e3          	bltz	a0,3a32 <iref+0x7e>
      close(fd);
    3a94:	00002097          	auipc	ra,0x2
    3a98:	a7c080e7          	jalr	-1412(ra) # 5510 <close>
    3a9c:	bf59                	j	3a32 <iref+0x7e>
    3a9e:	03300493          	li	s1,51
    chdir("..");
    3aa2:	00004997          	auipc	s3,0x4
    3aa6:	a6e98993          	addi	s3,s3,-1426 # 7510 <malloc+0x1bf2>
    unlink("irefd");
    3aaa:	00004917          	auipc	s2,0x4
    3aae:	c4690913          	addi	s2,s2,-954 # 76f0 <malloc+0x1dd2>
    chdir("..");
    3ab2:	854e                	mv	a0,s3
    3ab4:	00002097          	auipc	ra,0x2
    3ab8:	aa4080e7          	jalr	-1372(ra) # 5558 <chdir>
    unlink("irefd");
    3abc:	854a                	mv	a0,s2
    3abe:	00002097          	auipc	ra,0x2
    3ac2:	a7a080e7          	jalr	-1414(ra) # 5538 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3ac6:	34fd                	addiw	s1,s1,-1
    3ac8:	f4ed                	bnez	s1,3ab2 <iref+0xfe>
  chdir("/");
    3aca:	00003517          	auipc	a0,0x3
    3ace:	44e50513          	addi	a0,a0,1102 # 6f18 <malloc+0x15fa>
    3ad2:	00002097          	auipc	ra,0x2
    3ad6:	a86080e7          	jalr	-1402(ra) # 5558 <chdir>
}
    3ada:	70e2                	ld	ra,56(sp)
    3adc:	7442                	ld	s0,48(sp)
    3ade:	74a2                	ld	s1,40(sp)
    3ae0:	7902                	ld	s2,32(sp)
    3ae2:	69e2                	ld	s3,24(sp)
    3ae4:	6a42                	ld	s4,16(sp)
    3ae6:	6aa2                	ld	s5,8(sp)
    3ae8:	6b02                	ld	s6,0(sp)
    3aea:	6121                	addi	sp,sp,64
    3aec:	8082                	ret

0000000000003aee <openiputtest>:
{
    3aee:	7179                	addi	sp,sp,-48
    3af0:	f406                	sd	ra,40(sp)
    3af2:	f022                	sd	s0,32(sp)
    3af4:	ec26                	sd	s1,24(sp)
    3af6:	1800                	addi	s0,sp,48
    3af8:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3afa:	00004517          	auipc	a0,0x4
    3afe:	c2e50513          	addi	a0,a0,-978 # 7728 <malloc+0x1e0a>
    3b02:	00002097          	auipc	ra,0x2
    3b06:	a4e080e7          	jalr	-1458(ra) # 5550 <mkdir>
    3b0a:	04054263          	bltz	a0,3b4e <openiputtest+0x60>
  pid = fork();
    3b0e:	00002097          	auipc	ra,0x2
    3b12:	9d2080e7          	jalr	-1582(ra) # 54e0 <fork>
  if(pid < 0){
    3b16:	04054a63          	bltz	a0,3b6a <openiputtest+0x7c>
  if(pid == 0){
    3b1a:	e93d                	bnez	a0,3b90 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3b1c:	4589                	li	a1,2
    3b1e:	00004517          	auipc	a0,0x4
    3b22:	c0a50513          	addi	a0,a0,-1014 # 7728 <malloc+0x1e0a>
    3b26:	00002097          	auipc	ra,0x2
    3b2a:	a02080e7          	jalr	-1534(ra) # 5528 <open>
    if(fd >= 0){
    3b2e:	04054c63          	bltz	a0,3b86 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3b32:	85a6                	mv	a1,s1
    3b34:	00004517          	auipc	a0,0x4
    3b38:	c1450513          	addi	a0,a0,-1004 # 7748 <malloc+0x1e2a>
    3b3c:	00002097          	auipc	ra,0x2
    3b40:	d24080e7          	jalr	-732(ra) # 5860 <printf>
      exit(1);
    3b44:	4505                	li	a0,1
    3b46:	00002097          	auipc	ra,0x2
    3b4a:	9a2080e7          	jalr	-1630(ra) # 54e8 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3b4e:	85a6                	mv	a1,s1
    3b50:	00004517          	auipc	a0,0x4
    3b54:	be050513          	addi	a0,a0,-1056 # 7730 <malloc+0x1e12>
    3b58:	00002097          	auipc	ra,0x2
    3b5c:	d08080e7          	jalr	-760(ra) # 5860 <printf>
    exit(1);
    3b60:	4505                	li	a0,1
    3b62:	00002097          	auipc	ra,0x2
    3b66:	986080e7          	jalr	-1658(ra) # 54e8 <exit>
    printf("%s: fork failed\n", s);
    3b6a:	85a6                	mv	a1,s1
    3b6c:	00003517          	auipc	a0,0x3
    3b70:	a1450513          	addi	a0,a0,-1516 # 6580 <malloc+0xc62>
    3b74:	00002097          	auipc	ra,0x2
    3b78:	cec080e7          	jalr	-788(ra) # 5860 <printf>
    exit(1);
    3b7c:	4505                	li	a0,1
    3b7e:	00002097          	auipc	ra,0x2
    3b82:	96a080e7          	jalr	-1686(ra) # 54e8 <exit>
    exit(0);
    3b86:	4501                	li	a0,0
    3b88:	00002097          	auipc	ra,0x2
    3b8c:	960080e7          	jalr	-1696(ra) # 54e8 <exit>
  sleep(1);
    3b90:	4505                	li	a0,1
    3b92:	00002097          	auipc	ra,0x2
    3b96:	9e6080e7          	jalr	-1562(ra) # 5578 <sleep>
  if(unlink("oidir") != 0){
    3b9a:	00004517          	auipc	a0,0x4
    3b9e:	b8e50513          	addi	a0,a0,-1138 # 7728 <malloc+0x1e0a>
    3ba2:	00002097          	auipc	ra,0x2
    3ba6:	996080e7          	jalr	-1642(ra) # 5538 <unlink>
    3baa:	cd19                	beqz	a0,3bc8 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3bac:	85a6                	mv	a1,s1
    3bae:	00003517          	auipc	a0,0x3
    3bb2:	bc250513          	addi	a0,a0,-1086 # 6770 <malloc+0xe52>
    3bb6:	00002097          	auipc	ra,0x2
    3bba:	caa080e7          	jalr	-854(ra) # 5860 <printf>
    exit(1);
    3bbe:	4505                	li	a0,1
    3bc0:	00002097          	auipc	ra,0x2
    3bc4:	928080e7          	jalr	-1752(ra) # 54e8 <exit>
  wait(&xstatus);
    3bc8:	fdc40513          	addi	a0,s0,-36
    3bcc:	00002097          	auipc	ra,0x2
    3bd0:	924080e7          	jalr	-1756(ra) # 54f0 <wait>
  exit(xstatus);
    3bd4:	fdc42503          	lw	a0,-36(s0)
    3bd8:	00002097          	auipc	ra,0x2
    3bdc:	910080e7          	jalr	-1776(ra) # 54e8 <exit>

0000000000003be0 <forkforkfork>:
{
    3be0:	1101                	addi	sp,sp,-32
    3be2:	ec06                	sd	ra,24(sp)
    3be4:	e822                	sd	s0,16(sp)
    3be6:	e426                	sd	s1,8(sp)
    3be8:	1000                	addi	s0,sp,32
    3bea:	84aa                	mv	s1,a0
  unlink("stopforking");
    3bec:	00004517          	auipc	a0,0x4
    3bf0:	b8450513          	addi	a0,a0,-1148 # 7770 <malloc+0x1e52>
    3bf4:	00002097          	auipc	ra,0x2
    3bf8:	944080e7          	jalr	-1724(ra) # 5538 <unlink>
  int pid = fork();
    3bfc:	00002097          	auipc	ra,0x2
    3c00:	8e4080e7          	jalr	-1820(ra) # 54e0 <fork>
  if(pid < 0){
    3c04:	04054563          	bltz	a0,3c4e <forkforkfork+0x6e>
  if(pid == 0){
    3c08:	c12d                	beqz	a0,3c6a <forkforkfork+0x8a>
  sleep(20); // two seconds
    3c0a:	4551                	li	a0,20
    3c0c:	00002097          	auipc	ra,0x2
    3c10:	96c080e7          	jalr	-1684(ra) # 5578 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3c14:	20200593          	li	a1,514
    3c18:	00004517          	auipc	a0,0x4
    3c1c:	b5850513          	addi	a0,a0,-1192 # 7770 <malloc+0x1e52>
    3c20:	00002097          	auipc	ra,0x2
    3c24:	908080e7          	jalr	-1784(ra) # 5528 <open>
    3c28:	00002097          	auipc	ra,0x2
    3c2c:	8e8080e7          	jalr	-1816(ra) # 5510 <close>
  wait(0);
    3c30:	4501                	li	a0,0
    3c32:	00002097          	auipc	ra,0x2
    3c36:	8be080e7          	jalr	-1858(ra) # 54f0 <wait>
  sleep(10); // one second
    3c3a:	4529                	li	a0,10
    3c3c:	00002097          	auipc	ra,0x2
    3c40:	93c080e7          	jalr	-1732(ra) # 5578 <sleep>
}
    3c44:	60e2                	ld	ra,24(sp)
    3c46:	6442                	ld	s0,16(sp)
    3c48:	64a2                	ld	s1,8(sp)
    3c4a:	6105                	addi	sp,sp,32
    3c4c:	8082                	ret
    printf("%s: fork failed", s);
    3c4e:	85a6                	mv	a1,s1
    3c50:	00003517          	auipc	a0,0x3
    3c54:	af050513          	addi	a0,a0,-1296 # 6740 <malloc+0xe22>
    3c58:	00002097          	auipc	ra,0x2
    3c5c:	c08080e7          	jalr	-1016(ra) # 5860 <printf>
    exit(1);
    3c60:	4505                	li	a0,1
    3c62:	00002097          	auipc	ra,0x2
    3c66:	886080e7          	jalr	-1914(ra) # 54e8 <exit>
      int fd = open("stopforking", 0);
    3c6a:	00004497          	auipc	s1,0x4
    3c6e:	b0648493          	addi	s1,s1,-1274 # 7770 <malloc+0x1e52>
    3c72:	4581                	li	a1,0
    3c74:	8526                	mv	a0,s1
    3c76:	00002097          	auipc	ra,0x2
    3c7a:	8b2080e7          	jalr	-1870(ra) # 5528 <open>
      if(fd >= 0){
    3c7e:	02055463          	bgez	a0,3ca6 <forkforkfork+0xc6>
      if(fork() < 0){
    3c82:	00002097          	auipc	ra,0x2
    3c86:	85e080e7          	jalr	-1954(ra) # 54e0 <fork>
    3c8a:	fe0554e3          	bgez	a0,3c72 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3c8e:	20200593          	li	a1,514
    3c92:	8526                	mv	a0,s1
    3c94:	00002097          	auipc	ra,0x2
    3c98:	894080e7          	jalr	-1900(ra) # 5528 <open>
    3c9c:	00002097          	auipc	ra,0x2
    3ca0:	874080e7          	jalr	-1932(ra) # 5510 <close>
    3ca4:	b7f9                	j	3c72 <forkforkfork+0x92>
        exit(0);
    3ca6:	4501                	li	a0,0
    3ca8:	00002097          	auipc	ra,0x2
    3cac:	840080e7          	jalr	-1984(ra) # 54e8 <exit>

0000000000003cb0 <preempt>:
{
    3cb0:	7139                	addi	sp,sp,-64
    3cb2:	fc06                	sd	ra,56(sp)
    3cb4:	f822                	sd	s0,48(sp)
    3cb6:	f426                	sd	s1,40(sp)
    3cb8:	f04a                	sd	s2,32(sp)
    3cba:	ec4e                	sd	s3,24(sp)
    3cbc:	e852                	sd	s4,16(sp)
    3cbe:	0080                	addi	s0,sp,64
    3cc0:	892a                	mv	s2,a0
  pid1 = fork();
    3cc2:	00002097          	auipc	ra,0x2
    3cc6:	81e080e7          	jalr	-2018(ra) # 54e0 <fork>
  if(pid1 < 0) {
    3cca:	00054563          	bltz	a0,3cd4 <preempt+0x24>
    3cce:	84aa                	mv	s1,a0
  if(pid1 == 0)
    3cd0:	ed19                	bnez	a0,3cee <preempt+0x3e>
    for(;;)
    3cd2:	a001                	j	3cd2 <preempt+0x22>
    printf("%s: fork failed");
    3cd4:	00003517          	auipc	a0,0x3
    3cd8:	a6c50513          	addi	a0,a0,-1428 # 6740 <malloc+0xe22>
    3cdc:	00002097          	auipc	ra,0x2
    3ce0:	b84080e7          	jalr	-1148(ra) # 5860 <printf>
    exit(1);
    3ce4:	4505                	li	a0,1
    3ce6:	00002097          	auipc	ra,0x2
    3cea:	802080e7          	jalr	-2046(ra) # 54e8 <exit>
  pid2 = fork();
    3cee:	00001097          	auipc	ra,0x1
    3cf2:	7f2080e7          	jalr	2034(ra) # 54e0 <fork>
    3cf6:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3cf8:	00054463          	bltz	a0,3d00 <preempt+0x50>
  if(pid2 == 0)
    3cfc:	e105                	bnez	a0,3d1c <preempt+0x6c>
    for(;;)
    3cfe:	a001                	j	3cfe <preempt+0x4e>
    printf("%s: fork failed\n", s);
    3d00:	85ca                	mv	a1,s2
    3d02:	00003517          	auipc	a0,0x3
    3d06:	87e50513          	addi	a0,a0,-1922 # 6580 <malloc+0xc62>
    3d0a:	00002097          	auipc	ra,0x2
    3d0e:	b56080e7          	jalr	-1194(ra) # 5860 <printf>
    exit(1);
    3d12:	4505                	li	a0,1
    3d14:	00001097          	auipc	ra,0x1
    3d18:	7d4080e7          	jalr	2004(ra) # 54e8 <exit>
  pipe(pfds);
    3d1c:	fc840513          	addi	a0,s0,-56
    3d20:	00001097          	auipc	ra,0x1
    3d24:	7d8080e7          	jalr	2008(ra) # 54f8 <pipe>
  pid3 = fork();
    3d28:	00001097          	auipc	ra,0x1
    3d2c:	7b8080e7          	jalr	1976(ra) # 54e0 <fork>
    3d30:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    3d32:	02054e63          	bltz	a0,3d6e <preempt+0xbe>
  if(pid3 == 0){
    3d36:	e13d                	bnez	a0,3d9c <preempt+0xec>
    close(pfds[0]);
    3d38:	fc842503          	lw	a0,-56(s0)
    3d3c:	00001097          	auipc	ra,0x1
    3d40:	7d4080e7          	jalr	2004(ra) # 5510 <close>
    if(write(pfds[1], "x", 1) != 1)
    3d44:	4605                	li	a2,1
    3d46:	00002597          	auipc	a1,0x2
    3d4a:	07258593          	addi	a1,a1,114 # 5db8 <malloc+0x49a>
    3d4e:	fcc42503          	lw	a0,-52(s0)
    3d52:	00001097          	auipc	ra,0x1
    3d56:	7b6080e7          	jalr	1974(ra) # 5508 <write>
    3d5a:	4785                	li	a5,1
    3d5c:	02f51763          	bne	a0,a5,3d8a <preempt+0xda>
    close(pfds[1]);
    3d60:	fcc42503          	lw	a0,-52(s0)
    3d64:	00001097          	auipc	ra,0x1
    3d68:	7ac080e7          	jalr	1964(ra) # 5510 <close>
    for(;;)
    3d6c:	a001                	j	3d6c <preempt+0xbc>
     printf("%s: fork failed\n", s);
    3d6e:	85ca                	mv	a1,s2
    3d70:	00003517          	auipc	a0,0x3
    3d74:	81050513          	addi	a0,a0,-2032 # 6580 <malloc+0xc62>
    3d78:	00002097          	auipc	ra,0x2
    3d7c:	ae8080e7          	jalr	-1304(ra) # 5860 <printf>
     exit(1);
    3d80:	4505                	li	a0,1
    3d82:	00001097          	auipc	ra,0x1
    3d86:	766080e7          	jalr	1894(ra) # 54e8 <exit>
      printf("%s: preempt write error");
    3d8a:	00004517          	auipc	a0,0x4
    3d8e:	9f650513          	addi	a0,a0,-1546 # 7780 <malloc+0x1e62>
    3d92:	00002097          	auipc	ra,0x2
    3d96:	ace080e7          	jalr	-1330(ra) # 5860 <printf>
    3d9a:	b7d9                	j	3d60 <preempt+0xb0>
  close(pfds[1]);
    3d9c:	fcc42503          	lw	a0,-52(s0)
    3da0:	00001097          	auipc	ra,0x1
    3da4:	770080e7          	jalr	1904(ra) # 5510 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3da8:	660d                	lui	a2,0x3
    3daa:	00008597          	auipc	a1,0x8
    3dae:	bbe58593          	addi	a1,a1,-1090 # b968 <buf>
    3db2:	fc842503          	lw	a0,-56(s0)
    3db6:	00001097          	auipc	ra,0x1
    3dba:	74a080e7          	jalr	1866(ra) # 5500 <read>
    3dbe:	4785                	li	a5,1
    3dc0:	02f50263          	beq	a0,a5,3de4 <preempt+0x134>
    printf("%s: preempt read error");
    3dc4:	00004517          	auipc	a0,0x4
    3dc8:	9d450513          	addi	a0,a0,-1580 # 7798 <malloc+0x1e7a>
    3dcc:	00002097          	auipc	ra,0x2
    3dd0:	a94080e7          	jalr	-1388(ra) # 5860 <printf>
}
    3dd4:	70e2                	ld	ra,56(sp)
    3dd6:	7442                	ld	s0,48(sp)
    3dd8:	74a2                	ld	s1,40(sp)
    3dda:	7902                	ld	s2,32(sp)
    3ddc:	69e2                	ld	s3,24(sp)
    3dde:	6a42                	ld	s4,16(sp)
    3de0:	6121                	addi	sp,sp,64
    3de2:	8082                	ret
  close(pfds[0]);
    3de4:	fc842503          	lw	a0,-56(s0)
    3de8:	00001097          	auipc	ra,0x1
    3dec:	728080e7          	jalr	1832(ra) # 5510 <close>
  printf("kill... ");
    3df0:	00004517          	auipc	a0,0x4
    3df4:	9c050513          	addi	a0,a0,-1600 # 77b0 <malloc+0x1e92>
    3df8:	00002097          	auipc	ra,0x2
    3dfc:	a68080e7          	jalr	-1432(ra) # 5860 <printf>
  kill(pid1);
    3e00:	8526                	mv	a0,s1
    3e02:	00001097          	auipc	ra,0x1
    3e06:	716080e7          	jalr	1814(ra) # 5518 <kill>
  kill(pid2);
    3e0a:	854e                	mv	a0,s3
    3e0c:	00001097          	auipc	ra,0x1
    3e10:	70c080e7          	jalr	1804(ra) # 5518 <kill>
  kill(pid3);
    3e14:	8552                	mv	a0,s4
    3e16:	00001097          	auipc	ra,0x1
    3e1a:	702080e7          	jalr	1794(ra) # 5518 <kill>
  printf("wait... ");
    3e1e:	00004517          	auipc	a0,0x4
    3e22:	9a250513          	addi	a0,a0,-1630 # 77c0 <malloc+0x1ea2>
    3e26:	00002097          	auipc	ra,0x2
    3e2a:	a3a080e7          	jalr	-1478(ra) # 5860 <printf>
  wait(0);
    3e2e:	4501                	li	a0,0
    3e30:	00001097          	auipc	ra,0x1
    3e34:	6c0080e7          	jalr	1728(ra) # 54f0 <wait>
  wait(0);
    3e38:	4501                	li	a0,0
    3e3a:	00001097          	auipc	ra,0x1
    3e3e:	6b6080e7          	jalr	1718(ra) # 54f0 <wait>
  wait(0);
    3e42:	4501                	li	a0,0
    3e44:	00001097          	auipc	ra,0x1
    3e48:	6ac080e7          	jalr	1708(ra) # 54f0 <wait>
    3e4c:	b761                	j	3dd4 <preempt+0x124>

0000000000003e4e <sbrkfail>:
{
    3e4e:	7119                	addi	sp,sp,-128
    3e50:	fc86                	sd	ra,120(sp)
    3e52:	f8a2                	sd	s0,112(sp)
    3e54:	f4a6                	sd	s1,104(sp)
    3e56:	f0ca                	sd	s2,96(sp)
    3e58:	ecce                	sd	s3,88(sp)
    3e5a:	e8d2                	sd	s4,80(sp)
    3e5c:	e4d6                	sd	s5,72(sp)
    3e5e:	0100                	addi	s0,sp,128
    3e60:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    3e62:	fb040513          	addi	a0,s0,-80
    3e66:	00001097          	auipc	ra,0x1
    3e6a:	692080e7          	jalr	1682(ra) # 54f8 <pipe>
    3e6e:	e901                	bnez	a0,3e7e <sbrkfail+0x30>
    3e70:	f8040493          	addi	s1,s0,-128
    3e74:	fa840993          	addi	s3,s0,-88
    3e78:	8926                	mv	s2,s1
    if(pids[i] != -1)
    3e7a:	5a7d                	li	s4,-1
    3e7c:	a085                	j	3edc <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    3e7e:	85d6                	mv	a1,s5
    3e80:	00003517          	auipc	a0,0x3
    3e84:	80850513          	addi	a0,a0,-2040 # 6688 <malloc+0xd6a>
    3e88:	00002097          	auipc	ra,0x2
    3e8c:	9d8080e7          	jalr	-1576(ra) # 5860 <printf>
    exit(1);
    3e90:	4505                	li	a0,1
    3e92:	00001097          	auipc	ra,0x1
    3e96:	656080e7          	jalr	1622(ra) # 54e8 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    3e9a:	00001097          	auipc	ra,0x1
    3e9e:	6d6080e7          	jalr	1750(ra) # 5570 <sbrk>
    3ea2:	064007b7          	lui	a5,0x6400
    3ea6:	40a7853b          	subw	a0,a5,a0
    3eaa:	00001097          	auipc	ra,0x1
    3eae:	6c6080e7          	jalr	1734(ra) # 5570 <sbrk>
      write(fds[1], "x", 1);
    3eb2:	4605                	li	a2,1
    3eb4:	00002597          	auipc	a1,0x2
    3eb8:	f0458593          	addi	a1,a1,-252 # 5db8 <malloc+0x49a>
    3ebc:	fb442503          	lw	a0,-76(s0)
    3ec0:	00001097          	auipc	ra,0x1
    3ec4:	648080e7          	jalr	1608(ra) # 5508 <write>
      for(;;) sleep(1000);
    3ec8:	3e800513          	li	a0,1000
    3ecc:	00001097          	auipc	ra,0x1
    3ed0:	6ac080e7          	jalr	1708(ra) # 5578 <sleep>
    3ed4:	bfd5                	j	3ec8 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3ed6:	0911                	addi	s2,s2,4
    3ed8:	03390563          	beq	s2,s3,3f02 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    3edc:	00001097          	auipc	ra,0x1
    3ee0:	604080e7          	jalr	1540(ra) # 54e0 <fork>
    3ee4:	00a92023          	sw	a0,0(s2)
    3ee8:	d94d                	beqz	a0,3e9a <sbrkfail+0x4c>
    if(pids[i] != -1)
    3eea:	ff4506e3          	beq	a0,s4,3ed6 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    3eee:	4605                	li	a2,1
    3ef0:	faf40593          	addi	a1,s0,-81
    3ef4:	fb042503          	lw	a0,-80(s0)
    3ef8:	00001097          	auipc	ra,0x1
    3efc:	608080e7          	jalr	1544(ra) # 5500 <read>
    3f00:	bfd9                	j	3ed6 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    3f02:	6505                	lui	a0,0x1
    3f04:	00001097          	auipc	ra,0x1
    3f08:	66c080e7          	jalr	1644(ra) # 5570 <sbrk>
    3f0c:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    3f0e:	597d                	li	s2,-1
    3f10:	a021                	j	3f18 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3f12:	0491                	addi	s1,s1,4
    3f14:	01348f63          	beq	s1,s3,3f32 <sbrkfail+0xe4>
    if(pids[i] == -1)
    3f18:	4088                	lw	a0,0(s1)
    3f1a:	ff250ce3          	beq	a0,s2,3f12 <sbrkfail+0xc4>
    kill(pids[i]);
    3f1e:	00001097          	auipc	ra,0x1
    3f22:	5fa080e7          	jalr	1530(ra) # 5518 <kill>
    wait(0);
    3f26:	4501                	li	a0,0
    3f28:	00001097          	auipc	ra,0x1
    3f2c:	5c8080e7          	jalr	1480(ra) # 54f0 <wait>
    3f30:	b7cd                	j	3f12 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    3f32:	57fd                	li	a5,-1
    3f34:	04fa0163          	beq	s4,a5,3f76 <sbrkfail+0x128>
  pid = fork();
    3f38:	00001097          	auipc	ra,0x1
    3f3c:	5a8080e7          	jalr	1448(ra) # 54e0 <fork>
    3f40:	84aa                	mv	s1,a0
  if(pid < 0){
    3f42:	04054863          	bltz	a0,3f92 <sbrkfail+0x144>
  if(pid == 0){
    3f46:	c525                	beqz	a0,3fae <sbrkfail+0x160>
  wait(&xstatus);
    3f48:	fbc40513          	addi	a0,s0,-68
    3f4c:	00001097          	auipc	ra,0x1
    3f50:	5a4080e7          	jalr	1444(ra) # 54f0 <wait>
  if(xstatus != -1 && xstatus != 2)
    3f54:	fbc42783          	lw	a5,-68(s0)
    3f58:	577d                	li	a4,-1
    3f5a:	00e78563          	beq	a5,a4,3f64 <sbrkfail+0x116>
    3f5e:	4709                	li	a4,2
    3f60:	08e79c63          	bne	a5,a4,3ff8 <sbrkfail+0x1aa>
}
    3f64:	70e6                	ld	ra,120(sp)
    3f66:	7446                	ld	s0,112(sp)
    3f68:	74a6                	ld	s1,104(sp)
    3f6a:	7906                	ld	s2,96(sp)
    3f6c:	69e6                	ld	s3,88(sp)
    3f6e:	6a46                	ld	s4,80(sp)
    3f70:	6aa6                	ld	s5,72(sp)
    3f72:	6109                	addi	sp,sp,128
    3f74:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    3f76:	85d6                	mv	a1,s5
    3f78:	00004517          	auipc	a0,0x4
    3f7c:	85850513          	addi	a0,a0,-1960 # 77d0 <malloc+0x1eb2>
    3f80:	00002097          	auipc	ra,0x2
    3f84:	8e0080e7          	jalr	-1824(ra) # 5860 <printf>
    exit(1);
    3f88:	4505                	li	a0,1
    3f8a:	00001097          	auipc	ra,0x1
    3f8e:	55e080e7          	jalr	1374(ra) # 54e8 <exit>
    printf("%s: fork failed\n", s);
    3f92:	85d6                	mv	a1,s5
    3f94:	00002517          	auipc	a0,0x2
    3f98:	5ec50513          	addi	a0,a0,1516 # 6580 <malloc+0xc62>
    3f9c:	00002097          	auipc	ra,0x2
    3fa0:	8c4080e7          	jalr	-1852(ra) # 5860 <printf>
    exit(1);
    3fa4:	4505                	li	a0,1
    3fa6:	00001097          	auipc	ra,0x1
    3faa:	542080e7          	jalr	1346(ra) # 54e8 <exit>
    a = sbrk(0);
    3fae:	4501                	li	a0,0
    3fb0:	00001097          	auipc	ra,0x1
    3fb4:	5c0080e7          	jalr	1472(ra) # 5570 <sbrk>
    3fb8:	892a                	mv	s2,a0
    sbrk(10*BIG);
    3fba:	3e800537          	lui	a0,0x3e800
    3fbe:	00001097          	auipc	ra,0x1
    3fc2:	5b2080e7          	jalr	1458(ra) # 5570 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    3fc6:	87ca                	mv	a5,s2
    3fc8:	3e800737          	lui	a4,0x3e800
    3fcc:	993a                	add	s2,s2,a4
    3fce:	6705                	lui	a4,0x1
      n += *(a+i);
    3fd0:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f1688>
    3fd4:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    3fd6:	97ba                	add	a5,a5,a4
    3fd8:	ff279ce3          	bne	a5,s2,3fd0 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", n);
    3fdc:	85a6                	mv	a1,s1
    3fde:	00004517          	auipc	a0,0x4
    3fe2:	81250513          	addi	a0,a0,-2030 # 77f0 <malloc+0x1ed2>
    3fe6:	00002097          	auipc	ra,0x2
    3fea:	87a080e7          	jalr	-1926(ra) # 5860 <printf>
    exit(1);
    3fee:	4505                	li	a0,1
    3ff0:	00001097          	auipc	ra,0x1
    3ff4:	4f8080e7          	jalr	1272(ra) # 54e8 <exit>
    exit(1);
    3ff8:	4505                	li	a0,1
    3ffa:	00001097          	auipc	ra,0x1
    3ffe:	4ee080e7          	jalr	1262(ra) # 54e8 <exit>

0000000000004002 <reparent>:
{
    4002:	7179                	addi	sp,sp,-48
    4004:	f406                	sd	ra,40(sp)
    4006:	f022                	sd	s0,32(sp)
    4008:	ec26                	sd	s1,24(sp)
    400a:	e84a                	sd	s2,16(sp)
    400c:	e44e                	sd	s3,8(sp)
    400e:	e052                	sd	s4,0(sp)
    4010:	1800                	addi	s0,sp,48
    4012:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4014:	00001097          	auipc	ra,0x1
    4018:	554080e7          	jalr	1364(ra) # 5568 <getpid>
    401c:	8a2a                	mv	s4,a0
    401e:	0c800913          	li	s2,200
    int pid = fork();
    4022:	00001097          	auipc	ra,0x1
    4026:	4be080e7          	jalr	1214(ra) # 54e0 <fork>
    402a:	84aa                	mv	s1,a0
    if(pid < 0){
    402c:	02054263          	bltz	a0,4050 <reparent+0x4e>
    if(pid){
    4030:	cd21                	beqz	a0,4088 <reparent+0x86>
      if(wait(0) != pid){
    4032:	4501                	li	a0,0
    4034:	00001097          	auipc	ra,0x1
    4038:	4bc080e7          	jalr	1212(ra) # 54f0 <wait>
    403c:	02951863          	bne	a0,s1,406c <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    4040:	397d                	addiw	s2,s2,-1
    4042:	fe0910e3          	bnez	s2,4022 <reparent+0x20>
  exit(0);
    4046:	4501                	li	a0,0
    4048:	00001097          	auipc	ra,0x1
    404c:	4a0080e7          	jalr	1184(ra) # 54e8 <exit>
      printf("%s: fork failed\n", s);
    4050:	85ce                	mv	a1,s3
    4052:	00002517          	auipc	a0,0x2
    4056:	52e50513          	addi	a0,a0,1326 # 6580 <malloc+0xc62>
    405a:	00002097          	auipc	ra,0x2
    405e:	806080e7          	jalr	-2042(ra) # 5860 <printf>
      exit(1);
    4062:	4505                	li	a0,1
    4064:	00001097          	auipc	ra,0x1
    4068:	484080e7          	jalr	1156(ra) # 54e8 <exit>
        printf("%s: wait wrong pid\n", s);
    406c:	85ce                	mv	a1,s3
    406e:	00002517          	auipc	a0,0x2
    4072:	69a50513          	addi	a0,a0,1690 # 6708 <malloc+0xdea>
    4076:	00001097          	auipc	ra,0x1
    407a:	7ea080e7          	jalr	2026(ra) # 5860 <printf>
        exit(1);
    407e:	4505                	li	a0,1
    4080:	00001097          	auipc	ra,0x1
    4084:	468080e7          	jalr	1128(ra) # 54e8 <exit>
      int pid2 = fork();
    4088:	00001097          	auipc	ra,0x1
    408c:	458080e7          	jalr	1112(ra) # 54e0 <fork>
      if(pid2 < 0){
    4090:	00054763          	bltz	a0,409e <reparent+0x9c>
      exit(0);
    4094:	4501                	li	a0,0
    4096:	00001097          	auipc	ra,0x1
    409a:	452080e7          	jalr	1106(ra) # 54e8 <exit>
        kill(master_pid);
    409e:	8552                	mv	a0,s4
    40a0:	00001097          	auipc	ra,0x1
    40a4:	478080e7          	jalr	1144(ra) # 5518 <kill>
        exit(1);
    40a8:	4505                	li	a0,1
    40aa:	00001097          	auipc	ra,0x1
    40ae:	43e080e7          	jalr	1086(ra) # 54e8 <exit>

00000000000040b2 <mem>:
{
    40b2:	7139                	addi	sp,sp,-64
    40b4:	fc06                	sd	ra,56(sp)
    40b6:	f822                	sd	s0,48(sp)
    40b8:	f426                	sd	s1,40(sp)
    40ba:	f04a                	sd	s2,32(sp)
    40bc:	ec4e                	sd	s3,24(sp)
    40be:	0080                	addi	s0,sp,64
    40c0:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    40c2:	00001097          	auipc	ra,0x1
    40c6:	41e080e7          	jalr	1054(ra) # 54e0 <fork>
    m1 = 0;
    40ca:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    40cc:	6909                	lui	s2,0x2
    40ce:	71190913          	addi	s2,s2,1809 # 2711 <sbrkmuch+0x11b>
  if((pid = fork()) == 0){
    40d2:	c115                	beqz	a0,40f6 <mem+0x44>
    wait(&xstatus);
    40d4:	fcc40513          	addi	a0,s0,-52
    40d8:	00001097          	auipc	ra,0x1
    40dc:	418080e7          	jalr	1048(ra) # 54f0 <wait>
    if(xstatus == -1){
    40e0:	fcc42503          	lw	a0,-52(s0)
    40e4:	57fd                	li	a5,-1
    40e6:	06f50363          	beq	a0,a5,414c <mem+0x9a>
    exit(xstatus);
    40ea:	00001097          	auipc	ra,0x1
    40ee:	3fe080e7          	jalr	1022(ra) # 54e8 <exit>
      *(char**)m2 = m1;
    40f2:	e104                	sd	s1,0(a0)
      m1 = m2;
    40f4:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    40f6:	854a                	mv	a0,s2
    40f8:	00002097          	auipc	ra,0x2
    40fc:	826080e7          	jalr	-2010(ra) # 591e <malloc>
    4100:	f96d                	bnez	a0,40f2 <mem+0x40>
    while(m1){
    4102:	c881                	beqz	s1,4112 <mem+0x60>
      m2 = *(char**)m1;
    4104:	8526                	mv	a0,s1
    4106:	6084                	ld	s1,0(s1)
      free(m1);
    4108:	00001097          	auipc	ra,0x1
    410c:	78e080e7          	jalr	1934(ra) # 5896 <free>
    while(m1){
    4110:	f8f5                	bnez	s1,4104 <mem+0x52>
    m1 = malloc(1024*20);
    4112:	6515                	lui	a0,0x5
    4114:	00002097          	auipc	ra,0x2
    4118:	80a080e7          	jalr	-2038(ra) # 591e <malloc>
    if(m1 == 0){
    411c:	c911                	beqz	a0,4130 <mem+0x7e>
    free(m1);
    411e:	00001097          	auipc	ra,0x1
    4122:	778080e7          	jalr	1912(ra) # 5896 <free>
    exit(0);
    4126:	4501                	li	a0,0
    4128:	00001097          	auipc	ra,0x1
    412c:	3c0080e7          	jalr	960(ra) # 54e8 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4130:	85ce                	mv	a1,s3
    4132:	00003517          	auipc	a0,0x3
    4136:	6ee50513          	addi	a0,a0,1774 # 7820 <malloc+0x1f02>
    413a:	00001097          	auipc	ra,0x1
    413e:	726080e7          	jalr	1830(ra) # 5860 <printf>
      exit(1);
    4142:	4505                	li	a0,1
    4144:	00001097          	auipc	ra,0x1
    4148:	3a4080e7          	jalr	932(ra) # 54e8 <exit>
      exit(0);
    414c:	4501                	li	a0,0
    414e:	00001097          	auipc	ra,0x1
    4152:	39a080e7          	jalr	922(ra) # 54e8 <exit>

0000000000004156 <sharedfd>:
{
    4156:	7159                	addi	sp,sp,-112
    4158:	f486                	sd	ra,104(sp)
    415a:	f0a2                	sd	s0,96(sp)
    415c:	eca6                	sd	s1,88(sp)
    415e:	e8ca                	sd	s2,80(sp)
    4160:	e4ce                	sd	s3,72(sp)
    4162:	e0d2                	sd	s4,64(sp)
    4164:	fc56                	sd	s5,56(sp)
    4166:	f85a                	sd	s6,48(sp)
    4168:	f45e                	sd	s7,40(sp)
    416a:	1880                	addi	s0,sp,112
    416c:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    416e:	00002517          	auipc	a0,0x2
    4172:	a2250513          	addi	a0,a0,-1502 # 5b90 <malloc+0x272>
    4176:	00001097          	auipc	ra,0x1
    417a:	3c2080e7          	jalr	962(ra) # 5538 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    417e:	20200593          	li	a1,514
    4182:	00002517          	auipc	a0,0x2
    4186:	a0e50513          	addi	a0,a0,-1522 # 5b90 <malloc+0x272>
    418a:	00001097          	auipc	ra,0x1
    418e:	39e080e7          	jalr	926(ra) # 5528 <open>
  if(fd < 0){
    4192:	04054a63          	bltz	a0,41e6 <sharedfd+0x90>
    4196:	892a                	mv	s2,a0
  pid = fork();
    4198:	00001097          	auipc	ra,0x1
    419c:	348080e7          	jalr	840(ra) # 54e0 <fork>
    41a0:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    41a2:	06300593          	li	a1,99
    41a6:	c119                	beqz	a0,41ac <sharedfd+0x56>
    41a8:	07000593          	li	a1,112
    41ac:	4629                	li	a2,10
    41ae:	fa040513          	addi	a0,s0,-96
    41b2:	00001097          	auipc	ra,0x1
    41b6:	13a080e7          	jalr	314(ra) # 52ec <memset>
    41ba:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    41be:	4629                	li	a2,10
    41c0:	fa040593          	addi	a1,s0,-96
    41c4:	854a                	mv	a0,s2
    41c6:	00001097          	auipc	ra,0x1
    41ca:	342080e7          	jalr	834(ra) # 5508 <write>
    41ce:	47a9                	li	a5,10
    41d0:	02f51963          	bne	a0,a5,4202 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    41d4:	34fd                	addiw	s1,s1,-1
    41d6:	f4e5                	bnez	s1,41be <sharedfd+0x68>
  if(pid == 0) {
    41d8:	04099363          	bnez	s3,421e <sharedfd+0xc8>
    exit(0);
    41dc:	4501                	li	a0,0
    41de:	00001097          	auipc	ra,0x1
    41e2:	30a080e7          	jalr	778(ra) # 54e8 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    41e6:	85d2                	mv	a1,s4
    41e8:	00003517          	auipc	a0,0x3
    41ec:	65850513          	addi	a0,a0,1624 # 7840 <malloc+0x1f22>
    41f0:	00001097          	auipc	ra,0x1
    41f4:	670080e7          	jalr	1648(ra) # 5860 <printf>
    exit(1);
    41f8:	4505                	li	a0,1
    41fa:	00001097          	auipc	ra,0x1
    41fe:	2ee080e7          	jalr	750(ra) # 54e8 <exit>
      printf("%s: write sharedfd failed\n", s);
    4202:	85d2                	mv	a1,s4
    4204:	00003517          	auipc	a0,0x3
    4208:	66450513          	addi	a0,a0,1636 # 7868 <malloc+0x1f4a>
    420c:	00001097          	auipc	ra,0x1
    4210:	654080e7          	jalr	1620(ra) # 5860 <printf>
      exit(1);
    4214:	4505                	li	a0,1
    4216:	00001097          	auipc	ra,0x1
    421a:	2d2080e7          	jalr	722(ra) # 54e8 <exit>
    wait(&xstatus);
    421e:	f9c40513          	addi	a0,s0,-100
    4222:	00001097          	auipc	ra,0x1
    4226:	2ce080e7          	jalr	718(ra) # 54f0 <wait>
    if(xstatus != 0)
    422a:	f9c42983          	lw	s3,-100(s0)
    422e:	00098763          	beqz	s3,423c <sharedfd+0xe6>
      exit(xstatus);
    4232:	854e                	mv	a0,s3
    4234:	00001097          	auipc	ra,0x1
    4238:	2b4080e7          	jalr	692(ra) # 54e8 <exit>
  close(fd);
    423c:	854a                	mv	a0,s2
    423e:	00001097          	auipc	ra,0x1
    4242:	2d2080e7          	jalr	722(ra) # 5510 <close>
  fd = open("sharedfd", 0);
    4246:	4581                	li	a1,0
    4248:	00002517          	auipc	a0,0x2
    424c:	94850513          	addi	a0,a0,-1720 # 5b90 <malloc+0x272>
    4250:	00001097          	auipc	ra,0x1
    4254:	2d8080e7          	jalr	728(ra) # 5528 <open>
    4258:	8baa                	mv	s7,a0
  nc = np = 0;
    425a:	8ace                	mv	s5,s3
  if(fd < 0){
    425c:	02054563          	bltz	a0,4286 <sharedfd+0x130>
    4260:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4264:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4268:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    426c:	4629                	li	a2,10
    426e:	fa040593          	addi	a1,s0,-96
    4272:	855e                	mv	a0,s7
    4274:	00001097          	auipc	ra,0x1
    4278:	28c080e7          	jalr	652(ra) # 5500 <read>
    427c:	02a05f63          	blez	a0,42ba <sharedfd+0x164>
    4280:	fa040793          	addi	a5,s0,-96
    4284:	a01d                	j	42aa <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4286:	85d2                	mv	a1,s4
    4288:	00003517          	auipc	a0,0x3
    428c:	60050513          	addi	a0,a0,1536 # 7888 <malloc+0x1f6a>
    4290:	00001097          	auipc	ra,0x1
    4294:	5d0080e7          	jalr	1488(ra) # 5860 <printf>
    exit(1);
    4298:	4505                	li	a0,1
    429a:	00001097          	auipc	ra,0x1
    429e:	24e080e7          	jalr	590(ra) # 54e8 <exit>
        nc++;
    42a2:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    42a4:	0785                	addi	a5,a5,1
    42a6:	fd2783e3          	beq	a5,s2,426c <sharedfd+0x116>
      if(buf[i] == 'c')
    42aa:	0007c703          	lbu	a4,0(a5)
    42ae:	fe970ae3          	beq	a4,s1,42a2 <sharedfd+0x14c>
      if(buf[i] == 'p')
    42b2:	ff6719e3          	bne	a4,s6,42a4 <sharedfd+0x14e>
        np++;
    42b6:	2a85                	addiw	s5,s5,1
    42b8:	b7f5                	j	42a4 <sharedfd+0x14e>
  close(fd);
    42ba:	855e                	mv	a0,s7
    42bc:	00001097          	auipc	ra,0x1
    42c0:	254080e7          	jalr	596(ra) # 5510 <close>
  unlink("sharedfd");
    42c4:	00002517          	auipc	a0,0x2
    42c8:	8cc50513          	addi	a0,a0,-1844 # 5b90 <malloc+0x272>
    42cc:	00001097          	auipc	ra,0x1
    42d0:	26c080e7          	jalr	620(ra) # 5538 <unlink>
  if(nc == N*SZ && np == N*SZ){
    42d4:	6789                	lui	a5,0x2
    42d6:	71078793          	addi	a5,a5,1808 # 2710 <sbrkmuch+0x11a>
    42da:	00f99763          	bne	s3,a5,42e8 <sharedfd+0x192>
    42de:	6789                	lui	a5,0x2
    42e0:	71078793          	addi	a5,a5,1808 # 2710 <sbrkmuch+0x11a>
    42e4:	02fa8063          	beq	s5,a5,4304 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    42e8:	85d2                	mv	a1,s4
    42ea:	00003517          	auipc	a0,0x3
    42ee:	5c650513          	addi	a0,a0,1478 # 78b0 <malloc+0x1f92>
    42f2:	00001097          	auipc	ra,0x1
    42f6:	56e080e7          	jalr	1390(ra) # 5860 <printf>
    exit(1);
    42fa:	4505                	li	a0,1
    42fc:	00001097          	auipc	ra,0x1
    4300:	1ec080e7          	jalr	492(ra) # 54e8 <exit>
    exit(0);
    4304:	4501                	li	a0,0
    4306:	00001097          	auipc	ra,0x1
    430a:	1e2080e7          	jalr	482(ra) # 54e8 <exit>

000000000000430e <fourfiles>:
{
    430e:	7171                	addi	sp,sp,-176
    4310:	f506                	sd	ra,168(sp)
    4312:	f122                	sd	s0,160(sp)
    4314:	ed26                	sd	s1,152(sp)
    4316:	e94a                	sd	s2,144(sp)
    4318:	e54e                	sd	s3,136(sp)
    431a:	e152                	sd	s4,128(sp)
    431c:	fcd6                	sd	s5,120(sp)
    431e:	f8da                	sd	s6,112(sp)
    4320:	f4de                	sd	s7,104(sp)
    4322:	f0e2                	sd	s8,96(sp)
    4324:	ece6                	sd	s9,88(sp)
    4326:	e8ea                	sd	s10,80(sp)
    4328:	e4ee                	sd	s11,72(sp)
    432a:	1900                	addi	s0,sp,176
    432c:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    4330:	00001797          	auipc	a5,0x1
    4334:	6d878793          	addi	a5,a5,1752 # 5a08 <malloc+0xea>
    4338:	f6f43823          	sd	a5,-144(s0)
    433c:	00001797          	auipc	a5,0x1
    4340:	6d478793          	addi	a5,a5,1748 # 5a10 <malloc+0xf2>
    4344:	f6f43c23          	sd	a5,-136(s0)
    4348:	00001797          	auipc	a5,0x1
    434c:	6d078793          	addi	a5,a5,1744 # 5a18 <malloc+0xfa>
    4350:	f8f43023          	sd	a5,-128(s0)
    4354:	00001797          	auipc	a5,0x1
    4358:	6cc78793          	addi	a5,a5,1740 # 5a20 <malloc+0x102>
    435c:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4360:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4364:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    4366:	4481                	li	s1,0
    4368:	4a11                	li	s4,4
    fname = names[pi];
    436a:	00093983          	ld	s3,0(s2)
    unlink(fname);
    436e:	854e                	mv	a0,s3
    4370:	00001097          	auipc	ra,0x1
    4374:	1c8080e7          	jalr	456(ra) # 5538 <unlink>
    pid = fork();
    4378:	00001097          	auipc	ra,0x1
    437c:	168080e7          	jalr	360(ra) # 54e0 <fork>
    if(pid < 0){
    4380:	04054463          	bltz	a0,43c8 <fourfiles+0xba>
    if(pid == 0){
    4384:	c12d                	beqz	a0,43e6 <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    4386:	2485                	addiw	s1,s1,1
    4388:	0921                	addi	s2,s2,8
    438a:	ff4490e3          	bne	s1,s4,436a <fourfiles+0x5c>
    438e:	4491                	li	s1,4
    wait(&xstatus);
    4390:	f6c40513          	addi	a0,s0,-148
    4394:	00001097          	auipc	ra,0x1
    4398:	15c080e7          	jalr	348(ra) # 54f0 <wait>
    if(xstatus != 0)
    439c:	f6c42b03          	lw	s6,-148(s0)
    43a0:	0c0b1e63          	bnez	s6,447c <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    43a4:	34fd                	addiw	s1,s1,-1
    43a6:	f4ed                	bnez	s1,4390 <fourfiles+0x82>
    43a8:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    43ac:	00007a17          	auipc	s4,0x7
    43b0:	5bca0a13          	addi	s4,s4,1468 # b968 <buf>
    43b4:	00007a97          	auipc	s5,0x7
    43b8:	5b5a8a93          	addi	s5,s5,1461 # b969 <buf+0x1>
    if(total != N*SZ){
    43bc:	6d85                	lui	s11,0x1
    43be:	770d8d93          	addi	s11,s11,1904 # 1770 <pipe1+0x2a>
  for(i = 0; i < NCHILD; i++){
    43c2:	03400d13          	li	s10,52
    43c6:	aa1d                	j	44fc <fourfiles+0x1ee>
      printf("fork failed\n", s);
    43c8:	f5843583          	ld	a1,-168(s0)
    43cc:	00002517          	auipc	a0,0x2
    43d0:	5a450513          	addi	a0,a0,1444 # 6970 <malloc+0x1052>
    43d4:	00001097          	auipc	ra,0x1
    43d8:	48c080e7          	jalr	1164(ra) # 5860 <printf>
      exit(1);
    43dc:	4505                	li	a0,1
    43de:	00001097          	auipc	ra,0x1
    43e2:	10a080e7          	jalr	266(ra) # 54e8 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    43e6:	20200593          	li	a1,514
    43ea:	854e                	mv	a0,s3
    43ec:	00001097          	auipc	ra,0x1
    43f0:	13c080e7          	jalr	316(ra) # 5528 <open>
    43f4:	892a                	mv	s2,a0
      if(fd < 0){
    43f6:	04054763          	bltz	a0,4444 <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    43fa:	1f400613          	li	a2,500
    43fe:	0304859b          	addiw	a1,s1,48
    4402:	00007517          	auipc	a0,0x7
    4406:	56650513          	addi	a0,a0,1382 # b968 <buf>
    440a:	00001097          	auipc	ra,0x1
    440e:	ee2080e7          	jalr	-286(ra) # 52ec <memset>
    4412:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4414:	00007997          	auipc	s3,0x7
    4418:	55498993          	addi	s3,s3,1364 # b968 <buf>
    441c:	1f400613          	li	a2,500
    4420:	85ce                	mv	a1,s3
    4422:	854a                	mv	a0,s2
    4424:	00001097          	auipc	ra,0x1
    4428:	0e4080e7          	jalr	228(ra) # 5508 <write>
    442c:	85aa                	mv	a1,a0
    442e:	1f400793          	li	a5,500
    4432:	02f51863          	bne	a0,a5,4462 <fourfiles+0x154>
      for(i = 0; i < N; i++){
    4436:	34fd                	addiw	s1,s1,-1
    4438:	f0f5                	bnez	s1,441c <fourfiles+0x10e>
      exit(0);
    443a:	4501                	li	a0,0
    443c:	00001097          	auipc	ra,0x1
    4440:	0ac080e7          	jalr	172(ra) # 54e8 <exit>
        printf("create failed\n", s);
    4444:	f5843583          	ld	a1,-168(s0)
    4448:	00003517          	auipc	a0,0x3
    444c:	48050513          	addi	a0,a0,1152 # 78c8 <malloc+0x1faa>
    4450:	00001097          	auipc	ra,0x1
    4454:	410080e7          	jalr	1040(ra) # 5860 <printf>
        exit(1);
    4458:	4505                	li	a0,1
    445a:	00001097          	auipc	ra,0x1
    445e:	08e080e7          	jalr	142(ra) # 54e8 <exit>
          printf("write failed %d\n", n);
    4462:	00003517          	auipc	a0,0x3
    4466:	47650513          	addi	a0,a0,1142 # 78d8 <malloc+0x1fba>
    446a:	00001097          	auipc	ra,0x1
    446e:	3f6080e7          	jalr	1014(ra) # 5860 <printf>
          exit(1);
    4472:	4505                	li	a0,1
    4474:	00001097          	auipc	ra,0x1
    4478:	074080e7          	jalr	116(ra) # 54e8 <exit>
      exit(xstatus);
    447c:	855a                	mv	a0,s6
    447e:	00001097          	auipc	ra,0x1
    4482:	06a080e7          	jalr	106(ra) # 54e8 <exit>
          printf("wrong char\n", s);
    4486:	f5843583          	ld	a1,-168(s0)
    448a:	00003517          	auipc	a0,0x3
    448e:	46650513          	addi	a0,a0,1126 # 78f0 <malloc+0x1fd2>
    4492:	00001097          	auipc	ra,0x1
    4496:	3ce080e7          	jalr	974(ra) # 5860 <printf>
          exit(1);
    449a:	4505                	li	a0,1
    449c:	00001097          	auipc	ra,0x1
    44a0:	04c080e7          	jalr	76(ra) # 54e8 <exit>
      total += n;
    44a4:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    44a8:	660d                	lui	a2,0x3
    44aa:	85d2                	mv	a1,s4
    44ac:	854e                	mv	a0,s3
    44ae:	00001097          	auipc	ra,0x1
    44b2:	052080e7          	jalr	82(ra) # 5500 <read>
    44b6:	02a05363          	blez	a0,44dc <fourfiles+0x1ce>
    44ba:	00007797          	auipc	a5,0x7
    44be:	4ae78793          	addi	a5,a5,1198 # b968 <buf>
    44c2:	fff5069b          	addiw	a3,a0,-1
    44c6:	1682                	slli	a3,a3,0x20
    44c8:	9281                	srli	a3,a3,0x20
    44ca:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    44cc:	0007c703          	lbu	a4,0(a5)
    44d0:	fa971be3          	bne	a4,s1,4486 <fourfiles+0x178>
      for(j = 0; j < n; j++){
    44d4:	0785                	addi	a5,a5,1
    44d6:	fed79be3          	bne	a5,a3,44cc <fourfiles+0x1be>
    44da:	b7e9                	j	44a4 <fourfiles+0x196>
    close(fd);
    44dc:	854e                	mv	a0,s3
    44de:	00001097          	auipc	ra,0x1
    44e2:	032080e7          	jalr	50(ra) # 5510 <close>
    if(total != N*SZ){
    44e6:	03b91863          	bne	s2,s11,4516 <fourfiles+0x208>
    unlink(fname);
    44ea:	8566                	mv	a0,s9
    44ec:	00001097          	auipc	ra,0x1
    44f0:	04c080e7          	jalr	76(ra) # 5538 <unlink>
  for(i = 0; i < NCHILD; i++){
    44f4:	0c21                	addi	s8,s8,8
    44f6:	2b85                	addiw	s7,s7,1
    44f8:	03ab8d63          	beq	s7,s10,4532 <fourfiles+0x224>
    fname = names[i];
    44fc:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    4500:	4581                	li	a1,0
    4502:	8566                	mv	a0,s9
    4504:	00001097          	auipc	ra,0x1
    4508:	024080e7          	jalr	36(ra) # 5528 <open>
    450c:	89aa                	mv	s3,a0
    total = 0;
    450e:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    4510:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4514:	bf51                	j	44a8 <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    4516:	85ca                	mv	a1,s2
    4518:	00003517          	auipc	a0,0x3
    451c:	3e850513          	addi	a0,a0,1000 # 7900 <malloc+0x1fe2>
    4520:	00001097          	auipc	ra,0x1
    4524:	340080e7          	jalr	832(ra) # 5860 <printf>
      exit(1);
    4528:	4505                	li	a0,1
    452a:	00001097          	auipc	ra,0x1
    452e:	fbe080e7          	jalr	-66(ra) # 54e8 <exit>
}
    4532:	70aa                	ld	ra,168(sp)
    4534:	740a                	ld	s0,160(sp)
    4536:	64ea                	ld	s1,152(sp)
    4538:	694a                	ld	s2,144(sp)
    453a:	69aa                	ld	s3,136(sp)
    453c:	6a0a                	ld	s4,128(sp)
    453e:	7ae6                	ld	s5,120(sp)
    4540:	7b46                	ld	s6,112(sp)
    4542:	7ba6                	ld	s7,104(sp)
    4544:	7c06                	ld	s8,96(sp)
    4546:	6ce6                	ld	s9,88(sp)
    4548:	6d46                	ld	s10,80(sp)
    454a:	6da6                	ld	s11,72(sp)
    454c:	614d                	addi	sp,sp,176
    454e:	8082                	ret

0000000000004550 <concreate>:
{
    4550:	7135                	addi	sp,sp,-160
    4552:	ed06                	sd	ra,152(sp)
    4554:	e922                	sd	s0,144(sp)
    4556:	e526                	sd	s1,136(sp)
    4558:	e14a                	sd	s2,128(sp)
    455a:	fcce                	sd	s3,120(sp)
    455c:	f8d2                	sd	s4,112(sp)
    455e:	f4d6                	sd	s5,104(sp)
    4560:	f0da                	sd	s6,96(sp)
    4562:	ecde                	sd	s7,88(sp)
    4564:	1100                	addi	s0,sp,160
    4566:	89aa                	mv	s3,a0
  file[0] = 'C';
    4568:	04300793          	li	a5,67
    456c:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4570:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4574:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4576:	4b0d                	li	s6,3
    4578:	4a85                	li	s5,1
      link("C0", file);
    457a:	00003b97          	auipc	s7,0x3
    457e:	39eb8b93          	addi	s7,s7,926 # 7918 <malloc+0x1ffa>
  for(i = 0; i < N; i++){
    4582:	02800a13          	li	s4,40
    4586:	acc1                	j	4856 <concreate+0x306>
      link("C0", file);
    4588:	fa840593          	addi	a1,s0,-88
    458c:	855e                	mv	a0,s7
    458e:	00001097          	auipc	ra,0x1
    4592:	fba080e7          	jalr	-70(ra) # 5548 <link>
    if(pid == 0) {
    4596:	a45d                	j	483c <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    4598:	4795                	li	a5,5
    459a:	02f9693b          	remw	s2,s2,a5
    459e:	4785                	li	a5,1
    45a0:	02f90b63          	beq	s2,a5,45d6 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    45a4:	20200593          	li	a1,514
    45a8:	fa840513          	addi	a0,s0,-88
    45ac:	00001097          	auipc	ra,0x1
    45b0:	f7c080e7          	jalr	-132(ra) # 5528 <open>
      if(fd < 0){
    45b4:	26055b63          	bgez	a0,482a <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    45b8:	fa840593          	addi	a1,s0,-88
    45bc:	00003517          	auipc	a0,0x3
    45c0:	36450513          	addi	a0,a0,868 # 7920 <malloc+0x2002>
    45c4:	00001097          	auipc	ra,0x1
    45c8:	29c080e7          	jalr	668(ra) # 5860 <printf>
        exit(1);
    45cc:	4505                	li	a0,1
    45ce:	00001097          	auipc	ra,0x1
    45d2:	f1a080e7          	jalr	-230(ra) # 54e8 <exit>
      link("C0", file);
    45d6:	fa840593          	addi	a1,s0,-88
    45da:	00003517          	auipc	a0,0x3
    45de:	33e50513          	addi	a0,a0,830 # 7918 <malloc+0x1ffa>
    45e2:	00001097          	auipc	ra,0x1
    45e6:	f66080e7          	jalr	-154(ra) # 5548 <link>
      exit(0);
    45ea:	4501                	li	a0,0
    45ec:	00001097          	auipc	ra,0x1
    45f0:	efc080e7          	jalr	-260(ra) # 54e8 <exit>
        exit(1);
    45f4:	4505                	li	a0,1
    45f6:	00001097          	auipc	ra,0x1
    45fa:	ef2080e7          	jalr	-270(ra) # 54e8 <exit>
  memset(fa, 0, sizeof(fa));
    45fe:	02800613          	li	a2,40
    4602:	4581                	li	a1,0
    4604:	f8040513          	addi	a0,s0,-128
    4608:	00001097          	auipc	ra,0x1
    460c:	ce4080e7          	jalr	-796(ra) # 52ec <memset>
  fd = open(".", 0);
    4610:	4581                	li	a1,0
    4612:	00002517          	auipc	a0,0x2
    4616:	dce50513          	addi	a0,a0,-562 # 63e0 <malloc+0xac2>
    461a:	00001097          	auipc	ra,0x1
    461e:	f0e080e7          	jalr	-242(ra) # 5528 <open>
    4622:	892a                	mv	s2,a0
  n = 0;
    4624:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4626:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    462a:	02700b13          	li	s6,39
      fa[i] = 1;
    462e:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4630:	4641                	li	a2,16
    4632:	f7040593          	addi	a1,s0,-144
    4636:	854a                	mv	a0,s2
    4638:	00001097          	auipc	ra,0x1
    463c:	ec8080e7          	jalr	-312(ra) # 5500 <read>
    4640:	08a05163          	blez	a0,46c2 <concreate+0x172>
    if(de.inum == 0)
    4644:	f7045783          	lhu	a5,-144(s0)
    4648:	d7e5                	beqz	a5,4630 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    464a:	f7244783          	lbu	a5,-142(s0)
    464e:	ff4791e3          	bne	a5,s4,4630 <concreate+0xe0>
    4652:	f7444783          	lbu	a5,-140(s0)
    4656:	ffe9                	bnez	a5,4630 <concreate+0xe0>
      i = de.name[1] - '0';
    4658:	f7344783          	lbu	a5,-141(s0)
    465c:	fd07879b          	addiw	a5,a5,-48
    4660:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4664:	00eb6f63          	bltu	s6,a4,4682 <concreate+0x132>
      if(fa[i]){
    4668:	fb040793          	addi	a5,s0,-80
    466c:	97ba                	add	a5,a5,a4
    466e:	fd07c783          	lbu	a5,-48(a5)
    4672:	eb85                	bnez	a5,46a2 <concreate+0x152>
      fa[i] = 1;
    4674:	fb040793          	addi	a5,s0,-80
    4678:	973e                	add	a4,a4,a5
    467a:	fd770823          	sb	s7,-48(a4) # fd0 <bigdir+0x66>
      n++;
    467e:	2a85                	addiw	s5,s5,1
    4680:	bf45                	j	4630 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4682:	f7240613          	addi	a2,s0,-142
    4686:	85ce                	mv	a1,s3
    4688:	00003517          	auipc	a0,0x3
    468c:	2b850513          	addi	a0,a0,696 # 7940 <malloc+0x2022>
    4690:	00001097          	auipc	ra,0x1
    4694:	1d0080e7          	jalr	464(ra) # 5860 <printf>
        exit(1);
    4698:	4505                	li	a0,1
    469a:	00001097          	auipc	ra,0x1
    469e:	e4e080e7          	jalr	-434(ra) # 54e8 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    46a2:	f7240613          	addi	a2,s0,-142
    46a6:	85ce                	mv	a1,s3
    46a8:	00003517          	auipc	a0,0x3
    46ac:	2b850513          	addi	a0,a0,696 # 7960 <malloc+0x2042>
    46b0:	00001097          	auipc	ra,0x1
    46b4:	1b0080e7          	jalr	432(ra) # 5860 <printf>
        exit(1);
    46b8:	4505                	li	a0,1
    46ba:	00001097          	auipc	ra,0x1
    46be:	e2e080e7          	jalr	-466(ra) # 54e8 <exit>
  close(fd);
    46c2:	854a                	mv	a0,s2
    46c4:	00001097          	auipc	ra,0x1
    46c8:	e4c080e7          	jalr	-436(ra) # 5510 <close>
  if(n != N){
    46cc:	02800793          	li	a5,40
    46d0:	00fa9763          	bne	s5,a5,46de <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    46d4:	4a8d                	li	s5,3
    46d6:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    46d8:	02800a13          	li	s4,40
    46dc:	a8c9                	j	47ae <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    46de:	85ce                	mv	a1,s3
    46e0:	00003517          	auipc	a0,0x3
    46e4:	2a850513          	addi	a0,a0,680 # 7988 <malloc+0x206a>
    46e8:	00001097          	auipc	ra,0x1
    46ec:	178080e7          	jalr	376(ra) # 5860 <printf>
    exit(1);
    46f0:	4505                	li	a0,1
    46f2:	00001097          	auipc	ra,0x1
    46f6:	df6080e7          	jalr	-522(ra) # 54e8 <exit>
      printf("%s: fork failed\n", s);
    46fa:	85ce                	mv	a1,s3
    46fc:	00002517          	auipc	a0,0x2
    4700:	e8450513          	addi	a0,a0,-380 # 6580 <malloc+0xc62>
    4704:	00001097          	auipc	ra,0x1
    4708:	15c080e7          	jalr	348(ra) # 5860 <printf>
      exit(1);
    470c:	4505                	li	a0,1
    470e:	00001097          	auipc	ra,0x1
    4712:	dda080e7          	jalr	-550(ra) # 54e8 <exit>
      close(open(file, 0));
    4716:	4581                	li	a1,0
    4718:	fa840513          	addi	a0,s0,-88
    471c:	00001097          	auipc	ra,0x1
    4720:	e0c080e7          	jalr	-500(ra) # 5528 <open>
    4724:	00001097          	auipc	ra,0x1
    4728:	dec080e7          	jalr	-532(ra) # 5510 <close>
      close(open(file, 0));
    472c:	4581                	li	a1,0
    472e:	fa840513          	addi	a0,s0,-88
    4732:	00001097          	auipc	ra,0x1
    4736:	df6080e7          	jalr	-522(ra) # 5528 <open>
    473a:	00001097          	auipc	ra,0x1
    473e:	dd6080e7          	jalr	-554(ra) # 5510 <close>
      close(open(file, 0));
    4742:	4581                	li	a1,0
    4744:	fa840513          	addi	a0,s0,-88
    4748:	00001097          	auipc	ra,0x1
    474c:	de0080e7          	jalr	-544(ra) # 5528 <open>
    4750:	00001097          	auipc	ra,0x1
    4754:	dc0080e7          	jalr	-576(ra) # 5510 <close>
      close(open(file, 0));
    4758:	4581                	li	a1,0
    475a:	fa840513          	addi	a0,s0,-88
    475e:	00001097          	auipc	ra,0x1
    4762:	dca080e7          	jalr	-566(ra) # 5528 <open>
    4766:	00001097          	auipc	ra,0x1
    476a:	daa080e7          	jalr	-598(ra) # 5510 <close>
      close(open(file, 0));
    476e:	4581                	li	a1,0
    4770:	fa840513          	addi	a0,s0,-88
    4774:	00001097          	auipc	ra,0x1
    4778:	db4080e7          	jalr	-588(ra) # 5528 <open>
    477c:	00001097          	auipc	ra,0x1
    4780:	d94080e7          	jalr	-620(ra) # 5510 <close>
      close(open(file, 0));
    4784:	4581                	li	a1,0
    4786:	fa840513          	addi	a0,s0,-88
    478a:	00001097          	auipc	ra,0x1
    478e:	d9e080e7          	jalr	-610(ra) # 5528 <open>
    4792:	00001097          	auipc	ra,0x1
    4796:	d7e080e7          	jalr	-642(ra) # 5510 <close>
    if(pid == 0)
    479a:	08090363          	beqz	s2,4820 <concreate+0x2d0>
      wait(0);
    479e:	4501                	li	a0,0
    47a0:	00001097          	auipc	ra,0x1
    47a4:	d50080e7          	jalr	-688(ra) # 54f0 <wait>
  for(i = 0; i < N; i++){
    47a8:	2485                	addiw	s1,s1,1
    47aa:	0f448563          	beq	s1,s4,4894 <concreate+0x344>
    file[1] = '0' + i;
    47ae:	0304879b          	addiw	a5,s1,48
    47b2:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    47b6:	00001097          	auipc	ra,0x1
    47ba:	d2a080e7          	jalr	-726(ra) # 54e0 <fork>
    47be:	892a                	mv	s2,a0
    if(pid < 0){
    47c0:	f2054de3          	bltz	a0,46fa <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    47c4:	0354e73b          	remw	a4,s1,s5
    47c8:	00a767b3          	or	a5,a4,a0
    47cc:	2781                	sext.w	a5,a5
    47ce:	d7a1                	beqz	a5,4716 <concreate+0x1c6>
    47d0:	01671363          	bne	a4,s6,47d6 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    47d4:	f129                	bnez	a0,4716 <concreate+0x1c6>
      unlink(file);
    47d6:	fa840513          	addi	a0,s0,-88
    47da:	00001097          	auipc	ra,0x1
    47de:	d5e080e7          	jalr	-674(ra) # 5538 <unlink>
      unlink(file);
    47e2:	fa840513          	addi	a0,s0,-88
    47e6:	00001097          	auipc	ra,0x1
    47ea:	d52080e7          	jalr	-686(ra) # 5538 <unlink>
      unlink(file);
    47ee:	fa840513          	addi	a0,s0,-88
    47f2:	00001097          	auipc	ra,0x1
    47f6:	d46080e7          	jalr	-698(ra) # 5538 <unlink>
      unlink(file);
    47fa:	fa840513          	addi	a0,s0,-88
    47fe:	00001097          	auipc	ra,0x1
    4802:	d3a080e7          	jalr	-710(ra) # 5538 <unlink>
      unlink(file);
    4806:	fa840513          	addi	a0,s0,-88
    480a:	00001097          	auipc	ra,0x1
    480e:	d2e080e7          	jalr	-722(ra) # 5538 <unlink>
      unlink(file);
    4812:	fa840513          	addi	a0,s0,-88
    4816:	00001097          	auipc	ra,0x1
    481a:	d22080e7          	jalr	-734(ra) # 5538 <unlink>
    481e:	bfb5                	j	479a <concreate+0x24a>
      exit(0);
    4820:	4501                	li	a0,0
    4822:	00001097          	auipc	ra,0x1
    4826:	cc6080e7          	jalr	-826(ra) # 54e8 <exit>
      close(fd);
    482a:	00001097          	auipc	ra,0x1
    482e:	ce6080e7          	jalr	-794(ra) # 5510 <close>
    if(pid == 0) {
    4832:	bb65                	j	45ea <concreate+0x9a>
      close(fd);
    4834:	00001097          	auipc	ra,0x1
    4838:	cdc080e7          	jalr	-804(ra) # 5510 <close>
      wait(&xstatus);
    483c:	f6c40513          	addi	a0,s0,-148
    4840:	00001097          	auipc	ra,0x1
    4844:	cb0080e7          	jalr	-848(ra) # 54f0 <wait>
      if(xstatus != 0)
    4848:	f6c42483          	lw	s1,-148(s0)
    484c:	da0494e3          	bnez	s1,45f4 <concreate+0xa4>
  for(i = 0; i < N; i++){
    4850:	2905                	addiw	s2,s2,1
    4852:	db4906e3          	beq	s2,s4,45fe <concreate+0xae>
    file[1] = '0' + i;
    4856:	0309079b          	addiw	a5,s2,48
    485a:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    485e:	fa840513          	addi	a0,s0,-88
    4862:	00001097          	auipc	ra,0x1
    4866:	cd6080e7          	jalr	-810(ra) # 5538 <unlink>
    pid = fork();
    486a:	00001097          	auipc	ra,0x1
    486e:	c76080e7          	jalr	-906(ra) # 54e0 <fork>
    if(pid && (i % 3) == 1){
    4872:	d20503e3          	beqz	a0,4598 <concreate+0x48>
    4876:	036967bb          	remw	a5,s2,s6
    487a:	d15787e3          	beq	a5,s5,4588 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    487e:	20200593          	li	a1,514
    4882:	fa840513          	addi	a0,s0,-88
    4886:	00001097          	auipc	ra,0x1
    488a:	ca2080e7          	jalr	-862(ra) # 5528 <open>
      if(fd < 0){
    488e:	fa0553e3          	bgez	a0,4834 <concreate+0x2e4>
    4892:	b31d                	j	45b8 <concreate+0x68>
}
    4894:	60ea                	ld	ra,152(sp)
    4896:	644a                	ld	s0,144(sp)
    4898:	64aa                	ld	s1,136(sp)
    489a:	690a                	ld	s2,128(sp)
    489c:	79e6                	ld	s3,120(sp)
    489e:	7a46                	ld	s4,112(sp)
    48a0:	7aa6                	ld	s5,104(sp)
    48a2:	7b06                	ld	s6,96(sp)
    48a4:	6be6                	ld	s7,88(sp)
    48a6:	610d                	addi	sp,sp,160
    48a8:	8082                	ret

00000000000048aa <bigfile>:
{
    48aa:	7139                	addi	sp,sp,-64
    48ac:	fc06                	sd	ra,56(sp)
    48ae:	f822                	sd	s0,48(sp)
    48b0:	f426                	sd	s1,40(sp)
    48b2:	f04a                	sd	s2,32(sp)
    48b4:	ec4e                	sd	s3,24(sp)
    48b6:	e852                	sd	s4,16(sp)
    48b8:	e456                	sd	s5,8(sp)
    48ba:	0080                	addi	s0,sp,64
    48bc:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    48be:	00003517          	auipc	a0,0x3
    48c2:	10250513          	addi	a0,a0,258 # 79c0 <malloc+0x20a2>
    48c6:	00001097          	auipc	ra,0x1
    48ca:	c72080e7          	jalr	-910(ra) # 5538 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    48ce:	20200593          	li	a1,514
    48d2:	00003517          	auipc	a0,0x3
    48d6:	0ee50513          	addi	a0,a0,238 # 79c0 <malloc+0x20a2>
    48da:	00001097          	auipc	ra,0x1
    48de:	c4e080e7          	jalr	-946(ra) # 5528 <open>
    48e2:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    48e4:	4481                	li	s1,0
    memset(buf, i, SZ);
    48e6:	00007917          	auipc	s2,0x7
    48ea:	08290913          	addi	s2,s2,130 # b968 <buf>
  for(i = 0; i < N; i++){
    48ee:	4a51                	li	s4,20
  if(fd < 0){
    48f0:	0a054063          	bltz	a0,4990 <bigfile+0xe6>
    memset(buf, i, SZ);
    48f4:	25800613          	li	a2,600
    48f8:	85a6                	mv	a1,s1
    48fa:	854a                	mv	a0,s2
    48fc:	00001097          	auipc	ra,0x1
    4900:	9f0080e7          	jalr	-1552(ra) # 52ec <memset>
    if(write(fd, buf, SZ) != SZ){
    4904:	25800613          	li	a2,600
    4908:	85ca                	mv	a1,s2
    490a:	854e                	mv	a0,s3
    490c:	00001097          	auipc	ra,0x1
    4910:	bfc080e7          	jalr	-1028(ra) # 5508 <write>
    4914:	25800793          	li	a5,600
    4918:	08f51a63          	bne	a0,a5,49ac <bigfile+0x102>
  for(i = 0; i < N; i++){
    491c:	2485                	addiw	s1,s1,1
    491e:	fd449be3          	bne	s1,s4,48f4 <bigfile+0x4a>
  close(fd);
    4922:	854e                	mv	a0,s3
    4924:	00001097          	auipc	ra,0x1
    4928:	bec080e7          	jalr	-1044(ra) # 5510 <close>
  fd = open("bigfile.dat", 0);
    492c:	4581                	li	a1,0
    492e:	00003517          	auipc	a0,0x3
    4932:	09250513          	addi	a0,a0,146 # 79c0 <malloc+0x20a2>
    4936:	00001097          	auipc	ra,0x1
    493a:	bf2080e7          	jalr	-1038(ra) # 5528 <open>
    493e:	8a2a                	mv	s4,a0
  total = 0;
    4940:	4981                	li	s3,0
  for(i = 0; ; i++){
    4942:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4944:	00007917          	auipc	s2,0x7
    4948:	02490913          	addi	s2,s2,36 # b968 <buf>
  if(fd < 0){
    494c:	06054e63          	bltz	a0,49c8 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4950:	12c00613          	li	a2,300
    4954:	85ca                	mv	a1,s2
    4956:	8552                	mv	a0,s4
    4958:	00001097          	auipc	ra,0x1
    495c:	ba8080e7          	jalr	-1112(ra) # 5500 <read>
    if(cc < 0){
    4960:	08054263          	bltz	a0,49e4 <bigfile+0x13a>
    if(cc == 0)
    4964:	c971                	beqz	a0,4a38 <bigfile+0x18e>
    if(cc != SZ/2){
    4966:	12c00793          	li	a5,300
    496a:	08f51b63          	bne	a0,a5,4a00 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    496e:	01f4d79b          	srliw	a5,s1,0x1f
    4972:	9fa5                	addw	a5,a5,s1
    4974:	4017d79b          	sraiw	a5,a5,0x1
    4978:	00094703          	lbu	a4,0(s2)
    497c:	0af71063          	bne	a4,a5,4a1c <bigfile+0x172>
    4980:	12b94703          	lbu	a4,299(s2)
    4984:	08f71c63          	bne	a4,a5,4a1c <bigfile+0x172>
    total += cc;
    4988:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    498c:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    498e:	b7c9                	j	4950 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4990:	85d6                	mv	a1,s5
    4992:	00003517          	auipc	a0,0x3
    4996:	03e50513          	addi	a0,a0,62 # 79d0 <malloc+0x20b2>
    499a:	00001097          	auipc	ra,0x1
    499e:	ec6080e7          	jalr	-314(ra) # 5860 <printf>
    exit(1);
    49a2:	4505                	li	a0,1
    49a4:	00001097          	auipc	ra,0x1
    49a8:	b44080e7          	jalr	-1212(ra) # 54e8 <exit>
      printf("%s: write bigfile failed\n", s);
    49ac:	85d6                	mv	a1,s5
    49ae:	00003517          	auipc	a0,0x3
    49b2:	04250513          	addi	a0,a0,66 # 79f0 <malloc+0x20d2>
    49b6:	00001097          	auipc	ra,0x1
    49ba:	eaa080e7          	jalr	-342(ra) # 5860 <printf>
      exit(1);
    49be:	4505                	li	a0,1
    49c0:	00001097          	auipc	ra,0x1
    49c4:	b28080e7          	jalr	-1240(ra) # 54e8 <exit>
    printf("%s: cannot open bigfile\n", s);
    49c8:	85d6                	mv	a1,s5
    49ca:	00003517          	auipc	a0,0x3
    49ce:	04650513          	addi	a0,a0,70 # 7a10 <malloc+0x20f2>
    49d2:	00001097          	auipc	ra,0x1
    49d6:	e8e080e7          	jalr	-370(ra) # 5860 <printf>
    exit(1);
    49da:	4505                	li	a0,1
    49dc:	00001097          	auipc	ra,0x1
    49e0:	b0c080e7          	jalr	-1268(ra) # 54e8 <exit>
      printf("%s: read bigfile failed\n", s);
    49e4:	85d6                	mv	a1,s5
    49e6:	00003517          	auipc	a0,0x3
    49ea:	04a50513          	addi	a0,a0,74 # 7a30 <malloc+0x2112>
    49ee:	00001097          	auipc	ra,0x1
    49f2:	e72080e7          	jalr	-398(ra) # 5860 <printf>
      exit(1);
    49f6:	4505                	li	a0,1
    49f8:	00001097          	auipc	ra,0x1
    49fc:	af0080e7          	jalr	-1296(ra) # 54e8 <exit>
      printf("%s: short read bigfile\n", s);
    4a00:	85d6                	mv	a1,s5
    4a02:	00003517          	auipc	a0,0x3
    4a06:	04e50513          	addi	a0,a0,78 # 7a50 <malloc+0x2132>
    4a0a:	00001097          	auipc	ra,0x1
    4a0e:	e56080e7          	jalr	-426(ra) # 5860 <printf>
      exit(1);
    4a12:	4505                	li	a0,1
    4a14:	00001097          	auipc	ra,0x1
    4a18:	ad4080e7          	jalr	-1324(ra) # 54e8 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4a1c:	85d6                	mv	a1,s5
    4a1e:	00003517          	auipc	a0,0x3
    4a22:	04a50513          	addi	a0,a0,74 # 7a68 <malloc+0x214a>
    4a26:	00001097          	auipc	ra,0x1
    4a2a:	e3a080e7          	jalr	-454(ra) # 5860 <printf>
      exit(1);
    4a2e:	4505                	li	a0,1
    4a30:	00001097          	auipc	ra,0x1
    4a34:	ab8080e7          	jalr	-1352(ra) # 54e8 <exit>
  close(fd);
    4a38:	8552                	mv	a0,s4
    4a3a:	00001097          	auipc	ra,0x1
    4a3e:	ad6080e7          	jalr	-1322(ra) # 5510 <close>
  if(total != N*SZ){
    4a42:	678d                	lui	a5,0x3
    4a44:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0xac>
    4a48:	02f99363          	bne	s3,a5,4a6e <bigfile+0x1c4>
  unlink("bigfile.dat");
    4a4c:	00003517          	auipc	a0,0x3
    4a50:	f7450513          	addi	a0,a0,-140 # 79c0 <malloc+0x20a2>
    4a54:	00001097          	auipc	ra,0x1
    4a58:	ae4080e7          	jalr	-1308(ra) # 5538 <unlink>
}
    4a5c:	70e2                	ld	ra,56(sp)
    4a5e:	7442                	ld	s0,48(sp)
    4a60:	74a2                	ld	s1,40(sp)
    4a62:	7902                	ld	s2,32(sp)
    4a64:	69e2                	ld	s3,24(sp)
    4a66:	6a42                	ld	s4,16(sp)
    4a68:	6aa2                	ld	s5,8(sp)
    4a6a:	6121                	addi	sp,sp,64
    4a6c:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4a6e:	85d6                	mv	a1,s5
    4a70:	00003517          	auipc	a0,0x3
    4a74:	01850513          	addi	a0,a0,24 # 7a88 <malloc+0x216a>
    4a78:	00001097          	auipc	ra,0x1
    4a7c:	de8080e7          	jalr	-536(ra) # 5860 <printf>
    exit(1);
    4a80:	4505                	li	a0,1
    4a82:	00001097          	auipc	ra,0x1
    4a86:	a66080e7          	jalr	-1434(ra) # 54e8 <exit>

0000000000004a8a <dirtest>:
{
    4a8a:	1101                	addi	sp,sp,-32
    4a8c:	ec06                	sd	ra,24(sp)
    4a8e:	e822                	sd	s0,16(sp)
    4a90:	e426                	sd	s1,8(sp)
    4a92:	1000                	addi	s0,sp,32
    4a94:	84aa                	mv	s1,a0
  printf("mkdir test\n");
    4a96:	00003517          	auipc	a0,0x3
    4a9a:	01250513          	addi	a0,a0,18 # 7aa8 <malloc+0x218a>
    4a9e:	00001097          	auipc	ra,0x1
    4aa2:	dc2080e7          	jalr	-574(ra) # 5860 <printf>
  if(mkdir("dir0") < 0){
    4aa6:	00003517          	auipc	a0,0x3
    4aaa:	01250513          	addi	a0,a0,18 # 7ab8 <malloc+0x219a>
    4aae:	00001097          	auipc	ra,0x1
    4ab2:	aa2080e7          	jalr	-1374(ra) # 5550 <mkdir>
    4ab6:	04054d63          	bltz	a0,4b10 <dirtest+0x86>
  if(chdir("dir0") < 0){
    4aba:	00003517          	auipc	a0,0x3
    4abe:	ffe50513          	addi	a0,a0,-2 # 7ab8 <malloc+0x219a>
    4ac2:	00001097          	auipc	ra,0x1
    4ac6:	a96080e7          	jalr	-1386(ra) # 5558 <chdir>
    4aca:	06054163          	bltz	a0,4b2c <dirtest+0xa2>
  if(chdir("..") < 0){
    4ace:	00003517          	auipc	a0,0x3
    4ad2:	a4250513          	addi	a0,a0,-1470 # 7510 <malloc+0x1bf2>
    4ad6:	00001097          	auipc	ra,0x1
    4ada:	a82080e7          	jalr	-1406(ra) # 5558 <chdir>
    4ade:	06054563          	bltz	a0,4b48 <dirtest+0xbe>
  if(unlink("dir0") < 0){
    4ae2:	00003517          	auipc	a0,0x3
    4ae6:	fd650513          	addi	a0,a0,-42 # 7ab8 <malloc+0x219a>
    4aea:	00001097          	auipc	ra,0x1
    4aee:	a4e080e7          	jalr	-1458(ra) # 5538 <unlink>
    4af2:	06054963          	bltz	a0,4b64 <dirtest+0xda>
  printf("%s: mkdir test ok\n");
    4af6:	00003517          	auipc	a0,0x3
    4afa:	01250513          	addi	a0,a0,18 # 7b08 <malloc+0x21ea>
    4afe:	00001097          	auipc	ra,0x1
    4b02:	d62080e7          	jalr	-670(ra) # 5860 <printf>
}
    4b06:	60e2                	ld	ra,24(sp)
    4b08:	6442                	ld	s0,16(sp)
    4b0a:	64a2                	ld	s1,8(sp)
    4b0c:	6105                	addi	sp,sp,32
    4b0e:	8082                	ret
    printf("%s: mkdir failed\n", s);
    4b10:	85a6                	mv	a1,s1
    4b12:	00002517          	auipc	a0,0x2
    4b16:	39e50513          	addi	a0,a0,926 # 6eb0 <malloc+0x1592>
    4b1a:	00001097          	auipc	ra,0x1
    4b1e:	d46080e7          	jalr	-698(ra) # 5860 <printf>
    exit(1);
    4b22:	4505                	li	a0,1
    4b24:	00001097          	auipc	ra,0x1
    4b28:	9c4080e7          	jalr	-1596(ra) # 54e8 <exit>
    printf("%s: chdir dir0 failed\n", s);
    4b2c:	85a6                	mv	a1,s1
    4b2e:	00003517          	auipc	a0,0x3
    4b32:	f9250513          	addi	a0,a0,-110 # 7ac0 <malloc+0x21a2>
    4b36:	00001097          	auipc	ra,0x1
    4b3a:	d2a080e7          	jalr	-726(ra) # 5860 <printf>
    exit(1);
    4b3e:	4505                	li	a0,1
    4b40:	00001097          	auipc	ra,0x1
    4b44:	9a8080e7          	jalr	-1624(ra) # 54e8 <exit>
    printf("%s: chdir .. failed\n", s);
    4b48:	85a6                	mv	a1,s1
    4b4a:	00003517          	auipc	a0,0x3
    4b4e:	f8e50513          	addi	a0,a0,-114 # 7ad8 <malloc+0x21ba>
    4b52:	00001097          	auipc	ra,0x1
    4b56:	d0e080e7          	jalr	-754(ra) # 5860 <printf>
    exit(1);
    4b5a:	4505                	li	a0,1
    4b5c:	00001097          	auipc	ra,0x1
    4b60:	98c080e7          	jalr	-1652(ra) # 54e8 <exit>
    printf("%s: unlink dir0 failed\n", s);
    4b64:	85a6                	mv	a1,s1
    4b66:	00003517          	auipc	a0,0x3
    4b6a:	f8a50513          	addi	a0,a0,-118 # 7af0 <malloc+0x21d2>
    4b6e:	00001097          	auipc	ra,0x1
    4b72:	cf2080e7          	jalr	-782(ra) # 5860 <printf>
    exit(1);
    4b76:	4505                	li	a0,1
    4b78:	00001097          	auipc	ra,0x1
    4b7c:	970080e7          	jalr	-1680(ra) # 54e8 <exit>

0000000000004b80 <fsfull>:
{
    4b80:	7171                	addi	sp,sp,-176
    4b82:	f506                	sd	ra,168(sp)
    4b84:	f122                	sd	s0,160(sp)
    4b86:	ed26                	sd	s1,152(sp)
    4b88:	e94a                	sd	s2,144(sp)
    4b8a:	e54e                	sd	s3,136(sp)
    4b8c:	e152                	sd	s4,128(sp)
    4b8e:	fcd6                	sd	s5,120(sp)
    4b90:	f8da                	sd	s6,112(sp)
    4b92:	f4de                	sd	s7,104(sp)
    4b94:	f0e2                	sd	s8,96(sp)
    4b96:	ece6                	sd	s9,88(sp)
    4b98:	e8ea                	sd	s10,80(sp)
    4b9a:	e4ee                	sd	s11,72(sp)
    4b9c:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4b9e:	00003517          	auipc	a0,0x3
    4ba2:	f8250513          	addi	a0,a0,-126 # 7b20 <malloc+0x2202>
    4ba6:	00001097          	auipc	ra,0x1
    4baa:	cba080e7          	jalr	-838(ra) # 5860 <printf>
  for(nfiles = 0; ; nfiles++){
    4bae:	4481                	li	s1,0
    name[0] = 'f';
    4bb0:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4bb4:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4bb8:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4bbc:	4b29                	li	s6,10
    printf("%s: writing %s\n", name);
    4bbe:	00003c97          	auipc	s9,0x3
    4bc2:	f72c8c93          	addi	s9,s9,-142 # 7b30 <malloc+0x2212>
    int total = 0;
    4bc6:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4bc8:	00007a17          	auipc	s4,0x7
    4bcc:	da0a0a13          	addi	s4,s4,-608 # b968 <buf>
    name[0] = 'f';
    4bd0:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4bd4:	0384c7bb          	divw	a5,s1,s8
    4bd8:	0307879b          	addiw	a5,a5,48
    4bdc:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4be0:	0384e7bb          	remw	a5,s1,s8
    4be4:	0377c7bb          	divw	a5,a5,s7
    4be8:	0307879b          	addiw	a5,a5,48
    4bec:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4bf0:	0374e7bb          	remw	a5,s1,s7
    4bf4:	0367c7bb          	divw	a5,a5,s6
    4bf8:	0307879b          	addiw	a5,a5,48
    4bfc:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c00:	0364e7bb          	remw	a5,s1,s6
    4c04:	0307879b          	addiw	a5,a5,48
    4c08:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c0c:	f4040aa3          	sb	zero,-171(s0)
    printf("%s: writing %s\n", name);
    4c10:	f5040593          	addi	a1,s0,-176
    4c14:	8566                	mv	a0,s9
    4c16:	00001097          	auipc	ra,0x1
    4c1a:	c4a080e7          	jalr	-950(ra) # 5860 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4c1e:	20200593          	li	a1,514
    4c22:	f5040513          	addi	a0,s0,-176
    4c26:	00001097          	auipc	ra,0x1
    4c2a:	902080e7          	jalr	-1790(ra) # 5528 <open>
    4c2e:	892a                	mv	s2,a0
    if(fd < 0){
    4c30:	0a055663          	bgez	a0,4cdc <fsfull+0x15c>
      printf("%s: open %s failed\n", name);
    4c34:	f5040593          	addi	a1,s0,-176
    4c38:	00003517          	auipc	a0,0x3
    4c3c:	f0850513          	addi	a0,a0,-248 # 7b40 <malloc+0x2222>
    4c40:	00001097          	auipc	ra,0x1
    4c44:	c20080e7          	jalr	-992(ra) # 5860 <printf>
  while(nfiles >= 0){
    4c48:	0604c363          	bltz	s1,4cae <fsfull+0x12e>
    name[0] = 'f';
    4c4c:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4c50:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4c54:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4c58:	4929                	li	s2,10
  while(nfiles >= 0){
    4c5a:	5afd                	li	s5,-1
    name[0] = 'f';
    4c5c:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4c60:	0344c7bb          	divw	a5,s1,s4
    4c64:	0307879b          	addiw	a5,a5,48
    4c68:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4c6c:	0344e7bb          	remw	a5,s1,s4
    4c70:	0337c7bb          	divw	a5,a5,s3
    4c74:	0307879b          	addiw	a5,a5,48
    4c78:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4c7c:	0334e7bb          	remw	a5,s1,s3
    4c80:	0327c7bb          	divw	a5,a5,s2
    4c84:	0307879b          	addiw	a5,a5,48
    4c88:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c8c:	0324e7bb          	remw	a5,s1,s2
    4c90:	0307879b          	addiw	a5,a5,48
    4c94:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c98:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4c9c:	f5040513          	addi	a0,s0,-176
    4ca0:	00001097          	auipc	ra,0x1
    4ca4:	898080e7          	jalr	-1896(ra) # 5538 <unlink>
    nfiles--;
    4ca8:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4caa:	fb5499e3          	bne	s1,s5,4c5c <fsfull+0xdc>
  printf("fsfull test finished\n");
    4cae:	00003517          	auipc	a0,0x3
    4cb2:	ec250513          	addi	a0,a0,-318 # 7b70 <malloc+0x2252>
    4cb6:	00001097          	auipc	ra,0x1
    4cba:	baa080e7          	jalr	-1110(ra) # 5860 <printf>
}
    4cbe:	70aa                	ld	ra,168(sp)
    4cc0:	740a                	ld	s0,160(sp)
    4cc2:	64ea                	ld	s1,152(sp)
    4cc4:	694a                	ld	s2,144(sp)
    4cc6:	69aa                	ld	s3,136(sp)
    4cc8:	6a0a                	ld	s4,128(sp)
    4cca:	7ae6                	ld	s5,120(sp)
    4ccc:	7b46                	ld	s6,112(sp)
    4cce:	7ba6                	ld	s7,104(sp)
    4cd0:	7c06                	ld	s8,96(sp)
    4cd2:	6ce6                	ld	s9,88(sp)
    4cd4:	6d46                	ld	s10,80(sp)
    4cd6:	6da6                	ld	s11,72(sp)
    4cd8:	614d                	addi	sp,sp,176
    4cda:	8082                	ret
    int total = 0;
    4cdc:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4cde:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4ce2:	40000613          	li	a2,1024
    4ce6:	85d2                	mv	a1,s4
    4ce8:	854a                	mv	a0,s2
    4cea:	00001097          	auipc	ra,0x1
    4cee:	81e080e7          	jalr	-2018(ra) # 5508 <write>
      if(cc < BSIZE)
    4cf2:	00aad563          	bge	s5,a0,4cfc <fsfull+0x17c>
      total += cc;
    4cf6:	00a989bb          	addw	s3,s3,a0
    while(1){
    4cfa:	b7e5                	j	4ce2 <fsfull+0x162>
    printf("%s: wrote %d bytes\n", total);
    4cfc:	85ce                	mv	a1,s3
    4cfe:	00003517          	auipc	a0,0x3
    4d02:	e5a50513          	addi	a0,a0,-422 # 7b58 <malloc+0x223a>
    4d06:	00001097          	auipc	ra,0x1
    4d0a:	b5a080e7          	jalr	-1190(ra) # 5860 <printf>
    close(fd);
    4d0e:	854a                	mv	a0,s2
    4d10:	00001097          	auipc	ra,0x1
    4d14:	800080e7          	jalr	-2048(ra) # 5510 <close>
    if(total == 0)
    4d18:	f20988e3          	beqz	s3,4c48 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4d1c:	2485                	addiw	s1,s1,1
    4d1e:	bd4d                	j	4bd0 <fsfull+0x50>

0000000000004d20 <rand>:
{
    4d20:	1141                	addi	sp,sp,-16
    4d22:	e422                	sd	s0,8(sp)
    4d24:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4d26:	00003717          	auipc	a4,0x3
    4d2a:	41270713          	addi	a4,a4,1042 # 8138 <randstate>
    4d2e:	6308                	ld	a0,0(a4)
    4d30:	001967b7          	lui	a5,0x196
    4d34:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187c95>
    4d38:	02f50533          	mul	a0,a0,a5
    4d3c:	3c6ef7b7          	lui	a5,0x3c6ef
    4d40:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e09e7>
    4d44:	953e                	add	a0,a0,a5
    4d46:	e308                	sd	a0,0(a4)
}
    4d48:	2501                	sext.w	a0,a0
    4d4a:	6422                	ld	s0,8(sp)
    4d4c:	0141                	addi	sp,sp,16
    4d4e:	8082                	ret

0000000000004d50 <badwrite>:
{
    4d50:	7179                	addi	sp,sp,-48
    4d52:	f406                	sd	ra,40(sp)
    4d54:	f022                	sd	s0,32(sp)
    4d56:	ec26                	sd	s1,24(sp)
    4d58:	e84a                	sd	s2,16(sp)
    4d5a:	e44e                	sd	s3,8(sp)
    4d5c:	e052                	sd	s4,0(sp)
    4d5e:	1800                	addi	s0,sp,48
  unlink("junk");
    4d60:	00003517          	auipc	a0,0x3
    4d64:	e2850513          	addi	a0,a0,-472 # 7b88 <malloc+0x226a>
    4d68:	00000097          	auipc	ra,0x0
    4d6c:	7d0080e7          	jalr	2000(ra) # 5538 <unlink>
    4d70:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4d74:	00003997          	auipc	s3,0x3
    4d78:	e1498993          	addi	s3,s3,-492 # 7b88 <malloc+0x226a>
    write(fd, (char*)0xffffffffffL, 1);
    4d7c:	5a7d                	li	s4,-1
    4d7e:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4d82:	20100593          	li	a1,513
    4d86:	854e                	mv	a0,s3
    4d88:	00000097          	auipc	ra,0x0
    4d8c:	7a0080e7          	jalr	1952(ra) # 5528 <open>
    4d90:	84aa                	mv	s1,a0
    if(fd < 0){
    4d92:	06054b63          	bltz	a0,4e08 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4d96:	4605                	li	a2,1
    4d98:	85d2                	mv	a1,s4
    4d9a:	00000097          	auipc	ra,0x0
    4d9e:	76e080e7          	jalr	1902(ra) # 5508 <write>
    close(fd);
    4da2:	8526                	mv	a0,s1
    4da4:	00000097          	auipc	ra,0x0
    4da8:	76c080e7          	jalr	1900(ra) # 5510 <close>
    unlink("junk");
    4dac:	854e                	mv	a0,s3
    4dae:	00000097          	auipc	ra,0x0
    4db2:	78a080e7          	jalr	1930(ra) # 5538 <unlink>
  for(int i = 0; i < assumed_free; i++){
    4db6:	397d                	addiw	s2,s2,-1
    4db8:	fc0915e3          	bnez	s2,4d82 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4dbc:	20100593          	li	a1,513
    4dc0:	00003517          	auipc	a0,0x3
    4dc4:	dc850513          	addi	a0,a0,-568 # 7b88 <malloc+0x226a>
    4dc8:	00000097          	auipc	ra,0x0
    4dcc:	760080e7          	jalr	1888(ra) # 5528 <open>
    4dd0:	84aa                	mv	s1,a0
  if(fd < 0){
    4dd2:	04054863          	bltz	a0,4e22 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4dd6:	4605                	li	a2,1
    4dd8:	00001597          	auipc	a1,0x1
    4ddc:	fe058593          	addi	a1,a1,-32 # 5db8 <malloc+0x49a>
    4de0:	00000097          	auipc	ra,0x0
    4de4:	728080e7          	jalr	1832(ra) # 5508 <write>
    4de8:	4785                	li	a5,1
    4dea:	04f50963          	beq	a0,a5,4e3c <badwrite+0xec>
    printf("write failed\n");
    4dee:	00003517          	auipc	a0,0x3
    4df2:	dba50513          	addi	a0,a0,-582 # 7ba8 <malloc+0x228a>
    4df6:	00001097          	auipc	ra,0x1
    4dfa:	a6a080e7          	jalr	-1430(ra) # 5860 <printf>
    exit(1);
    4dfe:	4505                	li	a0,1
    4e00:	00000097          	auipc	ra,0x0
    4e04:	6e8080e7          	jalr	1768(ra) # 54e8 <exit>
      printf("open junk failed\n");
    4e08:	00003517          	auipc	a0,0x3
    4e0c:	d8850513          	addi	a0,a0,-632 # 7b90 <malloc+0x2272>
    4e10:	00001097          	auipc	ra,0x1
    4e14:	a50080e7          	jalr	-1456(ra) # 5860 <printf>
      exit(1);
    4e18:	4505                	li	a0,1
    4e1a:	00000097          	auipc	ra,0x0
    4e1e:	6ce080e7          	jalr	1742(ra) # 54e8 <exit>
    printf("open junk failed\n");
    4e22:	00003517          	auipc	a0,0x3
    4e26:	d6e50513          	addi	a0,a0,-658 # 7b90 <malloc+0x2272>
    4e2a:	00001097          	auipc	ra,0x1
    4e2e:	a36080e7          	jalr	-1482(ra) # 5860 <printf>
    exit(1);
    4e32:	4505                	li	a0,1
    4e34:	00000097          	auipc	ra,0x0
    4e38:	6b4080e7          	jalr	1716(ra) # 54e8 <exit>
  close(fd);
    4e3c:	8526                	mv	a0,s1
    4e3e:	00000097          	auipc	ra,0x0
    4e42:	6d2080e7          	jalr	1746(ra) # 5510 <close>
  unlink("junk");
    4e46:	00003517          	auipc	a0,0x3
    4e4a:	d4250513          	addi	a0,a0,-702 # 7b88 <malloc+0x226a>
    4e4e:	00000097          	auipc	ra,0x0
    4e52:	6ea080e7          	jalr	1770(ra) # 5538 <unlink>
  exit(0);
    4e56:	4501                	li	a0,0
    4e58:	00000097          	auipc	ra,0x0
    4e5c:	690080e7          	jalr	1680(ra) # 54e8 <exit>

0000000000004e60 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4e60:	7139                	addi	sp,sp,-64
    4e62:	fc06                	sd	ra,56(sp)
    4e64:	f822                	sd	s0,48(sp)
    4e66:	f426                	sd	s1,40(sp)
    4e68:	f04a                	sd	s2,32(sp)
    4e6a:	ec4e                	sd	s3,24(sp)
    4e6c:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4e6e:	fc840513          	addi	a0,s0,-56
    4e72:	00000097          	auipc	ra,0x0
    4e76:	686080e7          	jalr	1670(ra) # 54f8 <pipe>
    4e7a:	06054763          	bltz	a0,4ee8 <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4e7e:	00000097          	auipc	ra,0x0
    4e82:	662080e7          	jalr	1634(ra) # 54e0 <fork>

  if(pid < 0){
    4e86:	06054e63          	bltz	a0,4f02 <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4e8a:	ed51                	bnez	a0,4f26 <countfree+0xc6>
    close(fds[0]);
    4e8c:	fc842503          	lw	a0,-56(s0)
    4e90:	00000097          	auipc	ra,0x0
    4e94:	680080e7          	jalr	1664(ra) # 5510 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4e98:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4e9a:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4e9c:	00001997          	auipc	s3,0x1
    4ea0:	f1c98993          	addi	s3,s3,-228 # 5db8 <malloc+0x49a>
      uint64 a = (uint64) sbrk(4096);
    4ea4:	6505                	lui	a0,0x1
    4ea6:	00000097          	auipc	ra,0x0
    4eaa:	6ca080e7          	jalr	1738(ra) # 5570 <sbrk>
      if(a == 0xffffffffffffffff){
    4eae:	07250763          	beq	a0,s2,4f1c <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    4eb2:	6785                	lui	a5,0x1
    4eb4:	953e                	add	a0,a0,a5
    4eb6:	fe950fa3          	sb	s1,-1(a0) # fff <bigdir+0x95>
      if(write(fds[1], "x", 1) != 1){
    4eba:	8626                	mv	a2,s1
    4ebc:	85ce                	mv	a1,s3
    4ebe:	fcc42503          	lw	a0,-52(s0)
    4ec2:	00000097          	auipc	ra,0x0
    4ec6:	646080e7          	jalr	1606(ra) # 5508 <write>
    4eca:	fc950de3          	beq	a0,s1,4ea4 <countfree+0x44>
        printf("write() failed in countfree()\n");
    4ece:	00003517          	auipc	a0,0x3
    4ed2:	d2a50513          	addi	a0,a0,-726 # 7bf8 <malloc+0x22da>
    4ed6:	00001097          	auipc	ra,0x1
    4eda:	98a080e7          	jalr	-1654(ra) # 5860 <printf>
        exit(1);
    4ede:	4505                	li	a0,1
    4ee0:	00000097          	auipc	ra,0x0
    4ee4:	608080e7          	jalr	1544(ra) # 54e8 <exit>
    printf("pipe() failed in countfree()\n");
    4ee8:	00003517          	auipc	a0,0x3
    4eec:	cd050513          	addi	a0,a0,-816 # 7bb8 <malloc+0x229a>
    4ef0:	00001097          	auipc	ra,0x1
    4ef4:	970080e7          	jalr	-1680(ra) # 5860 <printf>
    exit(1);
    4ef8:	4505                	li	a0,1
    4efa:	00000097          	auipc	ra,0x0
    4efe:	5ee080e7          	jalr	1518(ra) # 54e8 <exit>
    printf("fork failed in countfree()\n");
    4f02:	00003517          	auipc	a0,0x3
    4f06:	cd650513          	addi	a0,a0,-810 # 7bd8 <malloc+0x22ba>
    4f0a:	00001097          	auipc	ra,0x1
    4f0e:	956080e7          	jalr	-1706(ra) # 5860 <printf>
    exit(1);
    4f12:	4505                	li	a0,1
    4f14:	00000097          	auipc	ra,0x0
    4f18:	5d4080e7          	jalr	1492(ra) # 54e8 <exit>
      }
    }

    exit(0);
    4f1c:	4501                	li	a0,0
    4f1e:	00000097          	auipc	ra,0x0
    4f22:	5ca080e7          	jalr	1482(ra) # 54e8 <exit>
  }

  close(fds[1]);
    4f26:	fcc42503          	lw	a0,-52(s0)
    4f2a:	00000097          	auipc	ra,0x0
    4f2e:	5e6080e7          	jalr	1510(ra) # 5510 <close>

  int n = 0;
    4f32:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    4f34:	4605                	li	a2,1
    4f36:	fc740593          	addi	a1,s0,-57
    4f3a:	fc842503          	lw	a0,-56(s0)
    4f3e:	00000097          	auipc	ra,0x0
    4f42:	5c2080e7          	jalr	1474(ra) # 5500 <read>
    if(cc < 0){
    4f46:	00054563          	bltz	a0,4f50 <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    4f4a:	c105                	beqz	a0,4f6a <countfree+0x10a>
      break;
    n += 1;
    4f4c:	2485                	addiw	s1,s1,1
  while(1){
    4f4e:	b7dd                	j	4f34 <countfree+0xd4>
      printf("read() failed in countfree()\n");
    4f50:	00003517          	auipc	a0,0x3
    4f54:	cc850513          	addi	a0,a0,-824 # 7c18 <malloc+0x22fa>
    4f58:	00001097          	auipc	ra,0x1
    4f5c:	908080e7          	jalr	-1784(ra) # 5860 <printf>
      exit(1);
    4f60:	4505                	li	a0,1
    4f62:	00000097          	auipc	ra,0x0
    4f66:	586080e7          	jalr	1414(ra) # 54e8 <exit>
  }

  close(fds[0]);
    4f6a:	fc842503          	lw	a0,-56(s0)
    4f6e:	00000097          	auipc	ra,0x0
    4f72:	5a2080e7          	jalr	1442(ra) # 5510 <close>
  wait((int*)0);
    4f76:	4501                	li	a0,0
    4f78:	00000097          	auipc	ra,0x0
    4f7c:	578080e7          	jalr	1400(ra) # 54f0 <wait>
  
  return n;
}
    4f80:	8526                	mv	a0,s1
    4f82:	70e2                	ld	ra,56(sp)
    4f84:	7442                	ld	s0,48(sp)
    4f86:	74a2                	ld	s1,40(sp)
    4f88:	7902                	ld	s2,32(sp)
    4f8a:	69e2                	ld	s3,24(sp)
    4f8c:	6121                	addi	sp,sp,64
    4f8e:	8082                	ret

0000000000004f90 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    4f90:	7179                	addi	sp,sp,-48
    4f92:	f406                	sd	ra,40(sp)
    4f94:	f022                	sd	s0,32(sp)
    4f96:	ec26                	sd	s1,24(sp)
    4f98:	e84a                	sd	s2,16(sp)
    4f9a:	1800                	addi	s0,sp,48
    4f9c:	84aa                	mv	s1,a0
    4f9e:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    4fa0:	00003517          	auipc	a0,0x3
    4fa4:	c9850513          	addi	a0,a0,-872 # 7c38 <malloc+0x231a>
    4fa8:	00001097          	auipc	ra,0x1
    4fac:	8b8080e7          	jalr	-1864(ra) # 5860 <printf>
  if((pid = fork()) < 0) {
    4fb0:	00000097          	auipc	ra,0x0
    4fb4:	530080e7          	jalr	1328(ra) # 54e0 <fork>
    4fb8:	02054e63          	bltz	a0,4ff4 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    4fbc:	c929                	beqz	a0,500e <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    4fbe:	fdc40513          	addi	a0,s0,-36
    4fc2:	00000097          	auipc	ra,0x0
    4fc6:	52e080e7          	jalr	1326(ra) # 54f0 <wait>
    if(xstatus != 0) 
    4fca:	fdc42783          	lw	a5,-36(s0)
    4fce:	c7b9                	beqz	a5,501c <run+0x8c>
      printf("FAILED\n");
    4fd0:	00003517          	auipc	a0,0x3
    4fd4:	c9050513          	addi	a0,a0,-880 # 7c60 <malloc+0x2342>
    4fd8:	00001097          	auipc	ra,0x1
    4fdc:	888080e7          	jalr	-1912(ra) # 5860 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    4fe0:	fdc42503          	lw	a0,-36(s0)
  }
}
    4fe4:	00153513          	seqz	a0,a0
    4fe8:	70a2                	ld	ra,40(sp)
    4fea:	7402                	ld	s0,32(sp)
    4fec:	64e2                	ld	s1,24(sp)
    4fee:	6942                	ld	s2,16(sp)
    4ff0:	6145                	addi	sp,sp,48
    4ff2:	8082                	ret
    printf("runtest: fork error\n");
    4ff4:	00003517          	auipc	a0,0x3
    4ff8:	c5450513          	addi	a0,a0,-940 # 7c48 <malloc+0x232a>
    4ffc:	00001097          	auipc	ra,0x1
    5000:	864080e7          	jalr	-1948(ra) # 5860 <printf>
    exit(1);
    5004:	4505                	li	a0,1
    5006:	00000097          	auipc	ra,0x0
    500a:	4e2080e7          	jalr	1250(ra) # 54e8 <exit>
    f(s);
    500e:	854a                	mv	a0,s2
    5010:	9482                	jalr	s1
    exit(0);
    5012:	4501                	li	a0,0
    5014:	00000097          	auipc	ra,0x0
    5018:	4d4080e7          	jalr	1236(ra) # 54e8 <exit>
      printf("OK\n");
    501c:	00003517          	auipc	a0,0x3
    5020:	c4c50513          	addi	a0,a0,-948 # 7c68 <malloc+0x234a>
    5024:	00001097          	auipc	ra,0x1
    5028:	83c080e7          	jalr	-1988(ra) # 5860 <printf>
    502c:	bf55                	j	4fe0 <run+0x50>

000000000000502e <main>:

int
main(int argc, char *argv[])
{
    502e:	c3010113          	addi	sp,sp,-976
    5032:	3c113423          	sd	ra,968(sp)
    5036:	3c813023          	sd	s0,960(sp)
    503a:	3a913c23          	sd	s1,952(sp)
    503e:	3b213823          	sd	s2,944(sp)
    5042:	3b313423          	sd	s3,936(sp)
    5046:	3b413023          	sd	s4,928(sp)
    504a:	39513c23          	sd	s5,920(sp)
    504e:	39613823          	sd	s6,912(sp)
    5052:	0f80                	addi	s0,sp,976
    5054:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5056:	4789                	li	a5,2
    5058:	08f50f63          	beq	a0,a5,50f6 <main+0xc8>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    505c:	4785                	li	a5,1
  char *justone = 0;
    505e:	4901                	li	s2,0
  } else if(argc > 1){
    5060:	0ca7c963          	blt	a5,a0,5132 <main+0x104>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    5064:	00003797          	auipc	a5,0x3
    5068:	d1c78793          	addi	a5,a5,-740 # 7d80 <malloc+0x2462>
    506c:	c3040713          	addi	a4,s0,-976
    5070:	00003317          	auipc	t1,0x3
    5074:	0a030313          	addi	t1,t1,160 # 8110 <malloc+0x27f2>
    5078:	0007b883          	ld	a7,0(a5)
    507c:	0087b803          	ld	a6,8(a5)
    5080:	6b88                	ld	a0,16(a5)
    5082:	6f8c                	ld	a1,24(a5)
    5084:	7390                	ld	a2,32(a5)
    5086:	7794                	ld	a3,40(a5)
    5088:	01173023          	sd	a7,0(a4)
    508c:	01073423          	sd	a6,8(a4)
    5090:	eb08                	sd	a0,16(a4)
    5092:	ef0c                	sd	a1,24(a4)
    5094:	f310                	sd	a2,32(a4)
    5096:	f714                	sd	a3,40(a4)
    5098:	03078793          	addi	a5,a5,48
    509c:	03070713          	addi	a4,a4,48
    50a0:	fc679ce3          	bne	a5,t1,5078 <main+0x4a>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    50a4:	00003517          	auipc	a0,0x3
    50a8:	c7c50513          	addi	a0,a0,-900 # 7d20 <malloc+0x2402>
    50ac:	00000097          	auipc	ra,0x0
    50b0:	7b4080e7          	jalr	1972(ra) # 5860 <printf>
  int free0 = countfree();
    50b4:	00000097          	auipc	ra,0x0
    50b8:	dac080e7          	jalr	-596(ra) # 4e60 <countfree>
    50bc:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    50be:	c3843503          	ld	a0,-968(s0)
    50c2:	c3040493          	addi	s1,s0,-976
  int fail = 0;
    50c6:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    50c8:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    50ca:	e55d                	bnez	a0,5178 <main+0x14a>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    50cc:	00000097          	auipc	ra,0x0
    50d0:	d94080e7          	jalr	-620(ra) # 4e60 <countfree>
    50d4:	85aa                	mv	a1,a0
    50d6:	0f455163          	bge	a0,s4,51b8 <main+0x18a>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    50da:	8652                	mv	a2,s4
    50dc:	00003517          	auipc	a0,0x3
    50e0:	bfc50513          	addi	a0,a0,-1028 # 7cd8 <malloc+0x23ba>
    50e4:	00000097          	auipc	ra,0x0
    50e8:	77c080e7          	jalr	1916(ra) # 5860 <printf>
    exit(1);
    50ec:	4505                	li	a0,1
    50ee:	00000097          	auipc	ra,0x0
    50f2:	3fa080e7          	jalr	1018(ra) # 54e8 <exit>
    50f6:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    50f8:	00003597          	auipc	a1,0x3
    50fc:	b7858593          	addi	a1,a1,-1160 # 7c70 <malloc+0x2352>
    5100:	6488                	ld	a0,8(s1)
    5102:	00000097          	auipc	ra,0x0
    5106:	194080e7          	jalr	404(ra) # 5296 <strcmp>
    510a:	10050563          	beqz	a0,5214 <main+0x1e6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    510e:	00003597          	auipc	a1,0x3
    5112:	c4a58593          	addi	a1,a1,-950 # 7d58 <malloc+0x243a>
    5116:	6488                	ld	a0,8(s1)
    5118:	00000097          	auipc	ra,0x0
    511c:	17e080e7          	jalr	382(ra) # 5296 <strcmp>
    5120:	c97d                	beqz	a0,5216 <main+0x1e8>
  } else if(argc == 2 && argv[1][0] != '-'){
    5122:	0084b903          	ld	s2,8(s1)
    5126:	00094703          	lbu	a4,0(s2)
    512a:	02d00793          	li	a5,45
    512e:	f2f71be3          	bne	a4,a5,5064 <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    5132:	00003517          	auipc	a0,0x3
    5136:	b4650513          	addi	a0,a0,-1210 # 7c78 <malloc+0x235a>
    513a:	00000097          	auipc	ra,0x0
    513e:	726080e7          	jalr	1830(ra) # 5860 <printf>
    exit(1);
    5142:	4505                	li	a0,1
    5144:	00000097          	auipc	ra,0x0
    5148:	3a4080e7          	jalr	932(ra) # 54e8 <exit>
          exit(1);
    514c:	4505                	li	a0,1
    514e:	00000097          	auipc	ra,0x0
    5152:	39a080e7          	jalr	922(ra) # 54e8 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5156:	40a905bb          	subw	a1,s2,a0
    515a:	855a                	mv	a0,s6
    515c:	00000097          	auipc	ra,0x0
    5160:	704080e7          	jalr	1796(ra) # 5860 <printf>
        if(continuous != 2)
    5164:	09498463          	beq	s3,s4,51ec <main+0x1be>
          exit(1);
    5168:	4505                	li	a0,1
    516a:	00000097          	auipc	ra,0x0
    516e:	37e080e7          	jalr	894(ra) # 54e8 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    5172:	04c1                	addi	s1,s1,16
    5174:	6488                	ld	a0,8(s1)
    5176:	c115                	beqz	a0,519a <main+0x16c>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    5178:	00090863          	beqz	s2,5188 <main+0x15a>
    517c:	85ca                	mv	a1,s2
    517e:	00000097          	auipc	ra,0x0
    5182:	118080e7          	jalr	280(ra) # 5296 <strcmp>
    5186:	f575                	bnez	a0,5172 <main+0x144>
      if(!run(t->f, t->s))
    5188:	648c                	ld	a1,8(s1)
    518a:	6088                	ld	a0,0(s1)
    518c:	00000097          	auipc	ra,0x0
    5190:	e04080e7          	jalr	-508(ra) # 4f90 <run>
    5194:	fd79                	bnez	a0,5172 <main+0x144>
        fail = 1;
    5196:	89d6                	mv	s3,s5
    5198:	bfe9                	j	5172 <main+0x144>
  if(fail){
    519a:	f20989e3          	beqz	s3,50cc <main+0x9e>
    printf("SOME TESTS FAILED\n");
    519e:	00003517          	auipc	a0,0x3
    51a2:	b2250513          	addi	a0,a0,-1246 # 7cc0 <malloc+0x23a2>
    51a6:	00000097          	auipc	ra,0x0
    51aa:	6ba080e7          	jalr	1722(ra) # 5860 <printf>
    exit(1);
    51ae:	4505                	li	a0,1
    51b0:	00000097          	auipc	ra,0x0
    51b4:	338080e7          	jalr	824(ra) # 54e8 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    51b8:	00003517          	auipc	a0,0x3
    51bc:	b5050513          	addi	a0,a0,-1200 # 7d08 <malloc+0x23ea>
    51c0:	00000097          	auipc	ra,0x0
    51c4:	6a0080e7          	jalr	1696(ra) # 5860 <printf>
    exit(0);
    51c8:	4501                	li	a0,0
    51ca:	00000097          	auipc	ra,0x0
    51ce:	31e080e7          	jalr	798(ra) # 54e8 <exit>
        printf("SOME TESTS FAILED\n");
    51d2:	8556                	mv	a0,s5
    51d4:	00000097          	auipc	ra,0x0
    51d8:	68c080e7          	jalr	1676(ra) # 5860 <printf>
        if(continuous != 2)
    51dc:	f74998e3          	bne	s3,s4,514c <main+0x11e>
      int free1 = countfree();
    51e0:	00000097          	auipc	ra,0x0
    51e4:	c80080e7          	jalr	-896(ra) # 4e60 <countfree>
      if(free1 < free0){
    51e8:	f72547e3          	blt	a0,s2,5156 <main+0x128>
      int free0 = countfree();
    51ec:	00000097          	auipc	ra,0x0
    51f0:	c74080e7          	jalr	-908(ra) # 4e60 <countfree>
    51f4:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    51f6:	c3843583          	ld	a1,-968(s0)
    51fa:	d1fd                	beqz	a1,51e0 <main+0x1b2>
    51fc:	c3040493          	addi	s1,s0,-976
        if(!run(t->f, t->s)){
    5200:	6088                	ld	a0,0(s1)
    5202:	00000097          	auipc	ra,0x0
    5206:	d8e080e7          	jalr	-626(ra) # 4f90 <run>
    520a:	d561                	beqz	a0,51d2 <main+0x1a4>
      for (struct test *t = tests; t->s != 0; t++) {
    520c:	04c1                	addi	s1,s1,16
    520e:	648c                	ld	a1,8(s1)
    5210:	f9e5                	bnez	a1,5200 <main+0x1d2>
    5212:	b7f9                	j	51e0 <main+0x1b2>
    continuous = 1;
    5214:	4985                	li	s3,1
  } tests[] = {
    5216:	00003797          	auipc	a5,0x3
    521a:	b6a78793          	addi	a5,a5,-1174 # 7d80 <malloc+0x2462>
    521e:	c3040713          	addi	a4,s0,-976
    5222:	00003317          	auipc	t1,0x3
    5226:	eee30313          	addi	t1,t1,-274 # 8110 <malloc+0x27f2>
    522a:	0007b883          	ld	a7,0(a5)
    522e:	0087b803          	ld	a6,8(a5)
    5232:	6b88                	ld	a0,16(a5)
    5234:	6f8c                	ld	a1,24(a5)
    5236:	7390                	ld	a2,32(a5)
    5238:	7794                	ld	a3,40(a5)
    523a:	01173023          	sd	a7,0(a4)
    523e:	01073423          	sd	a6,8(a4)
    5242:	eb08                	sd	a0,16(a4)
    5244:	ef0c                	sd	a1,24(a4)
    5246:	f310                	sd	a2,32(a4)
    5248:	f714                	sd	a3,40(a4)
    524a:	03078793          	addi	a5,a5,48
    524e:	03070713          	addi	a4,a4,48
    5252:	fc679ce3          	bne	a5,t1,522a <main+0x1fc>
    printf("continuous usertests starting\n");
    5256:	00003517          	auipc	a0,0x3
    525a:	ae250513          	addi	a0,a0,-1310 # 7d38 <malloc+0x241a>
    525e:	00000097          	auipc	ra,0x0
    5262:	602080e7          	jalr	1538(ra) # 5860 <printf>
        printf("SOME TESTS FAILED\n");
    5266:	00003a97          	auipc	s5,0x3
    526a:	a5aa8a93          	addi	s5,s5,-1446 # 7cc0 <malloc+0x23a2>
        if(continuous != 2)
    526e:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5270:	00003b17          	auipc	s6,0x3
    5274:	a30b0b13          	addi	s6,s6,-1488 # 7ca0 <malloc+0x2382>
    5278:	bf95                	j	51ec <main+0x1be>

000000000000527a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    527a:	1141                	addi	sp,sp,-16
    527c:	e422                	sd	s0,8(sp)
    527e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5280:	87aa                	mv	a5,a0
    5282:	0585                	addi	a1,a1,1
    5284:	0785                	addi	a5,a5,1
    5286:	fff5c703          	lbu	a4,-1(a1)
    528a:	fee78fa3          	sb	a4,-1(a5)
    528e:	fb75                	bnez	a4,5282 <strcpy+0x8>
    ;
  return os;
}
    5290:	6422                	ld	s0,8(sp)
    5292:	0141                	addi	sp,sp,16
    5294:	8082                	ret

0000000000005296 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5296:	1141                	addi	sp,sp,-16
    5298:	e422                	sd	s0,8(sp)
    529a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    529c:	00054783          	lbu	a5,0(a0)
    52a0:	cb91                	beqz	a5,52b4 <strcmp+0x1e>
    52a2:	0005c703          	lbu	a4,0(a1)
    52a6:	00f71763          	bne	a4,a5,52b4 <strcmp+0x1e>
    p++, q++;
    52aa:	0505                	addi	a0,a0,1
    52ac:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    52ae:	00054783          	lbu	a5,0(a0)
    52b2:	fbe5                	bnez	a5,52a2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    52b4:	0005c503          	lbu	a0,0(a1)
}
    52b8:	40a7853b          	subw	a0,a5,a0
    52bc:	6422                	ld	s0,8(sp)
    52be:	0141                	addi	sp,sp,16
    52c0:	8082                	ret

00000000000052c2 <strlen>:

uint
strlen(const char *s)
{
    52c2:	1141                	addi	sp,sp,-16
    52c4:	e422                	sd	s0,8(sp)
    52c6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    52c8:	00054783          	lbu	a5,0(a0)
    52cc:	cf91                	beqz	a5,52e8 <strlen+0x26>
    52ce:	0505                	addi	a0,a0,1
    52d0:	87aa                	mv	a5,a0
    52d2:	4685                	li	a3,1
    52d4:	9e89                	subw	a3,a3,a0
    52d6:	00f6853b          	addw	a0,a3,a5
    52da:	0785                	addi	a5,a5,1
    52dc:	fff7c703          	lbu	a4,-1(a5)
    52e0:	fb7d                	bnez	a4,52d6 <strlen+0x14>
    ;
  return n;
}
    52e2:	6422                	ld	s0,8(sp)
    52e4:	0141                	addi	sp,sp,16
    52e6:	8082                	ret
  for(n = 0; s[n]; n++)
    52e8:	4501                	li	a0,0
    52ea:	bfe5                	j	52e2 <strlen+0x20>

00000000000052ec <memset>:

void*
memset(void *dst, int c, uint n)
{
    52ec:	1141                	addi	sp,sp,-16
    52ee:	e422                	sd	s0,8(sp)
    52f0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    52f2:	ca19                	beqz	a2,5308 <memset+0x1c>
    52f4:	87aa                	mv	a5,a0
    52f6:	1602                	slli	a2,a2,0x20
    52f8:	9201                	srli	a2,a2,0x20
    52fa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    52fe:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5302:	0785                	addi	a5,a5,1
    5304:	fee79de3          	bne	a5,a4,52fe <memset+0x12>
  }
  return dst;
}
    5308:	6422                	ld	s0,8(sp)
    530a:	0141                	addi	sp,sp,16
    530c:	8082                	ret

000000000000530e <strchr>:

char*
strchr(const char *s, char c)
{
    530e:	1141                	addi	sp,sp,-16
    5310:	e422                	sd	s0,8(sp)
    5312:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5314:	00054783          	lbu	a5,0(a0)
    5318:	cb99                	beqz	a5,532e <strchr+0x20>
    if(*s == c)
    531a:	00f58763          	beq	a1,a5,5328 <strchr+0x1a>
  for(; *s; s++)
    531e:	0505                	addi	a0,a0,1
    5320:	00054783          	lbu	a5,0(a0)
    5324:	fbfd                	bnez	a5,531a <strchr+0xc>
      return (char*)s;
  return 0;
    5326:	4501                	li	a0,0
}
    5328:	6422                	ld	s0,8(sp)
    532a:	0141                	addi	sp,sp,16
    532c:	8082                	ret
  return 0;
    532e:	4501                	li	a0,0
    5330:	bfe5                	j	5328 <strchr+0x1a>

0000000000005332 <gets>:

char*
gets(char *buf, int max)
{
    5332:	711d                	addi	sp,sp,-96
    5334:	ec86                	sd	ra,88(sp)
    5336:	e8a2                	sd	s0,80(sp)
    5338:	e4a6                	sd	s1,72(sp)
    533a:	e0ca                	sd	s2,64(sp)
    533c:	fc4e                	sd	s3,56(sp)
    533e:	f852                	sd	s4,48(sp)
    5340:	f456                	sd	s5,40(sp)
    5342:	f05a                	sd	s6,32(sp)
    5344:	ec5e                	sd	s7,24(sp)
    5346:	1080                	addi	s0,sp,96
    5348:	8baa                	mv	s7,a0
    534a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    534c:	892a                	mv	s2,a0
    534e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5350:	4aa9                	li	s5,10
    5352:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5354:	89a6                	mv	s3,s1
    5356:	2485                	addiw	s1,s1,1
    5358:	0344d863          	bge	s1,s4,5388 <gets+0x56>
    cc = read(0, &c, 1);
    535c:	4605                	li	a2,1
    535e:	faf40593          	addi	a1,s0,-81
    5362:	4501                	li	a0,0
    5364:	00000097          	auipc	ra,0x0
    5368:	19c080e7          	jalr	412(ra) # 5500 <read>
    if(cc < 1)
    536c:	00a05e63          	blez	a0,5388 <gets+0x56>
    buf[i++] = c;
    5370:	faf44783          	lbu	a5,-81(s0)
    5374:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5378:	01578763          	beq	a5,s5,5386 <gets+0x54>
    537c:	0905                	addi	s2,s2,1
    537e:	fd679be3          	bne	a5,s6,5354 <gets+0x22>
  for(i=0; i+1 < max; ){
    5382:	89a6                	mv	s3,s1
    5384:	a011                	j	5388 <gets+0x56>
    5386:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5388:	99de                	add	s3,s3,s7
    538a:	00098023          	sb	zero,0(s3)
  return buf;
}
    538e:	855e                	mv	a0,s7
    5390:	60e6                	ld	ra,88(sp)
    5392:	6446                	ld	s0,80(sp)
    5394:	64a6                	ld	s1,72(sp)
    5396:	6906                	ld	s2,64(sp)
    5398:	79e2                	ld	s3,56(sp)
    539a:	7a42                	ld	s4,48(sp)
    539c:	7aa2                	ld	s5,40(sp)
    539e:	7b02                	ld	s6,32(sp)
    53a0:	6be2                	ld	s7,24(sp)
    53a2:	6125                	addi	sp,sp,96
    53a4:	8082                	ret

00000000000053a6 <stat>:

int
stat(const char *n, struct stat *st)
{
    53a6:	1101                	addi	sp,sp,-32
    53a8:	ec06                	sd	ra,24(sp)
    53aa:	e822                	sd	s0,16(sp)
    53ac:	e426                	sd	s1,8(sp)
    53ae:	e04a                	sd	s2,0(sp)
    53b0:	1000                	addi	s0,sp,32
    53b2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    53b4:	4581                	li	a1,0
    53b6:	00000097          	auipc	ra,0x0
    53ba:	172080e7          	jalr	370(ra) # 5528 <open>
  if(fd < 0)
    53be:	02054563          	bltz	a0,53e8 <stat+0x42>
    53c2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    53c4:	85ca                	mv	a1,s2
    53c6:	00000097          	auipc	ra,0x0
    53ca:	17a080e7          	jalr	378(ra) # 5540 <fstat>
    53ce:	892a                	mv	s2,a0
  close(fd);
    53d0:	8526                	mv	a0,s1
    53d2:	00000097          	auipc	ra,0x0
    53d6:	13e080e7          	jalr	318(ra) # 5510 <close>
  return r;
}
    53da:	854a                	mv	a0,s2
    53dc:	60e2                	ld	ra,24(sp)
    53de:	6442                	ld	s0,16(sp)
    53e0:	64a2                	ld	s1,8(sp)
    53e2:	6902                	ld	s2,0(sp)
    53e4:	6105                	addi	sp,sp,32
    53e6:	8082                	ret
    return -1;
    53e8:	597d                	li	s2,-1
    53ea:	bfc5                	j	53da <stat+0x34>

00000000000053ec <atoi>:

int
atoi(const char *s)
{
    53ec:	1141                	addi	sp,sp,-16
    53ee:	e422                	sd	s0,8(sp)
    53f0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    53f2:	00054603          	lbu	a2,0(a0)
    53f6:	fd06079b          	addiw	a5,a2,-48
    53fa:	0ff7f793          	andi	a5,a5,255
    53fe:	4725                	li	a4,9
    5400:	02f76963          	bltu	a4,a5,5432 <atoi+0x46>
    5404:	86aa                	mv	a3,a0
  n = 0;
    5406:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5408:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    540a:	0685                	addi	a3,a3,1
    540c:	0025179b          	slliw	a5,a0,0x2
    5410:	9fa9                	addw	a5,a5,a0
    5412:	0017979b          	slliw	a5,a5,0x1
    5416:	9fb1                	addw	a5,a5,a2
    5418:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    541c:	0006c603          	lbu	a2,0(a3)
    5420:	fd06071b          	addiw	a4,a2,-48
    5424:	0ff77713          	andi	a4,a4,255
    5428:	fee5f1e3          	bgeu	a1,a4,540a <atoi+0x1e>
  return n;
}
    542c:	6422                	ld	s0,8(sp)
    542e:	0141                	addi	sp,sp,16
    5430:	8082                	ret
  n = 0;
    5432:	4501                	li	a0,0
    5434:	bfe5                	j	542c <atoi+0x40>

0000000000005436 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5436:	1141                	addi	sp,sp,-16
    5438:	e422                	sd	s0,8(sp)
    543a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    543c:	02b57463          	bgeu	a0,a1,5464 <memmove+0x2e>
    while(n-- > 0)
    5440:	00c05f63          	blez	a2,545e <memmove+0x28>
    5444:	1602                	slli	a2,a2,0x20
    5446:	9201                	srli	a2,a2,0x20
    5448:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    544c:	872a                	mv	a4,a0
      *dst++ = *src++;
    544e:	0585                	addi	a1,a1,1
    5450:	0705                	addi	a4,a4,1
    5452:	fff5c683          	lbu	a3,-1(a1)
    5456:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    545a:	fee79ae3          	bne	a5,a4,544e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    545e:	6422                	ld	s0,8(sp)
    5460:	0141                	addi	sp,sp,16
    5462:	8082                	ret
    dst += n;
    5464:	00c50733          	add	a4,a0,a2
    src += n;
    5468:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    546a:	fec05ae3          	blez	a2,545e <memmove+0x28>
    546e:	fff6079b          	addiw	a5,a2,-1
    5472:	1782                	slli	a5,a5,0x20
    5474:	9381                	srli	a5,a5,0x20
    5476:	fff7c793          	not	a5,a5
    547a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    547c:	15fd                	addi	a1,a1,-1
    547e:	177d                	addi	a4,a4,-1
    5480:	0005c683          	lbu	a3,0(a1)
    5484:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5488:	fee79ae3          	bne	a5,a4,547c <memmove+0x46>
    548c:	bfc9                	j	545e <memmove+0x28>

000000000000548e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    548e:	1141                	addi	sp,sp,-16
    5490:	e422                	sd	s0,8(sp)
    5492:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5494:	ca05                	beqz	a2,54c4 <memcmp+0x36>
    5496:	fff6069b          	addiw	a3,a2,-1
    549a:	1682                	slli	a3,a3,0x20
    549c:	9281                	srli	a3,a3,0x20
    549e:	0685                	addi	a3,a3,1
    54a0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    54a2:	00054783          	lbu	a5,0(a0)
    54a6:	0005c703          	lbu	a4,0(a1)
    54aa:	00e79863          	bne	a5,a4,54ba <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    54ae:	0505                	addi	a0,a0,1
    p2++;
    54b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    54b2:	fed518e3          	bne	a0,a3,54a2 <memcmp+0x14>
  }
  return 0;
    54b6:	4501                	li	a0,0
    54b8:	a019                	j	54be <memcmp+0x30>
      return *p1 - *p2;
    54ba:	40e7853b          	subw	a0,a5,a4
}
    54be:	6422                	ld	s0,8(sp)
    54c0:	0141                	addi	sp,sp,16
    54c2:	8082                	ret
  return 0;
    54c4:	4501                	li	a0,0
    54c6:	bfe5                	j	54be <memcmp+0x30>

00000000000054c8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    54c8:	1141                	addi	sp,sp,-16
    54ca:	e406                	sd	ra,8(sp)
    54cc:	e022                	sd	s0,0(sp)
    54ce:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    54d0:	00000097          	auipc	ra,0x0
    54d4:	f66080e7          	jalr	-154(ra) # 5436 <memmove>
}
    54d8:	60a2                	ld	ra,8(sp)
    54da:	6402                	ld	s0,0(sp)
    54dc:	0141                	addi	sp,sp,16
    54de:	8082                	ret

00000000000054e0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    54e0:	4885                	li	a7,1
 ecall
    54e2:	00000073          	ecall
 ret
    54e6:	8082                	ret

00000000000054e8 <exit>:
.global exit
exit:
 li a7, SYS_exit
    54e8:	4889                	li	a7,2
 ecall
    54ea:	00000073          	ecall
 ret
    54ee:	8082                	ret

00000000000054f0 <wait>:
.global wait
wait:
 li a7, SYS_wait
    54f0:	488d                	li	a7,3
 ecall
    54f2:	00000073          	ecall
 ret
    54f6:	8082                	ret

00000000000054f8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    54f8:	4891                	li	a7,4
 ecall
    54fa:	00000073          	ecall
 ret
    54fe:	8082                	ret

0000000000005500 <read>:
.global read
read:
 li a7, SYS_read
    5500:	4895                	li	a7,5
 ecall
    5502:	00000073          	ecall
 ret
    5506:	8082                	ret

0000000000005508 <write>:
.global write
write:
 li a7, SYS_write
    5508:	48c1                	li	a7,16
 ecall
    550a:	00000073          	ecall
 ret
    550e:	8082                	ret

0000000000005510 <close>:
.global close
close:
 li a7, SYS_close
    5510:	48d5                	li	a7,21
 ecall
    5512:	00000073          	ecall
 ret
    5516:	8082                	ret

0000000000005518 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5518:	4899                	li	a7,6
 ecall
    551a:	00000073          	ecall
 ret
    551e:	8082                	ret

0000000000005520 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5520:	489d                	li	a7,7
 ecall
    5522:	00000073          	ecall
 ret
    5526:	8082                	ret

0000000000005528 <open>:
.global open
open:
 li a7, SYS_open
    5528:	48bd                	li	a7,15
 ecall
    552a:	00000073          	ecall
 ret
    552e:	8082                	ret

0000000000005530 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5530:	48c5                	li	a7,17
 ecall
    5532:	00000073          	ecall
 ret
    5536:	8082                	ret

0000000000005538 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5538:	48c9                	li	a7,18
 ecall
    553a:	00000073          	ecall
 ret
    553e:	8082                	ret

0000000000005540 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5540:	48a1                	li	a7,8
 ecall
    5542:	00000073          	ecall
 ret
    5546:	8082                	ret

0000000000005548 <link>:
.global link
link:
 li a7, SYS_link
    5548:	48cd                	li	a7,19
 ecall
    554a:	00000073          	ecall
 ret
    554e:	8082                	ret

0000000000005550 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5550:	48d1                	li	a7,20
 ecall
    5552:	00000073          	ecall
 ret
    5556:	8082                	ret

0000000000005558 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5558:	48a5                	li	a7,9
 ecall
    555a:	00000073          	ecall
 ret
    555e:	8082                	ret

0000000000005560 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5560:	48a9                	li	a7,10
 ecall
    5562:	00000073          	ecall
 ret
    5566:	8082                	ret

0000000000005568 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5568:	48ad                	li	a7,11
 ecall
    556a:	00000073          	ecall
 ret
    556e:	8082                	ret

0000000000005570 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5570:	48b1                	li	a7,12
 ecall
    5572:	00000073          	ecall
 ret
    5576:	8082                	ret

0000000000005578 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5578:	48b5                	li	a7,13
 ecall
    557a:	00000073          	ecall
 ret
    557e:	8082                	ret

0000000000005580 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5580:	48b9                	li	a7,14
 ecall
    5582:	00000073          	ecall
 ret
    5586:	8082                	ret

0000000000005588 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5588:	1101                	addi	sp,sp,-32
    558a:	ec06                	sd	ra,24(sp)
    558c:	e822                	sd	s0,16(sp)
    558e:	1000                	addi	s0,sp,32
    5590:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5594:	4605                	li	a2,1
    5596:	fef40593          	addi	a1,s0,-17
    559a:	00000097          	auipc	ra,0x0
    559e:	f6e080e7          	jalr	-146(ra) # 5508 <write>
}
    55a2:	60e2                	ld	ra,24(sp)
    55a4:	6442                	ld	s0,16(sp)
    55a6:	6105                	addi	sp,sp,32
    55a8:	8082                	ret

00000000000055aa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    55aa:	7139                	addi	sp,sp,-64
    55ac:	fc06                	sd	ra,56(sp)
    55ae:	f822                	sd	s0,48(sp)
    55b0:	f426                	sd	s1,40(sp)
    55b2:	f04a                	sd	s2,32(sp)
    55b4:	ec4e                	sd	s3,24(sp)
    55b6:	0080                	addi	s0,sp,64
    55b8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    55ba:	c299                	beqz	a3,55c0 <printint+0x16>
    55bc:	0805c863          	bltz	a1,564c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    55c0:	2581                	sext.w	a1,a1
  neg = 0;
    55c2:	4881                	li	a7,0
    55c4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    55c8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    55ca:	2601                	sext.w	a2,a2
    55cc:	00003517          	auipc	a0,0x3
    55d0:	b4c50513          	addi	a0,a0,-1204 # 8118 <digits>
    55d4:	883a                	mv	a6,a4
    55d6:	2705                	addiw	a4,a4,1
    55d8:	02c5f7bb          	remuw	a5,a1,a2
    55dc:	1782                	slli	a5,a5,0x20
    55de:	9381                	srli	a5,a5,0x20
    55e0:	97aa                	add	a5,a5,a0
    55e2:	0007c783          	lbu	a5,0(a5)
    55e6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    55ea:	0005879b          	sext.w	a5,a1
    55ee:	02c5d5bb          	divuw	a1,a1,a2
    55f2:	0685                	addi	a3,a3,1
    55f4:	fec7f0e3          	bgeu	a5,a2,55d4 <printint+0x2a>
  if(neg)
    55f8:	00088b63          	beqz	a7,560e <printint+0x64>
    buf[i++] = '-';
    55fc:	fd040793          	addi	a5,s0,-48
    5600:	973e                	add	a4,a4,a5
    5602:	02d00793          	li	a5,45
    5606:	fef70823          	sb	a5,-16(a4)
    560a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    560e:	02e05863          	blez	a4,563e <printint+0x94>
    5612:	fc040793          	addi	a5,s0,-64
    5616:	00e78933          	add	s2,a5,a4
    561a:	fff78993          	addi	s3,a5,-1
    561e:	99ba                	add	s3,s3,a4
    5620:	377d                	addiw	a4,a4,-1
    5622:	1702                	slli	a4,a4,0x20
    5624:	9301                	srli	a4,a4,0x20
    5626:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    562a:	fff94583          	lbu	a1,-1(s2)
    562e:	8526                	mv	a0,s1
    5630:	00000097          	auipc	ra,0x0
    5634:	f58080e7          	jalr	-168(ra) # 5588 <putc>
  while(--i >= 0)
    5638:	197d                	addi	s2,s2,-1
    563a:	ff3918e3          	bne	s2,s3,562a <printint+0x80>
}
    563e:	70e2                	ld	ra,56(sp)
    5640:	7442                	ld	s0,48(sp)
    5642:	74a2                	ld	s1,40(sp)
    5644:	7902                	ld	s2,32(sp)
    5646:	69e2                	ld	s3,24(sp)
    5648:	6121                	addi	sp,sp,64
    564a:	8082                	ret
    x = -xx;
    564c:	40b005bb          	negw	a1,a1
    neg = 1;
    5650:	4885                	li	a7,1
    x = -xx;
    5652:	bf8d                	j	55c4 <printint+0x1a>

0000000000005654 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5654:	7119                	addi	sp,sp,-128
    5656:	fc86                	sd	ra,120(sp)
    5658:	f8a2                	sd	s0,112(sp)
    565a:	f4a6                	sd	s1,104(sp)
    565c:	f0ca                	sd	s2,96(sp)
    565e:	ecce                	sd	s3,88(sp)
    5660:	e8d2                	sd	s4,80(sp)
    5662:	e4d6                	sd	s5,72(sp)
    5664:	e0da                	sd	s6,64(sp)
    5666:	fc5e                	sd	s7,56(sp)
    5668:	f862                	sd	s8,48(sp)
    566a:	f466                	sd	s9,40(sp)
    566c:	f06a                	sd	s10,32(sp)
    566e:	ec6e                	sd	s11,24(sp)
    5670:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5672:	0005c903          	lbu	s2,0(a1)
    5676:	18090f63          	beqz	s2,5814 <vprintf+0x1c0>
    567a:	8aaa                	mv	s5,a0
    567c:	8b32                	mv	s6,a2
    567e:	00158493          	addi	s1,a1,1
  state = 0;
    5682:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5684:	02500a13          	li	s4,37
      if(c == 'd'){
    5688:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    568c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5690:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5694:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5698:	00003b97          	auipc	s7,0x3
    569c:	a80b8b93          	addi	s7,s7,-1408 # 8118 <digits>
    56a0:	a839                	j	56be <vprintf+0x6a>
        putc(fd, c);
    56a2:	85ca                	mv	a1,s2
    56a4:	8556                	mv	a0,s5
    56a6:	00000097          	auipc	ra,0x0
    56aa:	ee2080e7          	jalr	-286(ra) # 5588 <putc>
    56ae:	a019                	j	56b4 <vprintf+0x60>
    } else if(state == '%'){
    56b0:	01498f63          	beq	s3,s4,56ce <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    56b4:	0485                	addi	s1,s1,1
    56b6:	fff4c903          	lbu	s2,-1(s1)
    56ba:	14090d63          	beqz	s2,5814 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    56be:	0009079b          	sext.w	a5,s2
    if(state == 0){
    56c2:	fe0997e3          	bnez	s3,56b0 <vprintf+0x5c>
      if(c == '%'){
    56c6:	fd479ee3          	bne	a5,s4,56a2 <vprintf+0x4e>
        state = '%';
    56ca:	89be                	mv	s3,a5
    56cc:	b7e5                	j	56b4 <vprintf+0x60>
      if(c == 'd'){
    56ce:	05878063          	beq	a5,s8,570e <vprintf+0xba>
      } else if(c == 'l') {
    56d2:	05978c63          	beq	a5,s9,572a <vprintf+0xd6>
      } else if(c == 'x') {
    56d6:	07a78863          	beq	a5,s10,5746 <vprintf+0xf2>
      } else if(c == 'p') {
    56da:	09b78463          	beq	a5,s11,5762 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    56de:	07300713          	li	a4,115
    56e2:	0ce78663          	beq	a5,a4,57ae <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    56e6:	06300713          	li	a4,99
    56ea:	0ee78e63          	beq	a5,a4,57e6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    56ee:	11478863          	beq	a5,s4,57fe <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    56f2:	85d2                	mv	a1,s4
    56f4:	8556                	mv	a0,s5
    56f6:	00000097          	auipc	ra,0x0
    56fa:	e92080e7          	jalr	-366(ra) # 5588 <putc>
        putc(fd, c);
    56fe:	85ca                	mv	a1,s2
    5700:	8556                	mv	a0,s5
    5702:	00000097          	auipc	ra,0x0
    5706:	e86080e7          	jalr	-378(ra) # 5588 <putc>
      }
      state = 0;
    570a:	4981                	li	s3,0
    570c:	b765                	j	56b4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    570e:	008b0913          	addi	s2,s6,8
    5712:	4685                	li	a3,1
    5714:	4629                	li	a2,10
    5716:	000b2583          	lw	a1,0(s6)
    571a:	8556                	mv	a0,s5
    571c:	00000097          	auipc	ra,0x0
    5720:	e8e080e7          	jalr	-370(ra) # 55aa <printint>
    5724:	8b4a                	mv	s6,s2
      state = 0;
    5726:	4981                	li	s3,0
    5728:	b771                	j	56b4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    572a:	008b0913          	addi	s2,s6,8
    572e:	4681                	li	a3,0
    5730:	4629                	li	a2,10
    5732:	000b2583          	lw	a1,0(s6)
    5736:	8556                	mv	a0,s5
    5738:	00000097          	auipc	ra,0x0
    573c:	e72080e7          	jalr	-398(ra) # 55aa <printint>
    5740:	8b4a                	mv	s6,s2
      state = 0;
    5742:	4981                	li	s3,0
    5744:	bf85                	j	56b4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5746:	008b0913          	addi	s2,s6,8
    574a:	4681                	li	a3,0
    574c:	4641                	li	a2,16
    574e:	000b2583          	lw	a1,0(s6)
    5752:	8556                	mv	a0,s5
    5754:	00000097          	auipc	ra,0x0
    5758:	e56080e7          	jalr	-426(ra) # 55aa <printint>
    575c:	8b4a                	mv	s6,s2
      state = 0;
    575e:	4981                	li	s3,0
    5760:	bf91                	j	56b4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5762:	008b0793          	addi	a5,s6,8
    5766:	f8f43423          	sd	a5,-120(s0)
    576a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    576e:	03000593          	li	a1,48
    5772:	8556                	mv	a0,s5
    5774:	00000097          	auipc	ra,0x0
    5778:	e14080e7          	jalr	-492(ra) # 5588 <putc>
  putc(fd, 'x');
    577c:	85ea                	mv	a1,s10
    577e:	8556                	mv	a0,s5
    5780:	00000097          	auipc	ra,0x0
    5784:	e08080e7          	jalr	-504(ra) # 5588 <putc>
    5788:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    578a:	03c9d793          	srli	a5,s3,0x3c
    578e:	97de                	add	a5,a5,s7
    5790:	0007c583          	lbu	a1,0(a5)
    5794:	8556                	mv	a0,s5
    5796:	00000097          	auipc	ra,0x0
    579a:	df2080e7          	jalr	-526(ra) # 5588 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    579e:	0992                	slli	s3,s3,0x4
    57a0:	397d                	addiw	s2,s2,-1
    57a2:	fe0914e3          	bnez	s2,578a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    57a6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    57aa:	4981                	li	s3,0
    57ac:	b721                	j	56b4 <vprintf+0x60>
        s = va_arg(ap, char*);
    57ae:	008b0993          	addi	s3,s6,8
    57b2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    57b6:	02090163          	beqz	s2,57d8 <vprintf+0x184>
        while(*s != 0){
    57ba:	00094583          	lbu	a1,0(s2)
    57be:	c9a1                	beqz	a1,580e <vprintf+0x1ba>
          putc(fd, *s);
    57c0:	8556                	mv	a0,s5
    57c2:	00000097          	auipc	ra,0x0
    57c6:	dc6080e7          	jalr	-570(ra) # 5588 <putc>
          s++;
    57ca:	0905                	addi	s2,s2,1
        while(*s != 0){
    57cc:	00094583          	lbu	a1,0(s2)
    57d0:	f9e5                	bnez	a1,57c0 <vprintf+0x16c>
        s = va_arg(ap, char*);
    57d2:	8b4e                	mv	s6,s3
      state = 0;
    57d4:	4981                	li	s3,0
    57d6:	bdf9                	j	56b4 <vprintf+0x60>
          s = "(null)";
    57d8:	00003917          	auipc	s2,0x3
    57dc:	93890913          	addi	s2,s2,-1736 # 8110 <malloc+0x27f2>
        while(*s != 0){
    57e0:	02800593          	li	a1,40
    57e4:	bff1                	j	57c0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    57e6:	008b0913          	addi	s2,s6,8
    57ea:	000b4583          	lbu	a1,0(s6)
    57ee:	8556                	mv	a0,s5
    57f0:	00000097          	auipc	ra,0x0
    57f4:	d98080e7          	jalr	-616(ra) # 5588 <putc>
    57f8:	8b4a                	mv	s6,s2
      state = 0;
    57fa:	4981                	li	s3,0
    57fc:	bd65                	j	56b4 <vprintf+0x60>
        putc(fd, c);
    57fe:	85d2                	mv	a1,s4
    5800:	8556                	mv	a0,s5
    5802:	00000097          	auipc	ra,0x0
    5806:	d86080e7          	jalr	-634(ra) # 5588 <putc>
      state = 0;
    580a:	4981                	li	s3,0
    580c:	b565                	j	56b4 <vprintf+0x60>
        s = va_arg(ap, char*);
    580e:	8b4e                	mv	s6,s3
      state = 0;
    5810:	4981                	li	s3,0
    5812:	b54d                	j	56b4 <vprintf+0x60>
    }
  }
}
    5814:	70e6                	ld	ra,120(sp)
    5816:	7446                	ld	s0,112(sp)
    5818:	74a6                	ld	s1,104(sp)
    581a:	7906                	ld	s2,96(sp)
    581c:	69e6                	ld	s3,88(sp)
    581e:	6a46                	ld	s4,80(sp)
    5820:	6aa6                	ld	s5,72(sp)
    5822:	6b06                	ld	s6,64(sp)
    5824:	7be2                	ld	s7,56(sp)
    5826:	7c42                	ld	s8,48(sp)
    5828:	7ca2                	ld	s9,40(sp)
    582a:	7d02                	ld	s10,32(sp)
    582c:	6de2                	ld	s11,24(sp)
    582e:	6109                	addi	sp,sp,128
    5830:	8082                	ret

0000000000005832 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5832:	715d                	addi	sp,sp,-80
    5834:	ec06                	sd	ra,24(sp)
    5836:	e822                	sd	s0,16(sp)
    5838:	1000                	addi	s0,sp,32
    583a:	e010                	sd	a2,0(s0)
    583c:	e414                	sd	a3,8(s0)
    583e:	e818                	sd	a4,16(s0)
    5840:	ec1c                	sd	a5,24(s0)
    5842:	03043023          	sd	a6,32(s0)
    5846:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    584a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    584e:	8622                	mv	a2,s0
    5850:	00000097          	auipc	ra,0x0
    5854:	e04080e7          	jalr	-508(ra) # 5654 <vprintf>
}
    5858:	60e2                	ld	ra,24(sp)
    585a:	6442                	ld	s0,16(sp)
    585c:	6161                	addi	sp,sp,80
    585e:	8082                	ret

0000000000005860 <printf>:

void
printf(const char *fmt, ...)
{
    5860:	711d                	addi	sp,sp,-96
    5862:	ec06                	sd	ra,24(sp)
    5864:	e822                	sd	s0,16(sp)
    5866:	1000                	addi	s0,sp,32
    5868:	e40c                	sd	a1,8(s0)
    586a:	e810                	sd	a2,16(s0)
    586c:	ec14                	sd	a3,24(s0)
    586e:	f018                	sd	a4,32(s0)
    5870:	f41c                	sd	a5,40(s0)
    5872:	03043823          	sd	a6,48(s0)
    5876:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    587a:	00840613          	addi	a2,s0,8
    587e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5882:	85aa                	mv	a1,a0
    5884:	4505                	li	a0,1
    5886:	00000097          	auipc	ra,0x0
    588a:	dce080e7          	jalr	-562(ra) # 5654 <vprintf>
}
    588e:	60e2                	ld	ra,24(sp)
    5890:	6442                	ld	s0,16(sp)
    5892:	6125                	addi	sp,sp,96
    5894:	8082                	ret

0000000000005896 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5896:	1141                	addi	sp,sp,-16
    5898:	e422                	sd	s0,8(sp)
    589a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    589c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    58a0:	00003797          	auipc	a5,0x3
    58a4:	8a87b783          	ld	a5,-1880(a5) # 8148 <freep>
    58a8:	a805                	j	58d8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    58aa:	4618                	lw	a4,8(a2)
    58ac:	9db9                	addw	a1,a1,a4
    58ae:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    58b2:	6398                	ld	a4,0(a5)
    58b4:	6318                	ld	a4,0(a4)
    58b6:	fee53823          	sd	a4,-16(a0)
    58ba:	a091                	j	58fe <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    58bc:	ff852703          	lw	a4,-8(a0)
    58c0:	9e39                	addw	a2,a2,a4
    58c2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    58c4:	ff053703          	ld	a4,-16(a0)
    58c8:	e398                	sd	a4,0(a5)
    58ca:	a099                	j	5910 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    58cc:	6398                	ld	a4,0(a5)
    58ce:	00e7e463          	bltu	a5,a4,58d6 <free+0x40>
    58d2:	00e6ea63          	bltu	a3,a4,58e6 <free+0x50>
{
    58d6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    58d8:	fed7fae3          	bgeu	a5,a3,58cc <free+0x36>
    58dc:	6398                	ld	a4,0(a5)
    58de:	00e6e463          	bltu	a3,a4,58e6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    58e2:	fee7eae3          	bltu	a5,a4,58d6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    58e6:	ff852583          	lw	a1,-8(a0)
    58ea:	6390                	ld	a2,0(a5)
    58ec:	02059713          	slli	a4,a1,0x20
    58f0:	9301                	srli	a4,a4,0x20
    58f2:	0712                	slli	a4,a4,0x4
    58f4:	9736                	add	a4,a4,a3
    58f6:	fae60ae3          	beq	a2,a4,58aa <free+0x14>
    bp->s.ptr = p->s.ptr;
    58fa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    58fe:	4790                	lw	a2,8(a5)
    5900:	02061713          	slli	a4,a2,0x20
    5904:	9301                	srli	a4,a4,0x20
    5906:	0712                	slli	a4,a4,0x4
    5908:	973e                	add	a4,a4,a5
    590a:	fae689e3          	beq	a3,a4,58bc <free+0x26>
  } else
    p->s.ptr = bp;
    590e:	e394                	sd	a3,0(a5)
  freep = p;
    5910:	00003717          	auipc	a4,0x3
    5914:	82f73c23          	sd	a5,-1992(a4) # 8148 <freep>
}
    5918:	6422                	ld	s0,8(sp)
    591a:	0141                	addi	sp,sp,16
    591c:	8082                	ret

000000000000591e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    591e:	7139                	addi	sp,sp,-64
    5920:	fc06                	sd	ra,56(sp)
    5922:	f822                	sd	s0,48(sp)
    5924:	f426                	sd	s1,40(sp)
    5926:	f04a                	sd	s2,32(sp)
    5928:	ec4e                	sd	s3,24(sp)
    592a:	e852                	sd	s4,16(sp)
    592c:	e456                	sd	s5,8(sp)
    592e:	e05a                	sd	s6,0(sp)
    5930:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5932:	02051493          	slli	s1,a0,0x20
    5936:	9081                	srli	s1,s1,0x20
    5938:	04bd                	addi	s1,s1,15
    593a:	8091                	srli	s1,s1,0x4
    593c:	0014899b          	addiw	s3,s1,1
    5940:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5942:	00003517          	auipc	a0,0x3
    5946:	80653503          	ld	a0,-2042(a0) # 8148 <freep>
    594a:	c515                	beqz	a0,5976 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    594c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    594e:	4798                	lw	a4,8(a5)
    5950:	02977f63          	bgeu	a4,s1,598e <malloc+0x70>
    5954:	8a4e                	mv	s4,s3
    5956:	0009871b          	sext.w	a4,s3
    595a:	6685                	lui	a3,0x1
    595c:	00d77363          	bgeu	a4,a3,5962 <malloc+0x44>
    5960:	6a05                	lui	s4,0x1
    5962:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5966:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    596a:	00002917          	auipc	s2,0x2
    596e:	7de90913          	addi	s2,s2,2014 # 8148 <freep>
  if(p == (char*)-1)
    5972:	5afd                	li	s5,-1
    5974:	a88d                	j	59e6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    5976:	00009797          	auipc	a5,0x9
    597a:	ff278793          	addi	a5,a5,-14 # e968 <base>
    597e:	00002717          	auipc	a4,0x2
    5982:	7cf73523          	sd	a5,1994(a4) # 8148 <freep>
    5986:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5988:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    598c:	b7e1                	j	5954 <malloc+0x36>
      if(p->s.size == nunits)
    598e:	02e48b63          	beq	s1,a4,59c4 <malloc+0xa6>
        p->s.size -= nunits;
    5992:	4137073b          	subw	a4,a4,s3
    5996:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5998:	1702                	slli	a4,a4,0x20
    599a:	9301                	srli	a4,a4,0x20
    599c:	0712                	slli	a4,a4,0x4
    599e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    59a0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    59a4:	00002717          	auipc	a4,0x2
    59a8:	7aa73223          	sd	a0,1956(a4) # 8148 <freep>
      return (void*)(p + 1);
    59ac:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    59b0:	70e2                	ld	ra,56(sp)
    59b2:	7442                	ld	s0,48(sp)
    59b4:	74a2                	ld	s1,40(sp)
    59b6:	7902                	ld	s2,32(sp)
    59b8:	69e2                	ld	s3,24(sp)
    59ba:	6a42                	ld	s4,16(sp)
    59bc:	6aa2                	ld	s5,8(sp)
    59be:	6b02                	ld	s6,0(sp)
    59c0:	6121                	addi	sp,sp,64
    59c2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    59c4:	6398                	ld	a4,0(a5)
    59c6:	e118                	sd	a4,0(a0)
    59c8:	bff1                	j	59a4 <malloc+0x86>
  hp->s.size = nu;
    59ca:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    59ce:	0541                	addi	a0,a0,16
    59d0:	00000097          	auipc	ra,0x0
    59d4:	ec6080e7          	jalr	-314(ra) # 5896 <free>
  return freep;
    59d8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    59dc:	d971                	beqz	a0,59b0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    59de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    59e0:	4798                	lw	a4,8(a5)
    59e2:	fa9776e3          	bgeu	a4,s1,598e <malloc+0x70>
    if(p == freep)
    59e6:	00093703          	ld	a4,0(s2)
    59ea:	853e                	mv	a0,a5
    59ec:	fef719e3          	bne	a4,a5,59de <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    59f0:	8552                	mv	a0,s4
    59f2:	00000097          	auipc	ra,0x0
    59f6:	b7e080e7          	jalr	-1154(ra) # 5570 <sbrk>
  if(p == (char*)-1)
    59fa:	fd5518e3          	bne	a0,s5,59ca <malloc+0xac>
        return 0;
    59fe:	4501                	li	a0,0
    5a00:	bf45                	j	59b0 <malloc+0x92>
