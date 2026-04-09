module clock_divider(
    input logic clk,
    input logic rst_n,
    input logic [1:0] sel,
    output logic clk_out
);

    logic [3:0] div;

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            clk_out <= 1'b0;
        end else begin
            if (sel == 2'b00) begin
                div = clk;
            end else if (sel == 2'b01) begin
                div = 8 * clk;
            end else if (sel == 2'b10) begin
                div = 256 * clk;
            end else begin
                div = 1'b0;
            end
            clk_out = div;
        end
    end

endmodule
