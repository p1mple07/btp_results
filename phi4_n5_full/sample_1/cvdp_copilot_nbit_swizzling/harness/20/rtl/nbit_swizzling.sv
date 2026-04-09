module nbit_swizzling #(parameter DATA_WIDTH = 64)(
    input  [DATA_WIDTH-1:0] data_in,                     // Input data of size DATA_WIDTH 
    input  [1:0]           sel,                           // 2-bit selection signal 
    output reg [DATA_WIDTH:0] data_out,                    // Output data of size DATA_WIDTH 
    output [DATA_WIDTH + PARITY_BITS - 1:0] ecc_out        // Encoded output with parity bits
);

    // Local Parameters
    localparam integer PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);
    localparam integer TOTAL_WIDTH = DATA_WIDTH + PARITY_BITS;

    integer i;
    wire parity_bit;
    assign parity_bit = ^data_in;

    // --------------------------------------------------------------------
    // Existing swizzling logic for data_out based on sel
    // --------------------------------------------------------------------
    always @(*) begin
        case (sel)
            2'b00: begin
                for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                    data_out[i] = data_in[DATA_WIDTH-1-i];
                end
                data_out[DATA_WIDTH] = parity_bit;
            end
            2'b01: begin
                for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                    data_out[i]                = data_in[DATA_WIDTH/2-1-i];
                    data_out[DATA_WIDTH/2 + i] = data_in[DATA_WIDTH-1-i];
                end
                data_out[DATA_WIDTH] = parity_bit;
            end
            2'b10: begin
                for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                    data_out[i]                     = data_in[DATA_WIDTH/4-1-i];
                    data_out[DATA_WIDTH/4 + i]       = data_in[DATA_WIDTH/2-1-i];
                    data_out[DATA_WIDTH/2 + i]       = data_in[3*DATA_WIDTH/4-1-i];
                    data_out[3*DATA_WIDTH/4 + i]     = data_in[DATA_WIDTH-1-i];
                end
                data_out[DATA_WIDTH] = parity_bit;
            end
            2'b11: begin
                for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                    data_out[i]                      = data_in[DATA_WIDTH/8-1-i];
                    data_out[DATA_WIDTH/8 + i]       = data_in[DATA_WIDTH/4-1-i];
                    data_out[DATA_WIDTH/4 + i]       = data_in[3*DATA_WIDTH/8-1-i];
                    data_out[3*DATA_WIDTH/8 + i]     = data_in[DATA_WIDTH/2-1-i];
                    data_out[DATA_WIDTH/2 + i]       = data_in[5*DATA_WIDTH/8-1-i];
                    data_out[5*DATA_WIDTH/8 + i]     = data_in[3*DATA_WIDTH/4-1-i];
                    data_out[3*DATA_WIDTH/4 + i]     = data_in[7*DATA_WIDTH/8-1-i];
                    data_out[7*DATA_WIDTH/8 + i]     = data_in[DATA_WIDTH-1-i];
                end
                data_out[DATA_WIDTH] = parity_bit;
            end
            default: begin
                data_out = data_in;
                data_out[DATA_WIDTH] = parity_bit;
            end
        endcase
    end

    // --------------------------------------------------------------------
    // Hamming ECC Generation for ecc_out
    // --------------------------------------------------------------------
    // The encoded word has TOTAL_WIDTH bits. Parity bits are inserted at positions
    // that are powers of 2 (1-indexed). The remaining positions are filled with data bits.
    // Parity for each parity position is computed as the XOR of all bits in positions
    // where the corresponding bit (in the position number) is set (excluding the parity bit itself).
    always @(*) begin
        integer pos, j, data_idx;
        bit p_val;
        reg [TOTAL_WIDTH-1:0] encoded;
        
        encoded = '0;
        data_idx = 0;
        
        // Place data bits in positions that are NOT powers of 2 (positions are 1-indexed)
        for (pos = 1; pos <= TOTAL_WIDTH; pos = pos + 1) begin
            // Check if 'pos' is NOT a power of 2.
            if ((pos & (pos-1)) != 0) begin
                encoded[pos-1] = data_in[data_idx];
                data_idx = data_idx + 1;
            end
        end
        
        // Compute parity bits for positions that ARE powers of 2.
        for (pos = 1; pos <= TOTAL_WIDTH; pos = pos + 1) begin
            if ((pos & (pos-1)) == 0) begin  // pos is a power of 2
                p_val = 1'b0;
                // For each position j (1-indexed), if j has the bit corresponding to 'pos' set,
                // include that bit in the XOR (excluding the parity bit itself).
                for (j = 1; j <= TOTAL_WIDTH; j = j + 1) begin
                    if ((j & pos) != 0 && j != pos) begin
                        p_val = p_val ^ encoded[j-1];
                    end
                end
                encoded[pos-1] = p_val;
            end
        end
        
        ecc_out = encoded;
    end

endmodule