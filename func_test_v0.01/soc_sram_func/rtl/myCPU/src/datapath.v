module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire branchD,
	input wire jumpD,jalD,jrD,
	input wire  syscallD,breakD,invalidD,eretD,
	output wire[31:0] instrD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,jalE,balE,jrE,jumpE,
	input wire [7:0] alucontrolE,
	input wire signed_divE,start_iE,
	output wire divstallE,
	output wire flushE,
	//mem stage
	input wire memtoregM,
	input wire regwriteM,
	input wire weM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	input wire cp0weM,
	output wire [31:0] excepttypeM,
	//writeback stage
	input wire memtoregW,regwriteW,
	output wire[31:0] pcW,
	output wire [4:0] writeregW,
	output wire [31:0] resultW,
	//except
	input wire [5:0] int,
	output wire flush_except
    );
	
	//fetch stage
	wire stallF;
	wire is_in_delayslotF;
	//FD
	wire [31:0] pcD,pcnextFD,pcnextbrFD,pcplus4F,pcbranchD,pcnextFD_temp;
	//decode stage
	wire [31:0] pcplus4D;
	wire [31:0] pcplus8D;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD,saD;
	wire [5:0] opD,functD;
	wire stallD; 
	wire equalD;
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire is_in_delayslotD;
	//execute stage
	wire[31:0] pcE;
	wire[5:0] opE;
	wire [31:0] pcplus8E;
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE,saE;
	wire [4:0] writeregE,writeregE_temp;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE,aluoutE_temp;
	wire ready_o;
	wire is_in_delayslotE;
	wire [31:0] cp0dataE,cp0data2E;
	wire forwardcp0E;
	//mem stage 
	wire[31:0] pcM;
	wire[5:0] opM;
	wire [4:0] writeregM;
    wire [4:0] rdM;
    wire divstallM;
	//writeback stage
	wire[5:0] opW;
	wire [31:0] aluoutW,readdataW,readdataW_temp;
	wire[31:0] hiE,loE,hiM,loM;
	wire[31:0] hi_o,lo_o;
	wire overflow,zero;
	wire[63:0] divresult;
	wire annul_i;
	wire [7:0] exceptF, exceptE, exceptD, exceptM,exceptM_temp;
	wire [31:0] data_oM, count_oM, compare_oM, status_oM, cause_oM, epc_oM, config_oM, prid_oM, badvaddrM;
	wire [31:0] bad_addrM;
	wire adelM,adesM;
	wire timer_int_oM,is_in_delayslotM;
	wire [31:0] pcnewM;
	
	assign annul_i = 1'b0;
	assign divstallE = start_iE&!ready_o;
	assign is_in_delayslotF = (jumpD|jrD|jalD|branchD); 

	//hazard detection
	hazard h(
		//fetch stage
		stallF,
		//decode stage
		rsD,rtD,
		branchD,
		jrD,
		forwardaD,forwardbD,
		stallD,
		//execute stage
		rsE,rtE,rdE,
		writeregE,
		regwriteE,
		memtoregE,
		forwardaE,forwardbE,
		flushE,
		forwardcp0E,
		//mem stage
		rdM,
		writeregM,
		regwriteM,
		memtoregM,
		cp0weM,
		excepttypeM,
		epc_oM,
		pcnewM,
		//write back stage
		writeregW,
		regwriteW,
		flush_except
		);

	//next PC logic (operates in fetch an decode)
    branch branch(opD,rtD,pcplus4F,pcbranchD,branchD,equalD,srca2D,pcnextbrFD);
	mux2 #(32) pcmux(pcnextbrFD,{pcplus4D[31:28],instrD[25:0],2'b00},
		jalD|(jumpD&!jrD),pcnextFD_temp);
    mux2 #(32) pcjrmux(pcnextFD_temp,srca2D,jrD,pcnextFD);
	//regfile (operates in decode and writeback)
	
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//fetch stage logic
	pc #(32) pcreg(clk,rst,~stallF&~divstallE,flush_except,pcnextFD,pcnewM,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	
	assign exceptF = (pcF[1:0]== 2'b00 ? 8'b00000000 : 8'b10000000);
	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD&~divstallE,flush_except,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD&~divstallE,flush_except,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD&~divstallE,flush_except,pcF,pcD);
	flopenrc #(1) r4D(clk,rst,~stallD&~divstallE,flush_except,is_in_delayslotF,is_in_delayslotD);
	flopenrc #(8) r5D(clk,rst,~stallD&~divstallE,flush_except,exceptF,exceptD);
	
	signext se(instrD[15:0],instrD[29:28],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	adder pcadd3(pcplus4D,32'b100,pcplus8D);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,equalD);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];

	//execute stage
	flopenrc #(32) r1E(clk,rst,~divstallE,flushE|flush_except,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~divstallE,flushE|flush_except,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~divstallE,flushE|flush_except,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~divstallE,flushE|flush_except,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~divstallE,flushE|flush_except,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~divstallE,flushE|flush_except,rdD,rdE);
	flopenrc #(5) r7E(clk,rst,~divstallE,flushE|flush_except,saD,saE);
	flopenrc #(32) r8E(clk,rst,~divstallE,flushE|flush_except,pcplus8D,pcplus8E);
	flopenrc #(6) r9E(clk,rst,~divstallE,flushE|flush_except,opD,opE);
	flopenrc #(32) r10E(clk,rst,~divstallE,flushE|flush_except,pcD,pcE);
	flopenrc #(1) r11E(clk,rst,~divstallE,flushE|flush_except,is_in_delayslotD,is_in_delayslotE);
	flopenrc #(8) r12E(clk,rst,~divstallE,flushE|flush_except,{exceptD[7],syscallD,breakD,eretD,~invalidD,exceptD[2:0]},exceptE);

	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	
	
	div div(clk, rst,signed_divE,srca2E,srcb3E,divstallE,annul_i,divresult,ready_o);
	
	mux2 #(32) forwardcp0(cp0dataE,aluoutM,forwardcp0E,cp0data2E);
	
	alu alu(srca2E,srcb3E,alucontrolE,saE,{hi_o,lo_o},divresult,cp0data2E,aluoutE_temp,overflow,zero,{hiE,loE});
	
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE_temp);
    mux2 #(5) reg31_address_mux(writeregE_temp,5'b11111,jalE | balE,writeregE);
    mux2 #(32) reg31_result_mux(aluoutE_temp,pcplus8E,jalE | balE | (jrE & !jumpE),aluoutE);
    
	//mem stage
	floprc #(32) r1M(clk,rst,flush_except,srcb2E,writedataM);
	floprc #(32) r2M(clk,rst,flush_except,aluoutE,aluoutM);
	floprc #(5) r3M(clk,rst,flush_except,writeregE,writeregM);
	floprc #(6) r4M(clk,rst,flush_except,opE,opM);
	floprc #(32) r5M(clk,rst,flush_except,pcE,pcM);
	floprc #(5) r6M(clk,rst,flush_except,rdE,rdM);
	floprc #(32) r7M(clk,rst,flush_except,pcE,pcM);
	floprc #(32) r8M(clk,rst,flush_except,hiE,hiM);
	floprc #(32) r9M(clk,rst,flush_except,loE,loM);
	floprc #(1) r10M(clk,rst,flush_except,divstallE,divstallM);
	floprc #(1) r11M(clk,rst,flush_except,is_in_delayslotE,is_in_delayslotM);
	floprc #(8) r12M(clk,rst,flush_except,{exceptE[7:3],overflow,exceptE[1:0]},exceptM_temp);
	 
	memsel memsel(pcM,opM,aluoutM,adesM,adelM,bad_addrM);
	
	assign exceptM = {exceptM_temp[7]|adelM,exceptM_temp[6:2],adesM,exceptM_temp[0]};
	
	exception exception(rst, exceptM, cause_oM, status_oM,excepttypeM);
    
	cp0_reg cp0(clk,rst,cp0weM,rdM,rdE,aluoutM,int,excepttypeM,pcM,is_in_delayslotM,bad_addrM,data_oM,
	                   count_oM,compare_oM,status_oM,cause_oM,epc_oM,config_oM,prid_oM,badvaddrM,timer_int_oM);
   
   assign cp0dataE = data_oM;
   
   hilo_reg hilo_reg(clk,rst,weM&~divstallM,hiM,loM,hi_o,lo_o);

	//writeback stage
	floprc #(32) r1W(clk,rst,flush_except,aluoutM,aluoutW);
	floprc #(32) r2W(clk,rst,flush_except,readdataM,readdataW_temp);
	floprc #(5) r3W(clk,rst,flush_except,writeregM,writeregW);
	floprc #(6) r4W(clk,rst,flush_except,opM,opW);
	floprc #(32) r5W(clk,rst,flush_except,pcM,pcW);
	
	data_extend data_extend(readdataW_temp,aluoutW[1:0],memtoregW,opW,readdataW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	
endmodule