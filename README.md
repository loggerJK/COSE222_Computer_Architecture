# COSE222_Computer_Architecture

<img src="https://img.shields.io/badge/RISC_V-283272?style=flat-square&logo=riscv&logoColor=white"/>

- Assignment & Milestone specifications can be found in `./Specifications`

# Assignments
- Implement & analayze **sorting algorithm w/ RV32I assembly**

# Milestone
- Implement simple **single-cyle RV32I CPU which supports pipelining** (**Verilog**)
- Worked mainly in `Milestones/RV32I_Class_Project_Milestone_*/RV32I_System/RV32I_CPU/rv32i_cpu.v` 

### Milestone2
- Schematic Drawing
![Image](https://i.imgur.com/PhQg8mH.png)
![Image](https://i.imgur.com/Z0WgqSQ.png)


### Milestone3
- Add instructions to the provided single-cycle CPU
- [x] xor(i)
- [x] bge(u)
- [X] jalr
  
### Milestone4
- Implement **Pipelining** w/ **Data hazard detection and handling** logic
1. Insturction
- [x] sll(i)
2. Flipflop insert
3. Simple Forwarding
3. Forwarding Unit
4. Hardware Interlock

### Milestone5
- Add **control hazard detection and handling logic**
- [x] bne
- [x] btaken으로 통합하기
- [x] mux 2개 새로 만들기
- [x] EX 단계로 branch 옮기기
- [x] nop 추가

### Milestone Final
- [x] blt
- [x] bge
