module direct_map_cache #(
    parameter CACHE_SIZE = 256,
    parameter DATA_WIDTH = 16,
    parameter TAG_WIDTH = 5,
    parameter OFFSET_WIDTH = 3,
    parameter N = 2
) (
    input wire enable,
    input wire [N*(CACHE_SIZE)-1:N*0] index,
    input wire [OFFSET_WIDTH-1:0] offset,
    input wire comp,
    input wire write,
    input [TAG_WIDTH-1:0] tag_in,
    input [DATA_WIDTH-1:0] data_in,
    input wire valid_in,
    input wire [DATA_WIDTH-1:0] data_out,
    input wire valid,
    input wire error
    output reg hit,
    output reg dirty,
    output reg [TAG_WIDTH-1:0] tag_out,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg valid,
    output reg [TAG_WIDTH-1:0] tag_out,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg valid,
    output reg error
) 

    // Cache line definitions
    reg [TAG_WIDTH-1:0] tags_set [N*(CACHE_SIZE)-1:N*0];                       // Tag storage per set
    reg [DATA_WIDTH-1:0] data_set [N*(CACHE_SIZE)-1:N*0][OFFSET_WIDTH:0];  // Data storage per set
    reg valid_set [N*(CACHE_SIZE)-1:N*0];                                     // Valid bits per set
    reg dirty_set [N*(CACHE_SIZE)-1:N*0];                                      // Dirty bits per set
    reg victimway [N*(CACHE_SIZE)-1:N*0];                                      // Victim way selection
    integer i;

    // Variables for tag lookup
    reg [TAG_WIDTH-1:0] tag;                                                // Current tag being checked
    reg [TAG_WIDTH-1:0] tag0;                                               // First tag in pair
    reg [TAG_WIDTH-1:0] tag1;                                               // Second tag in pair
    reg [TAG_WIDTH-1:0] tag0_valid;                                         // Validity of first tag
    reg [TAG_WIDTH-1:0] tag1_valid;                                         // Validity of second tag
    reg i0;                                                                  // Index for first way
    reg i1;                                                                  // Index for second way

    // Sequential logic for cache operations
    always @(posedge clk) begin
        if (rst) begin
            // Initialize cache lines on reset
            for (i = 0; i < CACHE_SIZE * N; i = i + 1) begin
                valid_set[i] <= 1'b0;                                      // All lines initially invalid
                dirty_set[i] <= 1'b0;                                       // All lines initially clean
            end
            victimway <= 0;                                              // Initial victim way
            hit <= 1'b0;                                                  // No hits yet
            dirty <= 1'b0;                                                 // No dirty bits yet
            valid <= 1'b0;                                                 // No valid lines yet
        end 
        else if (enable) begin
            // Check for LSB alignment error
            if (offset[0] == 1'b1) begin
                error <= 1'b1;                                // Set error if LSB of offset is 1
                hit <= 1'b0;                                 
                dirty <= 1'b0;                              // Clear dirty flag
                valid <= 1'b0;                              // Clear validity
                data_out <= {DATA_WIDTH{1'b0}};              // Return default value
            end 
            else begin
                // Compare operation
                if (comp) begin
                    if (write) begin
                        // Access Write (comp = 0, write = 1)
                        // Tags and data are compared here
                        if (tag_in == tag0) begin
                            // Match found in first way
                            hit <= 1'b1;
                            data_out <= data_set[i0][offset[OFFSET_WIDTH-1:1]];
                            dirty_set[victimway] <= 1'b1;
                            valid_set[victimway] <= valid_in;
                            tag_out <= tag0;
                            victimway <= (victimway + 1) % (CACHE_SIZE * N);
                        end 
                        else begin
                            // No match in first way
                            if (tag_in == tag1) begin
                                // Match found in second way
                                hit <= 1'b1;
                                data_out <= data_set[i1][offset[OFFSET_WIDTH-1:1]];
                                dirty_set[victimway] <= 1'b1;
                                valid_set[victimway] <= valid_in;
                                tag_out <= tag1;
                                victimway <= (victimway + 1) % (CACHE_SIZE * N);
                            end 
                            else begin
                                // No matches found
                                hit <= 1'b0;
                                tag_out <= tag0;
                                data_out <= data_set[i0][offset[OFFSET_WIDTH-1:1]];
                                valid_set[victimway] <= valid_in;
                                dirty_set[victimway] <= 1'b0;
                                victimway <= (victimway + 1) % (CACHE_SIZE * N);
                            end 
                        end
                    end 
                    else begin
                        // Compare
                        if (write) begin
                            // Access Read (comp = 0, write = 0)
                            // Compares read (comp = 0, write = 0)
                            if (tag_in == tag0) begin
                                // Match found in first way
                                hit <= 1'b1;
                                data_out <= data_set[i0][offset[OFFSET_WIDTH-1:1]];
                                valid_set[victimway] <= valid_in;
                                dirty_set[victimway] <= 1'b1;
                                tag_out <= tag0;
                                victimway <= (victimway + 1) % (CACHE_SIZE * N);
                            end 
                            else begin
                                // No match in first way
                                if (tag_in == tag1) begin
                                    // Match found in second way
                                    hit <= 1'b1;
                                    data_out <= data_set[i1][offset[OFFSET_WIDTH-1:1]];
                                    valid_set[victimway] <= valid_in;
                                    dirty_set[victimway] <= 1'b1;
                                    tag_out <= tag1;
                                    victimway <= (victimway + 1) % (CACHE_SIZE * N);
                                end 
                                else begin
                                    // No matches found
                                    hit <= 1'b0;
                                    tag_out <= tag0;
                                    data_out <= data_set[i0][offset[OFFSET_WIDTH-1:1]];
                                    valid_set[victimway] <= valid_in;
                                    dirty_set[victimway] <= 1'b0;
                                    victimway <= (victimway + 1) % (CACHE_SIZE * N);
                                end 
                            end 
                        end 
                    end 
                end 
                // Write operation
                if (write) begin
                    // Write operation
                    if (valid_in) begin
                        if (tag0_valid || tag1_valid) begin
                            if (tag0_valid) begin
                                // Write to first way
                                data_set[i0][offset[OFFSET_WIDTH-1:1]] <= data_in;
                                dirty_set[i0] <= 1'b1;
                                valid_set[i0] <= valid_in;
                                victimway <= (victimway + 1) % (CACHE_SIZE * N);
                            end 
                            else if (tag1_valid) begin
                                // Write to second way
                                data_set[i1][offset[OFFSET_WIDTH-1:1]] <= data_in;
                                dirty_set[i1] <= 1'b1;
                                valid_set[i1] <= valid_in;
                                victimway <= (victimway + 1) % (CACHE_SIZE * N);
                            end 
                        end
                        else begin
                            // No valid line found, use victim way
                            data_set[victimway][offset[OFFSET_WIDTH-1:1]] <= data_in;
                            dirty_set[victimway] <= 1'b1;
                            valid_set[victimway] <= valid_in;
                            victimway <= (victimway + 1) % (CACHE_SIZE * N);
                        end 
                    end 
                    hit <= 1'b0;
                    dirty <= 1'b0;
                    valid <= 1'b0;
                end 
            end 
        end 
        else begin 
            // enable is low
            // enable is low
            for (i = 0; i < CACHE_SIZE * N; i = i + 1) begin
                valid_set[i] <= 1'b0;                           
                dirty_set[i] <= 1'b0;                                                  
            end
            hit <= 1'b0;                                       
            dirty <= 1'b0;                                                         
            valid <= 1'b0;                                     
        end 
    end 

    // Clock generation
    initial begin
        // Initialize inputs
        enable = 0;
        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk); 

        // Enable cache
        enable = 1;
        // Pseudo-Random Replacement Condition Checking
        // Fill the cache to trigger replacement
        write_task(8'h02, 3'b000, 5'b00000, 1'b1,1'b1);
        read_task(8'h02, 3'b000, 5'b00000, 1'b1);
        write_task(8'h02, 3'b000, 5'b00001, 1'b1,1'b1);
        read_task(8'h02, 3'b000, 5'b00001, 1'b1);
        write_task(8'h02, 3'b000, 5'b00010, 1'b1,1'b1);
        read_task(8'h02, 3'b000, 5'b00010, 1'b1);
        write_task(8'h02, 3'b000, 5'b00011, 1'b1,1'b1);
        read_task(8'h02, 3'b000, 5'b00011, 1'b1);

        @(posedge clk); 

        // Write to cache without compare
        write_task(8'h00, 3'b001, 5'b00001, 1'b0,1'b1);

        // Read from cache without compare
        read_task(8'h00, 3'b001, 5'b00001, 1'b0);

        // Write to cache with compare
        write_task(8'h00, 3'b001, 5'b00001, 1'b1,1'b1);

        // Read from cache with compare
        read_task(8'h00, 3'b001, 5'b00001, 1'b1);

        // Error condition
        write_task(8'h01, 3'b110, 5'b00010, 1'b0,1'b1);      
        $display("  -> [ERROR] Data mismatch! data_in=%0h, data_out=%0h", data_in, data_out);
        $finish;
    end

    // Task to handle writing to the cache
    task write_task(input [7:0] index, input [2:0] off, input [4:0] tag, input compr, valid);
        begin
            index = index;  
            offset = off; 
            tag_in = tag; 
            data_in = $random; 
            valid_in = valid;    
            write = 1'b1;       
            comp = compr; 
            @(posedge clk);        
            write = 1'b0;
            end
    endtask 

    // Task to handle reading from the cache
    task read_task(input [7:0] index, input [2:0] off, input [4:0] tag, input compr);
        begin
            index = index;  
            offset = off; 
            tag_in = tag; 
            comp = compr;
            @(posedge clk);        
            write = 1'b0;
            end
    endtask

    task check_error(input [2:0] offset_val, input error_signal);
        begin
            if (offset_val[0]) begin
                if (error_signal)
                    $display("  -> [ERROR] Data mismatch! offset[0]=1");
                else
                    $display("  -> [FAIL] ERROR was expected for misaligned offset, but not asserted!");
                end else begin
                if (error_signal)
                    $display("  -> [FAIL] ERROR was unexpectedly asserted on aligned offset (offset[0]=0)");
                else
                    $display("  -> [PASS] No error as expected (aligned offset)");
            end
        end
    endtask

    // Waveform dumping for simulation analysis
    initial begin
        $dumpfile("direct_map_cachet.vcd");    // Specify the VCD file for waveform dumping
        $dumpvars(0, tb_direct_map_cache);     // Dump all variables in the testbench
    end
endmodule