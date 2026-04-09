module decoder_8b10b (
    input  logic        clk_in,       // trigger on rising edge
    input  logic        reset_in,     // reset_in, assert HI
    input  logic [9:0]  decoder_in,   // 10bit input
    output logic [7:0]  decoder_out,  // 8bit decoded output
    output logic        control_out   // control char, assert HI for control words
);

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
        decoder_out <= 8'b0;
        control_out <= 1'b0;
    end else begin
        // No decoding performed for simplicity. 
        // Replace with actual logic for 8b10b decoding when needed.
    end
end

endmodule
