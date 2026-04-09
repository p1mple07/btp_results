module Attenuator (
    input        clk,
    input        reset,
    input  [4:0] data,
    output reg   ATTN_CLK,
    output reg   ATTN_DATA,
    output reg   ATTN_LE
);

reg [1:0] current_state, next_state;
reg  [4:0] shift_reg;
reg  [2:0] bit_count;
reg  [4:0] old_data;

localparam IDLE  = 2'b00,
           LOAD  = 2'b01,
           SHIFT = 2'b10,
           LATCH = 2'b11;

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
    end else begin
        case (current_state)
            IDLE:
                if (data != 5'b00000) begin
                    current_state <= LOAD;
                    old_data <= data;
                end else begin
                    next_state <= IDLE;
                end
            LOAD:
                if (data != 5'b00000) begin
                    current_state <= SHIFT;
                    old_data <= data;
                    bit_count <= 0;
                    shift_reg <= 5'b00000;
                end else begin
                    next_state <= LOAD;
                end
            SHIFT:
                next_state <= LATCH;
                bit_count <= bit_count + 1;
                if (bit_count < 5) begin
                    ATTN_DATA <= shift_reg[bit_count];
                    ATTN_CLK <= 1'b1;
                end else begin
                    ATTN_DATA <= 1'b0;
                    ATTN_CLK <= 1'b0;
                end
            LATCH:
                next_state <= IDLE;
                ATTN_LE <= 1'b1;
                bit_count <= 0;
                shift_reg <= 5'b00000;
                bit_count <= 0;
        endcase
    end
end

endmodule
