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
	output reg[1:0] forwardaE,forwardbE,
	output wire flushE,
	output wire forwardcp0E,
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

	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			/* code */
			if(rsE == writeregM & regwriteM) begin
				/* code */
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				/* code */
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			/* code */
			if(rtE == writeregM & regwriteM) begin
				/* code */
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				/* code */
				forwardbE = 2'b01;
			end
		end
	end

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
	assign #1 stallD = lwstallD | branchstallD | jumpstallD;
	assign #1 stallF = stallD;
	
	assign #1 flushE = stallD;
	assign #1 flush_except = (excepttypeM != 32'b0);
	assign #1 pcnewM = (excepttypeM != 32'b0)? (excepttypeM==32'h0000_000e ? epc_o : 32'hbfc0_0380) : 32'h0;
endmodule