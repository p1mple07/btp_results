module nbit_swizzling #(parameter DATA_WIDTH = 64)(
    input  [DATA_WIDTH-1:0] data_in,
    input  [1:0]             sel,
    output reg [DATA_WIDTH:0] data_out,
    output reg [DATA_WIDTH + PARITY_BITS - 1:0] ecc_out
);

    // Calculate number of parity bits
    localparam int PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);
    localparam int TOTAL_BITS  = DATA_WIDTH + PARITY_BITS;

    // Function to check if a number is a power of two (1-indexed check)
    function automatic bit is_power_of_two(input int x);
        is_power_of_two = (x != 0) && ((x & (x-1)) == 0);
    endfunction

    integer i;
    wire parity_bit;

    // Calculate parity for data_in (used in swizzling)
    assign parity_bit = ^data_in;

    // Swizzling logic for data_out based on sel
    always @(*) begin
        case(sel)
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
                    data_out[i]                  = data_in[DATA_WIDTH/4-1-i];
                    data_out[DATA_WIDTH/4 + i]   = data_in[DATA_WIDTH/2-1-i];
                    data_out[DATA_WIDTH/2 + i]   = data_in[3*DATA_WIDTH/4-1-i];
                    data_out[3*DATA_WIDTH/4 + i] = data_in[DATA_WIDTH-1-i];
                end
                data_out[DATA_WIDTH] = parity_bit;
            end
            
            2'b11: begin
                for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                    data_out[i]                  = data_in[DATA_WIDTH/8-1-i];
                    data_out[DATA_WIDTH/8 + i]   = data_in[DATA_WIDTH/4-1-i];
                    data_out[DATA_WIDTH/4 + i]   = data_in[3*DATA_WIDTH/8-1-i];
                    data_out[3*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH/2-1-i];
                    data_out[DATA_WIDTH/2 + i]   = data_in[5*DATA_WIDTH/8-1-i];
                    data_out[5*DATA_WIDTH/8 + i] = data_in[3*DATA_WIDTH/4-1-i];
                    data_out[3*DATA_WIDTH/4 + i] = data_in[7*DATA_WIDTH/8-1-i];
                    data_out[7*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH-1-i];
                end
                data_out[DATA_WIDTH] = parity_bit;
            end
            default: begin
                data_out = data_in;
                data_out[DATA_WIDTH] = parity_bit;
            end
        endcase
    end

    // Hamming ECC Generation for ecc_out
    // The encoded output (ecc_out) is formed by inserting parity bits at positions
    // that are powers of two and filling the remaining positions with bits from data_in.
    always @(*) begin
        integer j, k, data_count;
        reg [TOTAL_BITS-1:0] temp;
        data_count = 0;
        
        // Place data bits into non-parity positions
        for (j = 0; j < TOTAL_BITS; j = j + 1) begin
            if (is_power_of_two(j+1)) begin
                // Positions that are powers of two will hold parity bits (initialized to 0)
                temp[j] = 1'b0;
            end else begin
                temp[j] = data_in[data_count];
                data_count = data_count + 1;
            end
        end
        
        // Calculate and insert parity bits
        // For each parity position (1-indexed positions that are powers of two)
        for (k = 0; k < PARITY_BITS; k = k + 1) begin
            bit parity = 1'b0;
            int p = (1 << k); // p is the parity position (1-indexed)
            // p_index in 0-indexed numbering is p - 1
            for (j = 0; j < TOTAL_BITS; j = j + 1) begin
                // Include bit at position j if its (j+1) has the kth bit set,
                // but skip the parity bit position itself.
                if (((j+1) & p) != 0 && (j+1 != p)) begin
                    parity = parity ^ temp[j];
                end
            end
            temp[p - 1] = parity;
        end
        
        ecc_out = temp;
    end

endmodule