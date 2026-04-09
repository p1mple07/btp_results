module perfect_squares_generator(
    input  logic clk,
    input  logic reset,
    output logic [31:0] sqr_o
);

    // Internal register to hold the base number.
    // On reset, base is set to 0 so that on the next clock edge,
    // (base+1) equals 1, yielding the first perfect square (1).
    logic [31:0] base;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Asynchronous reset: initialize base to 0 and output the first square.
            base   <= 32'd0;
            sqr_o  <= 32'd1;
        end else begin
            // Increment the base counter.
            base <= base + 1;
            
            // Calculate the perfect square using (base+1)^2.
            // Use a 64-bit temporary to catch any overflow.
            logic [63:0] temp;
            temp = ((base + 1) * (base + 1));
            
            // Overflow protection: if the result exceeds 32-bit maximum,
            // saturate the output to 32'hFFFFFFFF.
            if (temp > 32'hFFFFFFFF)
                sqr_o <= 32'hFFFFFFFF;
            else
                sqr_o <= temp[31:0];
        end
    end

endmodule