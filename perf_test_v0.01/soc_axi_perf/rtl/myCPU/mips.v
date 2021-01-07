module mips(
    input wire clk,
    input wire rst,  //low active
    input wire[5:0] int,  //interrupt,high active

    output wire inst_sram_en,
    output wire[3:0] inst_sram_wen,
    output wire[31:0] inst_sram_addr,
    output wire[31:0] inst_sram_wdata,
    input wire[31:0] inst_sram_rdata,
    input wire inst_sram_d_stall,
    
    output wire data_sram_en,
    output wire[3:0] data_sram_wen,
    output wire[31:0] data_sram_addr,
    output wire[31:0] data_sram_wdata,
    input wire[31:0] data_sram_rdata,
    input wire data_sram_d_stall,
    output wire no_dcache,

    //debug
    output wire[31:0] debug_wb_pc,
    output wire[3:0] debug_wb_rf_wen,
    output wire[4:0] debug_wb_rf_wnum,
    output wire[31:0] debug_wb_rf_wdata
    );
	
	wire CPU_clk,CPU_rst;

	//fetch stage
	wire[31:0] pcF;

	//decode stage
	wire[31:0] instrD;
	wire branchD,jumpD,jrD,jalD,equalD;
    wire  syscallD,breakD,invalidD,eretD;
	//execute stage
	wire flushE,regdstE,alusrcE,memtoregE,regwriteE;
	wire jalE,balE,jrE,jumpE;
	wire [7:0] alucontrolE;
	wire weM,signed_divE,start_iE,stallE;

	//memory stage
	wire flushM,memtoregM,regwriteM,memenM;
	wire [31:0] aluoutM;
	wire [31:0] writedataM;
    wire cp0weM;
    wire [31:0] excepttypeM;
	//writeback stage
	wire memtoregW,regwriteW;
	wire flushW;
	wire [31:0] pcW;
    wire [4:0] writeregW;
    wire [31:0] resultW;
    wire cpu_stall = inst_sram_d_stall | data_sram_d_stall;

	
	assign CPU_clk = clk;
	assign CPU_rst = rst;
	assign inst_sram_en = 1'b1;
	assign inst_sram_wen = 4'b0000;
	assign inst_sram_addr = (pcF[31] == 1) ? {3'b000,pcF[28:0]} : pcF;
	assign inst_sram_wdata = 32'b0;
	
	assign data_sram_en =  memenM & (excepttypeM==32'b0) ? 1'b1 : 1'b0;
	assign data_sram_addr = (aluoutM[31] == 1) ? {3'b000,aluoutM[28:0]} : aluoutM;
	assign no_dcache = (aluoutM[31] == 1);
	
	assign debug_wb_pc = pcW;
    assign debug_wb_rf_wen = {4{regwriteW & !inst_sram_d_stall & !data_sram_d_stall}};
    assign debug_wb_rf_wnum = writeregW;
    assign debug_wb_rf_wdata = resultW;
    
	
	

	controller c(
		CPU_clk,CPU_rst,
		//decode stage
		instrD,
		branchD,jumpD,jrD,jalD,
		syscallD,breakD,invalidD,eretD,
		//execute stage
		flushE,
		stallE,
		signed_divE,start_iE,
		memtoregE,alusrcE,
		regdstE,regwriteE,
		jalE,balE,jrE,jumpE,
		alucontrolE,

		//mem stage
		aluoutM[1:0],
		writedataM,data_sram_wdata,
		memtoregM,data_sram_wen,
		regwriteM,memenM,weM,
		cp0weM,
		//write back stage
		memtoregW,regwriteW,
		flushM,flushW,
		cpu_stall
		);
	datapath dp(
		CPU_clk,CPU_rst,
		//fetch stage
		pcF,
		inst_sram_rdata,
		//decode stage
		branchD,
		jumpD,jalD,jrD,
		syscallD,breakD,invalidD,eretD,
		instrD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,jalE,balE,jrE,jumpE,
		alucontrolE,signed_divE,start_iE,stallE,
		flushE,flushM,flushW,
		//mem stage
		memtoregM,
		regwriteM,
		weM,
		aluoutM,writedataM,
		data_sram_rdata,
		cp0weM,
		excepttypeM,
		//writeback stage
		memtoregW,
		regwriteW,
		pcW,
		writeregW,
		resultW,
		//except
		int,
		cpu_stall
	    );
	
endmodule