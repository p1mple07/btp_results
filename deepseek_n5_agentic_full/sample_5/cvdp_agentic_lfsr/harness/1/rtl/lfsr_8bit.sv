module lfsr_8bit (
    input wire clk,
    input wire rst,
    input wire [7:0] seed,
    output reg [7:0] lfsr_out
);

    parameter POLY = 8'd10110111; // Changed feedback polynomial

    always @(posedge clk or posedge rst) begin
        if (rst)
            lfsr_out = 8'b00000001;
        else 
            lfsr_out = {lfsr_out[6:0], (lfsr_out[7] ^ lfsr_out[5] ^ lfsr_out[4] ^ lfsr_out[3]) & POLY};
    end
endmodule