module hazard(
	//fetch stage
	output wire stallF,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire branchD,
	input wire jrD,
	output wire forwardaD,forwardbD,
	output wire stallD,
	//execute stage
	input wire[4:0] rsE,rtE,rdE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	output wire [1:0] forwardaE,forwardbE,
	output wire flushE,
	output wire forwardcp0E,
	input wire stall_divE,
	output wire stallE,
	output wire flushF,flushD,flushM,flushW,
	//mem stage
	input wire [4:0] rdM,
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
    input wire cp0weM,
    input wire [31:0] excepttypeM,
    input wire [31:0] epc_o,
    output wire [31:0] pcnewM,
	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW,
	output wire flush_except
    );

	wire lwstallD,branchstallD,jumpstallD;

	//forwarding sources to D stage (branch equality)
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	
	assign forwardcp0E = ((rdE!=0)&(rdE == rdM)&(cp0weM))?1'b1:1'b0;
	
	//forwarding sources to E stage (ALU)
    assign forwardaE = ((rsE != 0) && (rsE == writeregM) && regwriteM) ? 2'b10 : 
					((rsE != 0) && (rsE == writeregW) && regwriteW) ? 2'b01 : 2'b00;
	assign forwardbE = ((rtE != 0) && (rtE == writeregM) && regwriteM) ? 2'b10 : 
					((rtE != 0) && (rtE == writeregW) && regwriteW) ? 2'b01 : 2'b00;	

	//stalls
	assign #1 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign #1 branchstallD = branchD &
				(regwriteE & 
				(writeregE == rsD | writeregE == rtD) |
				memtoregM &
				(writeregM == rsD | writeregM == rtD));
    assign #1 jumpstallD = jrD &
				(regwriteE & 
				(writeregE == rsD) |
				memtoregM &
				(writeregM == rsD));
	assign #1 stallD = lwstallD | branchstallD | jumpstallD | stall_divE;
	assign #1 stallF = stallD;
	assign #1 stallE = stall_divE;
	 
	assign #1 flushF=flush_except;
    assign #1 flushD=flush_except; 
	assign #1 flushE = flush_except | (stallD & !stall_divE);
	assign #1 flushM=flush_except;
    assign #1 flushW=flush_except;
	assign  flush_except = (excepttypeM != 32'b0);
	assign  pcnewM = (excepttypeM != 32'b0)? (excepttypeM==32'h0000_000e ? epc_o : 32'hbfc0_0380) : 32'h0;
endmodule