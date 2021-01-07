module pc #(parameter WIDTH = 8) (
	input clk, rst, en,clr,
	input [WIDTH - 1 : 0] in,
	input [WIDTH - 1 : 0] new,
	output reg [WIDTH - 1 : 0] out
);

	always @(posedge clk, posedge rst)
	    begin
			if(rst) 
				out <= 32'hbfc00000;
			else if(clr)
                out <= new; 
			else if(en) 
				out <= in;
	    end
		 
endmodule
