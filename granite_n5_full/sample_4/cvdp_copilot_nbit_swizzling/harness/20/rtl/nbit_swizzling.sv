module nbit_swizzling #(parameter DATA_WIDTH = 64)(
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    // 2-bit selection signal 
    output wire [DATA_WIDTH:0] data_out,                                       // Output data of size DATA_WIDTH 
    output wire [DATA_WIDTH + $clog2(DATA_WIDTH):0] ecc_out                   // Encoded output with parity bits
);

localparam PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH)) + 1;       // Number of parity bits

reg [PARITY_BITS-1:0] parity_bits;                                          // Parity bits generated using XOR logic

// Compute parity bits
generate
    if (PARITY_BITS == 1) begin
        assign parity_bits[0] = data_in[DATA_WIDTH-1];                        // For single parity bit
    end else begin
        assign parity_bits[0] = data_in[DATA_WIDTH-1];                        // Set the first parity bit as data_in[DATA_WIDTH-1]
        genvar i;                                                                     // Generate variable for parity bit calculation
        generate
            for (i=1; i<PARITY_BITS; i=i+1) begin                                   // Iterate through remaining parity bits
                assign parity_bits[i] = ^parity_bits[i-1:0];                    // Calculate parity bits using XOR logic
            end
        endgenerate
    end
endgenerate

// Combine data_in and parity bits into data_out and ecc_out
assign data_out[DATA_WIDTH-1:0] = data_in[DATA_WIDTH-1:0];                     // Copy data_in to data_out
assign data_out[DATA_WIDTH:0] = {data_in[DATA_WIDTH-1:0], parity_bits};    // Concatenate data_in and parity bits to form data_out
assign ecc_out[DATA_WIDTH-1:0] = data_in[DATA_WIDTH-1:0];                     // Copy data_in to ecc_out
assign ecc_out[DATA_WIDTH:0] = {data_in[DATA_WIDTH-1:0], parity_bits};    // Concatenate data_in and parity bits to form ecc_out

endmodule