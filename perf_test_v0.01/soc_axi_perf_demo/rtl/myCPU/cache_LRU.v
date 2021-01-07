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

    //�ӿ�ת��
    wire cpu_data_req;
    wire cpu_data_wr;
    wire[1 :0] cpu_data_size;
    wire[31:0] cpu_data_addr;
    wire[31:0] cpu_data_wdata;
    wire[31:0] cpu_data_rdata;
    wire cpu_data_addr_ok;
    wire  cpu_data_data_ok;
    wire hit, miss;
     wire           back_dirty ; //��Ҫ�����Ŀ��Ƿ������,���������Ҫд��
    
    
    assign cpu_data_req = sram_en;
    assign cpu_data_wr = sram_wen[0] | sram_wen[1] | sram_wen[2] | sram_wen[3];
    assign cpu_data_size = sram_wen == 4'b0001 | sram_wen == 4'b0010 | sram_wen == 4'b0100 | sram_wen == 4'b1000 ? 2'b00: 
                            sram_wen == 4'b0011 | sram_wen == 4'b1100 ? 2'b01:2'b10;
    assign cpu_data_addr = sram_addr;
    assign cpu_data_wdata = sram_wdata;
    assign sram_rdata = cpu_data_rdata;
    assign sram_d_stall = cpu_data_req ? (write_req | read_req ? 1'b1 : (hit ? 1'b0 : (cpu_data_wr & ~back_dirty ? 1'b0 : 1'b1))) : 1'b0;

    
    
    //Cache���ã�4·������
    //ָ�������λ��
    parameter  INDEX_WIDTH  = 10, OFFSET_WIDTH = 2;
    parameter TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    parameter CACHE_DEEPTH = 1 << INDEX_WIDTH;
    parameter GROUP_WIDTH  = 2;  //�����ж�������һ���λ��
    parameter GROUP_DEEPTH = 4; //4��
    parameter NEW_INDEX_WIDTH = INDEX_WIDTH - GROUP_WIDTH;//��Ϊ������,new_index ʵ���Ͼ�����id
    parameter GROUP_NUM = 1 <<NEW_INDEX_WIDTH; //����Ϊ��λ�����
    parameter NEW_TAG_WIDTH = TAG_WIDTH + GROUP_WIDTH; //Ϊ�˱�֤�ܼ���������ַ
    
    //Cache�洢��Ԫ
    reg                 cache_valid [CACHE_DEEPTH - 1 : 0];
    reg [NEW_TAG_WIDTH-1:0] cache_tag   [CACHE_DEEPTH - 1 : 0];
    reg [31:0]          cache_block [CACHE_DEEPTH - 1 : 0];
    //my code begin
    reg                 cache_dirty [CACHE_DEEPTH - 1 : 0];
        //my code end
    //���ʵ�ַ�ֽ�
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
    //����Cache line
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
    //�ж��Ƿ�����
    wire g_hit[GROUP_DEEPTH -1 : 0], g_miss[GROUP_DEEPTH -1 : 0];
    assign g_hit[2'b00] = c_valid[2'b00] & (c_tag[2'b00] == new_tag); 
    assign g_hit[2'b01] = c_valid[2'b01] & (c_tag[2'b01] == new_tag); 
    assign g_hit[2'b10] = c_valid[2'b10] & (c_tag[2'b10] == new_tag); 
    assign g_hit[2'b11] = c_valid[2'b11] & (c_tag[2'b11] == new_tag); 
     //cache line��validλΪ1����tag���ַ��tag���
      wire [31:0]          hit_block ; //���еĿ�
      wire           hit_dirty ; //���еĿ��Ƿ������
      wire [GROUP_WIDTH -1: 0] hit_index;//���еĿ�λ�����ڵ����
      assign hit_block = c_block[hit_index];
//      assign hit_dirty = c_dirty[hit_index]; 
      //hit_dirty�ƺ�û����, hit��ʱ�Ͳ����ǲ��������,Ӧ����back_dirt������
      assign hit_index = g_hit[2'b00]? 2'b00:
                         g_hit[2'b01]? 2'b01:
                         g_hit[2'b10]? 2'b10:2'b11;
                    //   g_hit[2'b11]? 2'b11;
     assign hit = g_hit[0]|g_hit[1]|g_hit[2]|g_hit[3];//ֻҪ������һ�����о�����
    assign miss = ~hit;
    //����д
    wire read, write;
    assign write = cpu_data_wr;
    assign read = ~write;

    reg [GROUP_DEEPTH -1 -1 : 0] cache_back_index[GROUP_NUM -1 : 0];//ÿ����һ���ı�ǼĴ���
    wire [GROUP_DEEPTH -1 -1 : 0 ]   c_back_index;//��ǰ��ı�ǼĴ���, �������û�õĿ������
    wire [GROUP_WIDTH -1 : 0]           back_index; //ѡ���������Ҫ�����Ŀ������
     wire [NEW_TAG_WIDTH-1:0]           back_tag;//ѡ���������Ҫ�����Ŀ������, ��back_index���д�ص�ַ
     wire [31:0]                        back_addr;
    wire [31:0]  back_block; //��Ҫ�����Ŀ������, ���û�����еĻ�
      assign back_dirty = c_dirty[back_index]; 
    assign c_back_index = cache_back_index[new_index];
    assign back_block   = c_block[back_index];
    assign back_tag     = c_tag[back_index];
    //д�ص�offset�ض�Ϊ 2'b00
    //��Ϊtag�ӳ���,�����������Լ���ȫ��
    assign back_addr    = {back_tag, new_index, 2'b00};
    //�����Ǽ򵥵�αlru�㷨,������Ҫ��д�صĿ���������
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


    //���ڴ�
    //����read_req, addr_rcv, read_finish���ڹ�����sram�źš�
    wire read_req;      //һ�������Ķ����񣬴ӷ��������󵽽���
    reg addr_rcv;       //��ַ���ճɹ�(addr_ok)�󵽽���
    wire read_finish;   //���ݽ��ճɹ�(data_ok)�������������
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    read_req & cache_data_addr_ok ? 1'b1 :
                    read_finish ? 1'b0 : addr_rcv;
    end
    assign read_req = state==RM;
    assign read_finish = read_req & cache_data_data_ok;

    //д�ڴ�
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
        write_save <= write; //�����д״̬
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
    
    //����ʹ����Ϊд������ok��,��������ݾ�OK��
    assign cpu_data_data_ok = read & cpu_data_req & hit |
                             write & cpu_data_req & hit |
                                 ~wb_req & cache_data_data_ok;

    //output to axi interface
    assign cache_data_req   = read_req & ~addr_rcv | write_req & ~waddr_rcv 
    | wb_req & ~wbaddr_rcv ;// д��ʱ����Ҫ��������, ��дȱʧʱ��Ҫ��������
    //CPU����д��ʱ����Ҫ������Ҫд��������
    assign cache_data_wr    = write_req | wb_req;
    // assign cache_data_wr    = cpu_data_wr;
    //���д�صĻ� sizeӦ������2'b10
    assign cache_data_size  = wb_req ? 2'b10 : cpu_data_size;
    //��Ϊ������,����д�صĵ�ַ�����ݶ���һ���ǵ�ǰ���ʵ�,д�صĵ�ַӦΪ{new_tag,new_index}
    //���ڵĵ�ַ��new_tag,new_index�������й�ϵ, �������ϲ�Ӧ���й�, ����Ҳ������������
    //new_indexһ������һ��, ���Ű�lru�㷨��ȡ, ��ǰ����line, ��������group, ��Ҫ�����ķ�Χ������, 
    //�൱����Чindex������, 
    // Ӧ��tag�ӳ�, ������cache���(���Ǽӳ�index), ����֤����ȡ��32λ�ڴ�����е�ַ, �����õ�ǰ��
    assign cache_data_addr  = wb_req ? back_addr : cpu_data_addr;
    //����cpu����,������д��CPU�е�������
    assign cache_data_wdata = wb_req ? back_block : cpu_data_wdata;

    //д��Cache
    //�����ַ�е�tag, index����ֹaddr�����ı�
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
        hit_index_save<=rst ?0: //�������еĿ�����ڱ��(û��ʲô����)
                    cpu_data_req ? hit_index:hit_index_save;
        back_index_save<=rst ?0: //������Ҫд�صĿ�����ڱ��, ����д��ĵ�ַ, ��Ҫ
                cpu_data_req ? back_index:back_index_save;
    end

    wire [31:0] write_cache_data;
    wire [3:0] write_mask;

    //���ݵ�ַ����λ��size������д���루���sb��sh�Ȳ���д����һ���ֵ�ָ���4λ��Ӧ1���֣�4�ֽڣ���ÿ���ֵ�дʹ��
    assign write_mask = cpu_data_size==2'b00 ?
                            (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
                                                (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
                            (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);
    //��Ҫд�صĺͽ����λ�ò�һ����index
    //�����ʹ�ã�λΪ1�Ĵ�����Ҫ���µġ�
    //λ��չ��{8{1'b1}} -> 8'b11111111
    //new_data = old_data & ~mask | write_data & mask
    assign write_cache_data = cache_block[{hit_index,new_index}] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

    integer t;
    always @(posedge clk) begin
        if(rst) begin
            for(t=0; t<CACHE_DEEPTH; t=t+1) begin   //�տ�ʼ��Cache��Ϊ��Ч
                cache_valid[t] <= 0;
                cache_dirty[t] <= 0;
            end
            for(t=0;t<GROUP_NUM;t=t+1 )begin
            cache_back_index[t] = 3'b000;
            end
        end
        else begin
            if(read_finish) begin //�ô����ʱ
                cache_valid[{back_index_save,index_save}] <= 1'b1;             //��Cache line��Ϊ��Ч
                cache_dirty[{back_index_save,index_save}] <= 1'b0;
                cache_tag  [{back_index_save,index_save}] <= tag_save;
                cache_block[{back_index_save,index_save}] <= cache_data_rdata; //д��Cache line
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
            else if(write & cpu_data_req & hit) begin   //д����ʱ��ҪдCache, ����dirty��1
                cache_dirty[{hit_index,new_index}] <= 1'b1;
                cache_block[{hit_index,new_index}] <= write_cache_data;      //д��Cache line��ʹ��index������index_save
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
            //������ʱ��Ҫ���ݵ�ǰ����id������lru�ı�־cache_back_index
                // cache_dirty[index] <= 1'b1;
                // cache_block[index] <= write_cache_data;      //д��Cache line��ʹ��index������index_save
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