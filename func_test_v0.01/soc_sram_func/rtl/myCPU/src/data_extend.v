`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/03 01:18:45
// Design Name: 
// Module Name: data_extend
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_extend(
        input wire [31:0] readdata,
        input wire [1:0] offset,
        input wire memtoreg,
        input wire [5:0] op,
        output wire [31:0] readdata_extend
    );
    assign readdata_extend = memtoreg?
                             op == `EXE_LB? 
                             offset==0?{{24{readdata[7]}},readdata[7:0]}:
                             offset==1?{{24{readdata[15]}},readdata[15:8]}:
                             offset==2?{{24{readdata[23]}},readdata[23:16]}:
                             offset==3?{{24{readdata[31]}},readdata[31:24]}:32'b0:
					         op == `EXE_LBU? 
					         offset==0?{{24{1'b0}},readdata[7:0]}:
                             offset==1?{{24{1'b0}},readdata[15:8]}:
                             offset==2?{{24{1'b0}},readdata[23:16]}:
                             offset==3?{{24{1'b0}},readdata[31:24]}:32'b0:
					         op == `EXE_LH?
					         offset==0?{{16{readdata[15]}},readdata[15:0]}:
                             offset==2?{{16{readdata[31]}},readdata[31:16]}:32'b0:
					         op == `EXE_LHU?
					         offset==0?{{16{1'b0}},readdata[15:0]}:
                             offset==2?{{16{1'b0}},readdata[31:16]}:32'b0:
					         op == `EXE_LW? readdata:
					         32'b0:32'b0;
endmodule