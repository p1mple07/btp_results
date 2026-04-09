module unpack_one_hot(
    input sign,
    input size,
    input [2:0] one_hot_selector,
    input [255:0] source_reg,
    output [511:0] destination_reg
);
    integer i;
    parameter CHUNK_WIDTH = 8;
    parameter DEST_WIDTH = 512;
    
    // Initialize destination register to zero
    destination_reg <= 0;
    
    // Determine chunk size based on one-hot selector
    integer chunk_size;
    case (one_hot_selector)
    3'b001: chunk_size = 1;
    3'b010: chunk_size = 2;
    3'b100: chunk_size = size ? 8 : 4;
    default: chunk_size = 256;
    endcase
    
    // Determine destination width per chunk
    integer dest_chunk_size;
    case (one_hot_selector)
    3'b001: dest_chunk_size = 8;
    3'b010: dest_chunk_size = 8;
    3'b100: dest_chunk_size = size ? 16 : 8;
    default: dest_chunk_size = 256;
    endcase
    
    // Unpack data
    for (i = 0; i < 256; i += chunk_size) begin
        // Extract chunk from source register
        local [7:0] chunk;
        chunk = source_reg[i + 7: i];
        
        // Convert chunk to appropriate width
        local [dest_chunk_size - 1:0] unpacked;
        unpacked = chunk;
        
        // Apply sign extension
        if (sign) begin
            unpacked = { ( (chunk[0] & 1) ? ( (8 - dest_chunk_size) : (4 - dest_chunk_size) ) : 0 ) 
                        << (dest_chunk_size - 1), 
                        unpacked };
        end
        
        // Write to destination register
        destination_reg[i + dest_chunk_size - 1: i] = unpacked;
    endfor
endmodule