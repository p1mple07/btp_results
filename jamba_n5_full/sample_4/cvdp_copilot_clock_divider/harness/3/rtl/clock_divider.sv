module clock_divider #(
    parameter WIDTH = 16
) (
    input  logic clk,
    input  logic rst_n,
    input  logic [1:0] sel,
    output logic clk_out
);

    // Reset handler
    always @(posedge clk or posedge rst_n) begin
        if (~rst_n) begin
            clk_out <= 1'b0;
        end else begin
            // Only proceed when rst_n is inactive
            if (sel != 2'b00 && sel != 2'b01 && sel != 2'b10) begin
                clk_out <= 1'b0;
            end else begin
                case (sel)
                    2'b00: clk_out <= clk;
                    2'b01: clk_out <= posedge clk ? ~clk : 1'b0;
                    2'b10: clk_out <= posedge clk ? ~clk : 1'b0;
                    default: clk_out <= 1'b0;
                endcase
            end
        end
    end

endmodule
