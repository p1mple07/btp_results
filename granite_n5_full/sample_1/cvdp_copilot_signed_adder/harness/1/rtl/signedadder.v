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
    
    always @(posedge i_clk or posedge i_rst_n) begin
        if (!i_rst_n) begin
            // Reset logic
            // Set all outputs and registers to their default values
        end else begin
            // State machine logic
            case(o_status)
                2'b00: begin
                    if (i_start && i_enable) begin
                        // Load state logic
                        o_status <= 2'b01;
                    end
                end
                2'b01: begin
                    // Compute state logic
                    // Perform the addition or subtraction operation based on i_mode
                    // Update o_resultant_sum and o_overflow
                    // Set o_ready to 1 once the output values are ready
                    o_status <= 2'b10;
                end
                2'b10: begin
                    // Output state logic
                    o_ready <= 1'b1;
                    o_status <= 2'b11;
                end
                2'b11: begin
                    // Do nothing in this state
                end
                default: begin
                    // Handle invalid state
                    // Set o_ready to 0 in this case
                end
            endcase
        end
    end

endmodule