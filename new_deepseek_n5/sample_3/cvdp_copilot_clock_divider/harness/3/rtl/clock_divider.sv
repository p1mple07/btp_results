module clock_divider(
    input clock,
    input rst_n,
    input [1:0] sel,
    output clock_out
);
    reg clock_out;
    reg [1:0] sel_val = 0;
    reg counter = 0;
    always_comb begin
        if (rst_n) begin
            clock_out = 0;
            sel_val = 0;
        end else begin
            clock_out = 0;
            sel_val = sel;
            counter = 0;
            repeat(2) begin
                aposedge clock;
                counter = counter + 1;
                if (counter == sel_val) begin
                    clock_out = 1;
                    counter = 0;
                end
            end
        end
    end
endmodule