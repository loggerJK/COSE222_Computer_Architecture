//
//  Author: Prof. Taeweon Suh
//          Computer Science & Engineering
//          Korea University
//  Date: July 14, 2020
//  Description: Skeleton design of RV32I Single-cycle CPU
//

`timescale 1ns/1ns
`define simdelay 1

module rv32i_cpu (
		      input         clk, reset,
            output [31:0] pc,		  		// program counter for instruction fetch
            input  [31:0] inst, 			// incoming instruction
            output        Memwrite, 	// 'memory write' control signal
            output [31:0] Memaddr,  	// memory address 
            output [31:0] MemWdata, 	// data to write to memory
            input  [31:0] MemRdata); 	// data read from memory

  wire        auipc, lui;
  wire        alusrc, regwrite;
  wire [4:0]  alucontrol;
  wire        memtoreg, memwrite;
  wire        branch, jal, jalr;
  wire [31:0] inst_dec_mux;   // add inst_dec
  wire        memwrite_mem;

  assign Memwrite = memwrite_mem ;

  // Instantiate Controller
  controller i_controller(
    // ########### Jiwon Kang : Start ###########
      .opcode		(inst_dec_mux[6:0]), 
		.funct7		(inst_dec_mux[31:25]), 
		.funct3		(inst_dec_mux[14:12]), 
    // ########### Jiwon Kang : End ###########
		.auipc		(auipc),
		.lui			(lui),
		.memtoreg	(memtoreg),
		.memwrite	(memwrite),
		.branch		(branch),
		.alusrc		(alusrc),
		.regwrite	(regwrite),
		.jal			(jal),
		.jalr			(jalr),
		.alucontrol	(alucontrol));

  // Instantiate Datapath
  datapath i_datapath(
		.clk				(clk),
		.reset			(reset),
		.auipc			(auipc),
		.lui				(lui),
		.memtoreg		(memtoreg),
		.memwrite		(memwrite),
		.branch			(branch),
		.alusrc			(alusrc),
		.regwrite		(regwrite),
		.jal				(jal),
		.jalr				(jalr),
		.alucontrol		(alucontrol),
    .inst_dec_mux   (inst_dec_mux), // add inst_dec
		.pc				(pc),
		.inst				(inst),
		.aluout_mem			(Memaddr),  // aluout --> aluout_mem
    .memwrite_mem (memwrite_mem),
		.MemWdata		(MemWdata), 
		.MemRdata		(MemRdata));

endmodule


//
// Instruction Decoder 
// to generate control signals for datapath
//
module controller(input  [6:0] opcode,
                  input  [6:0] funct7,
                  input  [2:0] funct3,
                  output       auipc,
                  output       lui,
                  output       alusrc,
                  output [4:0] alucontrol,
                  output       branch,
                  output       jal,
                  output       jalr,
                  output       memtoreg,
                  output       memwrite,
                  output       regwrite);

	maindec i_maindec(
		.opcode		(opcode),
		.auipc		(auipc),
		.lui			(lui),
		.memtoreg	(memtoreg),
		.memwrite	(memwrite),
		.branch		(branch),
		.alusrc		(alusrc),
		.regwrite	(regwrite),
		.jal			(jal),
		.jalr			(jalr));

	aludec i_aludec( 
		.opcode     (opcode),
		.funct7     (funct7),
		.funct3     (funct3),
		.alucontrol (alucontrol));


endmodule


//
// RV32I Opcode map = Inst[6:0]
//
`define OP_R			7'b0110011
`define OP_I_ARITH	7'b0010011
`define OP_I_LOAD  	7'b0000011
`define OP_I_JALR  	7'b1100111
`define OP_S			7'b0100011
`define OP_B			7'b1100011
`define OP_U_LUI		7'b0110111
`define OP_J_JAL		7'b1101111
`define NOP         8'h00000013

//
// Main decoder generates all control signals except alucontrol 
//
//
module maindec(input  [6:0] opcode,
               output       auipc,
               output       lui,
               output       regwrite,
               output       alusrc,
               output       memtoreg, memwrite,
               output       branch, 
               output       jal,
               output       jalr);

  reg [8:0] controls;

  assign {auipc, lui, regwrite, alusrc, 
			 memtoreg, memwrite, branch, jal, 
			 jalr} = controls;

  always @(*)
  begin
    case(opcode)
      `OP_R: 			  controls <= #`simdelay 9'b0010_0000_0; // R-type
      `OP_I_ARITH: 	controls <= #`simdelay 9'b0011_0000_0; // I-type Arithmetic
      `OP_I_LOAD: 	controls <= #`simdelay 9'b0011_1000_0; // I-type Load
      `OP_S: 			  controls <= #`simdelay 9'b0001_0100_0; // S-type Store
      `OP_B: 			  controls <= #`simdelay 9'b0000_0010_0; // B-type Branch
      `OP_U_LUI: 		controls <= #`simdelay 9'b0111_0000_0; // LUI
      `OP_J_JAL: 		controls <= #`simdelay 9'b0011_0001_0; // JAL
      `OP_I_JALR:   controls <= #`simdelay 9'b0011_0000_1; // JALR
      default:    	controls <= #`simdelay 9'b0000_0000_0; // ???
    endcase
  end

endmodule

//
// ALU decoder generates ALU control signal (alucontrol)
//
module aludec(input      [6:0] opcode,
              input      [6:0] funct7,
              input      [2:0] funct3,
              output reg [4:0] alucontrol);

  always @(*)
  // alucontrol : determines ALU operations
    case(opcode)

      `OP_R:   		// R-type
		begin
			case({funct7,funct3})
			 10'b0000000_000: alucontrol <= #`simdelay 5'b00000; // addition (add)
			 10'b0100000_000: alucontrol <= #`simdelay 5'b10000; // subtraction (sub)
			 10'b0000000_111: alucontrol <= #`simdelay 5'b00001; // and (and)
			 10'b0000000_110: alucontrol <= #`simdelay 5'b00010; // or (or)
       10'b0000000_100: alucontrol <= #`simdelay 5'b00011; // xor
       // ########### Jiwon Kang : Start ###########
			 10'b0000000_001: alucontrol <= #`simdelay 5'b00100; // shift-left logical (sll)
       // ########### Jiwon Kang : End ###########
          default:         alucontrol <= #`simdelay 5'bxxxxx; // ???
        endcase
		end

      `OP_I_ARITH:   // I-type Arithmetic
		begin
			case(funct3)
			 3'b000:  alucontrol <= #`simdelay 5'b00000; // addition (addi)
			 3'b110:  alucontrol <= #`simdelay 5'b00010; // or (ori)
			 3'b111:  alucontrol <= #`simdelay 5'b00001; // and (andi)
       3'b100:  alucontrol <= #`simdelay 5'b00011; // xori
       // ########### Jiwon Kang : Start ###########
			 3'b001:  alucontrol <= #`simdelay 5'b00100; // slli
       // ########### Jiwon Kang : End ###########

          default: alucontrol <= #`simdelay 5'bxxxxx; // ???
        endcase
		end

      `OP_I_LOAD: 	// I-type Load (LW, LH, LB...)
      	alucontrol <= #`simdelay 5'b00000;  // addition 

      `OP_B:   		// B-type Branch (BEQ, BNE, ...)
      	alucontrol <= #`simdelay 5'b10000;  // subtraction 

      `OP_S:   		// S-type Store (SW, SH, SB)
      	alucontrol <= #`simdelay 5'b00000;  // addition 

      `OP_U_LUI: 		// U-type (LUI)
      	alucontrol <= #`simdelay 5'b00000;  // addition

      default: 
      	alucontrol <= #`simdelay 5'b00000;  // jal, jalr

    endcase
    
endmodule


//
// CPU datapath
//
module datapath(input         clk, reset,
                input  [31:0] inst,
                input         auipc,
                input         lui,
                input         regwrite,
                input         memtoreg,
                input         memwrite,
                input         alusrc, 
                input  [4:0]  alucontrol,
                input         branch,
                input         jal,
                input         jalr,
                output reg [31:0] inst_dec_mux,
                output reg [31:0] pc,
                output reg [31:0] aluout_mem, // change to mem
                output reg memwrite_mem,
                output [31:0] MemWdata,   // rs2_data_mem
                input  [31:0] MemRdata);

  wire [4:0]  rs1, rs2, rd;
  wire [6:0]  opcode; // opcode wire
  wire [2:0]  funct3;
  wire [31:0] rs1_data, rs2_data;
  reg  [31:0] rd_data;
  wire [20:1] jal_imm;
  wire [31:0] se_jal_imm;
  wire [12:1] br_imm;
  wire [31:0] se_br_imm;
  wire [31:0] se_imm_itype;
  wire [31:0] se_imm_stype;
  wire [31:0] auipc_lui_imm;
  reg  [31:0] alusrc1;
  reg  [31:0] alusrc2;
  wire [31:0] branch_dest, jal_dest;
  wire		  Nflag, Zflag, Cflag, Vflag;
  wire		  f3beq, f3blt, f3bge, f3bgeu, f3bne;
  wire		  beq_taken;
  wire		  blt_taken;
  wire      bge_taken, bgeu_taken;
  wire      bne_taken, b_taken;

  assign rs1 = inst_dec_mux[19:15];
  assign rs2 = inst_dec_mux[24:20];
  assign opcode = inst_dec_mux[6:0]; // assign opcode
  assign rd  = inst_dec_mux[11:7];
  assign funct3  = inst_dec_mux[14:12];

// ########### Jiwon Kang : Start ###########

reg [31:0] pc_dec, pc_exe, pc_mem, pc_wb;
reg memtoreg_exe, memtoreg_mem, memtoreg_wb;
reg regwrite_exe, regwrite_mem, regwrite_wb;
reg branch_exe, branch_mem;
reg memwrite_exe;
reg [4:0] alucontrol_exe;
reg alusrc_exe, alusrc_mem, alusrc_wb, auipc_exe, lui_exe, jal_exe, jalr_exe;

reg [4:0] rs1_exe, rs2_exe, rd_exe, rs1_mem, rs2_mem, rd_mem, rd_wb;
reg [31:0] se_imm_itype_exe, se_imm_stype_exe, auipc_lui_imm_exe, se_jal_imm_exe, se_br_imm_exe, rs1_data_exe, rs2_data_exe, branch_dest_mem, jal_dest_mem, MemRdata_wb, aluout_wb, rs2_data_mem, inst_exe, inst_mem, inst_wb, inst_dec, inst_mux;
reg Nflag_mem, Zflag_mem, Cflag_mem, Vflag_mem;
reg ff_enable, pc_enable;
reg [2:0] funct3_exe, funct3_mem;
reg jal_mem, jal_wb, jalr_mem, jalr_wb;
reg mux_rs1_data_rd_data, mux_rs2_data_rd_data, mux_alusrc1_aluout_mem, mux_alusrc1_rd_data, mux_alusrc2_aluout_mem, mux_rs2_data_exe_rd_data;
reg[6:0] opcode_exe, opcode_mem;
reg [31:0] rs1_data_mux, rs2_data_mux, rs2_data_exe_mux;
wire [31:0] aluout;


// fetch --> dec
  always @(posedge clk)
  begin
    if (ff_enable !== 1'b0)
    begin
      pc_dec <= pc;
      inst_dec <= inst_mux;
    end
  end

  // dec --> ex
  always @(posedge clk)
  begin
    // Control Signal
    inst_exe <= inst_dec_mux;
    pc_exe <= pc_dec;
    opcode_exe <= opcode;
    memtoreg_exe <= memtoreg;
    if (ff_enable !== 1'b0) regwrite_exe <= regwrite;
    else regwrite_exe <= 1'b0;
    if (ff_enable !== 1'b0) memwrite_exe <= memwrite;
    else memwrite_exe <= 1'b0;
    branch_exe <= branch;
    alucontrol_exe <= alucontrol;
    alusrc_exe <= alusrc;
    auipc_exe <= auipc;
    lui_exe <= lui;
    funct3_exe <= funct3;
    jal_exe <= jal;
    jalr_exe  <= jalr;

    // Register
    rs1_exe <= rs1;
    rs2_exe <= rs2;
    rd_exe <= rd;

    // Register Ouput
    rs1_data_exe <= rs1_data_mux;
    rs2_data_exe <= rs2_data_mux;

    // Sign Extended immediates
    se_imm_itype_exe <= se_imm_itype;
    se_imm_stype_exe <= se_imm_stype;
    auipc_lui_imm_exe <= auipc_lui_imm;
    se_jal_imm_exe <= se_jal_imm;
    se_br_imm_exe <= se_br_imm;
  end

  // exe --> mem
  always @(posedge clk)
  begin
    // Control Signal
    inst_mem <= inst_exe;
    alusrc_mem <= alusrc_exe;
    opcode_mem <= opcode_exe;
    pc_mem <= pc_exe;
    branch_mem <= branch_exe;
    funct3_mem <= funct3_exe;
    memwrite_mem <= memwrite_exe;
    regwrite_mem <= regwrite_exe;
    memtoreg_mem <= memtoreg_exe;
    jal_mem <= jal_exe;
    jalr_mem  <= jalr_exe;

    // Register
    rs1_mem <= rs1_exe;
    rs2_mem <= rs2_exe;
    rd_mem <= rd_exe;

    // branch src
    branch_dest_mem <= branch_dest;
    jal_dest_mem <= jal_dest;

    // ALU Output
    aluout_mem <= aluout;
    Nflag_mem <= Nflag;
    Zflag_mem <= Zflag;
    Cflag_mem <= Cflag;
    Vflag_mem <= Vflag;

    rs2_data_mem <= rs2_data_exe_mux;

  end

  // mem --> wb
  always @(posedge clk)
  begin
    // Control Signal
    inst_wb <= inst_mem;
    alusrc_wb <= alusrc_mem;
    pc_wb <= pc_mem;
    regwrite_wb <= regwrite_mem;
    memtoreg_wb <= memtoreg_mem;
    jal_wb <= jal_mem;
    jalr_wb  <= jalr_mem;

    // Register
    rd_wb <= rd_mem;

    //
    MemRdata_wb <= MemRdata;
    aluout_wb <= aluout_mem;
  end


  // ########### Jiwon Kang : For Data Hazard ###########

  always @(*)
  begin
    // First : Mem to exe
    // ALU에 의해 업데이트되는 register value가 나중에 필요한 경우
    begin
      if (regwrite_mem == 1'b1 && rd_mem == rs1_exe) mux_alusrc1_aluout_mem <= 1'b1;  // put aluout_mem to alusrc1
      else  mux_alusrc1_aluout_mem <= 1'b0;  
    end
    begin
      if (regwrite_mem == 1'b1 && rd_mem == rs2_exe) mux_alusrc2_aluout_mem <= 1'b1;  // put aluout_mem to  alursrc2 
      else  mux_alusrc2_aluout_mem <= 1'b0;  
    end
    // Second : WB to exe
    begin
      if (regwrite_wb == 1'b1 && rd_wb == rs1_exe) mux_alusrc1_rd_data <= 1'b1; 
      else mux_alusrc1_rd_data <= 1'b0;
    end
    begin
      if (regwrite_wb == 1'b1 && rd_wb == rs2_exe) mux_rs2_data_exe_rd_data <= 1'b1;
      else mux_rs2_data_exe_rd_data <= 1'b0;
    end
    // Third : WB to dec, updated register value = rd_data, if this maches with rs1_data or rs2_data, assign.
    begin
      if (regwrite_wb == 1'b1 && rd_wb == rs1) mux_rs1_data_rd_data <= 1'b1;
      else mux_rs1_data_rd_data <= 1'b0;
    end
    begin
      if (regwrite_wb == 1'b1 && rd_wb == rs2) mux_rs2_data_rd_data <= 1'b1;
      else mux_rs2_data_rd_data <= 1'b0;
    end
  end


   // load inst hazard detection unit
  always @(*)
  begin
    if ((opcode_exe == `OP_I_LOAD) && ((rd_exe == rs1) || (rd_exe == rs2))) 
    begin
        // Control Signal 0 -> Make EX nop
        ff_enable <= 1'b0;
        pc_enable <= 1'b0;
    end
    else 
    begin
        ff_enable <= 1'b1;
        pc_enable <= 1'b1;
    end
  end

  // ########### Jiwon Kang : End ###########

 // ########### Jiwon Kang : MUX WB -> Dec###########
always @(*)
begin
  if (mux_rs1_data_rd_data === 1'b1) rs1_data_mux <= rd_data;
  else                   rs1_data_mux <= rs1_data;
end

always @(*)
begin
  if (mux_rs2_data_rd_data === 1'b1) rs2_data_mux <= rd_data;
  else                   rs2_data_mux <= rs2_data;
end

 // rs2_data_exe Mux at EXE
  always @(*)
  begin
    if (mux_rs2_data_exe_rd_data) rs2_data_exe_mux <= rd_data;
    else rs2_data_exe_mux <= rs2_data_exe;
  end
  //
// ########### Jiwon Kang : End ###########

  // PC (Program Counter) logic 
  //
  assign f3beq  = (funct3_exe == 3'b000);
  assign f3blt  = (funct3_exe == 3'b100);
  assign f3bge  = (funct3_exe == 3'b101);
  assign f3bgeu = (funct3_exe == 3'b111);
  assign f3bne  = (funct3_exe == 3'b001);

  // ########### Jiwon Kang : change to EX variable ###########
  assign beq_taken  =  branch_exe & f3beq & Zflag_mem;
  assign blt_taken  =  branch_exe & f3blt & (Nflag_mem != Vflag_mem);
  assign bge_taken  =  branch_exe & f3bge & (Nflag_mem == Vflag_mem);
  assign bne_taken  =  branch_exe & f3bne & ~Zflag;
  assign bgeu_taken =  branch_exe & f3bgeu & Cflag_mem;
  assign b_taken = beq_taken | blt_taken | bge_taken | bgeu_taken | bne_taken;
  // ########### Jiwon Kang : End ###########



// ########### Jiwon Kang : Start ###########
  assign branch_dest = (pc_exe + se_br_imm_exe);
  assign jal_dest 	= (pc_exe + se_jal_imm_exe);

  always @(posedge clk, posedge reset)
  begin
    if (reset)  pc <= 32'b0;
	  else if (pc_enable !== 1'b0) // only if pc_enable
    // else
	  begin
	      if (b_taken) // branch_taken
				pc <= #`simdelay branch_dest;
        else if (jalr_exe)
        pc <= #`simdelay aluout_mem;
		   else if (jal_exe) /// jal
				pc <= #`simdelay jal_dest;
		   else 
				pc <= #`simdelay (pc + 4);
	  end
  end
// ########### Jiwon Kang : End ###########
  
// ########### Jiwon Kang : Control Hazard ###########

always @(*)
begin
  if (b_taken || jal_exe || jalr_exe)
  begin
    inst_mux <= `NOP;
  end
  else 
  begin
    inst_mux <= inst;
  end
end

always @(*)
begin
  if (b_taken || jal_exe || jalr_exe)
  begin
    inst_dec_mux <= `NOP;
  end
  else 
  begin
    inst_dec_mux <= inst_dec;
  end
end


// ########### Jiwon Kang : End ###########


  // JAL immediate
  assign jal_imm[20:1] = {inst_dec_mux[31],inst_dec_mux[19:12],inst_dec_mux[20],inst_dec_mux[30:21]};
  assign se_jal_imm[31:0] = {{11{jal_imm[20]}},jal_imm[20:1],1'b0};

  // Branch immediate
  assign br_imm[12:1] = {inst_dec_mux[31],inst_dec_mux[7],inst_dec_mux[30:25],inst_dec_mux[11:8]};
  assign se_br_imm[31:0] = {{19{br_imm[12]}},br_imm[12:1],1'b0};



  // 
  // Register File 
  //
  regfile i_regfile(
    .clk			(clk),
    // ########### Jiwon Kang : Start ###########
    .we			(regwrite_wb),
    .rs1			(rs1),
    .rs2			(rs2),
    .rd			(rd_wb),
    // ########### Jiwon Kang : End ###########
    .rd_data	(rd_data),
    .rs1_data	(rs1_data),
    .rs2_data	(rs2_data));


	assign MemWdata = rs2_data_mem;


	//
	// ALU 
	//
	alu i_alu(
		.a			(alusrc1),
		.b			(alusrc2),
		.alucont	(alucontrol_exe),   // Jiwon Kang : change to exe
		.result	(aluout),
		.N			(Nflag),
		.Z			(Zflag),
		.C			(Cflag),
		.V			(Vflag));


// ########### Jiwon Kang : Change to exe, add muxSrc ###########
	// 1st source to ALU (alusrc1)
	always@(*)
	begin
		if      (auipc_exe)	alusrc1[31:0]  =  pc_exe;
		else if (lui_exe) 		alusrc1[31:0]  =  32'b0;
    else if (mux_alusrc1_aluout_mem === 1'b1) alusrc1[31:0] = aluout_mem[31:0];     // first case
    else if (mux_alusrc1_rd_data === 1'b1)  alusrc1[31:0] = rd_data[31:0];    // second case
		else          		alusrc1[31:0]  =  rs1_data_exe[31:0];
	end
	
	// 2nd source to ALU (alusrc2)
	always@(*)
	begin
		if	     (auipc_exe | lui_exe)			alusrc2[31:0] = auipc_lui_imm_exe[31:0];
		else if (alusrc_exe & memwrite_exe)	        alusrc2[31:0] = se_imm_stype_exe[31:0];
		else if (alusrc_exe)					          alusrc2[31:0] = se_imm_itype_exe[31:0];
    else if (mux_alusrc2_aluout_mem === 1'b1)           alusrc2[31:0] = aluout_mem[31:0];
    else if (mux_rs2_data_exe_rd_data === 1'b1)            alusrc2[31:0] = rd_data[31:0];
		else									              alusrc2[31:0] = rs2_data[31:0];
	end
// ########### Jiwon Kang : End ###########
	
	assign se_imm_itype[31:0] = {{20{inst_dec_mux[31]}},inst_dec_mux[31:20]};
	assign se_imm_stype[31:0] = {{20{inst_dec_mux[31]}},inst_dec_mux[31:25],inst_dec_mux[11:7]};
	assign auipc_lui_imm[31:0] = {inst_dec_mux[31:12],12'b0};

// ########### Jiwon Kang : Change to wb ###########
	// Data selection for writing to RF
	always@(*)
	begin
		if	     (jal_wb|jalr_wb)			rd_data[31:0] = pc_wb + 4;
		else if (memtoreg_wb)	rd_data[31:0] = MemRdata_wb;
		else						rd_data[31:0] = aluout_wb;
	end
// ########### Jiwon Kang : End ###########
	
endmodule
