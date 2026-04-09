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

    // Cache line definitions
    reg [TAG_WIDTH-1:0] tags[N:0];              // Tag storage (N ways)
    reg [DATA_WIDTH-1:0] data[N][OFFSET_WIDTH:0];  // Data storage (2*N entries)
    reg valid[N];
    reg dirty[N];
    integer i;

    // Sequential logic for cache operations
    always @(posedge clk) begin
        if (rst) begin
            // Initialize cache lines on reset
            for (i = 0; i < CACHE_SIZE; i = i + 1) begin
                valid[i] <= 1'b0;                       
                dirty[i] <= 1'b0;                                      
            end
            hit      <= 1'b0;                                    
            dirty    <= 1'b0;                                                     
            valid    <= 1'b0;
            data_out <= {DATA_WIDTH{1'b0}};                                   
        end 
        else if (enable) begin
            // Check for LSB alignment error
            if (offset[0] == 1'b1) begin
                error <= 1'b1;                               // Set error if LSB of offset is 1
                hit   <= 1'b0;                                 
                dirty <= 1'b0;                               
                valid <= 1'b0;                               
                data_out <= {DATA_WIDTH{1'b0}};              
            end 
            else begin
                error <= 1'b0;                               // Clear error if LSB of offset is 0

                // Compare operation
                if (comp) begin
                    // Compare Write (comp = 1, write = 1) 
                    if (write) begin
                        if ((tags[index] == tag_in) && valid[index]) begin
                            hit <= 1'b1;
                            data_mem[index][offset[OFFSET_WIDTH-1:1]] <= data_in; 
                            dirty_bits[index] <= 1'b1;  
                            valid_bits[index] <= valid[index]; 
                            valid    <= 1'b0;                 
                            dirty    <= 1'b0; 

                        end
                        else begin
                            hit <= 1'b0;
                            dirty_bits[index] <= 1'b0;
                            valid_bits[index] <= valid[index];
                            tags[index]       <= tag_in;
                            valid    <= 1'b0;                 
                            dirty    <= 1'b0;  
                            data_mem[index][offset[OFFSET_WIDTH-1:1]] <= data_in;              
                        end
                    end 
                    else begin // Write
                        // Compare Read (comp = 1, write = 0)
                        if ((tags[index] == tag_in) && valid[index]) begin
                            hit <= 1'b1;
                            data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]]; 
                            valid    <= valid[index];                 
                            dirty    <= dirty[index]; 
                            tag_out  <= tags[index];                
                        end
                        else begin
                            hit <= 1'b0;
                            tag_out  <= tags[index];
                            valid <= valid[index];                   
                            dirty <= dirty[index]; 
                            data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]];                 
                        end
                    end
                end 
                else begin //compare
                    if (write) begin
                        // Access Write (comp = 0, write = 1)
                        tags[index]       <= tag_in;                       
                        data_mem[index][offset[OFFSET_WIDTH-1:1]] <= data_in; 
                        valid_bits[index] <= valid[index];               
                        dirty_bits[index] <= 1'b0;
                        hit      <= 1'b0;
                        valid    <= 1'b0;                 
                        dirty    <= 1'b0;

                    end 
                    else begin
                        // Access Read (comp = 0, write = 0)
                        tag_out  <= tags[index];                      
                        data_out <= data_mem[index][offset[OFFSET_WIDTH-1:1]]; 
                        valid    <= valid[index];                  
                        dirty    <= dirty[index];
                        hit      <= 1'b0;

                    end
                end
            end 
        end 
        else begin // enable
            // enable is low
            for (i = 0; i < CACHE_SIZE; i = i + 1) begin
                valid[i] <= 1'b0;                           
                dirty[i] <= 1'b0;                                                  
            end

            hit      <= 1'b0;                                       
            dirty    <= 1'b0;                                                         
            data_out <= {DATA_WIDTH{1'b0}};                    
            valid    <= 1'b0;                                     
        end
    end

endmodule
