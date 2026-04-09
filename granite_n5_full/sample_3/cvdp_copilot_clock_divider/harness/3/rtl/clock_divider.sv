module clock_divider(
    input logic clk,
    input logic rst_n,
    input logic [1:0] sel,
    output logic clk_out
);

logic [9:0] counter;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 0;
        clk_out <= 1'b0;
    end else begin
        case (sel)
            2'b00: counter <= counter + 1;
            2'b01: counter <= counter * 2;
            2'b10: counter <= counter * 4;
            default: ; // no action
        endcase

        if (counter == 50) begin
            clk_out <= ~clk_out;
            counter <= 0;
        end
    end
end

endmodule