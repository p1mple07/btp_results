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

// Clock divider
always @(posedge clk) begin
    clk_div2 <= ~clk_div2;
end

// FSM
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= IDLE;
        ATTN_CLK      <= 1'b0;
        ATTN_DATA     <= 1'b0;
        ATTN_LE       <= 1'b0;
        shift_reg     <= 5'b00000;
        bit_count     <= 3'd0;
        old_data      <= 5'b00000;
    end else begin
        case (current_state)
            IDLE: begin
                if (data != old_data) begin
                    current_state <= LOAD;
                    ATTN_CLK      <= 1'b0;
                    shift_reg     <= data;
                    bit_count     <= 3'd0;
                end
            end
            LOAD: begin
                bit_count <= bit_count + 1'b1;
                if (bit_count == 5'd5) begin
                    current_state <= SHIFT;
                    ATTN_CLK      <= ~ATTN_CLK;
                    ATTN_DATA     <= shift_reg[bit_count - 1];
                    bit_count     <= 3'd0;
                end
            end
            SHIFT: begin
                bit_count <= bit_count + 1'b1;
                if (bit_count == 5'd5) begin
                    current_state <= LATCH;
                    ATTN_CLK      <= 1'b0;
                    ATTN_LE       <= 1'b1;
                    bit_count     <= 3'd0;
                end
            end
            LATCH: begin
                bit_count <= 3'd0;
                ATTN_CLK      <= 1'b0;
                ATTN_LE       <= 1'b0;
            end
        endcase
    end
end

endmodule
