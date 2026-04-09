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

// Clock divider: generate a slower clock (divide by 2)
always @(posedge clk or posedge reset) begin
    if (reset)
        clk_div2 <= 1'b0;
    else
        clk_div2 <= ~clk_div2;
end

// FSM: triggered by the slower clock (clk_div2)
always @(posedge clk_div2 or posedge reset) begin
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
                // Transition to LOAD if new data is detected
                if (data !== old_data)
                    current_state <= LOAD;
                else
                    current_state <= IDLE;
            end
            LOAD: begin
                // Capture the new 5-bit control word and initialize bit_count
                shift_reg  <= data;       // Load new data into shift register
                bit_count  <= 3'd4;       // 5 bits to shift (count from 4 downto 0)
                old_data   <= data;       // Update stored data
                current_state <= SHIFT;
            end
            SHIFT: begin
                // Output the most significant bit (MSB) and shift left
                ATTN_DATA <= shift_reg[4];
                shift_reg <= shift_reg << 1;
                if (bit_count == 0)
                    current_state <= LATCH;
                else
                    bit_count <= bit_count - 1;
            end
            LATCH: begin
                // In LATCH state, pulse ATTN_LE for one cycle then return to IDLE
                current_state <= IDLE;
            end
            default: current_state <= IDLE;
        endcase

        // Drive the attenuator clock using the clock divider signal
        ATTN_CLK <= clk_div2;

        // Pulse ATTN_LE high only in the LATCH state
        if (current_state == LATCH)
            ATTN_LE <= 1'b1;
        else
            ATTN_LE <= 1'b0;
    end
end

endmodule