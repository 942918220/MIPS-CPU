module exception(
    input wire rst,
    input wire[7:0] except,
    input wire[31:0] cp0_cause,cp0_status,
    output reg[31:0] excepttype
);

always @(*) begin
    if (rst) begin
        excepttype <= 32'b0; 
    end
    else begin
        excepttype <= 32'b0;
        if (((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00)&&  //屏蔽中断
            (cp0_status[1] == 0) && (cp0_status[0] == 1)) begin
            excepttype <= 32'h00000001;
        end
        else if (except[7] == 1'b1) begin  //地址错例�?(读数据或取指�?)
            excepttype <= 32'h00000004;
        end
        else if (except[1] == 1'b1) begin  //地址错例�?(写数�?)
            excepttype <= 32'h00000005;
        end
        else if (except[6] == 1'b1) begin //系统调用例外
            excepttype <= 32'h00000008;
        end
        else if (except[5] == 1'b1) begin //断点例外
            excepttype <= 32'h00000009;
        end
        else if (except[4] == 1'b1) begin //eret
            excepttype <= 32'h0000000e;
        end
        else if (except[3] == 1'b1) begin //保留指令例外
            excepttype <= 32'h0000000a;
        end
        else if (except[2] == 1'b1) begin //算出溢出例外
            excepttype <= 32'h0000000c;
        end
    end
end

endmodule