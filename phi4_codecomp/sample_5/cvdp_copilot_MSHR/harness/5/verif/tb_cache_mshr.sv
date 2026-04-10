module tb_cache_mshr;

    // Parameters
    localparam INSTANCE_ID = "mo_mshr";
    localparam MSHR_SIZE = 32;
    localparam CS_LINE_ADDR_WIDTH = 10;
    localparam WORD_SEL_WIDTH = 4;
    localparam WORD_SIZE = 4;
    localparam MSHR_ADDR_WIDTH = $clog2(MSHR_SIZE);
    localparam TAG_WIDTH = 32 - (CS_LINE_ADDR_WIDTH + $clog2(WORD_SIZE) + WORD_SEL_WIDTH);
    localparam CS_WORD_WIDTH = WORD_SIZE * 8;
    localparam DATA_WIDTH = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH;

    // Clock and Reset
    reg clk;
    reg reset;

    // DUT Signals
    reg allocate_valid;
    reg [CS_LINE_ADDR_WIDTH-1:0] allocate_addr;
    reg allocate_rw;
    reg [DATA_WIDTH-1:0] allocate_data;
    wire allocate_ready;
    wire [MSHR_ADDR_WIDTH-1:0] allocate_id;
    wire allocate_pending;
    wire [MSHR_ADDR_WIDTH-1:0] allocate_previd;

    reg finalize_valid;
    reg finalize_is_release;
    reg [MSHR_ADDR_WIDTH-1:0] finalize_id;

    
    bit [CS_LINE_ADDR_WIDTH-1:0] fixed_addr ;
    bit [MSHR_ADDR_WIDTH-1:0] allocated_ids[$];
    int random_index ;
    
    class hit_mis;
            rand bit  hit;
            function new();
            endfunction
    
            constraint bias_to_miss {  hit dist{ 0:=6 , 1:=4};}
        endclass

    class allocate_req;
        rand bit [CS_LINE_ADDR_WIDTH-1:0] core_req_addr;
        rand bit core_req_rw;
        rand bit [WORD_SEL_WIDTH-1:0]     core_req_wsel; 
        rand bit [WORD_SIZE-1:0] core_req_byteen; 
        rand bit [CS_WORD_WIDTH-1:0] core_req_data;
        rand bit [TAG_WIDTH-1:0] core_req_tag;
        bit [DATA_WIDTH-1:0] entry_data ;

        
    
        function new();
        endfunction

        function void  post_randomize();
            entry_data = {core_req_rw, core_req_wsel, core_req_byteen, core_req_data, core_req_tag};
        endfunction
    endclass

    
    allocate_req req;
    hit_mis hit_random ;

    cache_mshr #(
        .INSTANCE_ID(INSTANCE_ID),
        .MSHR_SIZE(MSHR_SIZE),
        .CS_LINE_ADDR_WIDTH(CS_LINE_ADDR_WIDTH),
        .WORD_SEL_WIDTH(WORD_SEL_WIDTH),
        .WORD_SIZE(WORD_SIZE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .allocate_valid(allocate_valid),
        .allocate_addr(allocate_addr),
        .allocate_rw(allocate_rw),
        .allocate_data(allocate_data),
        .allocate_ready(allocate_ready),
        .allocate_id(allocate_id),
        .allocate_pending(allocate_pending),
        .allocate_previd(allocate_previd),
        .finalize_valid(finalize_valid),
        .finalize_id(finalize_id)
    );
	
    initial begin
      $dumpfile("dump.vcd"); $dumpvars;  
    end

    // Clock Generation
    always #5 clk = ~clk;

    // Task: Reset the DUT
    task reset_dut;
        begin
            reset = 1;
            #20;
            allocated_ids.delete(); // Delete all entries
            reset = 0;
            #20;
        end
    endtask

    
    task allocate_request(input allocate_req req);
        begin
            allocate_valid = 1;
            allocate_addr = req.core_req_addr;
            allocate_rw = req.core_req_rw;
            allocate_data =req.entry_data;
            @(negedge clk);
          	allocate_valid = 0;
            allocated_ids.push_back(allocate_id);
            //$display("Allocating ... Allocated id = %p", allocated_ids);

        end
    endtask

    task finalize_request(input bit hit, input int queue_idx);
        begin
            if (hit) begin
                finalize_valid = 1;
                finalize_is_release = 1;
                finalize_id = allocated_ids[queue_idx];
                @(negedge clk);
                finalize_valid = 0;
                finalize_is_release = 0;
                allocated_ids.delete(queue_idx);
                //$display("Finalizing ... Allocated id = %p", allocated_ids);
            end else begin 
                @(negedge clk) ;
            end
        end
    endtask

    task wait_random_negedge_cycles(input int min_cycles, input int max_cycles);
    int random_cycles;
        begin
            random_cycles = $urandom_range(min_cycles, max_cycles);

            for (int i = 0; i < random_cycles; i++) begin
                @(negedge clk);
            end
        end
    endtask


    initial begin
        req = new();
        hit_random = new();
        
        clk = 0;
        reset = 0;
        allocate_valid = 0;
        allocate_addr = 0;
        allocate_rw = 0;
        finalize_valid = 0;
        finalize_is_release = 0;
        

        

        reset_dut();
        @(negedge clk);
        fixed_addr = $urandom_range(0, $pow(2, CS_LINE_ADDR_WIDTH)-1);
        for (int i = 0; i < MSHR_SIZE; i++) begin : stim_gen_alloc
            assert(req.randomize());
            req.core_req_addr = fixed_addr ; 
            req.core_req_rw = 1'b0 ; 
            wait_random_negedge_cycles(0,5) ;
            if ( allocate_ready) begin    
                allocate_request(req);
                finalize_request(0, 0);
             end
        end
        
        reset_dut();
        @(negedge clk);
        fixed_addr = $urandom_range(0, $pow(2, CS_LINE_ADDR_WIDTH)-1);
        for (int i = 0; i < MSHR_SIZE; i++) begin : stim_gen_alloc
            assert(req.randomize());
            req.core_req_addr = fixed_addr ; 
            req.core_req_rw = 1'b1 ; 
            wait_random_negedge_cycles(0,5) ;
            if ( allocate_ready) begin    
                allocate_request(req);
                finalize_request(0, 0);
             end
        end

        reset_dut();
        @(negedge clk);
        fixed_addr = $urandom_range(0, $pow(2, CS_LINE_ADDR_WIDTH)-1);
        for (int i = 0; i < MSHR_SIZE; i++) begin : stim_gen_alloc
            assert(req.randomize());
            req.core_req_addr = fixed_addr ; 
            req.core_req_rw = 1'b0 ; 
            wait_random_negedge_cycles(0,5) ;
            if ( allocate_ready) begin    
                allocate_request(req);
                finalize_request(0, 0);
             end
        end

        reset_dut();
        @(negedge clk);
        fixed_addr = $urandom_range(0, $pow(2, CS_LINE_ADDR_WIDTH)-1);
        for (int i = 0; i < MSHR_SIZE; i++) begin : stim_gen_alloc
            assert(req.randomize());
            req.core_req_addr = fixed_addr ; 
            wait_random_negedge_cycles(0,5) ;
            if ( allocate_ready) begin    
                allocate_request(req);
                finalize_request(0, 0);
             end
        end

        @(negedge clk);
        for (int i = 0; i < MSHR_SIZE; i++) begin : stim_gen_finalize
            wait_random_negedge_cycles(0,5) ;
            finalize_request(1, 0);
        end

        reset_dut();
        @(negedge clk);

        for (int i = 0; i < 1000; i++) begin : random_stim_gen
            assert(req.randomize());
            wait_random_negedge_cycles(0,5) ;
            if ( allocate_ready) begin    
                allocate_request(req);
                assert(hit_random.randomize () );
                random_index = $urandom_range(0, allocated_ids.size() - 1);
                finalize_request(hit_random.hit, random_index);
             end
        end

        #100;
        $display("All tests completed.");
        $finish;
    end

endmodule