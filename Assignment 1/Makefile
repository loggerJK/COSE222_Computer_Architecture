#
#  Makefile to generate RISC-V binary for Computer Architecture class
#
#  Author: Prof. Taeweon Suh
#          Computer Science & Engineering
#	   College of Informatics
#          Korea University
#
#  Date:   2020-06-11
#

    HOME=/home/jiwon/rv32imac
    MIPSBIN=$(HOME)/bin
    AS=$(MIPSBIN)/riscv32-unknown-elf-as		# RISC-V Assembler
    LD=$(MIPSBIN)/riscv32-unknown-elf-ld		# Linker
	CC=$(MIPSBIN)/riscv32-unknown-elf-gcc		# 
	CPP=$(MIPSBIN)/riscv32-unknown-elf-cpp		# C Preprocessor        
    OBJDUMP=$(MIPSBIN)/riscv32-unknown-elf-objdump
    OBJCOPY=$(MIPSBIN)/riscv32-unknown-elf-objcopy
#   ASFLAGS= -Wall -O2 -g
#    ASFLAGS= -g -mips32
    ASFLAGS= -g -march=rv32i
    LDFLAGS= -N -X -Tlabcode.lds
    CCFLAGS= -S -g -march=rv32i					#  Compile only; do not assemble or link.. + Debugging
    
    all: labcode 

    labcode: lab0.o code1.o
	$(LD) $(LDFLAGS)  lab0.o code1.o -o labcode
	$(OBJDUMP) -xS  labcode > labcode.dump
	$(OBJCOPY) -O  binary labcode labcode.bin
	./bin2hex.perl > labcode.hex
	./hex2mif.perl
#	./mipsel-readelf -a labcode > labcode.r
#	./mipsel-nm labcode > labcode.n
	 
    lab0.o: lab0.s
	$(AS) $(ASFLAGS) lab0.s -o lab0.o
	
    code1.o:	code1.c
#	Preprocessing
	$(CPP) code1.c > code1.i
#	Compilation, output = code1.s
	$(CC) $(CCFLAGS) code1.i
#	Assembler
	$(AS) $(ASFLAGS) code1.s -o code1.o
	$(OBJDUMP) -xS  code1.o > code1.dump
	
	
    clean:
	rm -rf *.o *.mif *.dump *.hex *.bin *.mif labcode *.i code1.s code1
