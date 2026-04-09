module lfsr_8bit(input clock, reset, input [7:0] lfsr_seed, output reg [7:0] lfsr_out);
    logic q6, q7, q8;

    // Fibonacci configuration of 8-bit LFSR with primitive polynomial x^8 + x^6 + x^5 + x + 1

    // Feedback logic for Fibonacci configuration
    assign q6 = lfsr_out[7] ^ lfsr_out[6] ^ lfsr_out[5] ^ lfsr_out[1];
    assign q7 = lfsr_out[6];
    assign q8 = lfsr_out[5];

    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
            lfsr_out <= lfsr_seed; // Load the seed if reset is at logic LOW
        else
            lfsr_out <= {lfsr_out[7], q6, q7, q8, lfsr_out[4], lfsr_out[3], lfsr_out[2], lfsr_out[1]}; // Shift register with Fibonacci feedback
    end
endmodule