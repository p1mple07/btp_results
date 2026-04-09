module dual_port_memory #(
    parameter DATA_WIDTH = 4,
    parameter ADDR_WIDTH = 5,
    parameter ECC_WIDTH = 3, // Width of ECC code
    parameter MEM_DEPTH = (1 << ADDR_WIDTH)
)(
    input clk,
    input rst_n,
    input we,
    input [ADDR_WIDTH-1:0] addr_a,
    input [ADDR_WIDTH-1:0] addr_b,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);

    // Define RAM with ECC encoding
    reg [DATA_WIDTH-1:0] ram_data [MEM_DEPTH-1:0];
    reg [ECC_WIDTH-1:0] ram_ecc [MEM_DEPTH-1:0];

    // ECC parity calculation
    function bitvector parity_bit(vector data, integer bit_pos) {
        bitvector res = 0;
        for (integer i = 0; i < length(data); i++) {
            res ^= (data[i] >> bit_pos & 1);
        }
        return res;
    }

    always @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
            // ECC-related signals initialized to 0
            ram_data <= (replicate(0, DATA_WIDTH));
            ram_ecc <= (replicate(0, ECC_WIDTH));
        end else begin
            if (we) begin
                // Write operation with ECC encoding
                integer idx = addr_a;
                integer i, j;
                
                // Encode data_in into Hamming(7,4)
                bitvector data_bits = data_in;
                bitvector ecc_bits = (parity_bit(data_bits, 2) &
                                     parity_bit(data_bits, 1) &
                                     parity_bit(data_bits, 3));
                
                // Store encoded data
                ram_data[idx] <= data_in;
                ram_ecc[idx] <= ecc_bits;
            end else begin
                // Read operation with ECC decoding
                integer idx = addr_b;
                integer i, j;
                
                // Decode data from memory
                bitvector data_bits = ram_data[idx];
                bitvector ecc_bits = ram_ecc[idx];
                
                // Recompute ECC
                bitvector recomputed_ecc = (parity_bit(data_bits, 2) &
                                         parity_bit(data_bits, 1) &
                                         parity_bit(data_bits, 3));
                
                // Calculate syndrome
                bitvector syndrome = ecc_bits ^ recomputed_ecc;
                
                // Update ECC error flag
                if (syndrome != 0) begin
                    ecc_error = 1;
                else begin
                    ecc_error = 0;
                end
                // Store data word
                data_out <= ram_data[idx];
            end
        end
    end
endmodule