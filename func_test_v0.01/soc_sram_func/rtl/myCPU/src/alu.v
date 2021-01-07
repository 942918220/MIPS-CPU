`include "defines.vh"

module alu(
	input wire[31:0] a,b,
	input wire[7:0] op, //alucontrol
	input wire[4:0] sa,
	input wire[63:0] hilo_i, 
	input wire[63:0] divresult, 
	input wire[31:0] cp0data,
	output reg[31:0] y,
	output wire overflow,
	output wire zero,
	output reg[63:0] hilo_o
    );
	wire[31:0] subresult;
	wire[31:0] mult_a, mult_b;
	wire[63:0] hilo_temp;

	assign subresult = a+(~b+1);
	assign mult_a = ((op == `EXE_MULT_OP) && (a[31] == 1'b1)) ? (~a+1) : a;
	assign mult_b = ((op == `EXE_MULT_OP) && (b[31] == 1'b1)) ? (~b+1) : b;
	assign hilo_temp = ((op == `EXE_MULT_OP) && (a[31] ^ b[31] == 1'b1)) ? ~(mult_a*mult_b)+1 : mult_a*mult_b;
	assign zero = (y==32'b0);
	assign overflow = ((op == `EXE_ADD_OP) || (op == `EXE_ADDI_OP)) ? (y[31] && !a[31] && !b[31]) || (!y[31] && a[31] && b[31]) :
                  (op == `EXE_SUB_OP) ? ((a[31] && !b[31]) && !y[31]) || ((!a[31] & b[31]) && y[31]) : 1'b0;

	always @(*) begin
		case(op) 
			//memory inst
			`EXE_LB_OP,`EXE_LBU_OP,`EXE_LH_OP,`EXE_LHU_OP,`EXE_LW_OP,`EXE_SB_OP,`EXE_SH_OP,`EXE_SW_OP: y <= a+b;
			//logic inst
			`EXE_AND_OP,`EXE_ANDI_OP: y <= a&b;
			`EXE_OR_OP,`EXE_ORI_OP: y <= a|b;
			`EXE_XOR_OP,`EXE_XORI_OP: y <= a^b;
			`EXE_NOR_OP: y <= ~(a|b);
			`EXE_LUI_OP: y <= {b[15:0],b[31:16]};
			//shift inst
			`EXE_SLLV_OP: y <= b<<a[4:0];
			`EXE_SLL_OP: y <= b<<sa;
			`EXE_SRAV_OP: y <= ({32{b[31]}} << (6'b100000-{1'b0,a[4:0]})) | b>>a[4:0];
			`EXE_SRA_OP: y <= ({32{b[31]}} << (6'b100000-{1'b0,sa})) | b>>sa;
			`EXE_SRLV_OP: y <= b>>a[4:0];
			`EXE_SRL_OP: y <= b>>sa;
			//move data inst
			`EXE_MFHI_OP: y <= hilo_i[63:32];
			`EXE_MFLO_OP: y <= hilo_i[31:0];
			`EXE_MTHI_OP: hilo_o <= {a,hilo_i[31:0]};
			`EXE_MTLO_OP: hilo_o <= {hilo_i[63:32],a};
			//arithmetic inst
			`EXE_ADD_OP, `EXE_ADDI_OP, `EXE_ADDU_OP, `EXE_ADDIU_OP: y <= a+b;
			`EXE_SUB_OP, `EXE_SUBU_OP: y <= subresult;
			`EXE_SLT_OP, `EXE_SLTI_OP: y <= ((a[31] && !b[31]) || (!a[31] && !b[31] && subresult[31]) || (a[31] && b[31] && subresult[31]));
			`EXE_SLTU_OP,`EXE_SLTIU_OP: y <= a<b;
			`EXE_MULT_OP,`EXE_MULTU_OP: hilo_o <= hilo_temp;
			`EXE_DIV_OP,`EXE_DIVU_OP: hilo_o <= divresult;
			//privilege inst
			`EXE_MFC0_OP: y <= cp0data;
			`EXE_MTC0_OP: y <= b;
			default y <= 32'b0;
		endcase
	end
endmodule