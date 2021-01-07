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
	output wire stallE,
	output wire flushE,flushM,flushW,
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
	input wire cpu_stall
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
	wire divstallE;
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
	wire flush_except;
	wire flushF,flushD;
	
	
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
		divstallE,
		stallE,
	    flushF,flushD,flushM,flushW,
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
	pc #(32) pcreg(clk,rst,~(cpu_stall | stallF) ,flushF,pcnextFD,pcnewM,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	
	assign exceptF = (pcF[1:0]== 2'b00 ? 8'b00000000 : 8'b10000000);
	//decode stage
	flopenrc #(32) r1D(clk,rst,~cpu_stall,flushD,stallD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~cpu_stall,flushD,stallD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~cpu_stall,flushD,stallD,pcF,pcD);
	flopenrc #(1) r4D(clk,rst, ~cpu_stall,flushD,stallD,is_in_delayslotF,is_in_delayslotD);
	flopenrc #(8) r5D(clk,rst, ~cpu_stall,flushD,stallD,exceptF,exceptD);
	
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
	flopenrc #(32) r1E(clk,rst,~cpu_stall,flushE,stallE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~cpu_stall,flushE,stallE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~cpu_stall,flushE,stallE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst, ~cpu_stall,flushE,stallE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst, ~cpu_stall,flushE,stallE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst, ~cpu_stall,flushE,stallE,rdD,rdE);
	flopenrc #(5) r7E(clk,rst, ~cpu_stall,flushE,stallE,saD,saE);
	flopenrc #(32) r8E(clk,rst,~cpu_stall,flushE,stallE,pcplus8D,pcplus8E);
	flopenrc #(6) r9E(clk,rst, ~cpu_stall,flushE,stallE,opD,opE);
   flopenrc #(32) r10E(clk,rst,~cpu_stall,flushE,stallE,pcD,pcE);
    flopenrc #(1) r11E(clk,rst,~cpu_stall,flushE,stallE,is_in_delayslotD,is_in_delayslotE);
    flopenrc #(8) r12E(clk,rst,~cpu_stall,flushE,stallE,{exceptD[7],syscallD,breakD,eretD,~invalidD,exceptD[2:0]},exceptE);

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
	flopenrc #(32) r1M(clk,rst,~cpu_stall,flushM,1'b0,srcb2E,writedataM);
	flopenrc #(32) r2M(clk,rst,~cpu_stall,flushM,1'b0,aluoutE,aluoutM);
	flopenrc #(5) r3M(clk,rst,~cpu_stall, flushM,1'b0,writeregE,writeregM);
	flopenrc #(6) r4M(clk,rst,~cpu_stall, flushM,1'b0,opE,opM);
	flopenrc #(32) r5M(clk,rst,~cpu_stall,flushM,1'b0,pcE,pcM);
	flopenrc #(5) r6M(clk,rst,~cpu_stall, flushM,1'b0,rdE,rdM);
	flopenrc #(32) r7M(clk,rst,~cpu_stall,flushM,1'b0,pcE,pcM);
	flopenrc #(32) r8M(clk,rst,~cpu_stall,flushM,1'b0,hiE,hiM);
	flopenrc #(32) r9M(clk,rst,~cpu_stall,flushM,1'b0,loE,loM);
	flopenrc #(1) r10M(clk,rst,~cpu_stall,flushM,1'b0,divstallE,divstallM);
	flopenrc #(1) r11M(clk,rst,~cpu_stall,flushM,1'b0,is_in_delayslotE,is_in_delayslotM);
	flopenrc #(8) r12M(clk,rst,~cpu_stall,flushM,1'b0,{exceptE[7:3],overflow,exceptE[1:0]},exceptM_temp);
	 
	memsel memsel(pcM,opM,aluoutM,adesM,adelM,bad_addrM);
	
	assign exceptM = {exceptM_temp[7]|adelM,exceptM_temp[6:2],adesM,exceptM_temp[0]};
	
	exception exception(rst, exceptM, cause_oM, status_oM,excepttypeM);
    
	cp0_reg cp0(clk,rst,cp0weM,rdM,rdE,aluoutM,int,excepttypeM,pcM,is_in_delayslotM,bad_addrM,data_oM,
	                   count_oM,compare_oM,status_oM,cause_oM,epc_oM,config_oM,prid_oM,badvaddrM,timer_int_oM);
   
   assign cp0dataE = data_oM;
   
   hilo_reg hilo_reg(clk,rst,weM&~divstallM,hiM,loM,hi_o,lo_o);

	//writeback stage
	flopenrc #(32) r1W(clk,rst,~cpu_stall,flushW,1'b0,aluoutM,aluoutW);
	flopenrc #(32) r2W(clk,rst,~cpu_stall,flushW,1'b0,readdataM,readdataW_temp);
	flopenrc #(5) r3W(clk,rst,~cpu_stall, flushW,1'b0,writeregM,writeregW);
	flopenrc #(6) r4W(clk,rst,~cpu_stall, flushW,1'b0,opM,opW);
	flopenrc #(32) r5W(clk,rst,~cpu_stall,flushW,1'b0,pcM,pcW);
	
	data_extend data_extend(readdataW_temp,aluoutW[1:0],memtoregW,opW,readdataW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	
endmodule