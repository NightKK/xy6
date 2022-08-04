
user/_nettests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <decode_qname>:
}

// Decode a DNS name
static void
decode_qname(char *qn)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  while(*qn != '\0') {
   6:	00054783          	lbu	a5,0(a0)
    int l = *qn;
   a:	0007861b          	sext.w	a2,a5
    if(l == 0)
      break;
    for(int i = 0; i < l; i++) {
   e:	4581                	li	a1,0
      *qn = *(qn+1);
      qn++;
  10:	4885                	li	a7,1
    }
    *qn++ = '.';
  12:	02e00813          	li	a6,46
  while(*qn != '\0') {
  16:	ef81                	bnez	a5,2e <decode_qname+0x2e>
  }
}
  18:	6422                	ld	s0,8(sp)
  1a:	0141                	addi	sp,sp,16
  1c:	8082                	ret
    *qn++ = '.';
  1e:	0709                	addi	a4,a4,2
  20:	953a                	add	a0,a0,a4
  22:	01078023          	sb	a6,0(a5)
  while(*qn != '\0') {
  26:	0017c603          	lbu	a2,1(a5)
  2a:	d67d                	beqz	a2,18 <decode_qname+0x18>
    int l = *qn;
  2c:	2601                	sext.w	a2,a2
{
  2e:	87aa                	mv	a5,a0
    for(int i = 0; i < l; i++) {
  30:	872e                	mv	a4,a1
      *qn = *(qn+1);
  32:	0017c683          	lbu	a3,1(a5)
  36:	00d78023          	sb	a3,0(a5)
      qn++;
  3a:	0785                	addi	a5,a5,1
    for(int i = 0; i < l; i++) {
  3c:	2705                	addiw	a4,a4,1
  3e:	fec74ae3          	blt	a4,a2,32 <decode_qname+0x32>
  42:	fff6069b          	addiw	a3,a2,-1
  46:	1682                	slli	a3,a3,0x20
  48:	9281                	srli	a3,a3,0x20
      qn++;
  4a:	87c6                	mv	a5,a7
  4c:	00c05463          	blez	a2,54 <decode_qname+0x54>
  50:	00168793          	addi	a5,a3,1
  54:	97aa                	add	a5,a5,a0
    *qn++ = '.';
  56:	872e                	mv	a4,a1
  58:	fcc053e3          	blez	a2,1e <decode_qname+0x1e>
  5c:	8736                	mv	a4,a3
  5e:	b7c1                	j	1e <decode_qname+0x1e>

0000000000000060 <ping>:
{
  60:	7171                	addi	sp,sp,-176
  62:	f506                	sd	ra,168(sp)
  64:	f122                	sd	s0,160(sp)
  66:	ed26                	sd	s1,152(sp)
  68:	e94a                	sd	s2,144(sp)
  6a:	e54e                	sd	s3,136(sp)
  6c:	e152                	sd	s4,128(sp)
  6e:	1900                	addi	s0,sp,176
  70:	8a32                	mv	s4,a2
  if((fd = connect(dst, sport, dport)) < 0){
  72:	862e                	mv	a2,a1
  74:	85aa                	mv	a1,a0
  76:	0a000537          	lui	a0,0xa000
  7a:	20250513          	addi	a0,a0,514 # a000202 <__global_pointer$+0x9ffe839>
  7e:	00001097          	auipc	ra,0x1
  82:	a5e080e7          	jalr	-1442(ra) # adc <connect>
  86:	08054563          	bltz	a0,110 <ping+0xb0>
  8a:	89aa                	mv	s3,a0
  for(int i = 0; i < attempts; i++) {
  8c:	4481                	li	s1,0
    if(write(fd, obuf, strlen(obuf)) < 0){
  8e:	00001917          	auipc	s2,0x1
  92:	eea90913          	addi	s2,s2,-278 # f78 <malloc+0xfe>
  for(int i = 0; i < attempts; i++) {
  96:	03405463          	blez	s4,be <ping+0x5e>
    if(write(fd, obuf, strlen(obuf)) < 0){
  9a:	854a                	mv	a0,s2
  9c:	00000097          	auipc	ra,0x0
  a0:	77a080e7          	jalr	1914(ra) # 816 <strlen>
  a4:	0005061b          	sext.w	a2,a0
  a8:	85ca                	mv	a1,s2
  aa:	854e                	mv	a0,s3
  ac:	00001097          	auipc	ra,0x1
  b0:	9b0080e7          	jalr	-1616(ra) # a5c <write>
  b4:	06054c63          	bltz	a0,12c <ping+0xcc>
  for(int i = 0; i < attempts; i++) {
  b8:	2485                	addiw	s1,s1,1
  ba:	fe9a10e3          	bne	s4,s1,9a <ping+0x3a>
  int cc = read(fd, ibuf, sizeof(ibuf)-1);
  be:	07f00613          	li	a2,127
  c2:	f5040593          	addi	a1,s0,-176
  c6:	854e                	mv	a0,s3
  c8:	00001097          	auipc	ra,0x1
  cc:	98c080e7          	jalr	-1652(ra) # a54 <read>
  d0:	84aa                	mv	s1,a0
  if(cc < 0){
  d2:	06054b63          	bltz	a0,148 <ping+0xe8>
  close(fd);
  d6:	854e                	mv	a0,s3
  d8:	00001097          	auipc	ra,0x1
  dc:	98c080e7          	jalr	-1652(ra) # a64 <close>
  ibuf[cc] = '\0';
  e0:	fd040793          	addi	a5,s0,-48
  e4:	94be                	add	s1,s1,a5
  e6:	f8048023          	sb	zero,-128(s1)
  if(strcmp(ibuf, "this is the host!") != 0){
  ea:	00001597          	auipc	a1,0x1
  ee:	ed658593          	addi	a1,a1,-298 # fc0 <malloc+0x146>
  f2:	f5040513          	addi	a0,s0,-176
  f6:	00000097          	auipc	ra,0x0
  fa:	6f4080e7          	jalr	1780(ra) # 7ea <strcmp>
  fe:	e13d                	bnez	a0,164 <ping+0x104>
}
 100:	70aa                	ld	ra,168(sp)
 102:	740a                	ld	s0,160(sp)
 104:	64ea                	ld	s1,152(sp)
 106:	694a                	ld	s2,144(sp)
 108:	69aa                	ld	s3,136(sp)
 10a:	6a0a                	ld	s4,128(sp)
 10c:	614d                	addi	sp,sp,176
 10e:	8082                	ret
    fprintf(2, "ping: connect() failed\n");
 110:	00001597          	auipc	a1,0x1
 114:	e5058593          	addi	a1,a1,-432 # f60 <malloc+0xe6>
 118:	4509                	li	a0,2
 11a:	00001097          	auipc	ra,0x1
 11e:	c74080e7          	jalr	-908(ra) # d8e <fprintf>
    exit(1);
 122:	4505                	li	a0,1
 124:	00001097          	auipc	ra,0x1
 128:	918080e7          	jalr	-1768(ra) # a3c <exit>
      fprintf(2, "ping: send() failed\n");
 12c:	00001597          	auipc	a1,0x1
 130:	e6458593          	addi	a1,a1,-412 # f90 <malloc+0x116>
 134:	4509                	li	a0,2
 136:	00001097          	auipc	ra,0x1
 13a:	c58080e7          	jalr	-936(ra) # d8e <fprintf>
      exit(1);
 13e:	4505                	li	a0,1
 140:	00001097          	auipc	ra,0x1
 144:	8fc080e7          	jalr	-1796(ra) # a3c <exit>
    fprintf(2, "ping: recv() failed\n");
 148:	00001597          	auipc	a1,0x1
 14c:	e6058593          	addi	a1,a1,-416 # fa8 <malloc+0x12e>
 150:	4509                	li	a0,2
 152:	00001097          	auipc	ra,0x1
 156:	c3c080e7          	jalr	-964(ra) # d8e <fprintf>
    exit(1);
 15a:	4505                	li	a0,1
 15c:	00001097          	auipc	ra,0x1
 160:	8e0080e7          	jalr	-1824(ra) # a3c <exit>
    fprintf(2, "ping didn't receive correct payload\n");
 164:	00001597          	auipc	a1,0x1
 168:	e7458593          	addi	a1,a1,-396 # fd8 <malloc+0x15e>
 16c:	4509                	li	a0,2
 16e:	00001097          	auipc	ra,0x1
 172:	c20080e7          	jalr	-992(ra) # d8e <fprintf>
    exit(1);
 176:	4505                	li	a0,1
 178:	00001097          	auipc	ra,0x1
 17c:	8c4080e7          	jalr	-1852(ra) # a3c <exit>

0000000000000180 <dns>:
  }
}

static void
dns()
{
 180:	7119                	addi	sp,sp,-128
 182:	fc86                	sd	ra,120(sp)
 184:	f8a2                	sd	s0,112(sp)
 186:	f4a6                	sd	s1,104(sp)
 188:	f0ca                	sd	s2,96(sp)
 18a:	ecce                	sd	s3,88(sp)
 18c:	e8d2                	sd	s4,80(sp)
 18e:	e4d6                	sd	s5,72(sp)
 190:	e0da                	sd	s6,64(sp)
 192:	fc5e                	sd	s7,56(sp)
 194:	f862                	sd	s8,48(sp)
 196:	f466                	sd	s9,40(sp)
 198:	f06a                	sd	s10,32(sp)
 19a:	ec6e                	sd	s11,24(sp)
 19c:	0100                	addi	s0,sp,128
 19e:	82010113          	addi	sp,sp,-2016
  uint8 ibuf[N];
  uint32 dst;
  int fd;
  int len;

  memset(obuf, 0, N);
 1a2:	3e800613          	li	a2,1000
 1a6:	4581                	li	a1,0
 1a8:	ba840513          	addi	a0,s0,-1112
 1ac:	00000097          	auipc	ra,0x0
 1b0:	694080e7          	jalr	1684(ra) # 840 <memset>
  memset(ibuf, 0, N);
 1b4:	3e800613          	li	a2,1000
 1b8:	4581                	li	a1,0
 1ba:	77fd                	lui	a5,0xfffff
 1bc:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffddf7>
 1c0:	00f40533          	add	a0,s0,a5
 1c4:	00000097          	auipc	ra,0x0
 1c8:	67c080e7          	jalr	1660(ra) # 840 <memset>
  
  // 8.8.8.8: google's name server
  dst = (8 << 24) | (8 << 16) | (8 << 8) | (8 << 0);

  if((fd = connect(dst, 10000, 53)) < 0){
 1cc:	03500613          	li	a2,53
 1d0:	6589                	lui	a1,0x2
 1d2:	71058593          	addi	a1,a1,1808 # 2710 <__global_pointer$+0xd47>
 1d6:	08081537          	lui	a0,0x8081
 1da:	80850513          	addi	a0,a0,-2040 # 8080808 <__global_pointer$+0x807ee3f>
 1de:	00001097          	auipc	ra,0x1
 1e2:	8fe080e7          	jalr	-1794(ra) # adc <connect>
 1e6:	777d                	lui	a4,0xfffff
 1e8:	7b070713          	addi	a4,a4,1968 # fffffffffffff7b0 <__global_pointer$+0xffffffffffffdde7>
 1ec:	9722                	add	a4,a4,s0
 1ee:	e308                	sd	a0,0(a4)
 1f0:	02054c63          	bltz	a0,228 <dns+0xa8>
  hdr->id = htons(6828);
 1f4:	77ed                	lui	a5,0xffffb
 1f6:	c1a78793          	addi	a5,a5,-998 # ffffffffffffac1a <__global_pointer$+0xffffffffffff9251>
 1fa:	baf41423          	sh	a5,-1112(s0)
  hdr->rd = 1;
 1fe:	baa45783          	lhu	a5,-1110(s0)
 202:	0017e793          	ori	a5,a5,1
 206:	baf41523          	sh	a5,-1110(s0)
  hdr->qdcount = htons(1);
 20a:	10000793          	li	a5,256
 20e:	baf41623          	sh	a5,-1108(s0)
  for(char *c = host; c < host+strlen(host)+1; c++) {
 212:	00001497          	auipc	s1,0x1
 216:	dee48493          	addi	s1,s1,-530 # 1000 <malloc+0x186>
  char *l = host; 
 21a:	8a26                	mv	s4,s1
  for(char *c = host; c < host+strlen(host)+1; c++) {
 21c:	bb440a93          	addi	s5,s0,-1100
 220:	8926                	mv	s2,s1
    if(*c == '.') {
 222:	02e00993          	li	s3,46
  for(char *c = host; c < host+strlen(host)+1; c++) {
 226:	a01d                	j	24c <dns+0xcc>
    fprintf(2, "ping: connect() failed\n");
 228:	00001597          	auipc	a1,0x1
 22c:	d3858593          	addi	a1,a1,-712 # f60 <malloc+0xe6>
 230:	4509                	li	a0,2
 232:	00001097          	auipc	ra,0x1
 236:	b5c080e7          	jalr	-1188(ra) # d8e <fprintf>
    exit(1);
 23a:	4505                	li	a0,1
 23c:	00001097          	auipc	ra,0x1
 240:	800080e7          	jalr	-2048(ra) # a3c <exit>
      *qn++ = (char) (c-l);
 244:	8ab2                	mv	s5,a2
      l = c+1; // skip .
 246:	00148a13          	addi	s4,s1,1
  for(char *c = host; c < host+strlen(host)+1; c++) {
 24a:	0485                	addi	s1,s1,1
 24c:	854a                	mv	a0,s2
 24e:	00000097          	auipc	ra,0x0
 252:	5c8080e7          	jalr	1480(ra) # 816 <strlen>
 256:	02051793          	slli	a5,a0,0x20
 25a:	9381                	srli	a5,a5,0x20
 25c:	0785                	addi	a5,a5,1
 25e:	97ca                	add	a5,a5,s2
 260:	02f4fd63          	bgeu	s1,a5,29a <dns+0x11a>
    if(*c == '.') {
 264:	0004c783          	lbu	a5,0(s1)
 268:	ff3791e3          	bne	a5,s3,24a <dns+0xca>
      *qn++ = (char) (c-l);
 26c:	001a8613          	addi	a2,s5,1
 270:	414487b3          	sub	a5,s1,s4
 274:	00fa8023          	sb	a5,0(s5)
      for(char *d = l; d < c; d++) {
 278:	fc9a76e3          	bgeu	s4,s1,244 <dns+0xc4>
 27c:	87d2                	mv	a5,s4
      *qn++ = (char) (c-l);
 27e:	8732                	mv	a4,a2
        *qn++ = *d;
 280:	0705                	addi	a4,a4,1
 282:	0007c683          	lbu	a3,0(a5)
 286:	fed70fa3          	sb	a3,-1(a4)
      for(char *d = l; d < c; d++) {
 28a:	0785                	addi	a5,a5,1
 28c:	fef49ae3          	bne	s1,a5,280 <dns+0x100>
        *qn++ = *d;
 290:	41448a33          	sub	s4,s1,s4
 294:	01460ab3          	add	s5,a2,s4
 298:	b77d                	j	246 <dns+0xc6>
  *qn = '\0';
 29a:	000a8023          	sb	zero,0(s5)
  len += strlen(qname) + 1;
 29e:	bb440513          	addi	a0,s0,-1100
 2a2:	00000097          	auipc	ra,0x0
 2a6:	574080e7          	jalr	1396(ra) # 816 <strlen>
 2aa:	0005049b          	sext.w	s1,a0
  struct dns_question *h = (struct dns_question *) (qname+strlen(qname)+1);
 2ae:	bb440513          	addi	a0,s0,-1100
 2b2:	00000097          	auipc	ra,0x0
 2b6:	564080e7          	jalr	1380(ra) # 816 <strlen>
 2ba:	02051793          	slli	a5,a0,0x20
 2be:	9381                	srli	a5,a5,0x20
 2c0:	0785                	addi	a5,a5,1
 2c2:	bb440713          	addi	a4,s0,-1100
 2c6:	97ba                	add	a5,a5,a4
  h->qtype = htons(0x1);
 2c8:	00078023          	sb	zero,0(a5)
 2cc:	4705                	li	a4,1
 2ce:	00e780a3          	sb	a4,1(a5)
  h->qclass = htons(0x1);
 2d2:	00078123          	sb	zero,2(a5)
 2d6:	00e781a3          	sb	a4,3(a5)
  }

  len = dns_req(obuf);
  
  if(write(fd, obuf, len) < 0){
 2da:	0114861b          	addiw	a2,s1,17
 2de:	ba840593          	addi	a1,s0,-1112
 2e2:	77fd                	lui	a5,0xfffff
 2e4:	7b078793          	addi	a5,a5,1968 # fffffffffffff7b0 <__global_pointer$+0xffffffffffffdde7>
 2e8:	97a2                	add	a5,a5,s0
 2ea:	6388                	ld	a0,0(a5)
 2ec:	00000097          	auipc	ra,0x0
 2f0:	770080e7          	jalr	1904(ra) # a5c <write>
 2f4:	14054263          	bltz	a0,438 <dns+0x2b8>
    fprintf(2, "dns: send() failed\n");
    exit(1);
  }
  int cc = read(fd, ibuf, sizeof(ibuf));
 2f8:	3e800613          	li	a2,1000
 2fc:	77fd                	lui	a5,0xfffff
 2fe:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffddf7>
 302:	00f405b3          	add	a1,s0,a5
 306:	74fd                	lui	s1,0xfffff
 308:	7b048793          	addi	a5,s1,1968 # fffffffffffff7b0 <__global_pointer$+0xffffffffffffdde7>
 30c:	97a2                	add	a5,a5,s0
 30e:	6388                	ld	a0,0(a5)
 310:	00000097          	auipc	ra,0x0
 314:	744080e7          	jalr	1860(ra) # a54 <read>
 318:	7a848713          	addi	a4,s1,1960
 31c:	9722                	add	a4,a4,s0
 31e:	e308                	sd	a0,0(a4)
  if(cc < 0){
 320:	12054a63          	bltz	a0,454 <dns+0x2d4>
  if(!hdr->qr) {
 324:	77fd                	lui	a5,0xfffff
 326:	7c278793          	addi	a5,a5,1986 # fffffffffffff7c2 <__global_pointer$+0xffffffffffffddf9>
 32a:	97a2                	add	a5,a5,s0
 32c:	00078783          	lb	a5,0(a5)
 330:	1407d063          	bgez	a5,470 <dns+0x2f0>
  if(hdr->id != htons(6828))
 334:	77fd                	lui	a5,0xfffff
 336:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffddf7>
 33a:	97a2                	add	a5,a5,s0
 33c:	0007d703          	lhu	a4,0(a5)
 340:	0007069b          	sext.w	a3,a4
 344:	67ad                	lui	a5,0xb
 346:	c1a78793          	addi	a5,a5,-998 # ac1a <__global_pointer$+0x9251>
 34a:	12f69863          	bne	a3,a5,47a <dns+0x2fa>
  if(hdr->rcode != 0) {
 34e:	777d                	lui	a4,0xfffff
 350:	7c370793          	addi	a5,a4,1987 # fffffffffffff7c3 <__global_pointer$+0xffffffffffffddfa>
 354:	97a2                	add	a5,a5,s0
 356:	0007c783          	lbu	a5,0(a5)
 35a:	8bbd                	andi	a5,a5,15
 35c:	14079063          	bnez	a5,49c <dns+0x31c>
// endianness support
//

static inline uint16 bswaps(uint16 val)
{
  return (((val & 0x00ffU) << 8) |
 360:	7c470793          	addi	a5,a4,1988
 364:	97a2                	add	a5,a5,s0
 366:	0007d783          	lhu	a5,0(a5)
 36a:	0087971b          	slliw	a4,a5,0x8
 36e:	0107979b          	slliw	a5,a5,0x10
 372:	0107d79b          	srliw	a5,a5,0x10
 376:	0087d79b          	srliw	a5,a5,0x8
 37a:	8fd9                	or	a5,a5,a4
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 37c:	17c2                	slli	a5,a5,0x30
 37e:	93c1                	srli	a5,a5,0x30
 380:	4981                	li	s3,0
  len = sizeof(struct dns);
 382:	44b1                	li	s1,12
  char *qname = 0;
 384:	4901                	li	s2,0
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 386:	c7b1                	beqz	a5,3d2 <dns+0x252>
    char *qn = (char *) (ibuf+len);
 388:	7a7d                	lui	s4,0xfffff
 38a:	7c0a0793          	addi	a5,s4,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffddf7>
 38e:	97a2                	add	a5,a5,s0
 390:	00978933          	add	s2,a5,s1
    decode_qname(qn);
 394:	854a                	mv	a0,s2
 396:	00000097          	auipc	ra,0x0
 39a:	c6a080e7          	jalr	-918(ra) # 0 <decode_qname>
    len += strlen(qn)+1;
 39e:	854a                	mv	a0,s2
 3a0:	00000097          	auipc	ra,0x0
 3a4:	476080e7          	jalr	1142(ra) # 816 <strlen>
    len += sizeof(struct dns_question);
 3a8:	2515                	addiw	a0,a0,5
 3aa:	9ca9                	addw	s1,s1,a0
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 3ac:	2985                	addiw	s3,s3,1
 3ae:	7c4a0793          	addi	a5,s4,1988
 3b2:	97a2                	add	a5,a5,s0
 3b4:	0007d783          	lhu	a5,0(a5)
 3b8:	0087971b          	slliw	a4,a5,0x8
 3bc:	0107979b          	slliw	a5,a5,0x10
 3c0:	0107d79b          	srliw	a5,a5,0x10
 3c4:	0087d79b          	srliw	a5,a5,0x8
 3c8:	8fd9                	or	a5,a5,a4
 3ca:	17c2                	slli	a5,a5,0x30
 3cc:	93c1                	srli	a5,a5,0x30
 3ce:	faf9cde3          	blt	s3,a5,388 <dns+0x208>
 3d2:	77fd                	lui	a5,0xfffff
 3d4:	7c678793          	addi	a5,a5,1990 # fffffffffffff7c6 <__global_pointer$+0xffffffffffffddfd>
 3d8:	97a2                	add	a5,a5,s0
 3da:	0007d783          	lhu	a5,0(a5)
 3de:	0087971b          	slliw	a4,a5,0x8
 3e2:	0107979b          	slliw	a5,a5,0x10
 3e6:	0107d79b          	srliw	a5,a5,0x10
 3ea:	0087d79b          	srliw	a5,a5,0x8
 3ee:	8fd9                	or	a5,a5,a4
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 3f0:	17c2                	slli	a5,a5,0x30
 3f2:	93c1                	srli	a5,a5,0x30
 3f4:	24078e63          	beqz	a5,650 <dns+0x4d0>
 3f8:	00001797          	auipc	a5,0x1
 3fc:	ce878793          	addi	a5,a5,-792 # 10e0 <malloc+0x266>
 400:	00090363          	beqz	s2,406 <dns+0x286>
 404:	87ca                	mv	a5,s2
 406:	8bbe                	mv	s7,a5
  int record = 0;
 408:	77fd                	lui	a5,0xfffff
 40a:	7b878793          	addi	a5,a5,1976 # fffffffffffff7b8 <__global_pointer$+0xffffffffffffddef>
 40e:	97a2                	add	a5,a5,s0
 410:	0007b023          	sd	zero,0(a5)
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 414:	4901                	li	s2,0
    if((int) qn[0] > 63) {  // compression?
 416:	03f00a93          	li	s5,63
    if(ntohs(d->type) == ARECORD && ntohs(d->len) == 4) {
 41a:	4a05                	li	s4,1
 41c:	4b11                	li	s6,4
      printf("DNS arecord for %s is ", qname ? qname : "" );
 41e:	00001d97          	auipc	s11,0x1
 422:	c5ad8d93          	addi	s11,s11,-934 # 1078 <malloc+0x1fe>
      printf("%d.%d.%d.%d\n", ip[0], ip[1], ip[2], ip[3]);
 426:	00001d17          	auipc	s10,0x1
 42a:	c6ad0d13          	addi	s10,s10,-918 # 1090 <malloc+0x216>
      if(ip[0] != 128 || ip[1] != 52 || ip[2] != 129 || ip[3] != 126) {
 42e:	08000c93          	li	s9,128
 432:	03400c13          	li	s8,52
 436:	a0c5                	j	516 <dns+0x396>
    fprintf(2, "dns: send() failed\n");
 438:	00001597          	auipc	a1,0x1
 43c:	be058593          	addi	a1,a1,-1056 # 1018 <malloc+0x19e>
 440:	4509                	li	a0,2
 442:	00001097          	auipc	ra,0x1
 446:	94c080e7          	jalr	-1716(ra) # d8e <fprintf>
    exit(1);
 44a:	4505                	li	a0,1
 44c:	00000097          	auipc	ra,0x0
 450:	5f0080e7          	jalr	1520(ra) # a3c <exit>
    fprintf(2, "dns: recv() failed\n");
 454:	00001597          	auipc	a1,0x1
 458:	bdc58593          	addi	a1,a1,-1060 # 1030 <malloc+0x1b6>
 45c:	4509                	li	a0,2
 45e:	00001097          	auipc	ra,0x1
 462:	930080e7          	jalr	-1744(ra) # d8e <fprintf>
    exit(1);
 466:	4505                	li	a0,1
 468:	00000097          	auipc	ra,0x0
 46c:	5d4080e7          	jalr	1492(ra) # a3c <exit>
    exit(1);
 470:	4505                	li	a0,1
 472:	00000097          	auipc	ra,0x0
 476:	5ca080e7          	jalr	1482(ra) # a3c <exit>
 47a:	0087179b          	slliw	a5,a4,0x8
 47e:	0087571b          	srliw	a4,a4,0x8
 482:	8f5d                	or	a4,a4,a5
    printf("DNS wrong id: %d\n", ntohs(hdr->id));
 484:	03071593          	slli	a1,a4,0x30
 488:	91c1                	srli	a1,a1,0x30
 48a:	00001517          	auipc	a0,0x1
 48e:	bbe50513          	addi	a0,a0,-1090 # 1048 <malloc+0x1ce>
 492:	00001097          	auipc	ra,0x1
 496:	92a080e7          	jalr	-1750(ra) # dbc <printf>
 49a:	bd55                	j	34e <dns+0x1ce>
    printf("DNS rcode error: %x\n", hdr->rcode);
 49c:	77fd                	lui	a5,0xfffff
 49e:	7c378793          	addi	a5,a5,1987 # fffffffffffff7c3 <__global_pointer$+0xffffffffffffddfa>
 4a2:	97a2                	add	a5,a5,s0
 4a4:	0007c583          	lbu	a1,0(a5)
 4a8:	89bd                	andi	a1,a1,15
 4aa:	00001517          	auipc	a0,0x1
 4ae:	bb650513          	addi	a0,a0,-1098 # 1060 <malloc+0x1e6>
 4b2:	00001097          	auipc	ra,0x1
 4b6:	90a080e7          	jalr	-1782(ra) # dbc <printf>
    exit(1);
 4ba:	4505                	li	a0,1
 4bc:	00000097          	auipc	ra,0x0
 4c0:	580080e7          	jalr	1408(ra) # a3c <exit>
      decode_qname(qn);
 4c4:	854e                	mv	a0,s3
 4c6:	00000097          	auipc	ra,0x0
 4ca:	b3a080e7          	jalr	-1222(ra) # 0 <decode_qname>
      len += strlen(qn)+1;
 4ce:	854e                	mv	a0,s3
 4d0:	00000097          	auipc	ra,0x0
 4d4:	346080e7          	jalr	838(ra) # 816 <strlen>
 4d8:	2485                	addiw	s1,s1,1
 4da:	9ca9                	addw	s1,s1,a0
 4dc:	a881                	j	52c <dns+0x3ac>
      len += 4;
 4de:	00e9849b          	addiw	s1,s3,14
      record = 1;
 4e2:	77fd                	lui	a5,0xfffff
 4e4:	7b878793          	addi	a5,a5,1976 # fffffffffffff7b8 <__global_pointer$+0xffffffffffffddef>
 4e8:	97a2                	add	a5,a5,s0
 4ea:	0147b023          	sd	s4,0(a5)
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 4ee:	2905                	addiw	s2,s2,1
 4f0:	77fd                	lui	a5,0xfffff
 4f2:	7c678793          	addi	a5,a5,1990 # fffffffffffff7c6 <__global_pointer$+0xffffffffffffddfd>
 4f6:	97a2                	add	a5,a5,s0
 4f8:	0007d783          	lhu	a5,0(a5)
 4fc:	0087971b          	slliw	a4,a5,0x8
 500:	0107979b          	slliw	a5,a5,0x10
 504:	0107d79b          	srliw	a5,a5,0x10
 508:	0087d79b          	srliw	a5,a5,0x8
 50c:	8fd9                	or	a5,a5,a4
 50e:	17c2                	slli	a5,a5,0x30
 510:	93c1                	srli	a5,a5,0x30
 512:	0cf95b63          	bge	s2,a5,5e8 <dns+0x468>
    char *qn = (char *) (ibuf+len);
 516:	77fd                	lui	a5,0xfffff
 518:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffddf7>
 51c:	97a2                	add	a5,a5,s0
 51e:	009789b3          	add	s3,a5,s1
    if((int) qn[0] > 63) {  // compression?
 522:	0009c783          	lbu	a5,0(s3)
 526:	f8faffe3          	bgeu	s5,a5,4c4 <dns+0x344>
      len += 2;
 52a:	2489                	addiw	s1,s1,2
    struct dns_data *d = (struct dns_data *) (ibuf+len);
 52c:	77fd                	lui	a5,0xfffff
 52e:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffddf7>
 532:	97a2                	add	a5,a5,s0
 534:	00978733          	add	a4,a5,s1
    len += sizeof(struct dns_data);
 538:	0004899b          	sext.w	s3,s1
 53c:	24a9                	addiw	s1,s1,10
    if(ntohs(d->type) == ARECORD && ntohs(d->len) == 4) {
 53e:	00074683          	lbu	a3,0(a4)
 542:	00174783          	lbu	a5,1(a4)
 546:	07a2                	slli	a5,a5,0x8
 548:	8fd5                	or	a5,a5,a3
 54a:	0087969b          	slliw	a3,a5,0x8
 54e:	83a1                	srli	a5,a5,0x8
 550:	8fd5                	or	a5,a5,a3
 552:	17c2                	slli	a5,a5,0x30
 554:	93c1                	srli	a5,a5,0x30
 556:	f9479ce3          	bne	a5,s4,4ee <dns+0x36e>
 55a:	00874683          	lbu	a3,8(a4)
 55e:	00974783          	lbu	a5,9(a4)
 562:	07a2                	slli	a5,a5,0x8
 564:	8fd5                	or	a5,a5,a3
 566:	0087971b          	slliw	a4,a5,0x8
 56a:	83a1                	srli	a5,a5,0x8
 56c:	8fd9                	or	a5,a5,a4
 56e:	17c2                	slli	a5,a5,0x30
 570:	93c1                	srli	a5,a5,0x30
 572:	f7679ee3          	bne	a5,s6,4ee <dns+0x36e>
      printf("DNS arecord for %s is ", qname ? qname : "" );
 576:	85de                	mv	a1,s7
 578:	856e                	mv	a0,s11
 57a:	00001097          	auipc	ra,0x1
 57e:	842080e7          	jalr	-1982(ra) # dbc <printf>
      uint8 *ip = (ibuf+len);
 582:	77fd                	lui	a5,0xfffff
 584:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffddf7>
 588:	97a2                	add	a5,a5,s0
 58a:	94be                	add	s1,s1,a5
      printf("%d.%d.%d.%d\n", ip[0], ip[1], ip[2], ip[3]);
 58c:	0034c703          	lbu	a4,3(s1)
 590:	0024c683          	lbu	a3,2(s1)
 594:	0014c603          	lbu	a2,1(s1)
 598:	0004c583          	lbu	a1,0(s1)
 59c:	856a                	mv	a0,s10
 59e:	00001097          	auipc	ra,0x1
 5a2:	81e080e7          	jalr	-2018(ra) # dbc <printf>
      if(ip[0] != 128 || ip[1] != 52 || ip[2] != 129 || ip[3] != 126) {
 5a6:	0004c783          	lbu	a5,0(s1)
 5aa:	03979263          	bne	a5,s9,5ce <dns+0x44e>
 5ae:	0014c783          	lbu	a5,1(s1)
 5b2:	01879e63          	bne	a5,s8,5ce <dns+0x44e>
 5b6:	0024c703          	lbu	a4,2(s1)
 5ba:	08100793          	li	a5,129
 5be:	00f71863          	bne	a4,a5,5ce <dns+0x44e>
 5c2:	0034c703          	lbu	a4,3(s1)
 5c6:	07e00793          	li	a5,126
 5ca:	f0f70ae3          	beq	a4,a5,4de <dns+0x35e>
        printf("wrong ip address");
 5ce:	00001517          	auipc	a0,0x1
 5d2:	ad250513          	addi	a0,a0,-1326 # 10a0 <malloc+0x226>
 5d6:	00000097          	auipc	ra,0x0
 5da:	7e6080e7          	jalr	2022(ra) # dbc <printf>
        exit(1);
 5de:	4505                	li	a0,1
 5e0:	00000097          	auipc	ra,0x0
 5e4:	45c080e7          	jalr	1116(ra) # a3c <exit>
  if(len != cc) {
 5e8:	77fd                	lui	a5,0xfffff
 5ea:	7a878793          	addi	a5,a5,1960 # fffffffffffff7a8 <__global_pointer$+0xffffffffffffdddf>
 5ee:	97a2                	add	a5,a5,s0
 5f0:	639c                	ld	a5,0(a5)
 5f2:	06979663          	bne	a5,s1,65e <dns+0x4de>
  if(!record) {
 5f6:	77fd                	lui	a5,0xfffff
 5f8:	7b878793          	addi	a5,a5,1976 # fffffffffffff7b8 <__global_pointer$+0xffffffffffffddef>
 5fc:	97a2                	add	a5,a5,s0
 5fe:	639c                	ld	a5,0(a5)
 600:	cb9d                	beqz	a5,636 <dns+0x4b6>
  }
  dns_rep(ibuf, cc);

  close(fd);
 602:	77fd                	lui	a5,0xfffff
 604:	7b078793          	addi	a5,a5,1968 # fffffffffffff7b0 <__global_pointer$+0xffffffffffffdde7>
 608:	97a2                	add	a5,a5,s0
 60a:	6388                	ld	a0,0(a5)
 60c:	00000097          	auipc	ra,0x0
 610:	458080e7          	jalr	1112(ra) # a64 <close>
}  
 614:	7e010113          	addi	sp,sp,2016
 618:	70e6                	ld	ra,120(sp)
 61a:	7446                	ld	s0,112(sp)
 61c:	74a6                	ld	s1,104(sp)
 61e:	7906                	ld	s2,96(sp)
 620:	69e6                	ld	s3,88(sp)
 622:	6a46                	ld	s4,80(sp)
 624:	6aa6                	ld	s5,72(sp)
 626:	6b06                	ld	s6,64(sp)
 628:	7be2                	ld	s7,56(sp)
 62a:	7c42                	ld	s8,48(sp)
 62c:	7ca2                	ld	s9,40(sp)
 62e:	7d02                	ld	s10,32(sp)
 630:	6de2                	ld	s11,24(sp)
 632:	6109                	addi	sp,sp,128
 634:	8082                	ret
    printf("Didn't receive an arecord\n");
 636:	00001517          	auipc	a0,0x1
 63a:	ab250513          	addi	a0,a0,-1358 # 10e8 <malloc+0x26e>
 63e:	00000097          	auipc	ra,0x0
 642:	77e080e7          	jalr	1918(ra) # dbc <printf>
    exit(1);
 646:	4505                	li	a0,1
 648:	00000097          	auipc	ra,0x0
 64c:	3f4080e7          	jalr	1012(ra) # a3c <exit>
  if(len != cc) {
 650:	77fd                	lui	a5,0xfffff
 652:	7a878793          	addi	a5,a5,1960 # fffffffffffff7a8 <__global_pointer$+0xffffffffffffdddf>
 656:	97a2                	add	a5,a5,s0
 658:	639c                	ld	a5,0(a5)
 65a:	fc978ee3          	beq	a5,s1,636 <dns+0x4b6>
    printf("Processed %d data bytes but received %d\n", len, cc);
 65e:	77fd                	lui	a5,0xfffff
 660:	7a878793          	addi	a5,a5,1960 # fffffffffffff7a8 <__global_pointer$+0xffffffffffffdddf>
 664:	97a2                	add	a5,a5,s0
 666:	6390                	ld	a2,0(a5)
 668:	85a6                	mv	a1,s1
 66a:	00001517          	auipc	a0,0x1
 66e:	a4e50513          	addi	a0,a0,-1458 # 10b8 <malloc+0x23e>
 672:	00000097          	auipc	ra,0x0
 676:	74a080e7          	jalr	1866(ra) # dbc <printf>
    exit(1);
 67a:	4505                	li	a0,1
 67c:	00000097          	auipc	ra,0x0
 680:	3c0080e7          	jalr	960(ra) # a3c <exit>

0000000000000684 <main>:

int
main(int argc, char *argv[])
{
 684:	7179                	addi	sp,sp,-48
 686:	f406                	sd	ra,40(sp)
 688:	f022                	sd	s0,32(sp)
 68a:	ec26                	sd	s1,24(sp)
 68c:	e84a                	sd	s2,16(sp)
 68e:	1800                	addi	s0,sp,48
  int i, ret;
  uint16 dport = NET_TESTS_PORT;

  printf("nettests running on port %d\n", dport);
 690:	6499                	lui	s1,0x6
 692:	5f348593          	addi	a1,s1,1523 # 65f3 <__global_pointer$+0x4c2a>
 696:	00001517          	auipc	a0,0x1
 69a:	a7250513          	addi	a0,a0,-1422 # 1108 <malloc+0x28e>
 69e:	00000097          	auipc	ra,0x0
 6a2:	71e080e7          	jalr	1822(ra) # dbc <printf>

  printf("testing ping: ");
 6a6:	00001517          	auipc	a0,0x1
 6aa:	a8250513          	addi	a0,a0,-1406 # 1128 <malloc+0x2ae>
 6ae:	00000097          	auipc	ra,0x0
 6b2:	70e080e7          	jalr	1806(ra) # dbc <printf>
  ping(2000, dport, 1);
 6b6:	4605                	li	a2,1
 6b8:	5f348593          	addi	a1,s1,1523
 6bc:	7d000513          	li	a0,2000
 6c0:	00000097          	auipc	ra,0x0
 6c4:	9a0080e7          	jalr	-1632(ra) # 60 <ping>
  printf("OK\n");
 6c8:	00001517          	auipc	a0,0x1
 6cc:	a7050513          	addi	a0,a0,-1424 # 1138 <malloc+0x2be>
 6d0:	00000097          	auipc	ra,0x0
 6d4:	6ec080e7          	jalr	1772(ra) # dbc <printf>

  printf("testing single-process pings: ");
 6d8:	00001517          	auipc	a0,0x1
 6dc:	a6850513          	addi	a0,a0,-1432 # 1140 <malloc+0x2c6>
 6e0:	00000097          	auipc	ra,0x0
 6e4:	6dc080e7          	jalr	1756(ra) # dbc <printf>
 6e8:	06400493          	li	s1,100
  for (i = 0; i < 100; i++)
    ping(2000, dport, 1);
 6ec:	6919                	lui	s2,0x6
 6ee:	5f390913          	addi	s2,s2,1523 # 65f3 <__global_pointer$+0x4c2a>
 6f2:	4605                	li	a2,1
 6f4:	85ca                	mv	a1,s2
 6f6:	7d000513          	li	a0,2000
 6fa:	00000097          	auipc	ra,0x0
 6fe:	966080e7          	jalr	-1690(ra) # 60 <ping>
  for (i = 0; i < 100; i++)
 702:	34fd                	addiw	s1,s1,-1
 704:	f4fd                	bnez	s1,6f2 <main+0x6e>
  printf("OK\n");
 706:	00001517          	auipc	a0,0x1
 70a:	a3250513          	addi	a0,a0,-1486 # 1138 <malloc+0x2be>
 70e:	00000097          	auipc	ra,0x0
 712:	6ae080e7          	jalr	1710(ra) # dbc <printf>

  printf("testing multi-process pings: ");
 716:	00001517          	auipc	a0,0x1
 71a:	a4a50513          	addi	a0,a0,-1462 # 1160 <malloc+0x2e6>
 71e:	00000097          	auipc	ra,0x0
 722:	69e080e7          	jalr	1694(ra) # dbc <printf>
  for (i = 0; i < 10; i++){
 726:	4929                	li	s2,10
    int pid = fork();
 728:	00000097          	auipc	ra,0x0
 72c:	30c080e7          	jalr	780(ra) # a34 <fork>
    if (pid == 0){
 730:	c92d                	beqz	a0,7a2 <main+0x11e>
  for (i = 0; i < 10; i++){
 732:	2485                	addiw	s1,s1,1
 734:	ff249ae3          	bne	s1,s2,728 <main+0xa4>
 738:	44a9                	li	s1,10
      ping(2000 + i + 1, dport, 1);
      exit(0);
    }
  }
  for (i = 0; i < 10; i++){
    wait(&ret);
 73a:	fdc40513          	addi	a0,s0,-36
 73e:	00000097          	auipc	ra,0x0
 742:	306080e7          	jalr	774(ra) # a44 <wait>
    if (ret != 0)
 746:	fdc42783          	lw	a5,-36(s0)
 74a:	efad                	bnez	a5,7c4 <main+0x140>
  for (i = 0; i < 10; i++){
 74c:	34fd                	addiw	s1,s1,-1
 74e:	f4f5                	bnez	s1,73a <main+0xb6>
      exit(1);
  }
  printf("OK\n");
 750:	00001517          	auipc	a0,0x1
 754:	9e850513          	addi	a0,a0,-1560 # 1138 <malloc+0x2be>
 758:	00000097          	auipc	ra,0x0
 75c:	664080e7          	jalr	1636(ra) # dbc <printf>
  
  printf("testing DNS\n");
 760:	00001517          	auipc	a0,0x1
 764:	a2050513          	addi	a0,a0,-1504 # 1180 <malloc+0x306>
 768:	00000097          	auipc	ra,0x0
 76c:	654080e7          	jalr	1620(ra) # dbc <printf>
  dns();
 770:	00000097          	auipc	ra,0x0
 774:	a10080e7          	jalr	-1520(ra) # 180 <dns>
  printf("DNS OK\n");
 778:	00001517          	auipc	a0,0x1
 77c:	a1850513          	addi	a0,a0,-1512 # 1190 <malloc+0x316>
 780:	00000097          	auipc	ra,0x0
 784:	63c080e7          	jalr	1596(ra) # dbc <printf>
  
  printf("all tests passed.\n");
 788:	00001517          	auipc	a0,0x1
 78c:	a1050513          	addi	a0,a0,-1520 # 1198 <malloc+0x31e>
 790:	00000097          	auipc	ra,0x0
 794:	62c080e7          	jalr	1580(ra) # dbc <printf>
  exit(0);
 798:	4501                	li	a0,0
 79a:	00000097          	auipc	ra,0x0
 79e:	2a2080e7          	jalr	674(ra) # a3c <exit>
      ping(2000 + i + 1, dport, 1);
 7a2:	7d14851b          	addiw	a0,s1,2001
 7a6:	4605                	li	a2,1
 7a8:	6599                	lui	a1,0x6
 7aa:	5f358593          	addi	a1,a1,1523 # 65f3 <__global_pointer$+0x4c2a>
 7ae:	1542                	slli	a0,a0,0x30
 7b0:	9141                	srli	a0,a0,0x30
 7b2:	00000097          	auipc	ra,0x0
 7b6:	8ae080e7          	jalr	-1874(ra) # 60 <ping>
      exit(0);
 7ba:	4501                	li	a0,0
 7bc:	00000097          	auipc	ra,0x0
 7c0:	280080e7          	jalr	640(ra) # a3c <exit>
      exit(1);
 7c4:	4505                	li	a0,1
 7c6:	00000097          	auipc	ra,0x0
 7ca:	276080e7          	jalr	630(ra) # a3c <exit>

00000000000007ce <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 7ce:	1141                	addi	sp,sp,-16
 7d0:	e422                	sd	s0,8(sp)
 7d2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 7d4:	87aa                	mv	a5,a0
 7d6:	0585                	addi	a1,a1,1
 7d8:	0785                	addi	a5,a5,1
 7da:	fff5c703          	lbu	a4,-1(a1)
 7de:	fee78fa3          	sb	a4,-1(a5)
 7e2:	fb75                	bnez	a4,7d6 <strcpy+0x8>
    ;
  return os;
}
 7e4:	6422                	ld	s0,8(sp)
 7e6:	0141                	addi	sp,sp,16
 7e8:	8082                	ret

00000000000007ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
 7ea:	1141                	addi	sp,sp,-16
 7ec:	e422                	sd	s0,8(sp)
 7ee:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 7f0:	00054783          	lbu	a5,0(a0)
 7f4:	cb91                	beqz	a5,808 <strcmp+0x1e>
 7f6:	0005c703          	lbu	a4,0(a1)
 7fa:	00f71763          	bne	a4,a5,808 <strcmp+0x1e>
    p++, q++;
 7fe:	0505                	addi	a0,a0,1
 800:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 802:	00054783          	lbu	a5,0(a0)
 806:	fbe5                	bnez	a5,7f6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 808:	0005c503          	lbu	a0,0(a1)
}
 80c:	40a7853b          	subw	a0,a5,a0
 810:	6422                	ld	s0,8(sp)
 812:	0141                	addi	sp,sp,16
 814:	8082                	ret

0000000000000816 <strlen>:

uint
strlen(const char *s)
{
 816:	1141                	addi	sp,sp,-16
 818:	e422                	sd	s0,8(sp)
 81a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 81c:	00054783          	lbu	a5,0(a0)
 820:	cf91                	beqz	a5,83c <strlen+0x26>
 822:	0505                	addi	a0,a0,1
 824:	87aa                	mv	a5,a0
 826:	4685                	li	a3,1
 828:	9e89                	subw	a3,a3,a0
 82a:	00f6853b          	addw	a0,a3,a5
 82e:	0785                	addi	a5,a5,1
 830:	fff7c703          	lbu	a4,-1(a5)
 834:	fb7d                	bnez	a4,82a <strlen+0x14>
    ;
  return n;
}
 836:	6422                	ld	s0,8(sp)
 838:	0141                	addi	sp,sp,16
 83a:	8082                	ret
  for(n = 0; s[n]; n++)
 83c:	4501                	li	a0,0
 83e:	bfe5                	j	836 <strlen+0x20>

0000000000000840 <memset>:

void*
memset(void *dst, int c, uint n)
{
 840:	1141                	addi	sp,sp,-16
 842:	e422                	sd	s0,8(sp)
 844:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 846:	ca19                	beqz	a2,85c <memset+0x1c>
 848:	87aa                	mv	a5,a0
 84a:	1602                	slli	a2,a2,0x20
 84c:	9201                	srli	a2,a2,0x20
 84e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 852:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 856:	0785                	addi	a5,a5,1
 858:	fee79de3          	bne	a5,a4,852 <memset+0x12>
  }
  return dst;
}
 85c:	6422                	ld	s0,8(sp)
 85e:	0141                	addi	sp,sp,16
 860:	8082                	ret

0000000000000862 <strchr>:

char*
strchr(const char *s, char c)
{
 862:	1141                	addi	sp,sp,-16
 864:	e422                	sd	s0,8(sp)
 866:	0800                	addi	s0,sp,16
  for(; *s; s++)
 868:	00054783          	lbu	a5,0(a0)
 86c:	cb99                	beqz	a5,882 <strchr+0x20>
    if(*s == c)
 86e:	00f58763          	beq	a1,a5,87c <strchr+0x1a>
  for(; *s; s++)
 872:	0505                	addi	a0,a0,1
 874:	00054783          	lbu	a5,0(a0)
 878:	fbfd                	bnez	a5,86e <strchr+0xc>
      return (char*)s;
  return 0;
 87a:	4501                	li	a0,0
}
 87c:	6422                	ld	s0,8(sp)
 87e:	0141                	addi	sp,sp,16
 880:	8082                	ret
  return 0;
 882:	4501                	li	a0,0
 884:	bfe5                	j	87c <strchr+0x1a>

0000000000000886 <gets>:

char*
gets(char *buf, int max)
{
 886:	711d                	addi	sp,sp,-96
 888:	ec86                	sd	ra,88(sp)
 88a:	e8a2                	sd	s0,80(sp)
 88c:	e4a6                	sd	s1,72(sp)
 88e:	e0ca                	sd	s2,64(sp)
 890:	fc4e                	sd	s3,56(sp)
 892:	f852                	sd	s4,48(sp)
 894:	f456                	sd	s5,40(sp)
 896:	f05a                	sd	s6,32(sp)
 898:	ec5e                	sd	s7,24(sp)
 89a:	1080                	addi	s0,sp,96
 89c:	8baa                	mv	s7,a0
 89e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 8a0:	892a                	mv	s2,a0
 8a2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 8a4:	4aa9                	li	s5,10
 8a6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 8a8:	89a6                	mv	s3,s1
 8aa:	2485                	addiw	s1,s1,1
 8ac:	0344d863          	bge	s1,s4,8dc <gets+0x56>
    cc = read(0, &c, 1);
 8b0:	4605                	li	a2,1
 8b2:	faf40593          	addi	a1,s0,-81
 8b6:	4501                	li	a0,0
 8b8:	00000097          	auipc	ra,0x0
 8bc:	19c080e7          	jalr	412(ra) # a54 <read>
    if(cc < 1)
 8c0:	00a05e63          	blez	a0,8dc <gets+0x56>
    buf[i++] = c;
 8c4:	faf44783          	lbu	a5,-81(s0)
 8c8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 8cc:	01578763          	beq	a5,s5,8da <gets+0x54>
 8d0:	0905                	addi	s2,s2,1
 8d2:	fd679be3          	bne	a5,s6,8a8 <gets+0x22>
  for(i=0; i+1 < max; ){
 8d6:	89a6                	mv	s3,s1
 8d8:	a011                	j	8dc <gets+0x56>
 8da:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 8dc:	99de                	add	s3,s3,s7
 8de:	00098023          	sb	zero,0(s3)
  return buf;
}
 8e2:	855e                	mv	a0,s7
 8e4:	60e6                	ld	ra,88(sp)
 8e6:	6446                	ld	s0,80(sp)
 8e8:	64a6                	ld	s1,72(sp)
 8ea:	6906                	ld	s2,64(sp)
 8ec:	79e2                	ld	s3,56(sp)
 8ee:	7a42                	ld	s4,48(sp)
 8f0:	7aa2                	ld	s5,40(sp)
 8f2:	7b02                	ld	s6,32(sp)
 8f4:	6be2                	ld	s7,24(sp)
 8f6:	6125                	addi	sp,sp,96
 8f8:	8082                	ret

00000000000008fa <stat>:

int
stat(const char *n, struct stat *st)
{
 8fa:	1101                	addi	sp,sp,-32
 8fc:	ec06                	sd	ra,24(sp)
 8fe:	e822                	sd	s0,16(sp)
 900:	e426                	sd	s1,8(sp)
 902:	e04a                	sd	s2,0(sp)
 904:	1000                	addi	s0,sp,32
 906:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 908:	4581                	li	a1,0
 90a:	00000097          	auipc	ra,0x0
 90e:	172080e7          	jalr	370(ra) # a7c <open>
  if(fd < 0)
 912:	02054563          	bltz	a0,93c <stat+0x42>
 916:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 918:	85ca                	mv	a1,s2
 91a:	00000097          	auipc	ra,0x0
 91e:	17a080e7          	jalr	378(ra) # a94 <fstat>
 922:	892a                	mv	s2,a0
  close(fd);
 924:	8526                	mv	a0,s1
 926:	00000097          	auipc	ra,0x0
 92a:	13e080e7          	jalr	318(ra) # a64 <close>
  return r;
}
 92e:	854a                	mv	a0,s2
 930:	60e2                	ld	ra,24(sp)
 932:	6442                	ld	s0,16(sp)
 934:	64a2                	ld	s1,8(sp)
 936:	6902                	ld	s2,0(sp)
 938:	6105                	addi	sp,sp,32
 93a:	8082                	ret
    return -1;
 93c:	597d                	li	s2,-1
 93e:	bfc5                	j	92e <stat+0x34>

0000000000000940 <atoi>:

int
atoi(const char *s)
{
 940:	1141                	addi	sp,sp,-16
 942:	e422                	sd	s0,8(sp)
 944:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 946:	00054603          	lbu	a2,0(a0)
 94a:	fd06079b          	addiw	a5,a2,-48
 94e:	0ff7f793          	andi	a5,a5,255
 952:	4725                	li	a4,9
 954:	02f76963          	bltu	a4,a5,986 <atoi+0x46>
 958:	86aa                	mv	a3,a0
  n = 0;
 95a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 95c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 95e:	0685                	addi	a3,a3,1
 960:	0025179b          	slliw	a5,a0,0x2
 964:	9fa9                	addw	a5,a5,a0
 966:	0017979b          	slliw	a5,a5,0x1
 96a:	9fb1                	addw	a5,a5,a2
 96c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 970:	0006c603          	lbu	a2,0(a3)
 974:	fd06071b          	addiw	a4,a2,-48
 978:	0ff77713          	andi	a4,a4,255
 97c:	fee5f1e3          	bgeu	a1,a4,95e <atoi+0x1e>
  return n;
}
 980:	6422                	ld	s0,8(sp)
 982:	0141                	addi	sp,sp,16
 984:	8082                	ret
  n = 0;
 986:	4501                	li	a0,0
 988:	bfe5                	j	980 <atoi+0x40>

000000000000098a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 98a:	1141                	addi	sp,sp,-16
 98c:	e422                	sd	s0,8(sp)
 98e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 990:	02b57463          	bgeu	a0,a1,9b8 <memmove+0x2e>
    while(n-- > 0)
 994:	00c05f63          	blez	a2,9b2 <memmove+0x28>
 998:	1602                	slli	a2,a2,0x20
 99a:	9201                	srli	a2,a2,0x20
 99c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 9a0:	872a                	mv	a4,a0
      *dst++ = *src++;
 9a2:	0585                	addi	a1,a1,1
 9a4:	0705                	addi	a4,a4,1
 9a6:	fff5c683          	lbu	a3,-1(a1)
 9aa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 9ae:	fee79ae3          	bne	a5,a4,9a2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 9b2:	6422                	ld	s0,8(sp)
 9b4:	0141                	addi	sp,sp,16
 9b6:	8082                	ret
    dst += n;
 9b8:	00c50733          	add	a4,a0,a2
    src += n;
 9bc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 9be:	fec05ae3          	blez	a2,9b2 <memmove+0x28>
 9c2:	fff6079b          	addiw	a5,a2,-1
 9c6:	1782                	slli	a5,a5,0x20
 9c8:	9381                	srli	a5,a5,0x20
 9ca:	fff7c793          	not	a5,a5
 9ce:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 9d0:	15fd                	addi	a1,a1,-1
 9d2:	177d                	addi	a4,a4,-1
 9d4:	0005c683          	lbu	a3,0(a1)
 9d8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 9dc:	fee79ae3          	bne	a5,a4,9d0 <memmove+0x46>
 9e0:	bfc9                	j	9b2 <memmove+0x28>

00000000000009e2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 9e2:	1141                	addi	sp,sp,-16
 9e4:	e422                	sd	s0,8(sp)
 9e6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 9e8:	ca05                	beqz	a2,a18 <memcmp+0x36>
 9ea:	fff6069b          	addiw	a3,a2,-1
 9ee:	1682                	slli	a3,a3,0x20
 9f0:	9281                	srli	a3,a3,0x20
 9f2:	0685                	addi	a3,a3,1
 9f4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 9f6:	00054783          	lbu	a5,0(a0)
 9fa:	0005c703          	lbu	a4,0(a1)
 9fe:	00e79863          	bne	a5,a4,a0e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 a02:	0505                	addi	a0,a0,1
    p2++;
 a04:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 a06:	fed518e3          	bne	a0,a3,9f6 <memcmp+0x14>
  }
  return 0;
 a0a:	4501                	li	a0,0
 a0c:	a019                	j	a12 <memcmp+0x30>
      return *p1 - *p2;
 a0e:	40e7853b          	subw	a0,a5,a4
}
 a12:	6422                	ld	s0,8(sp)
 a14:	0141                	addi	sp,sp,16
 a16:	8082                	ret
  return 0;
 a18:	4501                	li	a0,0
 a1a:	bfe5                	j	a12 <memcmp+0x30>

0000000000000a1c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 a1c:	1141                	addi	sp,sp,-16
 a1e:	e406                	sd	ra,8(sp)
 a20:	e022                	sd	s0,0(sp)
 a22:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 a24:	00000097          	auipc	ra,0x0
 a28:	f66080e7          	jalr	-154(ra) # 98a <memmove>
}
 a2c:	60a2                	ld	ra,8(sp)
 a2e:	6402                	ld	s0,0(sp)
 a30:	0141                	addi	sp,sp,16
 a32:	8082                	ret

0000000000000a34 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 a34:	4885                	li	a7,1
 ecall
 a36:	00000073          	ecall
 ret
 a3a:	8082                	ret

0000000000000a3c <exit>:
.global exit
exit:
 li a7, SYS_exit
 a3c:	4889                	li	a7,2
 ecall
 a3e:	00000073          	ecall
 ret
 a42:	8082                	ret

0000000000000a44 <wait>:
.global wait
wait:
 li a7, SYS_wait
 a44:	488d                	li	a7,3
 ecall
 a46:	00000073          	ecall
 ret
 a4a:	8082                	ret

0000000000000a4c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 a4c:	4891                	li	a7,4
 ecall
 a4e:	00000073          	ecall
 ret
 a52:	8082                	ret

0000000000000a54 <read>:
.global read
read:
 li a7, SYS_read
 a54:	4895                	li	a7,5
 ecall
 a56:	00000073          	ecall
 ret
 a5a:	8082                	ret

0000000000000a5c <write>:
.global write
write:
 li a7, SYS_write
 a5c:	48c1                	li	a7,16
 ecall
 a5e:	00000073          	ecall
 ret
 a62:	8082                	ret

0000000000000a64 <close>:
.global close
close:
 li a7, SYS_close
 a64:	48d5                	li	a7,21
 ecall
 a66:	00000073          	ecall
 ret
 a6a:	8082                	ret

0000000000000a6c <kill>:
.global kill
kill:
 li a7, SYS_kill
 a6c:	4899                	li	a7,6
 ecall
 a6e:	00000073          	ecall
 ret
 a72:	8082                	ret

0000000000000a74 <exec>:
.global exec
exec:
 li a7, SYS_exec
 a74:	489d                	li	a7,7
 ecall
 a76:	00000073          	ecall
 ret
 a7a:	8082                	ret

0000000000000a7c <open>:
.global open
open:
 li a7, SYS_open
 a7c:	48bd                	li	a7,15
 ecall
 a7e:	00000073          	ecall
 ret
 a82:	8082                	ret

0000000000000a84 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 a84:	48c5                	li	a7,17
 ecall
 a86:	00000073          	ecall
 ret
 a8a:	8082                	ret

0000000000000a8c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 a8c:	48c9                	li	a7,18
 ecall
 a8e:	00000073          	ecall
 ret
 a92:	8082                	ret

0000000000000a94 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 a94:	48a1                	li	a7,8
 ecall
 a96:	00000073          	ecall
 ret
 a9a:	8082                	ret

0000000000000a9c <link>:
.global link
link:
 li a7, SYS_link
 a9c:	48cd                	li	a7,19
 ecall
 a9e:	00000073          	ecall
 ret
 aa2:	8082                	ret

0000000000000aa4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 aa4:	48d1                	li	a7,20
 ecall
 aa6:	00000073          	ecall
 ret
 aaa:	8082                	ret

0000000000000aac <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 aac:	48a5                	li	a7,9
 ecall
 aae:	00000073          	ecall
 ret
 ab2:	8082                	ret

0000000000000ab4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 ab4:	48a9                	li	a7,10
 ecall
 ab6:	00000073          	ecall
 ret
 aba:	8082                	ret

0000000000000abc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 abc:	48ad                	li	a7,11
 ecall
 abe:	00000073          	ecall
 ret
 ac2:	8082                	ret

0000000000000ac4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 ac4:	48b1                	li	a7,12
 ecall
 ac6:	00000073          	ecall
 ret
 aca:	8082                	ret

0000000000000acc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 acc:	48b5                	li	a7,13
 ecall
 ace:	00000073          	ecall
 ret
 ad2:	8082                	ret

0000000000000ad4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 ad4:	48b9                	li	a7,14
 ecall
 ad6:	00000073          	ecall
 ret
 ada:	8082                	ret

0000000000000adc <connect>:
.global connect
connect:
 li a7, SYS_connect
 adc:	48f5                	li	a7,29
 ecall
 ade:	00000073          	ecall
 ret
 ae2:	8082                	ret

0000000000000ae4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 ae4:	1101                	addi	sp,sp,-32
 ae6:	ec06                	sd	ra,24(sp)
 ae8:	e822                	sd	s0,16(sp)
 aea:	1000                	addi	s0,sp,32
 aec:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 af0:	4605                	li	a2,1
 af2:	fef40593          	addi	a1,s0,-17
 af6:	00000097          	auipc	ra,0x0
 afa:	f66080e7          	jalr	-154(ra) # a5c <write>
}
 afe:	60e2                	ld	ra,24(sp)
 b00:	6442                	ld	s0,16(sp)
 b02:	6105                	addi	sp,sp,32
 b04:	8082                	ret

0000000000000b06 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b06:	7139                	addi	sp,sp,-64
 b08:	fc06                	sd	ra,56(sp)
 b0a:	f822                	sd	s0,48(sp)
 b0c:	f426                	sd	s1,40(sp)
 b0e:	f04a                	sd	s2,32(sp)
 b10:	ec4e                	sd	s3,24(sp)
 b12:	0080                	addi	s0,sp,64
 b14:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b16:	c299                	beqz	a3,b1c <printint+0x16>
 b18:	0805c863          	bltz	a1,ba8 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 b1c:	2581                	sext.w	a1,a1
  neg = 0;
 b1e:	4881                	li	a7,0
 b20:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 b24:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 b26:	2601                	sext.w	a2,a2
 b28:	00000517          	auipc	a0,0x0
 b2c:	69050513          	addi	a0,a0,1680 # 11b8 <digits>
 b30:	883a                	mv	a6,a4
 b32:	2705                	addiw	a4,a4,1
 b34:	02c5f7bb          	remuw	a5,a1,a2
 b38:	1782                	slli	a5,a5,0x20
 b3a:	9381                	srli	a5,a5,0x20
 b3c:	97aa                	add	a5,a5,a0
 b3e:	0007c783          	lbu	a5,0(a5)
 b42:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 b46:	0005879b          	sext.w	a5,a1
 b4a:	02c5d5bb          	divuw	a1,a1,a2
 b4e:	0685                	addi	a3,a3,1
 b50:	fec7f0e3          	bgeu	a5,a2,b30 <printint+0x2a>
  if(neg)
 b54:	00088b63          	beqz	a7,b6a <printint+0x64>
    buf[i++] = '-';
 b58:	fd040793          	addi	a5,s0,-48
 b5c:	973e                	add	a4,a4,a5
 b5e:	02d00793          	li	a5,45
 b62:	fef70823          	sb	a5,-16(a4)
 b66:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 b6a:	02e05863          	blez	a4,b9a <printint+0x94>
 b6e:	fc040793          	addi	a5,s0,-64
 b72:	00e78933          	add	s2,a5,a4
 b76:	fff78993          	addi	s3,a5,-1
 b7a:	99ba                	add	s3,s3,a4
 b7c:	377d                	addiw	a4,a4,-1
 b7e:	1702                	slli	a4,a4,0x20
 b80:	9301                	srli	a4,a4,0x20
 b82:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 b86:	fff94583          	lbu	a1,-1(s2)
 b8a:	8526                	mv	a0,s1
 b8c:	00000097          	auipc	ra,0x0
 b90:	f58080e7          	jalr	-168(ra) # ae4 <putc>
  while(--i >= 0)
 b94:	197d                	addi	s2,s2,-1
 b96:	ff3918e3          	bne	s2,s3,b86 <printint+0x80>
}
 b9a:	70e2                	ld	ra,56(sp)
 b9c:	7442                	ld	s0,48(sp)
 b9e:	74a2                	ld	s1,40(sp)
 ba0:	7902                	ld	s2,32(sp)
 ba2:	69e2                	ld	s3,24(sp)
 ba4:	6121                	addi	sp,sp,64
 ba6:	8082                	ret
    x = -xx;
 ba8:	40b005bb          	negw	a1,a1
    neg = 1;
 bac:	4885                	li	a7,1
    x = -xx;
 bae:	bf8d                	j	b20 <printint+0x1a>

0000000000000bb0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 bb0:	7119                	addi	sp,sp,-128
 bb2:	fc86                	sd	ra,120(sp)
 bb4:	f8a2                	sd	s0,112(sp)
 bb6:	f4a6                	sd	s1,104(sp)
 bb8:	f0ca                	sd	s2,96(sp)
 bba:	ecce                	sd	s3,88(sp)
 bbc:	e8d2                	sd	s4,80(sp)
 bbe:	e4d6                	sd	s5,72(sp)
 bc0:	e0da                	sd	s6,64(sp)
 bc2:	fc5e                	sd	s7,56(sp)
 bc4:	f862                	sd	s8,48(sp)
 bc6:	f466                	sd	s9,40(sp)
 bc8:	f06a                	sd	s10,32(sp)
 bca:	ec6e                	sd	s11,24(sp)
 bcc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 bce:	0005c903          	lbu	s2,0(a1)
 bd2:	18090f63          	beqz	s2,d70 <vprintf+0x1c0>
 bd6:	8aaa                	mv	s5,a0
 bd8:	8b32                	mv	s6,a2
 bda:	00158493          	addi	s1,a1,1
  state = 0;
 bde:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 be0:	02500a13          	li	s4,37
      if(c == 'd'){
 be4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 be8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 bec:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 bf0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bf4:	00000b97          	auipc	s7,0x0
 bf8:	5c4b8b93          	addi	s7,s7,1476 # 11b8 <digits>
 bfc:	a839                	j	c1a <vprintf+0x6a>
        putc(fd, c);
 bfe:	85ca                	mv	a1,s2
 c00:	8556                	mv	a0,s5
 c02:	00000097          	auipc	ra,0x0
 c06:	ee2080e7          	jalr	-286(ra) # ae4 <putc>
 c0a:	a019                	j	c10 <vprintf+0x60>
    } else if(state == '%'){
 c0c:	01498f63          	beq	s3,s4,c2a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 c10:	0485                	addi	s1,s1,1
 c12:	fff4c903          	lbu	s2,-1(s1)
 c16:	14090d63          	beqz	s2,d70 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 c1a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 c1e:	fe0997e3          	bnez	s3,c0c <vprintf+0x5c>
      if(c == '%'){
 c22:	fd479ee3          	bne	a5,s4,bfe <vprintf+0x4e>
        state = '%';
 c26:	89be                	mv	s3,a5
 c28:	b7e5                	j	c10 <vprintf+0x60>
      if(c == 'd'){
 c2a:	05878063          	beq	a5,s8,c6a <vprintf+0xba>
      } else if(c == 'l') {
 c2e:	05978c63          	beq	a5,s9,c86 <vprintf+0xd6>
      } else if(c == 'x') {
 c32:	07a78863          	beq	a5,s10,ca2 <vprintf+0xf2>
      } else if(c == 'p') {
 c36:	09b78463          	beq	a5,s11,cbe <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 c3a:	07300713          	li	a4,115
 c3e:	0ce78663          	beq	a5,a4,d0a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c42:	06300713          	li	a4,99
 c46:	0ee78e63          	beq	a5,a4,d42 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 c4a:	11478863          	beq	a5,s4,d5a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c4e:	85d2                	mv	a1,s4
 c50:	8556                	mv	a0,s5
 c52:	00000097          	auipc	ra,0x0
 c56:	e92080e7          	jalr	-366(ra) # ae4 <putc>
        putc(fd, c);
 c5a:	85ca                	mv	a1,s2
 c5c:	8556                	mv	a0,s5
 c5e:	00000097          	auipc	ra,0x0
 c62:	e86080e7          	jalr	-378(ra) # ae4 <putc>
      }
      state = 0;
 c66:	4981                	li	s3,0
 c68:	b765                	j	c10 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 c6a:	008b0913          	addi	s2,s6,8
 c6e:	4685                	li	a3,1
 c70:	4629                	li	a2,10
 c72:	000b2583          	lw	a1,0(s6)
 c76:	8556                	mv	a0,s5
 c78:	00000097          	auipc	ra,0x0
 c7c:	e8e080e7          	jalr	-370(ra) # b06 <printint>
 c80:	8b4a                	mv	s6,s2
      state = 0;
 c82:	4981                	li	s3,0
 c84:	b771                	j	c10 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 c86:	008b0913          	addi	s2,s6,8
 c8a:	4681                	li	a3,0
 c8c:	4629                	li	a2,10
 c8e:	000b2583          	lw	a1,0(s6)
 c92:	8556                	mv	a0,s5
 c94:	00000097          	auipc	ra,0x0
 c98:	e72080e7          	jalr	-398(ra) # b06 <printint>
 c9c:	8b4a                	mv	s6,s2
      state = 0;
 c9e:	4981                	li	s3,0
 ca0:	bf85                	j	c10 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 ca2:	008b0913          	addi	s2,s6,8
 ca6:	4681                	li	a3,0
 ca8:	4641                	li	a2,16
 caa:	000b2583          	lw	a1,0(s6)
 cae:	8556                	mv	a0,s5
 cb0:	00000097          	auipc	ra,0x0
 cb4:	e56080e7          	jalr	-426(ra) # b06 <printint>
 cb8:	8b4a                	mv	s6,s2
      state = 0;
 cba:	4981                	li	s3,0
 cbc:	bf91                	j	c10 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 cbe:	008b0793          	addi	a5,s6,8
 cc2:	f8f43423          	sd	a5,-120(s0)
 cc6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 cca:	03000593          	li	a1,48
 cce:	8556                	mv	a0,s5
 cd0:	00000097          	auipc	ra,0x0
 cd4:	e14080e7          	jalr	-492(ra) # ae4 <putc>
  putc(fd, 'x');
 cd8:	85ea                	mv	a1,s10
 cda:	8556                	mv	a0,s5
 cdc:	00000097          	auipc	ra,0x0
 ce0:	e08080e7          	jalr	-504(ra) # ae4 <putc>
 ce4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ce6:	03c9d793          	srli	a5,s3,0x3c
 cea:	97de                	add	a5,a5,s7
 cec:	0007c583          	lbu	a1,0(a5)
 cf0:	8556                	mv	a0,s5
 cf2:	00000097          	auipc	ra,0x0
 cf6:	df2080e7          	jalr	-526(ra) # ae4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 cfa:	0992                	slli	s3,s3,0x4
 cfc:	397d                	addiw	s2,s2,-1
 cfe:	fe0914e3          	bnez	s2,ce6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 d02:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 d06:	4981                	li	s3,0
 d08:	b721                	j	c10 <vprintf+0x60>
        s = va_arg(ap, char*);
 d0a:	008b0993          	addi	s3,s6,8
 d0e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 d12:	02090163          	beqz	s2,d34 <vprintf+0x184>
        while(*s != 0){
 d16:	00094583          	lbu	a1,0(s2)
 d1a:	c9a1                	beqz	a1,d6a <vprintf+0x1ba>
          putc(fd, *s);
 d1c:	8556                	mv	a0,s5
 d1e:	00000097          	auipc	ra,0x0
 d22:	dc6080e7          	jalr	-570(ra) # ae4 <putc>
          s++;
 d26:	0905                	addi	s2,s2,1
        while(*s != 0){
 d28:	00094583          	lbu	a1,0(s2)
 d2c:	f9e5                	bnez	a1,d1c <vprintf+0x16c>
        s = va_arg(ap, char*);
 d2e:	8b4e                	mv	s6,s3
      state = 0;
 d30:	4981                	li	s3,0
 d32:	bdf9                	j	c10 <vprintf+0x60>
          s = "(null)";
 d34:	00000917          	auipc	s2,0x0
 d38:	47c90913          	addi	s2,s2,1148 # 11b0 <malloc+0x336>
        while(*s != 0){
 d3c:	02800593          	li	a1,40
 d40:	bff1                	j	d1c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 d42:	008b0913          	addi	s2,s6,8
 d46:	000b4583          	lbu	a1,0(s6)
 d4a:	8556                	mv	a0,s5
 d4c:	00000097          	auipc	ra,0x0
 d50:	d98080e7          	jalr	-616(ra) # ae4 <putc>
 d54:	8b4a                	mv	s6,s2
      state = 0;
 d56:	4981                	li	s3,0
 d58:	bd65                	j	c10 <vprintf+0x60>
        putc(fd, c);
 d5a:	85d2                	mv	a1,s4
 d5c:	8556                	mv	a0,s5
 d5e:	00000097          	auipc	ra,0x0
 d62:	d86080e7          	jalr	-634(ra) # ae4 <putc>
      state = 0;
 d66:	4981                	li	s3,0
 d68:	b565                	j	c10 <vprintf+0x60>
        s = va_arg(ap, char*);
 d6a:	8b4e                	mv	s6,s3
      state = 0;
 d6c:	4981                	li	s3,0
 d6e:	b54d                	j	c10 <vprintf+0x60>
    }
  }
}
 d70:	70e6                	ld	ra,120(sp)
 d72:	7446                	ld	s0,112(sp)
 d74:	74a6                	ld	s1,104(sp)
 d76:	7906                	ld	s2,96(sp)
 d78:	69e6                	ld	s3,88(sp)
 d7a:	6a46                	ld	s4,80(sp)
 d7c:	6aa6                	ld	s5,72(sp)
 d7e:	6b06                	ld	s6,64(sp)
 d80:	7be2                	ld	s7,56(sp)
 d82:	7c42                	ld	s8,48(sp)
 d84:	7ca2                	ld	s9,40(sp)
 d86:	7d02                	ld	s10,32(sp)
 d88:	6de2                	ld	s11,24(sp)
 d8a:	6109                	addi	sp,sp,128
 d8c:	8082                	ret

0000000000000d8e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 d8e:	715d                	addi	sp,sp,-80
 d90:	ec06                	sd	ra,24(sp)
 d92:	e822                	sd	s0,16(sp)
 d94:	1000                	addi	s0,sp,32
 d96:	e010                	sd	a2,0(s0)
 d98:	e414                	sd	a3,8(s0)
 d9a:	e818                	sd	a4,16(s0)
 d9c:	ec1c                	sd	a5,24(s0)
 d9e:	03043023          	sd	a6,32(s0)
 da2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 da6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 daa:	8622                	mv	a2,s0
 dac:	00000097          	auipc	ra,0x0
 db0:	e04080e7          	jalr	-508(ra) # bb0 <vprintf>
}
 db4:	60e2                	ld	ra,24(sp)
 db6:	6442                	ld	s0,16(sp)
 db8:	6161                	addi	sp,sp,80
 dba:	8082                	ret

0000000000000dbc <printf>:

void
printf(const char *fmt, ...)
{
 dbc:	711d                	addi	sp,sp,-96
 dbe:	ec06                	sd	ra,24(sp)
 dc0:	e822                	sd	s0,16(sp)
 dc2:	1000                	addi	s0,sp,32
 dc4:	e40c                	sd	a1,8(s0)
 dc6:	e810                	sd	a2,16(s0)
 dc8:	ec14                	sd	a3,24(s0)
 dca:	f018                	sd	a4,32(s0)
 dcc:	f41c                	sd	a5,40(s0)
 dce:	03043823          	sd	a6,48(s0)
 dd2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 dd6:	00840613          	addi	a2,s0,8
 dda:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 dde:	85aa                	mv	a1,a0
 de0:	4505                	li	a0,1
 de2:	00000097          	auipc	ra,0x0
 de6:	dce080e7          	jalr	-562(ra) # bb0 <vprintf>
}
 dea:	60e2                	ld	ra,24(sp)
 dec:	6442                	ld	s0,16(sp)
 dee:	6125                	addi	sp,sp,96
 df0:	8082                	ret

0000000000000df2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 df2:	1141                	addi	sp,sp,-16
 df4:	e422                	sd	s0,8(sp)
 df6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 df8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 dfc:	00000797          	auipc	a5,0x0
 e00:	3d47b783          	ld	a5,980(a5) # 11d0 <freep>
 e04:	a805                	j	e34 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 e06:	4618                	lw	a4,8(a2)
 e08:	9db9                	addw	a1,a1,a4
 e0a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e0e:	6398                	ld	a4,0(a5)
 e10:	6318                	ld	a4,0(a4)
 e12:	fee53823          	sd	a4,-16(a0)
 e16:	a091                	j	e5a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 e18:	ff852703          	lw	a4,-8(a0)
 e1c:	9e39                	addw	a2,a2,a4
 e1e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 e20:	ff053703          	ld	a4,-16(a0)
 e24:	e398                	sd	a4,0(a5)
 e26:	a099                	j	e6c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e28:	6398                	ld	a4,0(a5)
 e2a:	00e7e463          	bltu	a5,a4,e32 <free+0x40>
 e2e:	00e6ea63          	bltu	a3,a4,e42 <free+0x50>
{
 e32:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e34:	fed7fae3          	bgeu	a5,a3,e28 <free+0x36>
 e38:	6398                	ld	a4,0(a5)
 e3a:	00e6e463          	bltu	a3,a4,e42 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e3e:	fee7eae3          	bltu	a5,a4,e32 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 e42:	ff852583          	lw	a1,-8(a0)
 e46:	6390                	ld	a2,0(a5)
 e48:	02059713          	slli	a4,a1,0x20
 e4c:	9301                	srli	a4,a4,0x20
 e4e:	0712                	slli	a4,a4,0x4
 e50:	9736                	add	a4,a4,a3
 e52:	fae60ae3          	beq	a2,a4,e06 <free+0x14>
    bp->s.ptr = p->s.ptr;
 e56:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 e5a:	4790                	lw	a2,8(a5)
 e5c:	02061713          	slli	a4,a2,0x20
 e60:	9301                	srli	a4,a4,0x20
 e62:	0712                	slli	a4,a4,0x4
 e64:	973e                	add	a4,a4,a5
 e66:	fae689e3          	beq	a3,a4,e18 <free+0x26>
  } else
    p->s.ptr = bp;
 e6a:	e394                	sd	a3,0(a5)
  freep = p;
 e6c:	00000717          	auipc	a4,0x0
 e70:	36f73223          	sd	a5,868(a4) # 11d0 <freep>
}
 e74:	6422                	ld	s0,8(sp)
 e76:	0141                	addi	sp,sp,16
 e78:	8082                	ret

0000000000000e7a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 e7a:	7139                	addi	sp,sp,-64
 e7c:	fc06                	sd	ra,56(sp)
 e7e:	f822                	sd	s0,48(sp)
 e80:	f426                	sd	s1,40(sp)
 e82:	f04a                	sd	s2,32(sp)
 e84:	ec4e                	sd	s3,24(sp)
 e86:	e852                	sd	s4,16(sp)
 e88:	e456                	sd	s5,8(sp)
 e8a:	e05a                	sd	s6,0(sp)
 e8c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e8e:	02051493          	slli	s1,a0,0x20
 e92:	9081                	srli	s1,s1,0x20
 e94:	04bd                	addi	s1,s1,15
 e96:	8091                	srli	s1,s1,0x4
 e98:	0014899b          	addiw	s3,s1,1
 e9c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 e9e:	00000517          	auipc	a0,0x0
 ea2:	33253503          	ld	a0,818(a0) # 11d0 <freep>
 ea6:	c515                	beqz	a0,ed2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ea8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 eaa:	4798                	lw	a4,8(a5)
 eac:	02977f63          	bgeu	a4,s1,eea <malloc+0x70>
 eb0:	8a4e                	mv	s4,s3
 eb2:	0009871b          	sext.w	a4,s3
 eb6:	6685                	lui	a3,0x1
 eb8:	00d77363          	bgeu	a4,a3,ebe <malloc+0x44>
 ebc:	6a05                	lui	s4,0x1
 ebe:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ec2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ec6:	00000917          	auipc	s2,0x0
 eca:	30a90913          	addi	s2,s2,778 # 11d0 <freep>
  if(p == (char*)-1)
 ece:	5afd                	li	s5,-1
 ed0:	a88d                	j	f42 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 ed2:	00000797          	auipc	a5,0x0
 ed6:	30678793          	addi	a5,a5,774 # 11d8 <base>
 eda:	00000717          	auipc	a4,0x0
 ede:	2ef73b23          	sd	a5,758(a4) # 11d0 <freep>
 ee2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ee4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ee8:	b7e1                	j	eb0 <malloc+0x36>
      if(p->s.size == nunits)
 eea:	02e48b63          	beq	s1,a4,f20 <malloc+0xa6>
        p->s.size -= nunits;
 eee:	4137073b          	subw	a4,a4,s3
 ef2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ef4:	1702                	slli	a4,a4,0x20
 ef6:	9301                	srli	a4,a4,0x20
 ef8:	0712                	slli	a4,a4,0x4
 efa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 efc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 f00:	00000717          	auipc	a4,0x0
 f04:	2ca73823          	sd	a0,720(a4) # 11d0 <freep>
      return (void*)(p + 1);
 f08:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f0c:	70e2                	ld	ra,56(sp)
 f0e:	7442                	ld	s0,48(sp)
 f10:	74a2                	ld	s1,40(sp)
 f12:	7902                	ld	s2,32(sp)
 f14:	69e2                	ld	s3,24(sp)
 f16:	6a42                	ld	s4,16(sp)
 f18:	6aa2                	ld	s5,8(sp)
 f1a:	6b02                	ld	s6,0(sp)
 f1c:	6121                	addi	sp,sp,64
 f1e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 f20:	6398                	ld	a4,0(a5)
 f22:	e118                	sd	a4,0(a0)
 f24:	bff1                	j	f00 <malloc+0x86>
  hp->s.size = nu;
 f26:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 f2a:	0541                	addi	a0,a0,16
 f2c:	00000097          	auipc	ra,0x0
 f30:	ec6080e7          	jalr	-314(ra) # df2 <free>
  return freep;
 f34:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 f38:	d971                	beqz	a0,f0c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f3a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f3c:	4798                	lw	a4,8(a5)
 f3e:	fa9776e3          	bgeu	a4,s1,eea <malloc+0x70>
    if(p == freep)
 f42:	00093703          	ld	a4,0(s2)
 f46:	853e                	mv	a0,a5
 f48:	fef719e3          	bne	a4,a5,f3a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 f4c:	8552                	mv	a0,s4
 f4e:	00000097          	auipc	ra,0x0
 f52:	b76080e7          	jalr	-1162(ra) # ac4 <sbrk>
  if(p == (char*)-1)
 f56:	fd5518e3          	bne	a0,s5,f26 <malloc+0xac>
        return 0;
 f5a:	4501                	li	a0,0
 f5c:	bf45                	j	f0c <malloc+0x92>
