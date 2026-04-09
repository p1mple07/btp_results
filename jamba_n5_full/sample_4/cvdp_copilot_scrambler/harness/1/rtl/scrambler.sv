// Corrected LFSR initialization and feedback logic
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        lfsr <= {16{1'b0}}; // Reset to zero state
    end else begin
        lfsr <= {
            lfsr[14:0],  // Lower 14 bits
            feedback       // Feedback bit
        };
    end
end
