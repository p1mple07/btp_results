module hamming_code_receiver (
   input [7:0] data_in, // 8-bit input signal containing 4 data bits, 3 parity bits, and 1 redundant bit
   output reg [3:0] data_out // 4-bit output signal containing the corrected data if an error is detected, or the original data if no error is detected
);

// Even parity error detection logic
wire [2:0] c1 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
wire [2:0] c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
wire [2:0] c3 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

// Error indication by {c1, c2, c3}
wire error = (c1!= 3'b000) || (c2!= 3'b000) || (c3!= 3'b000);

// Error detection and correction
assign data_out[0] = data_in[0]; // Copy redundant bit to output
assign data_out[1] = data_in[1] ^ c1; // Copy parity bit 1 to output
assign data_out[2] = data_in[2] ^ c2; // Copy parity bit 2 to output
assign data_out[3] = data_in[3] ^ c3; // Copy parity bit 3 to output

endmodule