module unpack_one_hot(
    input [255:0] source_reg,
    input sign,
    input size,
    input [2:0] one_hot_selector,
    output [511:0] destination_reg
);

    // Initialize destination register
    destination_reg = 0;

    // Determine chunk size based on one-hot selector
    integer chunk_size;
    case (one_hot_selector)
        3'b000: chunk_size = 256; // Default case: no unpacking
        3'b001: chunk_size = 1;
        3'b010: chunk_size = 2;
        3'b100: chunk_size = size ? 8 : 4;
    endcase

    // Loop through source register in chunks
    for (int i = 0; i < 256; i += chunk_size) begin
        // Extract chunk from source register
        bit [7:0] chunk = source_reg[i + 7: i];

        // Convert chunk to signed or unsigned value
        if (sign) begin
            if (chunk & 128) begin // Negative number
                chunk = (chunk + 128) * 8;
            else
                chunk = chunk * 8;
            end
        else
            chunk = chunk * 8;
        end

        // Write chunk to destination register
        destination_reg[i + 7: i] = chunk;
    endfor

endmodule