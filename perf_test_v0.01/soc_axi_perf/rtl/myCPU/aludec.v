`include "defines.vh"

module aludec(
	input wire[31:0] instr,
	output reg[7:0] alucontrol
    );

	wire[5:0] op;
	wire[5:0] funct;
	wire[4:0] rs;

	assign op = instr[31:26];
	assign funct = instr[5:0];
	assign rs = instr[25:21];

	always @(*) begin
		case (op) 
			//memory inst
			`EXE_LB: alucontrol <= `EXE_LB_OP;
			`EXE_LBU: alucontrol <= `EXE_LBU_OP;
			`EXE_LH: alucontrol <= `EXE_LHU_OP;
			`EXE_LHU: alucontrol <= `EXE_LHU_OP;
			`EXE_LW: alucontrol <= `EXE_LW_OP;
			`EXE_SB: alucontrol <= `EXE_SB_OP;
			`EXE_SH: alucontrol <= `EXE_SH_OP;
			`EXE_SW: alucontrol <= `EXE_SW_OP;
			//logic inst
			`EXE_ANDI: alucontrol <= `EXE_ANDI_OP;
			`EXE_ORI: alucontrol <= `EXE_ORI_OP;
			`EXE_XORI: alucontrol <= `EXE_XORI_OP;
			`EXE_LUI: alucontrol <= `EXE_LUI_OP;
			//arithmetic inst
			`EXE_ADDI: alucontrol <= `EXE_ADDI_OP;
			`EXE_ADDIU: alucontrol <= `EXE_ADDIU_OP;
			`EXE_SLTI: alucontrol <= `EXE_SLTI_OP;
			`EXE_SLTIU: alucontrol <= `EXE_SLTIU_OP;
			//branch inst
			`EXE_J: alucontrol <= `EXE_J_OP;
			`EXE_JAL: alucontrol <= `EXE_JAL_OP;
			`EXE_BEQ: alucontrol <= `EXE_BEQ_OP;
			`EXE_BGTZ: alucontrol <= `EXE_BGTZ_OP;
			`EXE_BLEZ: alucontrol <= `EXE_BLEZ_OP;
			`EXE_BNE: alucontrol <= `EXE_BNE_OP;
			`EXE_SPECIAL_INST: case (funct)
				//logic inst
				`EXE_AND: alucontrol <= `EXE_AND_OP;
				`EXE_OR: alucontrol <= `EXE_OR_OP;
				`EXE_XOR: alucontrol <= `EXE_XOR_OP;
				`EXE_NOR: alucontrol <= `EXE_NOR_OP;
				//shift inst
				`EXE_SLL: alucontrol <= `EXE_SLL_OP;
				`EXE_SLLV: alucontrol <= `EXE_SLLV_OP;
				`EXE_SRL: alucontrol <= `EXE_SRL_OP;
				`EXE_SRLV: alucontrol <= `EXE_SRLV_OP;
				`EXE_SRA: alucontrol <= `EXE_SRA_OP;
				`EXE_SRAV: alucontrol <= `EXE_SRAV_OP;
				//move inst
				`EXE_MFHI: alucontrol <= `EXE_MFHI_OP;
				`EXE_MFLO: alucontrol <= `EXE_MFLO_OP;
				`EXE_MTHI: alucontrol <= `EXE_MTHI_OP;
				`EXE_MTLO: alucontrol <= `EXE_MTLO_OP;
				//arithmetic inst
				`EXE_ADD: alucontrol <= `EXE_ADD_OP;
				`EXE_ADDU: alucontrol <= `EXE_ADDU_OP;
				`EXE_SUB: alucontrol <= `EXE_SUB_OP;
				`EXE_SUBU: alucontrol <= `EXE_SUBU_OP;
				`EXE_SLT: alucontrol <= `EXE_SLT_OP;
				`EXE_SLTU: alucontrol <= `EXE_SLTU_OP;
				`EXE_MULT: alucontrol <= `EXE_MULT_OP;
				`EXE_MULTU: alucontrol <= `EXE_MULTU_OP;
				`EXE_DIV: alucontrol <= `EXE_DIV_OP;
				`EXE_DIVU: alucontrol <= `EXE_DIVU_OP;
				//branch inst
				`EXE_JR: alucontrol <= `EXE_JR_OP;
				`EXE_JALR: alucontrol <= `EXE_JALR_OP;
				//invagination inst
				`EXE_BREAK: alucontrol <= `EXE_BREAK_OP;
				`EXE_SYSCALL: alucontrol <= `EXE_SYSCALL_OP;
				default: alucontrol <= 8'b0;
			endcase 
			`EXE_REGIMM_INST: case (funct)
				`EXE_BLTZ: alucontrol <= `EXE_BLTZ_OP;
				`EXE_BLTZAL: alucontrol <= `EXE_BLTZAL_OP; 
				`EXE_BGEZ: alucontrol <= `EXE_BGEZ_OP;
				`EXE_BGEZAL: alucontrol <= `EXE_BGEZAL_OP;
				default: alucontrol <= 8'b0;
			endcase	
			6'b010000: case (rs)
				5'b00100: alucontrol <= `EXE_MTC0_OP;
				5'b00000: alucontrol <= `EXE_MFC0_OP;
				5'b10000: alucontrol <= `EXE_ERET_OP;
				default: alucontrol <= 8'b0;
			endcase 
		endcase
	
	end
endmodule