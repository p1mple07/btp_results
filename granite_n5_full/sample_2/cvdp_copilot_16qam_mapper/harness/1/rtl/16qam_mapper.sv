module qam16_mapper_interpolated #(
    parameter int N = 4, // Number of input symbols
    parameter int IN_WIDTH = 4, // Bit width of each input symbol
    parameter int OUT_WIDTH = 3 // Bit width of the output components
) (
    input wire [N * IN_WIDTH - 1:0] bits, // Packed input bits
    output logic [(N + N / 2) * OUT_WIDTH - 1:0] I, // Packed output of real (I) components
    output logic [(N + N / 2) * OUT_WIDTH - 1:0] Q // Packed output of imaginary (Q) components
);

// Define local types and variables
typedef enum logic [1:0] {
    IDLE,
    MAP,
    INTERPOLATE
} state_t;

logic [N * IN_WIDTH - 1:0] bit_stream;
state_t state;
int symbol_idx;
logic [IN_WIDTH - 1:0] msb_bits;
logic [IN_WIDTH - 1:0] lsb_bits;
logic [OUT_WIDTH - 1:0] i_val;
logic [OUT_WIDTH - 1:0] q_val;

// Generate input bit stream
always_comb begin
    case(state)
        IDLE: begin
            bit_stream <= bits;
            symbol_idx <= 0;
            state <= MAP;
        end
        MAP: begin
            if(symbol_idx < N) begin
                msb_bits <= bit_stream[symbol_idx * IN_WIDTH +: IN_WIDTH];
                lsb_bits <= bit_stream[(symbol_idx + 1) * IN_WIDTH - 1: symbol_idx * IN_WIDTH];
                state <= INTERPOLATE;
            end else begin
                state <= IDLE;
            end
        end
        INTERPOLATE: begin
            if(symbol_idx < N - 1) begin
                i_val <= (msb_bits == 2'd0)? 3'd3 : ((msb_bits == 2'd1)? 3'd1 : (msb_bits == 2'd2)? 3'd-1 : 3'd-3));
                q_val <= (lsb_bits == 2'd0)? 3'd3 : ((lsb_bits == 2'd1)? 3'd1 : (lsb_bits == 2'd2)? 3'd-1 : 3'd-3));
                state <= MAP;
            end else begin
                state <= IDLE;
            end
        end
    endcase
end

// Assign output values
assign I[(symbol_idx + symbol_idx / 2) * OUT_WIDTH +: OUT_WIDTH] = i_val;
assign Q[(symbol_idx + symbol_idx / 2) * OUT_WIDTH +: OUT_WIDTH] = q_val;

endmodule