module cache_LRU (
    input wire clk, rst,
    //mips core
    input wire sram_en,
    input wire[3:0] sram_wen,
    input  wire[31:0]sram_addr,
    input  wire[31:0]sram_wdata,
    output wire[31:0]sram_rdata,
    output wire sram_d_stall,

    //axi interface
    output  wire       cache_data_req     ,
    output  wire       cache_data_wr      ,
    output  wire[1 :0] cache_data_size    ,
    output  wire[31:0] cache_data_addr    ,
    output  wire[31:0] cache_data_wdata   ,
    input   wire[31:0] cache_data_rdata   ,
    input   wire       cache_data_addr_ok ,
    input   wire       cache_data_data_ok 
);

    //接口转换
    wire cpu_data_req;
    wire cpu_data_wr;
    wire[1 :0] cpu_data_size;
    wire[31:0] cpu_data_addr;
    wire[31:0] cpu_data_wdata;
    wire[31:0] cpu_data_rdata;
    wire cpu_data_addr_ok;
    wire  cpu_data_data_ok;
    wire hit, miss;
     wire           back_dirty ; //需要被换的块是否是脏的,如果是则需要写回
    
    
    assign cpu_data_req = sram_en;
    assign cpu_data_wr = sram_wen[0] | sram_wen[1] | sram_wen[2] | sram_wen[3];
    assign cpu_data_size = sram_wen == 4'b0001 | sram_wen == 4'b0010 | sram_wen == 4'b0100 | sram_wen == 4'b1000 ? 2'b00: 
                            sram_wen == 4'b0011 | sram_wen == 4'b1100 ? 2'b01:2'b10;
    assign cpu_data_addr = sram_addr;
    assign cpu_data_wdata = sram_wdata;
    assign sram_rdata = cpu_data_rdata;
    assign sram_d_stall = cpu_data_req ? (write_req | read_req ? 1'b1 : (hit ? 1'b0 : (cpu_data_wr & ~back_dirty ? 1'b0 : 1'b1))) : 1'b0;

    
    
    //Cache配置，4路组相联
    //指令各部分位宽
    parameter  INDEX_WIDTH  = 10, OFFSET_WIDTH = 2;
    parameter TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    parameter CACHE_DEEPTH = 1 << INDEX_WIDTH;
    parameter GROUP_WIDTH  = 2;  //用于判断属于那一组的位宽
    parameter GROUP_DEEPTH = 4; //4组
    parameter NEW_INDEX_WIDTH = INDEX_WIDTH - GROUP_WIDTH;//因为组相连,new_index 实际上就是组id
    parameter GROUP_NUM = 1 <<NEW_INDEX_WIDTH; //以组为单位的深度
    parameter NEW_TAG_WIDTH = TAG_WIDTH + GROUP_WIDTH; //为了保证能检索完整地址
    
    //Cache存储单元
    reg                 cache_valid [CACHE_DEEPTH - 1 : 0];
    reg [NEW_TAG_WIDTH-1:0] cache_tag   [CACHE_DEEPTH - 1 : 0];
    reg [31:0]          cache_block [CACHE_DEEPTH - 1 : 0];
    //my code begin
    reg                 cache_dirty [CACHE_DEEPTH - 1 : 0];
        //my code end
    //访问地址分解
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [NEW_INDEX_WIDTH-1:0] new_index;
    // wire [TAG_WIDTH-1:0] tag;
    wire [NEW_TAG_WIDTH-1:0] new_tag;
    
    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    // assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];
    assign new_index = cpu_data_addr[NEW_INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign new_tag = cpu_data_addr[31 : NEW_INDEX_WIDTH + OFFSET_WIDTH];
    //访问Cache line
    wire                 c_valid [GROUP_DEEPTH -1 : 0];
    wire [NEW_TAG_WIDTH-1:0]c_tag[GROUP_DEEPTH -1 : 0];
    wire [31:0]          c_block [GROUP_DEEPTH -1 : 0];
    wire                 c_dirty [GROUP_DEEPTH -1 : 0];
    assign c_dirty[2'b00] = cache_dirty[{2'b00,new_index}];
    assign c_dirty[2'b01] = cache_dirty[{2'b01,new_index}];
    assign c_dirty[2'b10] = cache_dirty[{2'b10,new_index}];
    assign c_dirty[2'b11] = cache_dirty[{2'b11,new_index}];

    // assign c_valid = cache_valid[{index}];
    // assign c_tag  = cache_tag  [{index}];
    // assign c_block = cache_block[{index}];
    assign c_valid[2'b00] = cache_valid[{2'b00,new_index}];
    assign c_valid[2'b01] = cache_valid[{2'b01,new_index}];
    assign c_valid[2'b10] = cache_valid[{2'b10,new_index}];
    assign c_valid[2'b11] = cache_valid[{2'b11,new_index}];
    assign   c_tag[2'b00] = cache_tag  [{2'b00,new_index}];
    assign   c_tag[2'b01] = cache_tag  [{2'b01,new_index}];
    assign   c_tag[2'b10] = cache_tag  [{2'b10,new_index}];
    assign   c_tag[2'b11] = cache_tag  [{2'b11,new_index}];
    assign c_block[2'b00] = cache_block[{2'b00,new_index}];
    assign c_block[2'b01] = cache_block[{2'b01,new_index}];
    assign c_block[2'b10] = cache_block[{2'b10,new_index}];
    assign c_block[2'b11] = cache_block[{2'b11,new_index}];
    //判断是否命中
    wire g_hit[GROUP_DEEPTH -1 : 0], g_miss[GROUP_DEEPTH -1 : 0];
    assign g_hit[2'b00] = c_valid[2'b00] & (c_tag[2'b00] == new_tag); 
    assign g_hit[2'b01] = c_valid[2'b01] & (c_tag[2'b01] == new_tag); 
    assign g_hit[2'b10] = c_valid[2'b10] & (c_tag[2'b10] == new_tag); 
    assign g_hit[2'b11] = c_valid[2'b11] & (c_tag[2'b11] == new_tag); 
     //cache line的valid位为1，且tag与地址中tag相等
      wire [31:0]          hit_block ; //命中的块
      wire           hit_dirty ; //命中的块是否是脏的
      wire [GROUP_WIDTH -1: 0] hit_index;//命中的块位于组内的序号
      assign hit_block = c_block[hit_index];
//      assign hit_dirty = c_dirty[hit_index]; 
      //hit_dirty似乎没有用, hit的时就不管是不是脏的了,应该是back_dirt才有用
      assign hit_index = g_hit[2'b00]? 2'b00:
                         g_hit[2'b01]? 2'b01:
                         g_hit[2'b10]? 2'b10:2'b11;
                    //   g_hit[2'b11]? 2'b11;
     assign hit = g_hit[0]|g_hit[1]|g_hit[2]|g_hit[3];//只要组里有一个命中就命中
    assign miss = ~hit;
    //读或写
    wire read, write;
    assign write = cpu_data_wr;
    assign read = ~write;

    reg [GROUP_DEEPTH -1 -1 : 0] cache_back_index[GROUP_NUM -1 : 0];//每个组一个的标记寄存器
    wire [GROUP_DEEPTH -1 -1 : 0 ]   c_back_index;//当前组的标记寄存器, 存着最久没用的块的索引
    wire [GROUP_WIDTH -1 : 0]           back_index; //选择出组中需要被换的块的索引
     wire [NEW_TAG_WIDTH-1:0]           back_tag;//选择出组中需要被换的块的索引, 与back_index组成写回地址
     wire [31:0]                        back_addr;
    wire [31:0]  back_block; //需要被换的块的数据, 如果没有命中的话
      assign back_dirty = c_dirty[back_index]; 
    assign c_back_index = cache_back_index[new_index];
    assign back_block   = c_block[back_index];
    assign back_tag     = c_tag[back_index];
    //写回的offset必定为 2'b00
    //因为tag加长了,所以这样可以检索全部
    assign back_addr    = {back_tag, new_index, 2'b00};
    //下面是简单的伪lru算法,查找需要被写回的块的组间索引
    assign back_index = c_back_index[0] ?( c_back_index[2] ? 2'b11 : 2'b10):
                                        ( c_back_index[1]? 2'b01 : 2'b00 );



    //FSM
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11, WB = 2'b10;
    reg [1:0] state;
    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE:   state <= cpu_data_req & read & miss &~back_dirty ? RM :
                                 cpu_data_req & write& miss &~back_dirty ? WM :
                                //  cpu_data_req & read & hit  ? IDLE :
                                 cpu_data_req & miss & back_dirty ? WB : IDLE;
                WB:     state <= read & cache_data_data_ok ? RM:
                                write & cache_data_data_ok ? WM: WB;
                RM:     state <= read & cache_data_data_ok ? IDLE : RM;
                WM:     state <=write & cache_data_data_ok ? IDLE : WM;
            endcase
        end
    end


    //读内存
    //变量read_req, addr_rcv, read_finish用于构造类sram信号。
    wire read_req;      //一次完整的读事务，从发出读请求到结束
    reg addr_rcv;       //地址接收成功(addr_ok)后到结束
    wire read_finish;   //数据接收成功(data_ok)，即读请求结束
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    read_req & cache_data_addr_ok ? 1'b1 :
                    read_finish ? 1'b0 : addr_rcv;
    end
    assign read_req = state==RM;
    assign read_finish = read_req & cache_data_data_ok;

    //写内存
    wire write_req;     
    reg waddr_rcv;      
    wire write_finish;   
    always @(posedge clk) begin
        waddr_rcv <= rst ? 1'b0 :
                     write_req & cache_data_addr_ok ? 1'b1 :
                     write_finish ? 1'b0 : waddr_rcv;
    end
    assign write_req = state==WM;
    assign write_finish = write_req & cache_data_data_ok;

        wire wb_req;     
    reg wbaddr_rcv, write_save;      
    wire wb_finish;   
    always @(posedge clk) begin
        wbaddr_rcv <= rst ? 1'b0 :
                     wb_req & cache_data_addr_ok ? 1'b1 :
                     wb_finish ? 1'b0 : wbaddr_rcv;
        if(wbaddr_rcv) begin
        write_save <= write; //保存读写状态
        end
    end
    assign wb_req = state==WB;
    assign wb_finish = wb_req & cache_data_data_ok;
    // assign wb_finish = miss & back_dirty & cache_data_data_ok;

    //output to mips core
    assign cpu_data_rdata   = hit ? hit_block : cache_data_rdata;
    assign cpu_data_addr_ok = read & cpu_data_req & hit |
                              write & cpu_data_req & hit |
                                ~wb_req & cache_data_req & cache_data_addr_ok;
    
    //不能使其以为写回数据ok了,请求的数据就OK了
    assign cpu_data_data_ok = read & cpu_data_req & hit |
                             write & cpu_data_req & hit |
                                 ~wb_req & cache_data_data_ok;

    //output to axi interface
    assign cache_data_req   = read_req & ~addr_rcv | write_req & ~waddr_rcv 
    | wb_req & ~wbaddr_rcv ;// 写回时不需要请求数据, 读写缺失时需要请求数据
    //CPU读和写的时候都需要可能需要写回脏数据
    assign cache_data_wr    = write_req | wb_req;
    // assign cache_data_wr    = cpu_data_wr;
    //如果写回的话 size应该总是2'b10
    assign cache_data_size  = wb_req ? 2'b10 : cpu_data_size;
    //因为成组了,所以写回的地址和数据都不一定是当前访问的,写回的地址应为{new_tag,new_index}
    //组内的地址和new_tag,new_index长度上有关系, 但数据上不应该有关, 否则也不是组相连了
    //new_index一样的在一组, 组编号按lru算法来取, 以前是找line, 现在是找group, 需要索引的范围减少了, 
    //相当于有效index缩短了, 
    // 应将tag加长, 或增加cache深度(即是加长index), 来保证可以取到32位内存的所有地址, 这里用的前者
    assign cache_data_addr  = wb_req ? back_addr : cpu_data_addr;
    //返回cpu数据,或者是写回CPU中的脏数据
    assign cache_data_wdata = wb_req ? back_block : cpu_data_wdata;

    //写入Cache
    //保存地址中的tag, index，防止addr发生改变
        wire read_save, read_hit, write_hit;
        assign read_hit = read  & cpu_data_req & hit;
        assign write_hit= write & cpu_data_req & hit;

      assign read_save = ~write_save;
    reg [NEW_TAG_WIDTH-1:0] tag_save;
    reg [NEW_INDEX_WIDTH-1:0] index_save;
    reg [GROUP_WIDTH -1: 0]hit_index_save;
    reg [GROUP_WIDTH -1: 0]back_index_save;
    always @(posedge clk) begin
        tag_save   <= rst ? 0 :
                      cpu_data_req ? new_tag : tag_save;
        index_save <= rst ? 0 :
                      cpu_data_req ? new_index : index_save;
        write_save <= rst ? 0 :
                      cpu_data_req ? write : write_save;
        hit_index_save<=rst ?0: //保存命中的块的组内编号(没有什么意义)
                    cpu_data_req ? hit_index:hit_index_save;
        back_index_save<=rst ?0: //保存需要写回的块的组内编号, 即新写入的地址, 重要
                cpu_data_req ? back_index:back_index_save;
    end

    wire [31:0] write_cache_data;
    wire [3:0] write_mask;

    //根据地址低两位和size，生成写掩码（针对sb，sh等不是写完整一个字的指令），4位对应1个字（4字节）中每个字的写使能
    assign write_mask = cpu_data_size==2'b00 ?
                            (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
                                                (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
                            (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);
    //需要写回的和进入的位置不一定是index
    //掩码的使用：位为1的代表需要更新的。
    //位拓展：{8{1'b1}} -> 8'b11111111
    //new_data = old_data & ~mask | write_data & mask
    assign write_cache_data = cache_block[{hit_index,new_index}] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

    integer t;
    always @(posedge clk) begin
        if(rst) begin
            for(t=0; t<CACHE_DEEPTH; t=t+1) begin   //刚开始将Cache置为无效
                cache_valid[t] <= 0;
                cache_dirty[t] <= 0;
            end
            for(t=0;t<GROUP_NUM;t=t+1 )begin
            cache_back_index[t] = 3'b000;
            end
        end
        else begin
            if(read_finish) begin //访存结束时
                cache_valid[{back_index_save,index_save}] <= 1'b1;             //将Cache line置为有效
                cache_dirty[{back_index_save,index_save}] <= 1'b0;
                cache_tag  [{back_index_save,index_save}] <= tag_save;
                cache_block[{back_index_save,index_save}] <= cache_data_rdata; //写入Cache line
                               case(back_index_save)
                    2'b00:begin
                        cache_back_index[index_save][0] <= 1;
                        cache_back_index[index_save][1] <= 1;
                    end
                    2'b01:begin
                        cache_back_index[index_save][0] <= 1;
                        cache_back_index[index_save][1] <= 0;
                    end
                    2'b10:begin
                        cache_back_index[index_save][0] <= 0;
                        cache_back_index[index_save][2] <= 1;
                    end
                    2'b11:begin
                        cache_back_index[index_save][0] <= 0;
                        cache_back_index[index_save][2] <= 0;
                    end
                    endcase
            end
            else if(write & cpu_data_req & hit) begin   //写命中时需要写Cache, 并将dirty置1
                cache_dirty[{hit_index,new_index}] <= 1'b1;
                cache_block[{hit_index,new_index}] <= write_cache_data;      //写入Cache line，使用index而不是index_save
                               case(hit_index)
                    2'b00:begin
                        cache_back_index[new_index][0] <= 1;
                        cache_back_index[new_index][1] <= 1;
                    end
                    2'b01:begin
                        cache_back_index[new_index][0] <= 1;
                        cache_back_index[new_index][1] <= 0;
                    end
                    2'b10:begin
                        cache_back_index[new_index][0] <= 0;
                        cache_back_index[new_index][2] <= 1;
                    end
                    2'b11:begin
                        cache_back_index[new_index][0] <= 0;
                        cache_back_index[new_index][2] <= 0;
                    end
                    endcase

            end
            else if(read & cpu_data_req & hit) begin   
            //读命中时需要根据当前命中id来更新lru的标志cache_back_index
                // cache_dirty[index] <= 1'b1;
                // cache_block[index] <= write_cache_data;      //写入Cache line，使用index而不是index_save
                case(hit_index)
                    2'b00:begin
                        cache_back_index[new_index][0] <= 1;
                        cache_back_index[new_index][1] <= 1;
                    end
                    2'b01:begin
                        cache_back_index[new_index][0] <= 1;
                        cache_back_index[new_index][1] <= 0;
                    end
                    2'b10:begin
                        cache_back_index[new_index][0] <= 0;
                        cache_back_index[new_index][2] <= 1;
                    end
                    2'b11:begin
                        cache_back_index[new_index][0] <= 0;
                        cache_back_index[new_index][2] <= 0;
                    end
                    endcase

            end
        end
    end
endmodule