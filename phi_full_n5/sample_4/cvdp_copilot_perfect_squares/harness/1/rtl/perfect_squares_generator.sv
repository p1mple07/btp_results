module perfect_squares_generator (
    input clk,
    input reset,
    output reg [31:0] sqr_o
);
    reg [3:0] counter = 0;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            sqr_o <= 1; // Output the first square after reset
        end else begin
            if (counter == 3) begin
                counter <= 0;
                sqr_o <= counter * counter;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
