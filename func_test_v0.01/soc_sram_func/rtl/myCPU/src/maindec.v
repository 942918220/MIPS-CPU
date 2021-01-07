`include "defines.vh"

module maindec(
	input wire[31:0] instr,
	output wire memtoreg,
	output wire memwrite,
	output wire memen,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,jal,jr,bal,
	output wire we,signed_div,start_i,
	output wire cp0we,eret,syscall,break,invalid
    );

	wire[5:0] op;
    wire[5:0] funct;
	wire [4:0] rt,rs;

	assign op = instr[31:26];
	assign funct = instr[5:0];
	assign rt = instr[20:16];
	assign rs = instr[25:21];

	//memtoreg:回写的数据来自于存储器读取的数据=1 
	assign memtoreg = ((op == `EXE_LB) ||
					   (op == `EXE_LBU) ||
					   (op == `EXE_LH) ||
					   (op == `EXE_LHU) ||
					   (op == `EXE_LW));
	//memwrite:是否要写数据存储�?=1
	assign memwrite = ((op == `EXE_SB) ||
					   (op == `EXE_SH) ||
					   (op == `EXE_SW));
	//memen:是否使用数据存储=1
	assign memen = ((op == `EXE_LB) || 
					(op == `EXE_LBU) ||
					(op == `EXE_LH) ||
					(op == `EXE_LHU) ||
					(op == `EXE_LW) ||
					(op == `EXE_SB) ||
					(op == `EXE_SH) ||
					(op == `EXE_SW));
	//branch:是否为branch指令，且满足branch的条�?=1 
	assign branch = ((op == `EXE_BEQ) ||
					 (op == `EXE_BNE) ||
					 (op == `EXE_BLEZ) ||
					 (op == `EXE_BGTZ) ||
					 (op == `EXE_REGIMM_INST && rt == `EXE_BLTZ) ||
					 (op == `EXE_REGIMM_INST && rt == `EXE_BLTZAL) ||
					 (op == `EXE_REGIMM_INST && rt == `EXE_BGEZ) ||
					 (op == `EXE_REGIMM_INST && rt == `EXE_BGEZAL));
	//alusrc:送入ALUB端口的是立即数的32位扩�?=1 
	assign alusrc = ((op == `EXE_ANDI) ||
					 (op == `EXE_ORI) ||
					 (op == `EXE_XORI) ||
					 (op == `EXE_LUI) ||
					 (op == `EXE_ADDI) ||
					 (op == `EXE_ADDIU) ||
					 (op == `EXE_SLTI)|| 
					 (op == `EXE_SLTIU) ||
					 (op == `EXE_LB) ||
					 (op == `EXE_LBU) ||
					 (op == `EXE_LH) ||
					 (op == `EXE_LHU) ||
					 (op == `EXE_LW) ||
					 (op == `EXE_SB) ||
					 (op == `EXE_SH) ||
					 (op == `EXE_SW));

	//写入寄存器堆的地�?寄存器是rt还是rd/rd=1				 
	assign regdst = ((op == `EXE_SPECIAL_INST));

	//是否要写寄存器堆
	assign regwrite= (((op == `EXE_SPECIAL_INST) &&
					  (funct != `EXE_MTHI) &&
					  (funct != `EXE_MTLO) &&
					  (funct != `EXE_MULT) &&
					  (funct != `EXE_MULTU) &&
					  (funct != `EXE_DIV) &&
					  (funct != `EXE_DIVU)) ||
					  (op == `EXE_ANDI) ||
					  (op == `EXE_ORI) ||
					  (op == `EXE_XORI) ||
					  (op == `EXE_LUI) ||
					  (op == `EXE_ADDI) ||
					  (op == `EXE_ADDIU) ||
					  (op == `EXE_SLTI) ||
					  (op == `EXE_SLTIU) ||
					  (op == `EXE_JALR) ||
					  (op == `EXE_LB) ||
					  (op == `EXE_LBU) ||
					  (op == `EXE_LH) ||
					  (op == `EXE_LHU) ||
					  (op == `EXE_LW) ||
					  (op == `EXE_JAL) ||
					  (op == `EXE_REGIMM_INST && rt == `EXE_BLTZAL) ||
					  (op == `EXE_REGIMM_INST && rt == `EXE_BGEZAL) ||
					  (op == 6'b010000 && rs == 5'b00000 ));

	//是否为jump指令 
	assign jump = ((op == `EXE_J) ||
               	   (op == `EXE_SPECIAL_INST && funct == `EXE_JR));
	
	//是否为jal指令,保存31号�?�用寄存�?
	assign jal = ((op == `EXE_JAL));

	//是否为jr指令
	assign jr = ((op == `EXE_SPECIAL_INST && funct == `EXE_JR) ||
                 (op == `EXE_SPECIAL_INST && funct == `EXE_JALR));

	//是否为bal指令,地址保存31号�?�用寄存�??
	assign bal = ((op == `EXE_REGIMM_INST && rt == `EXE_BLTZAL) ||
                  (op == `EXE_REGIMM_INST && rt == `EXE_BGEZAL));
			
	//we:写Hilo寄存�??
	assign we = ((op == `EXE_SPECIAL_INST && funct == `EXE_MULT) ||
				 (op == `EXE_SPECIAL_INST && funct == `EXE_MULTU) ||
				 (op == `EXE_SPECIAL_INST && funct == `EXE_DIV) ||
				 (op == `EXE_SPECIAL_INST && funct == `EXE_DIVU) ||
				 (op == `EXE_SPECIAL_INST && funct == `EXE_MTHI) || 
				 (op == `EXE_SPECIAL_INST && funct == `EXE_MTLO));

	//signed_div:有符号除�?
	assign signed_div = ((op == `EXE_SPECIAL_INST && funct == `EXE_DIV));

	//start_i:除法?
	assign start_i = ((op == `EXE_SPECIAL_INST && funct == `EXE_DIV) ||
					  (op == `EXE_SPECIAL_INST && funct == `EXE_DIVU));

	//cp0we:cp0的写使能/mtc0
	assign cp0we = (instr[31:21] == 11'b01000000100);

	//eret
	assign eret = (instr == `EXE_ERET);

	//syscall
	assign syscall = ((op == `EXE_SPECIAL_INST && funct == `EXE_SYSCALL));

	//break
	assign break = ((op == `EXE_SPECIAL_INST && funct == `EXE_BREAK));
	
	assign invalid = (memen || branch || alusrc || regdst || regwrite || jump|| jal || jr || bal || 
					  we || signed_div || start_i || cp0we || eret || syscall || break);
endmodule