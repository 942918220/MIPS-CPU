module bridge_1x2 (
    input clk,rst,
    input no_dcache,
    // sram
    input         cpu_data_req     ,
    input  [31:0] cpu_data_addr    ,
    input  [3 :0] cpu_data_wen     ,
    input  [31:0] cpu_data_wdata   ,
    input         cpu_inst_stall   ,
    output [31:0] cpu_data_rdata   ,
    output        cpu_data_stall   ,

    // sram
    output         ram_data_req     ,
    output  [31:0] ram_data_addr    ,
    output  [3 :0] ram_data_wen     ,
    output  [31:0] ram_data_wdata   ,
    input   [31:0] ram_data_rdata   ,
    input          ram_data_stall   ,

    // sram_like
    output         conf_data_req     ,
    output         conf_data_wr      ,
    output  [1 :0] conf_data_size    ,
    output  [31:0] conf_data_addr    ,
    output  [31:0] conf_data_wdata   ,
    input   [31:0] conf_data_rdata   ,
    input          conf_data_addr_ok ,
    input          conf_data_data_ok 
);

    wire cpu_data_wr;
    wire [1:0] cpu_data_size;
    assign cpu_data_wr     =  cpu_data_wen!=4'b0000;
    assign cpu_data_size   = (cpu_data_wen==4'b0000 | cpu_data_wen==4'b1111) ? 2'b10 :
                             (cpu_data_wen==4'b1100 | cpu_data_wen==4'b0011) ? 2'b01 :
                             (cpu_data_wen==4'b1000 | cpu_data_wen==4'b0100  |
                              cpu_data_wen==4'b0010 | cpu_data_wen==4'b0001) ? 2'b00 : 2'b10;

    // output to d_cache
    assign ram_data_req   = no_dcache ? 0 : cpu_data_req  ;
    assign ram_data_addr  = no_dcache ? 0 : cpu_data_addr ;
    assign ram_data_wen   = no_dcache ? 0 : cpu_data_wen  ;
    assign ram_data_wdata = no_dcache ? 0 : cpu_data_wdata;


    wire read_req, read_finish;
    wire write_req, write_finish;
    wire conf_data_stall;

    reg [31:0] conf_data_temp;
    reg [1:0] state;
    parameter IDLE = 2'b00, RD = 2'b01, WR = 2'b11, AR = 2'b10; // AR = after read如果处在该状态，说明已经完成�?次读外设事务，但是cpu仍在暂停，所以不发出读请�?
    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE:   state <= cpu_data_req & no_dcache &  cpu_data_wr ? WR :
                                 cpu_data_req & no_dcache & ~cpu_data_wr ? RD : IDLE;
                RD:     state <= read_finish    ? AR   : RD;
                WR:     state <= write_finish   ? IDLE : WR;
                AR:     state <= cpu_inst_stall ? AR   : IDLE;
            endcase
        end
    end

    assign read_req = state==RD;
    assign read_finish = read_req & conf_data_data_ok;
    assign write_req = state==WR;
    assign write_finish = write_req & conf_data_data_ok;
    assign conf_data_stall = read_req | write_req | state==AR;

    // output to mips
    assign cpu_data_rdata = no_dcache ? conf_data_temp : ram_data_rdata;
    assign cpu_data_stall = ram_data_stall | conf_data_stall;

    // output to confreg
    assign conf_data_req   = read_req | write_req;
    assign conf_data_wr    = write_req ? 1 : 0;
    assign conf_data_size  = no_dcache ? cpu_data_size  : 0;
    assign conf_data_addr  = no_dcache ? cpu_data_addr  : 0;
    assign conf_data_wdata = no_dcache ? cpu_data_wdata : 0;

    always @(posedge clk) begin
        if(rst) begin
            conf_data_temp <= 32'b0;
        end
        else begin
            if(cpu_data_req & no_dcache & ~cpu_data_wr & read_finish) begin
                conf_data_temp <= conf_data_rdata;
            end
        end
    end

endmodule