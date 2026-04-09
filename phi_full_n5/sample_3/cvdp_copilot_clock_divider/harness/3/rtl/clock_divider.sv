module clock_divider (
    input wire clk,
    input wire rst_n,
    input wire [1:0] sel,
    output reg clk_out
);

    reg [1:0] counter;

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            clk_out <= 0;
            counter <= 0;
        end else begin
            case (sel)
                2'b00: counter <= counter + 1;
                2'b01: counter <= counter + 2;
                2'b10: counter <= counter + 4;
                default: counter <= 0;
            endcase
            if (counter == (sel - 2)) begin
                clk_out <= ~clk_out;
                counter <= 0;
            end
        end
    end

endmodule
