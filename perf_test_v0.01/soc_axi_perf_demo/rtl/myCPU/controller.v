module controller(
	input wire clk,rst,
	//decode stage
	input wire[31:0] instrD,
	output wire branchD,
	output wire jumpD,jrD,jalD,
	output wire syscallD,breakD,invalidD,eretD,
	//execute stage
	input wire flushE,
	input wire stallE,
	output wire signed_divE,start_iE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,jalE,balE,jrE,jumpE,
	output wire[7:0] alucontrolE,

	//mem stage
	input wire[1:0] offset,
	input wire[31:0] writedataM,
	output wire[31:0] writedata,
	output wire memtoregM,
	output wire [3:0] memwriteM,
	output wire regwriteM,memenM,weM,
    output wire cp0weM,
	//write back stage
	output wire memtoregW,regwriteW,
	input wire flushM,flushW,
	input wire cpu_stall
    );
	
	//decode stage
	wire memtoregD,alusrcD;
	wire regdstD,regwriteD,balD;
	wire memwriteD_1;
	wire weD,signed_divD,start_iD;
	wire memenD;
	wire[7:0] alucontrolD;
	wire[5:0] opD;
	wire cp0weD;


	//execute stage
	wire memwriteE_1;
	wire memenE,weE;
	wire[5:0] opE;
	wire cp0weE;

	//memory stage
	wire memwriteM_1;
	wire[5:0] opM;

    assign opD = instrD[31:26];

	assign memwriteM = memwriteM_1?
					   opM == `EXE_SB?
					   offset==0?4'b0001:
					   offset==1?4'b0010:
					   offset==2?4'b0100:
					   offset==3?4'b1000:4'b0000:
					   opM == `EXE_SH?
					   offset==0?4'b0011:
					   offset==2?4'b1100:4'b0000:
					   opM == `EXE_SW?
					   4'b1111:4'b0000
					   :4'b0000;
   assign writedata =  memwriteM_1?
                       opM == `EXE_SB?
                       offset==0?{{24{1'b0}},writedataM[7:0]}:
                       offset==1?{{16{1'b0}},writedataM[7:0],{8{1'b0}}}:
                       offset==2?{{8{1'b0}},writedataM[7:0],{16{1'b0}}}:
                       offset==3?{writedataM[7:0],{24{1'b0}}}:32'b0:
                       opM == `EXE_SH?
                       offset==0?{{16{1'b0}},writedataM[15:0]}:
                       offset==2?{writedataM[15:0],{16{1'b0}}}:32'b0:
                       opM == `EXE_SW?
                       writedataM:32'b0:
                       32'b0;

	maindec md(
		instrD,
		memtoregD,memwriteD_1,memenD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,jalD,jrD,balD,
		weD,signed_divD,start_iD,
		cp0weD,eretD,syscallD,breakD,invalidD
		);
	aludec ad(instrD,alucontrolD);

	//pipeline registers
	flopenrc #(28) regE(
		clk,
		rst,
		~cpu_stall,
		flushE,
		stallE,
		{memenD,memtoregD,memwriteD_1,alusrcD,regdstD,regwriteD,jalD,balD,jrD,jumpD,alucontrolD,weD,signed_divD,start_iD,opD,cp0weD},
		{memenE,memtoregE,memwriteE_1,alusrcE,regdstE,regwriteE,jalE,balE,jrE,jumpE,alucontrolE,weE,signed_divE,start_iE,opE,cp0weE}
		);
	flopenrc #(12) regM(
		clk,
		rst,
		~cpu_stall,
		flushM,
		1'b0,
		{memenE,memtoregE,memwriteE_1,regwriteE,weE,opE,cp0weE},
		{memenM,memtoregM,memwriteM_1,regwriteM,weM,opM,cp0weM}
		);

	flopenrc #(2) regW(
		clk,
		rst,
		~cpu_stall,
		flushW,
		1'b0,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule