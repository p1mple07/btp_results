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
        if (data != old_data) begin
            current_state <= LOAD;
        end else begin
            // No data change, stay in current state
        end
    end
end else if (current_state == SHIFT) begin
    ATTN_DATA <= shift_reg[0];
    shift_reg <= (shift_reg >> 1);
    bit_count <= bit_count + 1;
    next_state <= LATCH;
end else if (current_state == LATCH) begin
    ATTN_LE <= 1;
    bit_count <= 0;
    next_state <= IDLE;
end

// FSM State Transitions
always @* begin
    case (current_state)
        IDLE:
            if (data != old_data)
                current_state = LOAD;
            next_state = current_state;
        LOAD:
            shift_reg = data;
            current_state = LOAD;
            next_state = current_state;
        SHIFT:
            ATTN_DATA <= shift_reg[0];
            shift_reg <= shift_reg >> 1;
            bit_count <= bit_count + 1;
            if (bit_count == 5)
                current_state = LATCH;
            next_state = current_state;
        LATCH:
            ATTN_LE <= 1;
            next_state = IDLE;
    endcase
end

// Internal State Variables
always @* begin
    old_data <= data;
    bit_count <= bit_count + 1;
end