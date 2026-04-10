`timescale 1ns/1ps

module tb_ping_pong_fifo_2_axi_stream;

    parameter DATA_WIDTH = 32;

    // DUT IO signals
    logic rst;
    logic i_flush;
    logic i_pause;

    // FIFO signals
    logic i_block_fifo_rdy;
    logic o_block_fifo_act;
    logic [23:0] i_block_fifo_size;
    logic [(DATA_WIDTH + 1)-1:0] i_block_fifo_data;
    logic o_block_fifo_stb;
    logic [3:0] i_axi_user;

    // AXI signals
    logic i_axi_clk;
    logic [3:0] o_axi_user;
    logic i_axi_ready;
    logic [DATA_WIDTH-1:0] o_axi_data;
    logic o_axi_last;
    logic o_axi_valid;

    // Instantiate DUT
    ping_pong_fifo_2_axi_stream #(.DATA_WIDTH(DATA_WIDTH)) dut (
        .rst                (rst),
        .i_flush            (i_flush),
        .i_pause            (i_pause),
        .i_block_fifo_rdy   (i_block_fifo_rdy),
        .o_block_fifo_act   (o_block_fifo_act),
        .i_block_fifo_size  (i_block_fifo_size),
        .i_block_fifo_data  (i_block_fifo_data),
        .o_block_fifo_stb   (o_block_fifo_stb),
        .i_axi_user         (i_axi_user),
        .i_axi_clk          (i_axi_clk),
        .o_axi_user         (o_axi_user),
        .i_axi_ready        (i_axi_ready),
        .o_axi_data         (o_axi_data),
        .o_axi_last         (o_axi_last),
        .o_axi_valid        (o_axi_valid)
    );

    initial begin
        i_axi_clk = 0;
        forever #5 i_axi_clk = ~i_axi_clk;
    end

    integer i;
    logic [DATA_WIDTH-1:0] mem_data [0:255];
    integer block_size;
    integer idx;

    always @(posedge i_axi_clk) begin
        if (o_axi_valid) begin
            $display("[%t] AXI OUT: data=0x%h, user=0x%h, last=%b", $time, o_axi_data, o_axi_user, o_axi_last);
        end
    end

    // Initialize signals
    initial begin
        rst = 1;
        i_flush = 0;
        i_pause = 0;
        i_block_fifo_rdy = 0;
        i_block_fifo_size = 0;
        i_block_fifo_data = 0;
        i_axi_user = 4'hA;
        i_axi_ready = 1;
        
        for (i = 0; i < 256; i++) begin
            mem_data[i] = i;
        end

        @(posedge i_axi_clk);
        @(posedge i_axi_clk);
        rst = 0;
        
        $display("Test 1");
        block_size = 8;
        i_block_fifo_size = block_size;
        i_block_fifo_rdy = 1;
        wait(o_block_fifo_act == 1);
        $display("[%t] (size=%0d)", $time, block_size);
        @(posedge i_axi_clk);
        for (idx = 0; idx < block_size; idx++) begin
            wait(o_block_fifo_stb == 1);
            i_block_fifo_data = {1'b0, mem_data[idx]}; // {VALID_BIT, DATA}
            $display("[%t] 0x%h ", $time, mem_data[idx]);
            @(posedge i_axi_clk);
        end
        wait(o_axi_last == 1);
        @(posedge i_axi_clk);
        i_block_fifo_rdy = 0;
        $display("[%t] Test 1 completed.", $time);

        $display("Test 2");
        block_size = 4;
        i_block_fifo_size = block_size;
        i_block_fifo_rdy = 1;
        wait(o_block_fifo_act == 1);
        $display("[%t] (size=%0d)", $time, block_size);

        for (idx = 0; idx < block_size; idx++) begin
            wait(o_block_fifo_stb == 1);
            i_block_fifo_data = {1'b0, mem_data[idx+10]};
            $display("[%t]  0x%h", $time, mem_data[idx+10]);
            @(posedge i_axi_clk);
        end
        wait(o_axi_last == 1);
        @(posedge i_axi_clk);

        i_block_fifo_size = block_size;
        wait(o_block_fifo_act == 1);
        $display("[%t] (size=%0d)", $time, block_size);
        for (idx = 0; idx < block_size; idx++) begin
            wait(o_block_fifo_stb == 1);
            i_block_fifo_data = {1'b0, mem_data[idx+20]};
            $display("[%t]  0x%h", $time, mem_data[idx+20]);
            @(posedge i_axi_clk);
        end
        wait(o_axi_last == 1);
        @(posedge i_axi_clk);
        i_block_fifo_rdy = 0;
        $display("[%t] Test 2 completed.", $time);

        $display("Test 3");
        block_size = 5;
        i_block_fifo_size = block_size;
        i_block_fifo_rdy = 1;
        wait(o_block_fifo_act == 1);
        $display("[%t]  (size=%0d)", $time, block_size);
        
        for (idx = 0; idx < 2; idx++) begin
            wait(o_block_fifo_stb == 1);
            i_block_fifo_data = {1'b0, mem_data[idx+30]};
            $display("[%t] 0x%h", $time, mem_data[idx+30]);
            @(posedge i_axi_clk);
        end
        
        $display("[%t] ", $time);
        i_flush = 1;
        @(posedge i_axi_clk);
        i_flush = 0;
        i_block_fifo_rdy = 0;
        $display("[%t] Test 3 completed ", $time);

        $display("Test 4");
        block_size = 6;
        i_block_fifo_size = block_size;
        i_block_fifo_rdy = 1;
        wait(o_block_fifo_act == 1);
        $display("[%t] (size=%0d)", $time, block_size);

        for (idx = 0; idx < block_size; idx++) begin
            wait(o_block_fifo_stb == 1);
            i_block_fifo_data = {1'b0, mem_data[idx+40]};
            $display("[%t]  0x%h", $time, mem_data[idx+40]);
            @(posedge i_axi_clk);

            if (idx == 2) begin
                $display("[%t] ", $time);
                i_pause = 1;
                repeat (5) @(posedge i_axi_clk);
                i_pause = 0; 
                $display("[%t] ", $time);
            end
        end
        wait(o_axi_last == 1);
        @(posedge i_axi_clk);
        i_block_fifo_rdy = 0;
        $display("[%t] Test 4 completed.", $time);

        $display("Test 5");
        block_size = 4;
        i_block_fifo_size = block_size;
        i_block_fifo_rdy = 1;
        wait(o_block_fifo_act == 1);
        $display("[%t] (size=%0d)", $time, block_size);

        for (idx = 0; idx < block_size; idx++) begin
            wait(o_block_fifo_stb == 1);
            i_block_fifo_data = {1'b0, mem_data[idx+50]};
            $display("[%t] : 0x%h", $time, mem_data[idx+50]);
            @(posedge i_axi_clk);
        end

        $display("[%t] ", $time);
        i_axi_ready = 0;
        repeat(10) @(posedge i_axi_clk);
        i_axi_ready = 1;
        $display("[%t] ", $time);

        wait(o_axi_last == 1);
        @(posedge i_axi_clk);
        i_block_fifo_rdy = 0;
        $display("[%t] Test 5 completed.", $time);

        $display("All tests completed successfully.");
        $finish;
    end

endmodule