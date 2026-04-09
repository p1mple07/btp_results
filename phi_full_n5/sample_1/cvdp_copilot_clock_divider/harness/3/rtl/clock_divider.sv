module clock_divider (
    input clk,
    input rst_n,
    input [1:0] sel,
    output reg clk_out
);

    reg [1:0] current_sel = 2'b00; // Initially, divide by 2

    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            clk_out <= 0;
            current_sel <= 2'b00; // Reset division factor
        end else begin
            case (current_sel)
                2'b00: clk_out <= ~clk; // Divide by 2
                2'b01: clk_out <= ~clk >> 1; // Divide by 4
                2'b10: clk_out <= ~clk >> 3; // Divide by 8
                default: clk_out <= 0; // Invalid sel value, hold output at 0
            endcase
        end
    end

endmodule
