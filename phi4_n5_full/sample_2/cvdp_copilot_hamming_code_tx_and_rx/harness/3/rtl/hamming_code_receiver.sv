module hamming_code_receiver(
    input  logic [7:0] data_in,
    output logic [3:0] data_out
);

   // Internal signals for syndrome computation and corrected data
   logic c3, c2, c1;
   logic [2:0] syndrome;
   logic [7:0] corrected_data;

   // Combinational logic for syndrome calculation and error correction
   always_comb begin
       // Calculate syndrome bits using even parity checks
       // c3: XOR of bits at positions with LSB = 1 (positions 1, 3, 5, 7)
       c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
       // c2: XOR of bits at positions with second LSB = 1 (positions 2, 3, 6, 7)
       c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
       // c1: XOR of bits at positions with MSB = 1 (positions 4, 5, 6, 7)
       c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
       
       // Combine syndrome bits: {c1, c2, c3}
       syndrome = {c1, c2, c3};

       // Default: assume no error; use original data
       corrected_data = data_in;

       // If syndrome is non-zero, an error is detected in one of the 7 significant bits.
       // Flip the bit at the position indicated by the syndrome value.
       if (syndrome != 3'b000) begin
           corrected_data[syndrome] = ~data_in[syndrome];
       end
       // If syndrome is 3'b000, the error (if any) is in the redundant bit (position 0),
       // which is not used for data extraction.
   end

   // Map the corrected data bits to the output.
   // According to the specification, the data bits are located at positions:
   // 7, 6, 5, and 3 of the corrected input.
   // data_out[3] gets corrected_data[7] (MSB of data bits),
   // data_out[2] gets corrected_data[6],
   // data_out[1] gets corrected_data[5],
   // data_out[0] gets corrected_data[3].
   assign data_out[3] = corrected_data[7];
   assign data_out[2] = corrected_data[6];
   assign data_out[1] = corrected_data[5];
   assign data_out[0] = corrected_data[3];

endmodule