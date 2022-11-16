# 구현되어 있는 것
- [X] add
- [X] addi
- [X] sub
- [X] and
- [X] or
- [X] sltu
- [X] lui
- [X] lw
- [X] sw
- [X] beq
- [x] jal

## Milestone 3

SevenSeg1
- [x] xor(i)
- [x] bge(u)

![Image](https://i.imgur.com/6rlTmsy.png)

SevenSeg2
- [X] jalr

![Image](https://i.imgur.com/cOn6vwa.png)


## Milestone 4
1. Insturction 구현하기
- [x] sll(i)
2. Flipflop insert
3. Simple Forwarding 구현
3. Forwarding Unit
4. Hardware Interlock 구현


문제점
마일스톤 3도 안돌아간다
jump의 구현이 문제인 것으로 보임 -> 마일스톤 5 내용이므로 신경 안쓰기로 함

pc_enable이 0이라서 아예 업데이트가 안됨 : 등가 연산자로 해결

sw 연산자의 경우에도 forwarding / stall 이 필요함을 발견함
sw rs1, rs2, imm 연산자는 이전 3개 instruction을 검사해야함

