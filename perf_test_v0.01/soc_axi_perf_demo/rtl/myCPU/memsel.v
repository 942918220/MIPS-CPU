`include "defines.vh"

module memsel(
    input wire[31:0] pc,
    input wire[5:0] op,
    input wire[31:0] addr, //=aluoutM

    output wire adesM,adelM,
    output wire[31:0] bad_addr
);

    assign adesM = (op == `EXE_SH && addr[0] != 0 ) ? 1'b1:
                    (op == `EXE_SW && addr[1:0] != 2'b00) ? 1'b1:
                    1'b0; 
    assign adelM = ((op == `EXE_LH || op == `EXE_LHU) && (addr[0] != 0)) ? 1'b1:
                    (op == `EXE_LW && addr[1:0] != 2'b00) ? 1'b1:
                    1'b0; 
    assign bad_addr = ((op == `EXE_LH || op == `EXE_LHU || op == `EXE_SH) && addr[0] != 0) ? addr:
                        ((op == `EXE_LW || op == `EXE_SW) && addr[1:0] != 2'b00) ? addr:
                        pc; 
endmodule