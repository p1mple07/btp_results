module hamming_code_receiver(
    // Input Ports
    input  [7:0] data_in,
    
    // Output Ports
    output [3:0] data_out
);

   /*
   - Transmitted data includes 4 data bits and 3 parity bits, organized within data_in[7:1].
   - An extra redundant bit at data_in[0] extends the input to 8 bits, separating the 7 bits used in Hamming code error detection (data_in[7:1]) from the redundant bit.
   */
   
   // Define parity bits based on their positions in data_in
   wire [2:0] parity_bits = {data_in[1], data_in[3], data_in[5]};
   
   // Even parity error detection logic
   wire [2:0] error_bits;
   assign error_bits = data_in[7] ^ parity_bits;
   
   // Error indication by error_bits
   wire error_present = |error_bits;
   
   // Corrected data bits after error correction
   wire [3:0] corrected_data_bits;
   assign corrected_data_bits = data_in[7:4];
   
   // Output assignment
   assign data_out = error_present? corrected_data_bits : data_in[3:0];
   
endmodule