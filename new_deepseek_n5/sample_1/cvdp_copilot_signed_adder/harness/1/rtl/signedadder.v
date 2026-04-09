module signedadder #(parameter DATA_WIDTH = 8)(
    input i_clk,
    input i_rst_n,
    input i_start,
    input i_enable,
    input i_mode,
    input i_clear,
    input [DATA_WIDTH-1:0] i_operand_a,
    input [DATA_WIDTH-1:0] i_operand_b,
    output reg [DATA_WIDTH-1:0] o_resultant_sum,
    output reg o_overflow,
    output reg o_ready,
    output reg [1:0] o_status
);
    reg [1:0] current_state = 0; // IDLE (00), LOAD (01), COMPUTE (10), OUTPUT (11)
    reg [DATA_WIDTH-1:0] operand_a_reg, operand_b_reg;
    reg [DATA_WIDTH-1:0] result_reg;

    // Initialize registers
    always @* begin
        operand_a_reg = i_operand_a;
        operand_b_reg = i_operand_b;
        result_reg = 0;
    end

    // Clear operation
    if (i_clear) begin
        o_resultant_sum = 0;
        o_overflow = 0;
        o_ready = 0;
        current_state = 0; // Reset to IDLE
        return;
    end

    // State transitions
    case (current_state)
        0: // IDLE
            if (i_start & i_enable) begin
                // Enter LOAD state
                current_state = 1;
                o_status = 2; // 01: LOAD
            end
        1: // LOAD
            if (i_enable) begin
                // Enter COMPUTE state after loading operands
                current_state = 2;
                o_status = 3; // 10: COMPUTE
            end
        2: // COMPUTE
            if (i_enable) begin
                // Perform addition or subtraction
                result_reg = i_operand_a + i_operand_b;
                // Detect overflow
                sign_a = (i_operand_a >> (DATA_WIDTH-1)) & 1;
                sign_b = (i_operand_b >> (DATA_WIDTH-1)) & 1;
                sign_result = (result_reg >> (DATA_WIDTH-1)) & 1;
                o_overflow = ((sign_a & sign_b) != (sign_result)) ? 1 : 0;
                
                // Enter OUTPUT state
                current_state = 3;
                o_status = 0; // 11: OUTPUT
                o_ready = 1;
                o_resultant_sum = result_reg;
            end
        3: // OUTPUT
            if (i_enable) begin
                // Transition back to IDLE state
                current_state = 0;
                o_status = 0; // 00: IDLE
            end
    endcase

    // Always ensure outputs are valid
    o_ready = 1;
    o_overflow = 0;

endmodule