`timescale 1ns/1ps
module cache_controller () 
    parameter NUM_CACHE_LINES = 32;
    parameter CACHE_LINE_SIZE = 32;

    reg [31:0] address;
    reg [31:0] read_data;
    reg [31:0] write_data;
    reg read, write, valid;
    wire [NUM_CACHE_LINES-1:0] tag Comparisons;
    reg [NUM_CACHE_LINES-1:0] valid;
    
    // Use a port of the address to get just the tag
    wire [5:0] tag;
    
    // The cache is an array of 32 cache lines
    const cache_lines[NUM_CACHE_LINES] of [4:0] = replicate({{0}}, NUM_CACHE_LINES);

    // The controller interacts with main memory through these ports
    reg [31:0] mem_address;
    reg [31:0] mem_write;
    reg [31:0] mem_read_data;
    reg mem_valid;
    
    // The CPU sends requests through these ports
    wire [31:0] cpu_request, cpu_response;

    // Initialize all cache lines as invalid
    initial begin
        for (int i = 0; i < NUM_CACHE_LINES; i++) {
            valid[i] = 0;
        }
    end
    
    // Controller core
    always @posedge clock) begin
        if(reset && !valid[0]) begin
            tag = {0, 0, 0, 0, 0};
            valid[0] = 1;
        end
    end

    // Read operation
    function void read() begin
        if (read_request) begin
            // Match tag to cache line
            if (tag == tag_cache) begin
                // Hit! Send data back
                cpu_response = data;
            else begin
                // Miss! Fetch data from memory
                cpu_request = write_request;
                cpu_request[address] = data;
                // Update cache
                valid[address] = 1;
                tag_cache = tag;
            end
        end
    end

    // Write operation
    function void write() begin
        if (write_request) begin
            // Write-through policy
            // First write to memory
            if (mem_valid) begin
                // If it was already in cache, update it
                if (tag == tag_cache) begin
                    valid[address] = 1;
                    tag_cache = tag;
                end
            end
            // Now write to cache
            valid[address] = 1;
            tag_cache = tag;
        end
    end

    // Simple test bench
    initial begin
        // Setup address bits
        address = 8'h12345679;

        // Setup input vectors
        #5 $send("read_request", 1);
        #10 $wait;
        $expect("data", 32'hABCDEF01);

        // Cleanup
        $finish;
    end