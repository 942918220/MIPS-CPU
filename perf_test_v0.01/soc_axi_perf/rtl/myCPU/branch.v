`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/02 20:01:10
// Design Name: 
// Module Name: branch
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

`include "defines.vh"

module branch(
    input wire[5:0] op,
    input wire[4:0] rt,
    input wire [31:0] pcplus4F,
    input wire [31:0] pcbranchD,
    input wire branchD,equalD,
    input wire [31:0] srcaD,
    output wire [31:0] pcnextbrFD
    );
    
    assign pcnextbrFD = branchD?
                        op==`EXE_BEQ? (equalD?pcbranchD:pcplus4F):
                        op==`EXE_BNE? (!equalD?pcbranchD:pcplus4F):
                        op==`EXE_BLEZ? (srcaD[31]==1 | srcaD==0?pcbranchD:pcplus4F):
                        op==`EXE_BGTZ? (srcaD[31]==0 & srcaD!=0?pcbranchD:pcplus4F):
                        op==`EXE_REGIMM_INST && rt==`EXE_BLTZ?(srcaD[31]==1?pcbranchD:pcplus4F):
                        op==`EXE_REGIMM_INST && rt==`EXE_BLTZAL?(srcaD[31]==1?pcbranchD:pcplus4F):
                        op==`EXE_REGIMM_INST && rt==`EXE_BGEZ?(srcaD[31]==0?pcbranchD:pcplus4F):
                        op==`EXE_REGIMM_INST && rt==`EXE_BGEZAL?(srcaD[31]==0?pcbranchD:pcplus4F):
                        pcplus4F:pcplus4F;
endmodule
