`timescale 1ns/1ps

module direct_map_cache #(
    parameter CACHE_SIZE = 256,                 // Number of cache lines
    parameter DATA_WIDTH = 16,                  // Width of data
    parameter TAG_WIDTH = 5,                    // Width of the tag
    parameter OFFSET_WIDTH = 3,                 // Width of the offset
    localparam INDEX_WIDTH = $clog2(CACHE_SIZE) // Width of the index
) (
    input wire enable,                          // Enable signal
    input wire [INDEX_WIDTH-1:0] index,         // Cache index
    input wire [OFFSET_WIDTH-1:0] offset,       // Byte offset within the cache line
    input wire comp,                            // Compare operation signal
    input wire write,                           // Write operation signal
    input wire [TAG_WIDTH-1:0] tag_in,          // Input tag for comparison and writing
    input wire [DATA_WIDTH-1:0] data_in,        // Input data to be written
    input wire valid_in,                        // Valid state for cache line
    input wire clk,                             // Clock signal
    input wire rst,                             // Reset signal (active high)
    output reg hit,                             // Hit indication
    output reg dirty,                           // Dirty state indication
    output reg [TAG_WIDTH-1:0] tag_out,         // Output tag of the cache line
    output reg [DATA_WIDTH-1:0] data_out,       // Output data from the cache line
    output reg valid,                           // Valid state output
    output reg error                            // Error indication for invalid accesses
);

// N-way set associative cache (2-way by default)
localparam N = 2;

// Internal storage for each set
reg [TAG_WIDTH-1:0] tags[N-1:0];
reg [DATA_WIDTH-1:0] data_mem[N-1][OFFSET_WIDTH:0];
reg valid_bits[N-1];
reg dirty_bits[N-1];
integer i;

// Sequential logic for cache operations
always @(posedge clk) begin
    if (rst) begin
        // Initialize cache lines on reset
        for (i = 0; i < CACHE_SIZE; i = i + 1) begin
            valid_bits[i] <= 1'b0;
            dirty_bits[i] <= 1'b0;
        end
        hit      <= 1'b0;
        dirty    <= 1'b0;
        valid    <= 1'b0;
        data_out <= {DATA_WIDTH{1'b0}};
    end
    else if (enable) begin
        // Check for LSB alignment error
        if (offset[0] == 1'b1) begin
            error <= 1'b1;
            hit   <= 1'b0;
            dirty <= 1'b0;
            valid <= 1'b0;
            data_out <= {DATA_WIDTH{1'b0}};
        end
        else begin
            error <= 1'b0;

            // Compare operation
            if (comp) begin
                // Compare Write
                if (write) begin
                    if ((tags[index] == tag_in) && valid_bits[index]) begin
                        hit <= 1'b1;
                        data_mem[index][offset[OFFSET_WIDTH-1:1]] <= data_in; 
                        dirty_bits[index] <= 1'b1;  
                        valid_bits[index] <= valid_in; 
                        tags[index]       <= tag_in;
                        valid    <= 1'b0;
                        dirty    <= 1'b0;

                    end
                    else begin
                        hit <= 1'b0;
                        dirty_bits[index] <= 1'b0;
                        valid_bits[index] <= valid_in;
                        tags[index]       <= tag_in;
                        valid    <= 1'b0;
                        dirty    <= 1'b0;
                        data_mem[index][offset[OFFSET_WIDTH-1:1]] <= data_in;              
                    end
                end
                // Compare Read
                else begin
                    tag_out  <= tags[index];
                    data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]]; 
                    valid    <= valid_bits[index];
                    dirty    <= dirty_bits[index];
                    hit      <= 1'b0;

                end
            end
            // Compare Read without compare
            else begin
                if (write) begin
                    // Access Write
                    tags[index]       <= tag_in;
                    data_mem[index][offset[OFFSET_WIDTH-1:1]] <= data_in; 
                    valid_bits[index] <= valid_in;
                    dirty_bits[index] <= 1'b0;
                    hit      <= 1'b0;
                    valid    <= 1'b0;
                    dirty    <= 1'b0;

                end
                else begin
                    // Access Read
                    tag_out  <= tags[index];
                    data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]]; 
                    valid    <= valid_bits[index];
                    dirty    <= dirty_bits[index];
                    hit      <= 1'b0;
                end
            end
        end
    end
    else begin
        // enable is low
        for (i = 0; i < CACHE_SIZE; i = i + 1) begin
            valid_bits[i] <= 1'b0;
            dirty_bits[i] <= 1'b0;
        end

        hit      <= 1'b0;
        dirty    <= 1'b0;
        data_out <= {DATA_WIDTH{1'b0}};
        valid    <= 1'b0;
    end
end

// Helper task to write to the cache
task write_task(input [7:0] indx, input [2:0] off, input [4:0] tag, input compr, valid);
    begin
        index = indx;
        offset = off;
        tag_in = tag;
        data_in = $random;
        valid_in = valid;
        write = 1'b1;
        comp = compr;
        @(posedge clk);

        // Simulate after the clock
        $display("\n[WRITE_TASK] @time %0t", $time);
        $display("  -> index=%0d (0x%0h), offset=%0d (0x%0h), tag_in=%b, data_in=%0h",
                  index, index, offset, offset, tag_in, data_in);
        $display("  -> comp=%b, write=%b, valid_in=%b", comp, write, valid_in);
        $display("  -> hit=%b, dirty=%b, tag_out=%b, data_out=%0h, valid=%b, error=%b",
                  hit, dirty, tag_out, data_out, valid, error);
    end
endtask

// Helper task to read from the cache
task read_task(input [7:0] indx, input [2:0] off, input [4:0] tag, input compr);
    begin
        index = indx;
        offset = off;
        tag_in = tag;
        comp = compr;
        @(posedge clk);

        $display("\n[READ_TASK] @time %0t", $time);
        $display("  -> index=%0d (0x%0h), offset=%0d (0x%0h), tag_in=%b",
                  index, index, offset, offset, tag_in);
        $display("  -> comp=%b, write=%b", comp, write);
        $display("  -> hit=%b, dirty=%b, tag_out=%b, data_out=%0h, valid=%b, error=%b",
                  hit, dirty, tag_out, data_out, valid, error);

        if (data_in !== data_out)
            $display("  -> [Error] Data mismatch! data_in=%0h, data_out=%0h",
                      data_in, data_out);
        else
            $display("  -> [Pass] Data matched.");
        @(posedge clk);
    end
endtask

// Task to handle writing to the cache
task write_task_impl();
    begin
        index = 0;
        offset = 0;
        tag_in = 0;
        data_in = $random;
        valid_in = 1'b0;
        write = 1'b1;
        comp = 1'b1;
        @(posedge clk);

        // Simulate write
        $display("\n[WRITE_TASK] @time %0t", $time);
        $display("  -> index=0, offset=0, tag_in=0, data_in=$random, comp=1, write=1");
        $display("  -> comp=%b, write=%b, valid_in=%b", comp, write, valid_in);
        $display("  -> hit=%b, dirty=%b, tag_out=%b, data_out=%0h, valid=%b, error=%b",
                  hit, dirty, tag_out, data_out, valid, error);
    end
endtask

// Task to handle reading from the cache
task read_task_impl();
    begin
        index = 0;
        offset = 0;
        tag_in = 0;
        comp = 1'b0;
        @(posedge clk);

        $display("\n[READ_TASK] @time %0t", $time);
        $display("  -> index=0, offset=0, tag_in=0, comp=1'b0, write=1'b0");
        $display("  -> hit=%b, dirty=%b, tag_out=%b, data_out=%0h, valid=%b, error=%b",
                  hit, dirty, tag_out, data_out, valid, error);
    end
endtask

initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10 ns period
end

// Test procedure
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
    write_task_impl(8'h02, 3'b000, 5'b00000, 1'b1,1'b1);
    read_task_impl(8'h02, 3'b000, 5'b00000, 1'b1);
    write_task_impl(8'h02, 3'b000, 5'b00001, 1'b1,1'b1);
    read_task_impl(8'h02, 3'b000, 5'b00001, 1'b1);
    write_task_impl(8'h02, 3'b000, 5'b00010, 1'b1,1'b1);
    read_task_impl(8'h02, 3'b000, 5'b00010, 1'b1);
    write_task_impl(8'h02, 3'b000, 5'b00011, 1'b1,1'b1);
    read_task_impl(8'h02, 3'b000, 5'b00011, 1'b1);

    @(posedge clk); 

    // Write to cache without compare
    write_task_impl(8'h00, 3'b000, 5'b00001, 1'b0,1'b1);

    // Read from cache without compare
    read_task_impl(8'h00, 3'b000, 5'b00001, 1'b0);

    // Write to cache with compare
    write_task_impl(8'h00, 3'b000, 5'b00001, 1'b1,1'b1);

    // Read from cache with compare
    read_task_impl(8'h00, 3'b000, 5'b00001, 1'b1);

    // Write to cache with out compare
    write_task_impl(8'h01, 3'b110, 5'b00010, 1'b0,1'b1);

    // Read from cache with compare
    read_task_impl(8'h01, 3'b110, 5'b00010, 1'b1);

    // Error condition
    write_task_impl(8'h01, 3'b001, 5'b00010, 1'b0,1'b1);
    @(posedge clk); 
    check_error(3'b001, error);
    // Finalize simulation
    $finish;
end

