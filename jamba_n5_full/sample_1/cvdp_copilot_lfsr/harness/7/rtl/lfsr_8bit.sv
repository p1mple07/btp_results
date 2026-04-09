module lfsr_8bit(input clock, reset, input [7:0] lfsr_seed, output reg [7:0] lfsr_out);

    reg [7:0] state;
    reg [1:0] feedback;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= lfsr_seed;
        end else begin
            feedback <= {lfsr_out[7], lfsr_out[6], lfsr_out[5], lfsr_out[1], lfsr_out[0]};
            state <= state ^ feedback;
        end
    end

    always_ff @(posedge clock) begin
        if (~reset) lfsr_out <= state;
    end

endmodule
