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
    end else begin
        case (current_state)
            IDLE: begin
                if (data != old_data) begin
                    current_state <= LOAD;
                end else begin
                    current_state <= IDLE;
                end
            end
            LOAD: begin
                shift_reg <= data;
                bit_count <= 5;
                current_state <= SHIFT;
            end
            SHIFT: begin
                ATTN_DATA <= shift_reg[bit_count];
                bit_count <= bit_count - 1;
                if (bit_count == 0) begin
                    current_state <= LATCH;
                end else begin
                    current_state <= SHIFT;
                end
            end
            LATCH: begin
                ATTN_LE <= 1'b1;
                @(posedge clk_div2); // Wait for the slower clock
                ATTN_LE <= 1'b0;
                current_state <= IDLE;
            end
        endcase
    end
end

endmodule
