module clock_divider(
    input clk,
    input rst_n,
    input [1:0] sel,
    output reg clk_out
);

    always_comb begin
        case (sel)
            2'b00: clk_out = ~clk; // Divide by 2
            2'b01: clk_out = ~clk; // Divide by 4
            2'b10: clk_out = ~clk; // Divide by 8
            default: clk_out = 1'b0; // Out-of-range sel, hold clk_out at 0
        endcase
    end

    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            clk_out <= 1'b0;
        end else begin
            case (sel)
                2'b00: clk_out <= ~clk_out;
                2'b01: clk_out <= ~clk_out >> 1;
                2'b10: clk_out <= ~clk_out >> 3;
                default: clk_out <= 1'b0;
            endcase
        end
    end

endmodule
