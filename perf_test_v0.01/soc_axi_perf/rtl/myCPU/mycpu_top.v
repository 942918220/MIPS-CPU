module mycpu_top(
    input [5:0] int,

    input wire aclk,    
    input wire aresetn,  

    output wire[3:0] arid,
    output wire[31:0] araddr,
    output wire[7:0] arlen,
    output wire[2:0] arsize,
    output wire[1:0] arburst,
    output wire[1:0] arlock,
    output wire[3:0] arcache,
    output wire[2:0] arprot,
    output wire arvalid,
    input wire arready,
                
    input wire[3:0] rid,
    input wire[31:0] rdata,
    input wire[1:0] rresp,
    input wire rlast,
    input wire rvalid,
    output wire rready, 
               
    output wire[3:0] awid,
    output wire[31:0] awaddr,
    output wire[7:0] awlen,
    output wire[2:0] awsize,
    output wire[1:0] awburst,
    output wire[1:0] awlock,
    output wire[3:0] awcache,
    output wire[2:0] awprot,
    output wire awvalid,
    input wire awready,
    
    output wire[3:0] wid,
    output wire[31:0] wdata,
    output wire[3:0] wstrb,
    output wire wlast,
    output wire wvalid,
    input wire wready,
    
    input wire[3:0] bid,
    input wire[1:0] bresp,
    input bvalid,
    output bready,

    //debug interface
    output wire[31:0] debug_wb_pc,
    output wire[3:0] debug_wb_rf_wen,
    output wire[4:0] debug_wb_rf_wnum,
    output wire[31:0] debug_wb_rf_wdata
);
wire clk, rst;
assign clk = ~aclk;
assign rst = ~aresetn;

wire cpu_inst_sram_en;
wire[3:0] cpu_inst_sram_wen;
wire[31:0] cpu_inst_sram_addr;
wire[31:0] cpu_inst_sram_wdata;
wire[31:0] cpu_inst_sram_rdata;
wire cpu_inst_sram_d_stall;

wire cpu_data_sram_en;
wire[3:0] cpu_data_sram_wen;
wire[31:0] cpu_data_sram_addr;
wire[31:0] cpu_data_sram_wdata;
wire[31:0] cpu_data_sram_rdata;
wire cpu_data_sram_d_stall;
wire no_dcache;

wire        cache_inst_req  ;
wire [31:0] cache_inst_addr ;
wire        cache_inst_wr   ;
wire [1:0]  cache_inst_size ;
wire [31:0] cache_inst_wdata;
wire [31:0] cache_inst_rdata;
wire        cache_inst_addr_ok;
wire        cache_inst_data_ok;

wire        cache_data_req  ;
wire [31:0] cache_data_addr ;
wire        cache_data_wr   ;
wire [1:0]  cache_data_size ;
wire [31:0] cache_data_wdata;
wire [31:0] cache_data_rdata;
wire        cache_data_addr_ok;
wire        cache_data_data_ok;

wire data_sram_en;
wire[3:0]  data_sram_wen;
wire[31:0] data_sram_addr;
wire[31:0] data_sram_wdata;
wire[31:0] data_sram_rdata;
wire data_sram_d_stall;

wire       conf_data_req    ;
wire       conf_data_wr     ;
wire[31 :0]conf_data_addr   ;
wire[31:0] conf_data_wdata  ;
wire[1:0]  conf_data_size   ;
wire[31:0] conf_data_rdata  ;
wire       conf_data_addr_ok;
wire       conf_data_data_ok;

wire         wrap_data_req    ;
wire         wrap_data_wr     ; 
wire  [1 :0] wrap_data_size   ; 
wire  [31:0] wrap_data_addr   ; 
wire  [31:0] wrap_data_wdata  ; 
wire  [31:0] wrap_data_rdata  ; 
wire         wrap_data_addr_ok; 
wire         wrap_data_data_ok;



mips mips_core(
    .clk(clk), .rst(rst),
    .int(int),

    .inst_sram_en(cpu_inst_sram_en),
    .inst_sram_wen(cpu_inst_sram_wen),
    .inst_sram_addr(cpu_inst_sram_addr),
    .inst_sram_wdata(cpu_inst_sram_wdata),
    .inst_sram_rdata(cpu_inst_sram_rdata),
    .inst_sram_d_stall(cpu_inst_sram_d_stall),
    
    .data_sram_en(cpu_data_sram_en),
    .data_sram_wen(cpu_data_sram_wen),
    .data_sram_addr(cpu_data_sram_addr),
    .data_sram_wdata(cpu_data_sram_wdata),
    .data_sram_rdata(cpu_data_sram_rdata),
    .data_sram_d_stall(cpu_data_sram_d_stall),
    .no_dcache(no_dcache),
    
    .debug_wb_pc       (debug_wb_pc       ),
    .debug_wb_rf_wen   (debug_wb_rf_wen   ),
    .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),
    .debug_wb_rf_wdata (debug_wb_rf_wdata )
);


//cache
cache_LRU i_cache(
    .clk(aclk), .rst(rst),

    .sram_en(cpu_inst_sram_en),
    .sram_wen(cpu_inst_sram_wen),
    .sram_addr(cpu_inst_sram_addr),
    .sram_wdata(cpu_inst_sram_wdata),
    .sram_rdata(cpu_inst_sram_rdata),
    .sram_d_stall(cpu_inst_sram_d_stall),

    .cache_data_req     (cache_inst_req  ),  
    .cache_data_wr      (cache_inst_wr   ),  
    .cache_data_size    (cache_inst_size ),  
    .cache_data_addr    (cache_inst_addr ),  
    .cache_data_wdata   (cache_inst_wdata),  
    .cache_data_rdata   (cache_inst_rdata),  
    .cache_data_addr_ok (cache_inst_addr_ok),
    .cache_data_data_ok (cache_inst_data_ok)
);

bridge_1x2 bridge_1x2(
    .clk(aclk), 
    .rst(rst),
    .no_dcache        (no_dcache    ),

   .cpu_data_req(cpu_data_sram_en),
   .cpu_data_addr(cpu_data_sram_addr),
   .cpu_data_wen(cpu_data_sram_wen),
   .cpu_data_wdata(cpu_data_sram_wdata),
   .cpu_inst_stall(cpu_inst_sram_d_stall),
   .cpu_data_rdata(cpu_data_sram_rdata),
   .cpu_data_stall(cpu_data_sram_d_stall),

    .ram_data_req(data_sram_en),
    .ram_data_addr(data_sram_addr),
    .ram_data_wen(data_sram_wen),
    .ram_data_wdata(data_sram_wdata),
    .ram_data_rdata(data_sram_rdata),
    .ram_data_stall(data_sram_d_stall),

    .conf_data_req     (conf_data_req  ),
    .conf_data_wr      (conf_data_wr   ),
    .conf_data_addr    (conf_data_addr ),
    .conf_data_wdata   (conf_data_wdata),
    .conf_data_size    (conf_data_size ),
    .conf_data_rdata   (conf_data_rdata),
    .conf_data_addr_ok (conf_data_addr_ok),
    .conf_data_data_ok (conf_data_data_ok)
);

cache_LRU d_cache(
    .clk(aclk), .rst(rst),

    .sram_en(data_sram_en),
    .sram_wen(data_sram_wen),
    .sram_addr(data_sram_addr),
    .sram_wdata(data_sram_wdata),
    .sram_rdata(data_sram_rdata),
    .sram_d_stall(data_sram_d_stall),

    .cache_data_req     (cache_data_req  ),      
    .cache_data_wr      (cache_data_wr   ),      
    .cache_data_size    (cache_data_size ),      
    .cache_data_addr    (cache_data_addr ),      
    .cache_data_wdata   (cache_data_wdata ),     
    .cache_data_rdata   (cache_data_rdata),      
    .cache_data_addr_ok (cache_data_addr_ok),    
    .cache_data_data_ok (cache_data_data_ok)
);

bridge_2x1 bridge_2x1(
    .no_dcache        (no_dcache    ),

    .ram_data_req     (cache_data_req  ),
    .ram_data_wr      (cache_data_wr   ),
    .ram_data_addr    (cache_data_addr ),
    .ram_data_wdata   (cache_data_wdata),
    .ram_data_size    (cache_data_size ),
    .ram_data_rdata   (cache_data_rdata),
    .ram_data_addr_ok (cache_data_addr_ok),
    .ram_data_data_ok (cache_data_data_ok),

    .conf_data_req     (conf_data_req  ),
    .conf_data_wr      (conf_data_wr   ),
    .conf_data_addr    (conf_data_addr ),
    .conf_data_wdata   (conf_data_wdata),
    .conf_data_size    (conf_data_size ),
    .conf_data_rdata   (conf_data_rdata),
    .conf_data_addr_ok (conf_data_addr_ok),
    .conf_data_data_ok (conf_data_data_ok),

    .wrap_data_req     (wrap_data_req  ),
    .wrap_data_wr      (wrap_data_wr   ),
    .wrap_data_addr    (wrap_data_addr ),
    .wrap_data_wdata   (wrap_data_wdata),
    .wrap_data_size    (wrap_data_size ),
    .wrap_data_rdata   (wrap_data_rdata),
    .wrap_data_addr_ok (wrap_data_addr_ok),
    .wrap_data_data_ok (wrap_data_data_ok)
);

//
cpu_axi_interface cpu_axi_interface(
    .clk(aclk),
    .resetn(aresetn),

    .inst_req       (cache_inst_req  ),
    .inst_wr        (cache_inst_wr   ),
    .inst_size      (cache_inst_size ),
    .inst_addr      (cache_inst_addr ),
    .inst_wdata     (cache_inst_wdata),
    .inst_rdata     (cache_inst_rdata),
    .inst_addr_ok   (cache_inst_addr_ok),
    .inst_data_ok   (cache_inst_data_ok),

    .data_req       (wrap_data_req  ),
    .data_wr        (wrap_data_wr   ),
    .data_size      (wrap_data_size ),
    .data_addr      (wrap_data_addr ),
    .data_wdata     (wrap_data_wdata ),
    .data_rdata     (wrap_data_rdata),
    .data_addr_ok   (wrap_data_addr_ok),
    .data_data_ok   (wrap_data_data_ok),

    .arid(arid),
    .araddr(araddr),
    .arlen(arlen),
    .arsize(arsize),
    .arburst(arburst),
    .arlock(arlock),
    .arcache(arcache),
    .arprot(arprot),
    .arvalid(arvalid),
    .arready(arready),

    .rid(rid),
    .rdata(rdata),
    .rresp(rresp),
    .rlast(rlast),
    .rvalid(rvalid),
    .rready(rready),

    .awid(awid),
    .awaddr(awaddr),
    .awlen(awlen),
    .awsize(awsize),
    .awburst(awburst),
    .awlock(awlock),
    .awcache(awcache),
    .awprot(awprot),
    .awvalid(awvalid),
    .awready(awready),

    .wid(wid),
    .wdata(wdata),
    .wstrb(wstrb),
    .wlast(wlast),
    .wvalid(wvalid),
    .wready(wready),

    .bid(bid),
    .bresp(bresp),
    .bvalid(bvalid),
    .bready(bready)
);

endmodule