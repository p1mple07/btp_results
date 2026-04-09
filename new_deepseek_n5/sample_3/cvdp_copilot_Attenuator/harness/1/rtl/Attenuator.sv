module Attenuator (
    input        clk,
    input        reset,
    input  [4:0] data,
    output reg   ATTN_CLK,
    output reg   ATTN_DATA,
    output reg   ATTN_LE
);

// Internal Signals
reg        clk_div2;
reg  [1:0] current_state, next_state;
reg  [4:0] shift_reg;
reg  [2:0] bit_count;
reg  [4:0] old_data;

// Parameters for FSM States
localparam IDLE  = 2'b00,
           LOAD  = 2'b01,
           SHIFT = 2'b10,
           LATCH = 2'b11;

// Reset Condition
always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk_div2 <= 1'b0;
        current_state <= IDLE;
        ATTN_CLK      <= 1'b0;
        ATTN_DATA     <= 1'b0;
        ATTN_LE       <= 1'b0;
        shift_reg     <= 5'b00000;
        bit_count     <= 3'd0;
        old_data      <= 5'b00000;
    else begin
        case(current_state)
            IDLE:
                if (data != old_data)
                    next_state = LOAD;
                else
                    next_state = IDLE;
                endcase

            LOAD:
                shift_reg = data;
                bit_count = 0;
                next_state = SHIFT;
            
            SHIFT:
                bit = shift_reg[4];
                ATTN_DATA = bit;
                clk_div2 = !clk_div2;
                bit_count = bit_count + 1;
                next_state = (bit_count == 4) ? LATCH : SHIFT;
            
            LATCH:
                ATTN_LE = 1;
                next_state = IDLE;
        endcase
    end
end