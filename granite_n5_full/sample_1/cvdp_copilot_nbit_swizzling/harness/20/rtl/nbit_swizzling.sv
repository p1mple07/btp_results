module nbit_swizzling #(parameter DATA_WIDTH = 64)(
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    //  2-bit selection signal 
    output reg [DATA_WIDTH+($clog2(DATA_WIDTH)-1):0] ecc_out,                   // Encoded output with parity bits.
    output reg [DATA_WIDTH:0] data_out                                      // Output data of size DATA_WIDTH 
);

localparam PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH)) + 1;

// Calculate parity bits using XOR logic
reg [PARITY_BITS-1:0] parity_bits;
generate
    if (PARITY_BITS == 1) begin
        assign parity_bits[0] = data_in[0];
    end else begin
        assign parity_bits[0] = data_in[0];
        genvar i;
        generate
            for (i = 1; i < PARITY_BITS; i = i + 1) begin
                assign parity_bits[i] = data_in[i] ^ parity_bits[i-1];
            end
        endgenerate
    end
endgenerate

// Insert parity bits at positions that are powers of 2
wire [PARITY_BITS-1:0] parity_bits_sel;
genvar j;
generate
    for (j = 0; j < PARITY_BITS; j = j + 1) begin
        if ((2**j) <= DATA_WIDTH) begin
            assign parity_bits_sel[j] = parity_bits[j];
        end
    end
endgenerate

// Combine data_in and parity_bits_sel into data_out
assign data_out = {data_in, parity_bits_sel};

// Compute encoded output using XOR logic
wire [DATA_WIDTH+($clog2(DATA_WIDTH)-1):0] ecc_out_calc;
generate
    if (PARITY_BITS == 1) begin
        assign ecc_out_calc = data_out;
    end else begin
        assign ecc_out_calc = data_out ^ (1 << (PARITY_BITS-1));
    end
endgenerate

// Assign computed encoded output to ecc_out
assign ecc_out = ecc_out_calc[$clog2(DATA_WIDTH)-1:0];

endmodule