module perfect_squares_generator (
    input clock,
    input reset,
    output sqr_o
);
    // State variable to track if reset is active
    reg [31:0] current_num = 0;
    // State variable to track if the module is ready to produce a square
    reg ready = 0;
    
    // Compute the square of current_num
    always_posedge clock begin
        if (reset) begin
            current_num = 1;
            ready = 1;
        end else begin
            current_num = current_num + 1;
            ready = 1;
        end
        // Compute square
        sqr_o = current_num * current_num;
        // Check for overflow
        if (sqr_o > 32'hFFFFFFFF) begin
            sqr_o = 32'hFFFFFFFF;
        end
    end
endmodule